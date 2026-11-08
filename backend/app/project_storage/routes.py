"""Small, file-backed project API for self-hosted projects."""

import json
import os
import threading
import uuid
from datetime import datetime, timezone
from pathlib import Path

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field


router = APIRouter()
_lock = threading.RLock()


class ProjectInput(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    project: dict
    revision: int | None = None


def _directory() -> Path:
    root = Path(os.environ.get("DATA_DIR", "data")) / "projects"
    root.mkdir(parents=True, exist_ok=True)
    return root


def _path(project_id: str) -> Path:
    try:
        safe_id = str(uuid.UUID(project_id))
    except ValueError:
        raise HTTPException(404, "Project not found") from None
    return _directory() / f"{safe_id}.json"


def _read(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise HTTPException(404, "Project not found") from None


def _validate(project: dict) -> None:
    if (project.get("format") != "velxio-project" or project.get("version") != 1
            or not isinstance(project.get("boards"), list)
            or not isinstance(project.get("fileGroups"), dict)
            or not isinstance(project.get("components"), list)
            or not isinstance(project.get("wires"), list)):
        raise HTTPException(422, "Invalid Velxio project payload")


def _write(path: Path, record: dict) -> None:
    temp = path.with_name(f".{path.name}.{uuid.uuid4().hex}.tmp")
    try:
        temp.write_text(json.dumps(record, ensure_ascii=False), encoding="utf-8")
        os.replace(temp, path)
    finally:
        temp.unlink(missing_ok=True)


def _summary(record: dict) -> dict:
    return {key: record[key] for key in ("id", "name", "created_at", "updated_at", "revision")}


@router.get("/")
def list_projects() -> list[dict]:
    with _lock:
        records = []
        for path in _directory().glob("*.json"):
            try:
                records.append(_summary(_read(path)))
            except (KeyError, ValueError, json.JSONDecodeError):
                continue
        return sorted(records, key=lambda item: item["updated_at"], reverse=True)


@router.post("/", status_code=201)
def create_project(body: ProjectInput) -> dict:
    _validate(body.project)
    now = datetime.now(timezone.utc).isoformat()
    record = {
        "id": str(uuid.uuid4()), "name": body.name.strip(),
        "created_at": now, "updated_at": now, "revision": 1,
        "project": body.project,
    }
    if not record["name"]:
        raise HTTPException(422, "Project name is required")
    with _lock:
        _write(_path(record["id"]), record)
    return _summary(record)


@router.get("/{project_id}")
def get_project(project_id: str) -> dict:
    with _lock:
        return _read(_path(project_id))


@router.put("/{project_id}")
def update_project(project_id: str, body: ProjectInput) -> dict:
    _validate(body.project)
    with _lock:
        path = _path(project_id)
        record = _read(path)
        if body.revision != record["revision"]:
            raise HTTPException(409, "Project changed elsewhere; reopen it before saving")
        record.update(
            name=body.name.strip(), project=body.project,
            updated_at=datetime.now(timezone.utc).isoformat(),
            revision=record["revision"] + 1,
        )
        if not record["name"]:
            raise HTTPException(422, "Project name is required")
        _write(path, record)
        return _summary(record)

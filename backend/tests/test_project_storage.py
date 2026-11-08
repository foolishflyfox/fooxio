"""Round-trip and overwrite protection for anonymous OSS projects."""

import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.project_storage.routes import router


class ProjectStorageTest(unittest.TestCase):
    def test_project_round_trip_and_revision_conflict(self):
        with tempfile.TemporaryDirectory() as temp_dir, patch.dict(os.environ, {"DATA_DIR": temp_dir}):
            self._check_round_trip(Path(temp_dir))

    def _check_round_trip(self, tmp_path: Path):
        app = FastAPI()
        app.include_router(router, prefix="/api/oss/projects")
        client = TestClient(app)
        payload = {
        "format": "velxio-project", "version": 1,
        "boards": [], "fileGroups": {}, "components": [], "wires": [],
        "activeBoardId": None,
        }

        created = client.post("/api/oss/projects/", json={"name": "Blink", "project": payload})
        assert created.status_code == 201
        summary = created.json()
        project_id = summary["id"]
        assert summary["revision"] == 1
        assert client.get("/api/oss/projects/").json()[0]["name"] == "Blink"
        assert client.get(f"/api/oss/projects/{project_id}").json()["project"] == payload
        assert (tmp_path / "projects" / f"{project_id}.json").is_file()

        changed = {**payload, "wires": [{"id": "wire-1"}]}
        saved = client.put(
            f"/api/oss/projects/{project_id}",
            json={"name": "Blink", "revision": 1, "project": changed},
        )
        assert saved.status_code == 200
        assert saved.json()["revision"] == 2
        stale = client.put(
            f"/api/oss/projects/{project_id}",
            json={"name": "Blink", "revision": 1, "project": payload},
        )
        assert stale.status_code == 409
        assert client.get(f"/api/oss/projects/{project_id}").json()["project"] == changed
        assert client.get("/api/oss/projects/not-an-id").status_code == 404

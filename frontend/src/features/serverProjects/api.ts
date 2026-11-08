import { getApiBase } from '../../lib/apiBase';
import type { VlxPayload } from '../../utils/vlxFile';

export interface ProjectSummary {
  id: string;
  name: string;
  created_at: string;
  updated_at: string;
  revision: number;
}

export interface StoredProject extends ProjectSummary {
  project: VlxPayload;
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${getApiBase()}/oss/projects${path}`, {
    ...init,
    headers: { 'Content-Type': 'application/json', ...init?.headers },
    credentials: 'include',
  });
  if (!response.ok) {
    const body = await response.json().catch(() => null);
    throw new Error(body?.detail ?? `Project request failed (${response.status})`);
  }
  return response.json() as Promise<T>;
}

export const listProjects = (): Promise<ProjectSummary[]> => request('/');
export const getProject = (id: string): Promise<StoredProject> => request(`/${encodeURIComponent(id)}`);
export const createProject = (name: string, project: VlxPayload): Promise<ProjectSummary> =>
  request('/', { method: 'POST', body: JSON.stringify({ name, project }) });
export const updateProject = (active: ProjectSummary | { id: string; name: string; revision: number }, project: VlxPayload): Promise<ProjectSummary> =>
  request(`/${encodeURIComponent(active.id)}`, {
    method: 'PUT',
    body: JSON.stringify({ name: active.name, revision: active.revision, project }),
  });

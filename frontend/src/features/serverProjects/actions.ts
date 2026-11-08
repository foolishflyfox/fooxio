import { buildVlxPayload } from '../../utils/vlxFile';
import { flushChipFileSync } from '../../services/chipFiles';
import { useSimulatorStore } from '../../store/useSimulatorStore';
import { useProjectStore } from '../../store/useProjectStore';
import type { BoardInstance } from '../../types/board';
import { createProject, getProject, updateProject } from './api';
import { useServerProjectState } from './state';
import { i18n } from '../../i18n';

export function requestServerSave(): void {
  const state = useServerProjectState.getState();
  if (state.busy) return;
  if (!state.active) {
    state.setDialog('save');
    return;
  }
  void saveServerProject().catch((error: unknown) => {
    useServerProjectState.getState().setNotice(
      error instanceof Error ? error.message : 'Could not save project', true,
    );
  });
}

export function openServerProjects(): void {
  useServerProjectState.getState().setDialog('open');
}

export async function saveServerProject(name?: string): Promise<void> {
  const state = useServerProjectState.getState();
  if (state.busy) return;
  const active = state.active;
  const generation = state.generation;
  const projectName = (active?.name ?? name ?? '').trim();
  if (!projectName) throw new Error('Project name is required');
  state.setBusy(true);
  try {
    flushChipFileSync();
    const payload = buildVlxPayload({ name: projectName });
    const result = active
      ? await updateProject(active, payload)
      : await createProject(projectName, payload);
    // A slow response for an earlier workspace must never attach to the next one.
    if (useServerProjectState.getState().generation === generation &&
        useServerProjectState.getState().active === active) {
      useServerProjectState.getState().setActive(result);
      useServerProjectState.getState().setDialog(null);
      useServerProjectState.getState().setNotice(i18n.t('editor.serverProjects.saved', 'Project saved'));
    }
  } finally {
    useServerProjectState.getState().setBusy(false);
  }
}

export async function loadServerProject(id: string): Promise<void> {
  const record = await getProject(id);
  const payload = record.project;
  if (payload.format !== 'velxio-project' || payload.version !== 1) {
    throw new Error('Unsupported project format');
  }
  useProjectStore.getState().clearCurrentProject();
  useSimulatorStore.getState().loadProjectState({
    boards: payload.boards as unknown as BoardInstance[],
    fileGroups: payload.fileGroups,
    folderGroups: payload.folderGroups,
    components: payload.components,
    wires: payload.wires,
    activeBoardId: payload.activeBoardId,
  });
  const state = useServerProjectState.getState();
  state.setActive(record);
  state.setDialog(null);
}

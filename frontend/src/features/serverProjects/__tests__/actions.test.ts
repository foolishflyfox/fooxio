import { beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('../../../utils/vlxFile', () => ({
  buildVlxPayload: vi.fn(() => ({ format: 'velxio-project', version: 1, boards: [], fileGroups: {}, components: [], wires: [], activeBoardId: null })),
}));
vi.mock('../../../services/chipFiles', () => ({ flushChipFileSync: vi.fn() }));
vi.mock('../../../store/useSimulatorStore', () => ({ useSimulatorStore: { getState: vi.fn() } }));
vi.mock('../../../store/useProjectStore', () => ({ useProjectStore: { getState: vi.fn() } }));
vi.mock('../api', () => ({
  createProject: vi.fn(async () => ({ id: 'one', name: 'Blink', revision: 1 })),
  updateProject: vi.fn(async () => ({ id: 'one', name: 'Blink', revision: 2 })),
  getProject: vi.fn(),
}));

import { createProject, updateProject } from '../api';
import { requestServerSave, saveServerProject } from '../actions';
import { clearServerProject, useServerProjectState } from '../state';

describe('anonymous project save', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useServerProjectState.setState({ active: null, generation: 0, dialog: null, busy: false, notice: null });
  });

  it('asks for a name once, then updates the same project without reopening the dialog', async () => {
    requestServerSave();
    expect(useServerProjectState.getState().dialog).toBe('save');
    await saveServerProject('Blink');
    expect(createProject).toHaveBeenCalledOnce();
    expect(useServerProjectState.getState().active?.id).toBe('one');
    expect(useServerProjectState.getState().dialog).toBeNull();

    requestServerSave();
    await vi.waitFor(() => expect(updateProject).toHaveBeenCalledOnce());
    expect(useServerProjectState.getState().active?.revision).toBe(2);
    expect(useServerProjectState.getState().dialog).toBeNull();
  });

  it('does not attach a slow save response after switching workspaces', async () => {
    let resolveCreate!: (value: { id: string; name: string; revision: number }) => void;
    vi.mocked(createProject).mockImplementationOnce(() => new Promise((resolve) => { resolveCreate = resolve; }));
    const save = saveServerProject('Blink');
    clearServerProject();
    resolveCreate({ id: 'old', name: 'Blink', revision: 1 });
    await save;
    expect(useServerProjectState.getState().active).toBeNull();
    expect(useServerProjectState.getState().notice).toBeNull();
  });
});

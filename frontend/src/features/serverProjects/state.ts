import { create } from 'zustand';

export interface ActiveServerProject {
  id: string;
  name: string;
  revision: number;
}

interface ServerProjectState {
  active: ActiveServerProject | null;
  generation: number;
  dialog: 'save' | 'open' | null;
  busy: boolean;
  notice: { message: string; error: boolean } | null;
  setActive: (active: ActiveServerProject | null) => void;
  clearActive: () => void;
  setDialog: (dialog: ServerProjectState['dialog']) => void;
  setBusy: (busy: boolean) => void;
  setNotice: (message: string | null, error?: boolean) => void;
}

export const useServerProjectState = create<ServerProjectState>((set) => ({
  active: null,
  generation: 0,
  dialog: null,
  busy: false,
  notice: null,
  setActive: (active) => set({ active }),
  clearActive: () => set((state) => ({ active: null, generation: state.generation + 1 })),
  setDialog: (dialog) => set({ dialog }),
  setBusy: (busy) => set({ busy }),
  setNotice: (message, error = false) => set({ notice: message ? { message, error } : null }),
}));

export function clearServerProject(): void {
  useServerProjectState.getState().clearActive();
}

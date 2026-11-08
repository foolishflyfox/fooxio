/**
 * Pro save-action registry.
 *
 * EditorPage used to import useAuthStore + SaveProjectModal + LoginPromptModal
 * directly, branching on `user` to decide which modal to open when the
 * user pressed Save. After Phase 3 of the OSS split, all of those live
 * in the pro overlay. The OSS editor exposes a stable `triggerSaveAction()`
 * that:
 *
 *   - In the OSS browser build → saves projects to the self-hosted API.
 *   - In the desktop build → downloads a portable `.vlx` snapshot.
 *   - With the pro overlay loaded → installSaveActionImpl() overrides
 *     the default. The overlay's impl inspects the auth store and opens
 *     SaveProjectModal (logged in) or LoginPromptModal (anonymous).
 *
 * Impl receives no arguments and returns nothing. State lives in the
 * caller's React tree (modal open/close, project data) — this registry
 * is just the doorbell.
 */

import { triggerDownloadVlx } from '../utils/vlxFile';
import { useProjectStore } from '../store/useProjectStore';
import { requestServerSave } from '../features/serverProjects/actions';

let _impl: (() => void) | null = null;

export function installSaveActionImpl(impl: (() => void) | null): void {
  _impl = impl;
}

function defaultSaveAction(): void {
  if (!import.meta.env.VITE_PRO_BUILD && !import.meta.env.VITE_DESKTOP) {
    requestServerSave();
    return;
  }
  // Desktop and Pro fallback: download a portable `.vlx` snapshot.
  // Use the loaded project's name if there is one (slug/identity tracking
  // doesn't require auth — useProjectStore stays in OSS).
  const proj = useProjectStore.getState().currentProject;
  const name = proj?.slug ?? proj?.id ?? undefined;
  const filename = triggerDownloadVlx({ name });
  // eslint-disable-next-line no-console
  console.info(`[oss] downloaded workspace as ${filename}`);
}

export function triggerSaveAction(): void {
  const impl = _impl ?? defaultSaveAction;
  try {
    impl();
  } catch (err) {
    // eslint-disable-next-line no-console
    console.warn('[oss] save-action impl threw:', err);
  }
}

/** Whether a custom (overlay) implementation has been installed. */
export function hasSaveActionImpl(): boolean {
  return _impl !== null;
}

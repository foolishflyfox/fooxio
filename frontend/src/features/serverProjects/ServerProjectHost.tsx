import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { useTranslation } from 'react-i18next';
import { showConfirmDialog } from '../../store/useMessageDialogStore';
import { listProjects, type ProjectSummary } from './api';
import { loadServerProject, saveServerProject } from './actions';
import { useServerProjectState } from './state';
import './serverProjects.css';

const enabled = !import.meta.env.VITE_PRO_BUILD && !import.meta.env.VITE_DESKTOP;

export function ServerProjectHost() {
  const { t } = useTranslation();
  const { dialog, busy, notice, setDialog, setNotice } = useServerProjectState();
  const [name, setName] = useState('');
  const [projects, setProjects] = useState<ProjectSummary[]>([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(() => setNotice(null), notice.error ? 6000 : 2500);
    return () => window.clearTimeout(timer);
  }, [notice, setNotice]);

  useEffect(() => {
    if (dialog !== 'open') return;
    let cancelled = false;
    setError('');
    setLoading(true);
    listProjects()
      .then((items) => { if (!cancelled) setProjects(items); })
      .catch((cause: unknown) => {
        if (!cancelled) setError(cause instanceof Error ? cause.message : String(cause));
      })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [dialog]);

  useEffect(() => {
    if (dialog === 'save') {
      setName('');
      setError('');
    }
  }, [dialog]);

  useEffect(() => {
    if (!dialog) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && !useServerProjectState.getState().busy) setDialog(null);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [dialog, setDialog]);

  if (!enabled) return null;

  const save = async () => {
    if (!name.trim()) {
      setError(t('editor.saveProject.errors.nameRequired'));
      return;
    }
    setError('');
    try {
      await saveServerProject(name);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : String(cause));
    }
  };

  const open = async (project: ProjectSummary) => {
    const confirmed = await showConfirmDialog(
      t('editor.serverProjects.confirmOpen', 'Open this project? Unsaved changes will be lost.'),
      { confirmLabel: t('editor.serverProjects.open', 'Open') },
    );
    if (!confirmed) return;
    setError('');
    try {
      await loadServerProject(project.id);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : String(cause));
    }
  };

  return createPortal(
    <>
      {notice && (
        <div className={`server-project-notice${notice.error ? ' is-error' : ''}`} role="status">
          {notice.message}
        </div>
      )}
      {dialog && (
        <div className="server-project-backdrop" onMouseDown={() => { if (!busy) setDialog(null); }}>
          <section className="server-project-dialog" role="dialog" aria-modal="true"
            aria-label={dialog === 'save' ? t('editor.saveProject.titleSave') : t('editor.serverProjects.title', 'Saved projects')}
            onMouseDown={(event) => event.stopPropagation()}>
            <header>
              <h2>{dialog === 'save' ? t('editor.saveProject.titleSave') : t('editor.serverProjects.title', 'Saved projects')}</h2>
              <button type="button" onClick={() => setDialog(null)} disabled={busy} aria-label={t('editor.saveProject.cancel')}>×</button>
            </header>
            {dialog === 'save' ? (
              <form onSubmit={(event) => { event.preventDefault(); void save(); }}>
                <label htmlFor="server-project-name">{t('editor.saveProject.nameLabel')}</label>
                <input id="server-project-name" autoFocus value={name} maxLength={100}
                  placeholder={t('editor.saveProject.namePlaceholder')}
                  onChange={(event) => setName(event.target.value)} />
                {error && <p className="server-project-error" role="alert">{error}</p>}
                <footer>
                  <button type="button" onClick={() => setDialog(null)} disabled={busy}>{t('editor.saveProject.cancel')}</button>
                  <button type="submit" disabled={busy}>{busy ? t('editor.saveProject.saving') : t('editor.saveProject.save')}</button>
                </footer>
              </form>
            ) : (
              <div>
                <button type="button" onClick={() => {
                  setDialog(null);
                  window.dispatchEvent(new Event('velxio-open-local-project'));
                }}>{t('editor.serverProjects.openLocal', 'Open local .vlx or .zip…')}</button>
                {error && <p className="server-project-error" role="alert">{error}</p>}
                {loading && <p>{t('editor.serverProjects.loading', 'Loading projects…')}</p>}
                {!loading && projects.length === 0 && !error && <p>{t('editor.serverProjects.empty', 'No saved projects yet.')}</p>}
                <ul className="server-project-list">
                  {projects.map((project) => (
                    <li key={project.id}>
                      <button type="button" onClick={() => void open(project)}>
                        <strong>{project.name}</strong>
                        <small>{new Date(project.updated_at).toLocaleString()}</small>
                      </button>
                    </li>
                  ))}
                </ul>
                <footer><button type="button" onClick={() => setDialog(null)}>{t('editor.saveProject.cancel')}</button></footer>
              </div>
            )}
          </section>
        </div>
      )}
    </>,
    document.body,
  );
}

#!/usr/bin/env bash
# 从任意目录运行：bash /path/to/fooxio/foo-scripts/start-backend.sh
# 自动准备环境，然后在当前终端启动后端；按 Ctrl+C 停止。

_fooxio_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P) || exit 1

# setup-env.sh 必须用 source 加载，使 Python 虚拟环境在本进程中生效。
if ! source "$_fooxio_root/foo-scripts/setup-env.sh"; then
  printf '环境准备失败，请检查上方输出。\n' >&2
  exit 1
fi

cd "$_fooxio_root/backend" || exit 1
printf '启动后端：http://127.0.0.1:8001（按 Ctrl+C 停止）\n'
exec python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8001

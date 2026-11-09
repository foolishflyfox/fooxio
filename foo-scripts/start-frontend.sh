#!/usr/bin/env bash
# 从任意目录运行：bash /path/to/fooxio/foo-scripts/start-frontend.sh
# 自动准备环境，然后在当前终端启动前端；按 Ctrl+C 停止。

_fooxio_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P) || exit 1

# setup-env.sh 必须用 source 加载，使 Node.js 22 和 npm 11 在本进程中生效。
if ! source "$_fooxio_root/foo-scripts/setup-env.sh"; then
  printf '环境准备失败，请检查上方输出。\n' >&2
  exit 1
fi

cd "$_fooxio_root/frontend" || exit 1
printf '启动前端：以 Vite 输出的地址为准，通常是 http://localhost:5173（按 Ctrl+C 停止）\n'
exec npm run dev

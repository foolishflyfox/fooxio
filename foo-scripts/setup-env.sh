#!/usr/bin/env bash
# 在 Bash 或 Zsh 中使用 source foo-scripts/setup-env.sh 加载本脚本。
# 使用 source 时，首行 shebang 仅作为注释；当前终端会保留 Node 22 和 backend/.venv 环境。

if [ -n "${BASH_VERSION:-}" ]; then # Bash 会设置 BASH_VERSION；非空说明当前是 Bash 在读取本脚本。
  if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    printf '请使用 source foo-scripts/setup-env.sh，以便环境在当前终端生效。\n' >&2
    exit 1
  fi
  _script_path=${BASH_SOURCE[0]}
elif [ -n "${ZSH_VERSION:-}" ]; then # Zsh 会设置 ZSH_VERSION；非空说明当前是 Zsh 在读取本脚本。
  if [[ ${ZSH_EVAL_CONTEXT:-} != *:file ]]; then
    printf '请使用 source foo-scripts/setup-env.sh，以便环境在当前终端生效。\n' >&2
    exit 1
  fi
  _script_path=${(%):-%x}
else
  printf '此脚本仅支持 Bash 和 Zsh。\n' >&2
  return 1 2>/dev/null || exit 1
fi

# 从脚本所在的 foo-scripts/ 向上一级定位项目根目录；命令替换不会改变当前终端的目录。
_fooxio_repo_root=$(cd "$(dirname "$_script_path")/.." && pwd -P) || return 1
unset _script_path

_fooxio_setup_env() {
  local os npm_major uv_bin
  local manifest checksum marker install_dir
  # 用于保存下载 nvm 或 uv 安装脚本时使用的临时文件路径。
  local installer
  # 用于确定 nvm 的安装目录，随后赋给环境变量 NVM_DIR。
  local nvm_dir
  # 获取操作系统名称
  os=$(uname -s) || return 1
  # 后端 Python 虚拟环境的目录。
  local python_env="$_fooxio_repo_root/backend/.venv"
  # 后端 Python 依赖清单的路径。
  local requirements="$_fooxio_repo_root/backend/requirements.txt"

  case "$os" in
    Darwin|Linux) ;;
    *) printf '暂不支持 %s；当前仅支持 macOS 和 Linux。\n' "$os" >&2; return 1 ;;
  esac

  # 当前 Shell 找不到 nvm 时，先查找已安装的 nvm.sh；只有找不到文件才安装。
  if ! command -v nvm >/dev/null 2>&1; then
    if [ -n "${NVM_DIR:-}" ]; then
      nvm_dir=$NVM_DIR
    elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
      nvm_dir=$XDG_CONFIG_HOME/nvm
    else
      nvm_dir=$HOME/.nvm
    fi
    export NVM_DIR=$nvm_dir
    # nvm.sh 不存在或文件为空时，才需要下载并安装 nvm。
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
      printf '安装 nvm...\n'
      # $(mktemp) 执行命令并返回新建的临时文件路径，再赋值给 installer。
      installer=$(mktemp) || return 1
      if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh -o "$installer" || {
          rm -f "$installer"
          printf '下载 nvm 安装脚本失败；请检查网络或手动安装 nvm。\n' >&2
          return 1
        }
      elif command -v wget >/dev/null 2>&1; then
        wget -qO "$installer" https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh || {
          rm -f "$installer"
          printf '下载 nvm 安装脚本失败；请检查网络或手动安装 nvm。\n' >&2
          return 1
        }
      else
        rm -f "$installer"
        printf '安装 nvm 需要 curl 或 wget。\n' >&2
        return 1
      fi
      bash "$installer"
      local install_status=$?
      rm -f "$installer"
      if [ "$install_status" -ne 0 ]; then
        printf 'nvm 安装失败，请检查上方输出。\n' >&2
        return 1
      fi
    fi
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
      printf '未找到 %s/nvm.sh，请检查 nvm 安装位置。\n' "$NVM_DIR" >&2
      return 1
    fi
    # nvm 是 Shell 函数；在此加载后，当前终端无需重启即可使用刚安装的 nvm。
    . "$NVM_DIR/nvm.sh" || return 1
  fi
  if ! command -v nvm >/dev/null 2>&1; then
    printf 'nvm 加载失败。\n' >&2
    return 1
  fi

  if [ "$(nvm version 22 2>/dev/null)" = 'N/A' ]; then
    printf '安装 Node.js 22...\n'
    nvm install 22 || return 1
  fi
  nvm use 22 || return 1
  # Vite 7 要求 Node.js 22.12.0 或更新版本；旧版 22.x 需升级。
  if ! node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major === 22 && minor >= 12 ? 0 : 1)'; then
    printf '升级 Node.js 22 至 22.12.0 或更新版本...\n'
    nvm install 22 || return 1
    nvm use 22 || return 1
  fi
  if ! node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major === 22 && minor >= 12 ? 0 : 1)'; then
    printf '预期 Node.js 22.12.0 或更新版本，实际为 %s。\n' "$(node --version)" >&2
    return 1
  fi
  # 获取 npm 的主版本号
  npm_major=$(npm --version 2>/dev/null) || return 1
  # %% 是最长匹配后缀删除：从第一个点起去掉版本后缀，只留下主版本号。
  npm_major=${npm_major%%.*}
  if [ "$npm_major" != 11 ]; then
    printf '安装 npm 11...\n'
    npm install -g npm@11 || return 1
  fi
  npm_major=$(npm --version 2>/dev/null) || return 1
  # 安装后再次截取主版本号，确认实际使用的是 npm 11。
  if [ "${npm_major%%.*}" != 11 ]; then
    printf 'npm 版本检查失败：预期 11，实际为 %s。\n' "$npm_major" >&2
    return 1
  fi

  # uv 是 Python 包管理工具，用于创建虚拟环境和安装后端依赖。
  if ! command -v uv >/dev/null 2>&1; then
    printf '安装 uv...\n'
    if [ "$os" = Darwin ] && command -v brew >/dev/null 2>&1; then
      brew install uv || return 1
    else
      # $(mktemp) 执行命令并返回新建的临时文件路径，再赋值给 installer。
      installer=$(mktemp) || return 1
      if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://astral.sh/uv/install.sh -o "$installer" || {
          rm -f "$installer"
          printf '下载 uv 安装脚本失败。\n' >&2
          return 1
        }
      elif command -v wget >/dev/null 2>&1; then
        wget -qO "$installer" https://astral.sh/uv/install.sh || {
          rm -f "$installer"
          printf '下载 uv 安装脚本失败。\n' >&2
          return 1
        }
      else
        rm -f "$installer"
        printf '安装 uv 需要 curl 或 wget。\n' >&2
        return 1
      fi
      sh "$installer"
      local install_status=$?
      rm -f "$installer"
      if [ "$install_status" -ne 0 ]; then
        printf 'uv 安装失败，请检查上方输出。\n' >&2
        return 1
      fi
      # 独立安装器可能只为新终端配置 PATH，因此这里也为当前终端加入 uv 路径。
      if [ -x "$HOME/.local/bin/uv" ]; then
        export PATH="$HOME/.local/bin:$PATH"
      fi
    fi
  fi
  # 获取 uv 可执行文件的路径
  uv_bin=$(command -v uv 2>/dev/null) || {
    printf 'uv 安装后仍不在 PATH 中；请检查安装器输出。\n' >&2
    return 1
  }

  if [ ! -d "$python_env" ]; then
    printf '创建 Python 3.12 虚拟环境...\n'
    "$uv_bin" venv --managed-python --python 3.12 "$python_env" || return 1
  fi
  if [ ! -x "$python_env/bin/python" ]; then
    printf '%s 存在，但不是可用的虚拟环境；请人工检查。\n' "$python_env" >&2
    return 1
  fi
  if ! "$python_env/bin/python" -c 'import sys; sys.exit(sys.version_info[:2] != (3, 12))'; then
    printf '%s 的 Python 不是 3.12；请人工处理现有环境后重试。\n' "$python_env" >&2
    return 1
  fi

  checksum=$(cksum < "$requirements") || return 1
  marker="$python_env/.fooxio-requirements.cksum"
  if [ ! -f "$marker" ] || [ "$(cat "$marker")" != "$checksum" ]; then
    printf '安装后端 Python 依赖...\n'
    "$uv_bin" pip install --python "$python_env/bin/python" -r "$requirements" || return 1
    printf '%s\n' "$checksum" > "$marker" || return 1
  fi

  for install_dir in "$_fooxio_repo_root" "$_fooxio_repo_root/frontend"; do
    manifest="$install_dir/package.json"
    marker="$install_dir/node_modules/.fooxio-package.cksum"
    checksum=$(cksum < "$manifest") || return 1
    if [ ! -d "$install_dir/node_modules" ] || [ ! -f "$marker" ] || [ "$(cat "$marker")" != "$checksum" ]; then
      printf '安装 %s 的 npm 依赖...\n' "$install_dir"
      (cd "$install_dir" && npm install --no-audit --no-fund --include=optional) || return 1
      printf '%s\n' "$checksum" > "$marker" || return 1
    fi
  done

  . "$python_env/bin/activate" || return 1
  if ! python -c 'import sys; sys.exit(sys.version_info[:2] != (3, 12))'; then
    printf '虚拟环境激活后，python 不是 3.12。\n' >&2
    return 1
  fi
  printf '环境已就绪：Node %s、npm %s、Python %s。\n' \
    "$(node --version)" "$(npm --version)" "$(python --version 2>&1)"
}

if _fooxio_setup_env; then
  _fooxio_status=0
else
  _fooxio_status=1
fi
unset -f _fooxio_setup_env
unset _fooxio_repo_root
if [ "$_fooxio_status" -eq 0 ]; then
  unset _fooxio_status
  return 0
fi
unset _fooxio_status
return 1

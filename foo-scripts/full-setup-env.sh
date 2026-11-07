#!/usr/bin/env bash
# 交互安装源码运行指南第 3、4 节中可直接获取的本机工具链。
# 用法：bash foo-scripts/full-setup-env.sh [-y|--yes]

usage() {
  printf '用法：bash foo-scripts/full-setup-env.sh [-y|--yes]\n'
  printf '  -y, --yes   自动确认安装所有缺少的软件\n'
  printf '  -h, --help  显示帮助\n'
}

yes_to_all=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    -y|--yes) yes_to_all=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ ! -t 0 ]; then
  printf '请在交互终端运行此脚本。\n' >&2
  exit 1
fi

_fooxio_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P) || exit 1
if ! source "$_fooxio_root/foo-scripts/setup-env.sh"; then
  printf '基础环境准备失败。\n' >&2
  exit 1
fi

toolchain_dir="$_fooxio_root/backend/.venv/toolchains"
os=$(uname -s) || exit 1
arch=$(uname -m) || exit 1
failures=0

ask_install() {
  local answer
  if [ "$yes_to_all" -eq 1 ]; then
    return 0
  fi
  while true; do
    printf '%s [Y/n] ' "$1" >&2 || return 1
    IFS= read -r answer || return 1
    case "$answer" in
      ''|y|Y|yes|YES) return 0 ;;
      n|N|no|NO) return 1 ;;
      *) printf '请输入 y 或 n。\n' ;;
    esac
  done
}

report_failure() {
  printf '安装失败：%s。可稍后重新运行此脚本。\n' "$1" >&2
  failures=$((failures + 1))
}

arduino_cli_compatible() {
  local version
  version=$(arduino-cli version 2>/dev/null) || return 1
  [[ "$version" =~ [Vv]ersion:[[:space:]]*1\. ]]
}

install_arduino_cli() {
  local installer
  installer=$(mktemp) || return 1
  if ! curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh -o "$installer"; then
    rm -f "$installer"
    return 1
  fi
  # 安装在虚拟环境的 bin/ 中，后端启动脚本加载 setup-env.sh 后即可找到。
  if ! BINDIR="$_fooxio_root/backend/.venv/bin" sh "$installer" 1.5.0; then
    rm -f "$installer"
    return 1
  fi
  rm -f "$installer"
  [ -x "$_fooxio_root/backend/.venv/bin/arduino-cli" ] && arduino_cli_compatible
}

core_installed() {
  local id="$1" version="$2"
  arduino-cli core list 2>/dev/null | awk -v id="$id" -v version="$version" \
    '$1 == id && (version == "" || $2 == version) { found = 1 } END { exit !found }'
}

add_board_index() {
  local url="$1"
  if arduino-cli config get board_manager.additional_urls 2>/dev/null | grep -Fq "$url"; then
    return 0
  fi
  if ! arduino-cli config add board_manager.additional_urls "$url"; then
    # 首次使用 Arduino CLI 时可能尚无配置文件。
    arduino-cli config init >/dev/null 2>&1 || true
    arduino-cli config add board_manager.additional_urls "$url"
  fi
}

install_core() {
  local id="$1" index_url="$2" data_dir
  if [ "$id" = 'ATTinyCore:avr@1.4.1' ]; then
    # 第三方索引站点可能不可用；先放入仓库附带的索引快照。
    data_dir=$(arduino-cli config get directories.data 2>/dev/null) || data_dir=''
    [ -n "$data_dir" ] && [ "$data_dir" != 'null' ] || data_dir="$HOME/.arduino15"
    mkdir -p "$data_dir" || return 1
    if [ ! -f "$data_dir/package_drazzy.com_index.json" ]; then
      cp "$_fooxio_root/backend/board-indexes/package_drazzy.com_index.json" "$data_dir/" || return 1
    fi
  fi
  if [ -n "$index_url" ]; then
    add_board_index "$index_url" || return 1
  fi
  if ! arduino-cli core update-index; then
    printf '部分板卡索引更新失败，尝试使用已有索引继续安装。\n' >&2
  fi
  arduino-cli core install "$id"
}

offer_core() {
  local id="$1" version="$2" description="$3" index_url="$4"
  if core_installed "$id" "$version"; then
    printf '已安装：%s\n' "$description"
  elif ask_install "未安装 ${description}，是否安装？"; then
    if ! install_core "${id}${version:+@$version}" "$index_url" || ! core_installed "$id" "$version"; then
      report_failure "$description"
    fi
  fi
}

install_wasi_sdk() {
  local platform archive url temp_dir extracted sha
  case "$os:$arch" in
    Darwin:arm64) platform=arm64-macos; sha=9c59398106b417f8f14913380fdf0097a8cc0ff4af9eb3ce0065a859e88d49e9 ;;
    Darwin:x86_64) platform=x86_64-macos; sha=87d27fa8adc68dee59bfbf2e22a6d34ef717c34d6bf1d8af2a56fc929d9ce0eb ;;
    Linux:aarch64|Linux:arm64) platform=arm64-linux; sha=f7e243dff54d60bcc576e94d6166b69f410f2500ae4a9ceef34315be10e77971 ;;
    Linux:x86_64) platform=x86_64-linux; sha=b761e3a0721dbae9c09a0059e5fdb2bf917d1b4a8a7b430fb3b5aafb0984b2c4 ;;
    *) printf 'WASI-SDK 暂无此平台的安装包：%s/%s\n' "$os" "$arch" >&2; return 1 ;;
  esac
  archive="wasi-sdk-34.0-$platform.tar.gz"
  url="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-34/$archive"
  temp_dir=$(mktemp -d) || return 1
  if ! curl -fL "$url" -o "$temp_dir/$archive"; then
    rm -rf "$temp_dir"
    return 1
  fi
  if command -v shasum >/dev/null 2>&1; then
    [ "$(shasum -a 256 "$temp_dir/$archive" | awk '{print $1}')" = "$sha" ] || { rm -rf "$temp_dir"; return 1; }
  else
    [ "$(sha256sum "$temp_dir/$archive" | awk '{print $1}')" = "$sha" ] || { rm -rf "$temp_dir"; return 1; }
  fi
  if ! tar -xzf "$temp_dir/$archive" -C "$temp_dir"; then
    rm -rf "$temp_dir"
    return 1
  fi
  extracted="$temp_dir/wasi-sdk-34.0-$platform"
  if [ ! -x "$extracted/bin/clang" ] || [ -e "$toolchain_dir/wasi-sdk" ]; then
    rm -rf "$temp_dir"
    return 1
  fi
  mkdir -p "$toolchain_dir" || { rm -rf "$temp_dir"; return 1; }
  mv "$extracted" "$toolchain_dir/wasi-sdk" || { rm -rf "$temp_dir"; return 1; }
  rm -rf "$temp_dir"
}

install_esp_idf() {
  local idf="$toolchain_dir/esp-idf-v5" arduino="$toolchain_dir/arduino-esp32-3" base_python
  if [ "$os" = Darwin ]; then
    command -v brew >/dev/null 2>&1 || { printf 'macOS 安装 ESP-IDF 需要 Homebrew。\n' >&2; return 1; }
    brew install cmake ninja dfu-util || return 1
  elif command -v apt-get >/dev/null 2>&1; then
    if [ "$(id -u)" -eq 0 ]; then
      apt-get update && apt-get install -y git wget flex bison gperf python3 python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 || return 1
    else
      sudo apt-get update && sudo apt-get install -y git wget flex bison gperf python3 python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 || return 1
    fi
  else
    printf '此 Linux 发行版需要先按 Espressif 文档安装 ESP-IDF 系统依赖。\n' >&2
    return 1
  fi
  mkdir -p "$toolchain_dir" || return 1
  if [ ! -f "$idf/export.sh" ]; then
    if [ ! -d "$idf/.git" ]; then
      [ ! -e "$idf" ] || { printf '%s 已存在但不完整，请检查。\n' "$idf" >&2; return 1; }
      git clone -b v5.5.4 --recursive --depth=1 --shallow-submodules \
        https://github.com/espressif/esp-idf.git "$idf" || return 1
    fi
  fi
  git -C "$idf" submodule update --init --recursive --depth=1 || return 1
  # ESP-IDF 会创建自己的 Python 环境，不能让安装器使用项目虚拟环境中的 Python。
  base_python=$(python -c 'import sys; print(sys._base_executable)') || return 1
  [ -x "$base_python" ] || return 1
  (
    unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT
    export PATH="${base_python%/*}:$PATH"
    cd "$idf" && ./install.sh esp32,esp32s3,esp32c3,esp32c6
  ) || return 1
  if [ ! -f "$arduino/CMakeLists.txt" ]; then
    if [ ! -d "$arduino/.git" ]; then
      [ ! -e "$arduino" ] || { printf '%s 已存在但不完整，请检查。\n' "$arduino" >&2; return 1; }
      git clone --branch 3.3.10 --depth=1 --recursive --shallow-submodules \
        https://github.com/espressif/arduino-esp32.git "$arduino" || return 1
    fi
  fi
  git -C "$arduino" submodule update --init --recursive --depth=1 || return 1
  touch "$toolchain_dir/.fooxio-esp-idf-ready"
}

install_sdcc() {
  if [ "$os" = Darwin ] && command -v brew >/dev/null 2>&1; then
    brew install sdcc
  elif command -v apt-get >/dev/null 2>&1; then
    if [ "$(id -u)" -eq 0 ]; then
      apt-get update && apt-get install -y sdcc
    else
      sudo apt-get update && sudo apt-get install -y sdcc
    fi
  else
    printf '未找到受支持的 SDCC 包管理器；请参照发行版文档安装。\n' >&2
    return 1
  fi
}

qemu_installed() {
  local dir
  for dir in "$toolchain_dir/qemu" "${VELXIO_QEMU_PATH:-}" "$_fooxio_root/backend/app/services"; do
    [ -n "$dir" ] && [ -f "$dir/libqemu-xtensa.$qemu_ext" ] &&
      [ -f "$dir/libqemu-riscv32.$qemu_ext" ] &&
      [ -s "$dir/esp32-v3-rom.bin" ] && [ -s "$dir/esp32-v3-rom-app.bin" ] &&
      [ -s "$dir/esp32c3-rom.bin" ] && [ -s "$dir/esp32s3_rev0_rom.bin" ] && return 0
  done
  return 1
}

install_qemu() {
  local asset_arch key temp_dir base file magic asset
  case "$os:$arch" in
    Darwin:arm64) asset_arch=macos-arm64 ;;
    Linux:x86_64) asset_arch=amd64 ;;
    Linux:aarch64|Linux:arm64) asset_arch=arm64 ;;
    *) printf '此平台尚无匹配的 Velxio QEMU 动态库：%s/%s。\n' "$os" "$arch" >&2; return 1 ;;
  esac
  key=${VELXIO_LICENSE_KEY:-}
  if [ -z "$key" ]; then
    printf '可在 https://velxio.dev/license/signup 申请个人密钥。\n'
    read -r -s -p '输入 Velxio 密钥（输入不显示）：' key || return 1
    printf '\n'
  fi
  [ -n "$key" ] || { printf '没有密钥，无法从下载接口获取 QEMU 文件。\n' >&2; return 1; }
  mkdir -p "$toolchain_dir" || return 1
  [ ! -e "$toolchain_dir/qemu" ] || { printf 'QEMU 目标目录已存在但文件不完整：%s\n' "$toolchain_dir/qemu" >&2; return 1; }
  temp_dir=$(mktemp -d "$toolchain_dir/qemu.partial.XXXXXX") || return 1
  for base in libqemu-xtensa libqemu-riscv32; do
    asset="$base-$asset_arch"
    file="$temp_dir/$base.$qemu_ext"
    printf '下载 %s...\n' "$asset"
    if ! curl -fsSL -G --data-urlencode "key=$key" -o "$file" \
      "https://velxio.dev/api/pro/license/downloads/$asset"; then
      rm -rf "$temp_dir"
      return 1
    fi
    magic=$(od -An -tx1 -N4 "$file" | tr -d '[:space:]')
    case "$os:$magic" in
      Darwin:cffaedfe|Darwin:cafebabe|Linux:7f454c46) ;;
      *) printf '下载的 %s 不是此平台的动态库。\n' "$asset" >&2; rm -rf "$temp_dir"; return 1 ;;
    esac
  done
  for file in esp32-v3-rom.bin esp32-v3-rom-app.bin esp32c3-rom.bin esp32s3_rev0_rom.bin; do
    asset=${file%.bin}
    printf '下载 %s...\n' "$asset"
    if ! curl -fsSL -G --data-urlencode "key=$key" -o "$temp_dir/$file" \
      "https://velxio.dev/api/pro/license/downloads/$asset" || [ ! -s "$temp_dir/$file" ]; then
      rm -rf "$temp_dir"
      return 1
    fi
  done
  mv "$temp_dir" "$toolchain_dir/qemu"
}

if ! arduino_cli_compatible; then
  if ask_install '未安装 Arduino CLI 1.x（编译开发板程序），是否安装？'; then
    install_arduino_cli || report_failure 'Arduino CLI'
  fi
else
  printf '已安装：Arduino CLI（%s）\n' "$(arduino-cli version)"
fi

if arduino_cli_compatible; then
  offer_core 'arduino:avr' '' 'Arduino AVR（Uno/Nano/Mega）' ''
  offer_core 'rp2040:rp2040' '' 'RP2040（Pico/Pico W）' \
    'https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json'
  offer_core 'esp32:esp32' '3.3.9' 'ESP32 Arduino 内核 3.3.9' \
    'https://espressif.github.io/arduino-esp32/package_esp32_index.json'
  offer_core 'ATTinyCore:avr' '1.4.1' 'ATTinyCore 1.4.1（ATtiny85）' \
    'http://drazzy.com/package_drazzy.com_index.json'
fi

wasi_installed() {
  local candidate
  for candidate in "$toolchain_dir/wasi-sdk" "${WASI_SDK:-}" /opt/wasi-sdk /usr/local/wasi-sdk "$HOME/wasi-sdk"; do
    if [ -n "$candidate" ] && [ -x "$candidate/bin/clang" ]; then
      return 0
    fi
  done
  return 1
}

idf_installed() {
  local idf arduino
  for idf in "$toolchain_dir/esp-idf-v5" "${IDF5_PATH:-}" /opt/esp-idf-v5; do
    [ -n "$idf" ] && [ -f "$idf/export.sh" ] || continue
    if [ "$idf" = "$toolchain_dir/esp-idf-v5" ] && [ ! -f "$toolchain_dir/.fooxio-esp-idf-ready" ]; then
      continue
    fi
    for arduino in "$toolchain_dir/arduino-esp32-3" "${ARDUINO_ESP32_5_PATH:-}" /opt/arduino-esp32-3; do
      [ -n "$arduino" ] && [ -f "$arduino/CMakeLists.txt" ] && return 0
    done
  done
  return 1
}

if wasi_installed; then
  printf '已安装：WASI-SDK\n'
elif ask_install '未安装 WASI-SDK（自定义芯片编译），是否安装？'; then
  install_wasi_sdk || report_failure 'WASI-SDK'
fi

if idf_installed; then
  printf '已安装：ESP-IDF 5.5.4 与 arduino-esp32 3.3.10\n'
elif ask_install '未安装完整 ESP-IDF 编译环境（下载量较大，并安装系统构建依赖），是否安装？'; then
  install_esp_idf || report_failure 'ESP-IDF 与 arduino-esp32'
fi

if command -v sdcc >/dev/null 2>&1; then
  printf '已安装：SDCC\n'
elif ask_install '未安装 SDCC（Z80 等目标的 C 编译），是否通过系统包管理器安装？'; then
  if ! install_sdcc || ! command -v sdcc >/dev/null 2>&1; then
    report_failure 'SDCC'
  fi
fi

case "$os" in
  Darwin) qemu_ext=dylib ;;
  Linux) qemu_ext=so ;;
  *) qemu_ext='' ;;
esac
if qemu_installed; then
  printf '已安装：Velxio QEMU 动态库与 ROM\n'
elif ask_install '未安装 Velxio QEMU 动态库与 ROM（ESP32 仿真），是否使用个人密钥下载？'; then
  install_qemu || report_failure 'Velxio QEMU 动态库与 ROM'
fi

# 启动后端时恢复安装在虚拟环境中的工具链路径。
env_file="$_fooxio_root/backend/.venv/.fooxio-full-setup-env"
{
  if [ -x "$toolchain_dir/wasi-sdk/bin/clang" ]; then
    printf 'export WASI_SDK=%q\n' "$toolchain_dir/wasi-sdk"
  fi
  if [ -f "$toolchain_dir/.fooxio-esp-idf-ready" ] && [ -f "$toolchain_dir/esp-idf-v5/export.sh" ] && [ -f "$toolchain_dir/arduino-esp32-3/CMakeLists.txt" ]; then
    printf 'export IDF5_PATH=%q\n' "$toolchain_dir/esp-idf-v5"
    printf 'export IDF_PATH=%q\n' "$toolchain_dir/esp-idf-v5"
    printf 'export ARDUINO_ESP32_5_PATH=%q\n' "$toolchain_dir/arduino-esp32-3"
    printf 'export ARDUINO_ESP32_PATH=%q\n' "$toolchain_dir/arduino-esp32-3"
  fi
  if [ -f "$toolchain_dir/qemu/libqemu-xtensa.$qemu_ext" ] && [ -f "$toolchain_dir/qemu/libqemu-riscv32.$qemu_ext" ]; then
    printf 'export VELXIO_QEMU_PATH=%q\n' "$toolchain_dir/qemu"
  fi
} > "$env_file" || exit 1

if [ "$failures" -ne 0 ]; then
  printf '有 %s 项安装失败。\n' "$failures" >&2
  exit 1
fi
printf '完整环境检查结束。\n'

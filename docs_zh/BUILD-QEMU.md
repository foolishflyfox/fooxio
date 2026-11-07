# 为 Velxio 从源码构建 QEMU

Velxio Docker 镜像附带预构建的 `libqemu-xtensa` 和 `libqemu-riscv32` 库，因此 ESP32、ESP32-S3 和 ESP32-C3 仿真开箱即用。如果你因许可证、审计要求，或希望自行编译运行的代码而不想使用预构建文件，本指南说明如何获取对应源码并构建。

QEMU 使用 **GPL-2.0**，Velxio 对它的所有修改也采用相同许可证。收到我们分发的二进制文件的人，都可以无附加条件地获取完整对应源码，参见[获取源码](#1-获取源码)。

## 请先阅读：上游源码无法构建出 Velxio 使用的版本

Velxio 的 ESP32 支持**并非**直接来自未经修改的上游代码。构建 [`lcgamboa/qemu`](https://github.com/lcgamboa/qemu) 也无法得到可直接替换的文件。具体来说：

- 上游的 `picsimlab-esp32` 分支虽然包含 `hw/xtensa/esp32s3.c`，但它注册的是 Espressif 普通的 `-M esp32s3` 机器。Velxio 使用 `esp32s3-picsimlab` 变体，其中连接了 Python 工作进程所需的宿主机 GPIO、SPI、I2C 和 UART 回调。上游没有这个机器型号，因此普通构建虽然可以启动，却找不到 Velxio 请求的机器型号。
- Velxio 依赖的若干设备模型只存在于我们的源码树中：`hw/ssi/esp32s3_gpspi.c`（S3 的 GPSPI2 控制器；普通机器未实现它，因此 SPI 显示屏没有可用的控制器）、`hw/i2c/esp32_ov2640.c`、`hw/misc/esp32_i2s_cam.c` 和 `hw/misc/velxio_camera_export.c`（ESP32-CAM 路径）。

因此，请使用下文所述的源码归档构建，不要直接克隆上游仓库。本文早期版本曾要求检出某个上游提交，并声称构建结果会与我们的预构建文件逐字节一致。这两种说法都不对，而且当时给出的提交 ID 根本不存在。对此我们深表歉意；这个错误让一些人白白花费了构建时间。

## 适用对象

本指南假设你使用 Linux 或 macOS 工作站，并已有可用的 C 工具链。Windows 构建使用 MSYS2 / MinGW；请参见源码归档中的 `build_libqemu-esp32-win.sh` 和 `.github/workflows/build-libqemu.yml` 的 `windows` 作业。

## 构建产物

| 文件 | 架构 | 用途 |
| --- | --- | --- |
| `libqemu-xtensa.so` | Xtensa LX6 / LX7 | ESP32、ESP32-S3、ESP32-CAM、Arduino Nano ESP32 |
| `libqemu-riscv32.so` | RISC-V RV32IMC | ESP32-C3、XIAO ESP32-C3 |

Velxio 后端运行时通过 `backend/app/services/esp32_worker.py` 加载这些库。将新构建的文件放入容器中的 `/app/lib/`（或映射到该目录的宿主机路径），Velxio 会在下一次启动仿真时使用它们。

## 1. 获取源码

对应源码以 tar 归档的形式与二进制文件一起发布，使用同一个下载接口：

```bash
# 列出当前密钥可下载的文件；源码归档命名为 qemu-source-<commit>，
# 与对应二进制文件的构建提交一致。
curl "https://velxio.dev/api/pro/license/downloads?key=$VELXIO_LICENSE_KEY"

# 下载其中一份归档。
curl -O -J \
  "https://velxio.dev/api/pro/license/downloads/qemu-source-83a944ce?key=$VELXIO_LICENSE_KEY"
```

可在 [`velxio.dev/license/signup`](https://velxio.dev/license/signup) 申请免费的个人密钥。列表会给出每个文件的 `sha256`，请校验下载结果。

归档包含完整源码树、构建脚本、发布用 CI 工作流，以及记录所对应二进制文件和相对上游修改的 `README.VELXIO-SOURCE.md`。源码采用 GPL-2.0；你可以依照该许可证研究、修改和再分发。

如果你收到了 Velxio 二进制文件，却因任何原因无法访问下载接口，请提交 issue。你有权获取对应源码，我们会提供给你。

## 2. 安装构建依赖

**Debian / Ubuntu**：

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential git wget curl \
    python3-pip python3-setuptools \
    ninja-build pkg-config flex bison \
    libglib2.0-dev libgcrypt-dev libslirp-dev \
    libpixman-1-dev libfdt-dev zlib1g-dev jq
pip3 install meson==1.2.3 tomli
```

使用 Python 3.11 以前的版本时，`tomli` 不是可选项：QEMU 9.2 的 `mkvenv` 需要它；缺少它时，`configure` 会报 *“found no usable tomli”*。

在 glibc 系统上，iconv 位于 libc 中，没有独立的库，但 QEMU 的 `configure` 仍会加入 `-liconv`。创建一个空的占位库即可满足链接器：

```bash
LIBDIR=$(dpkg-architecture -q DEB_HOST_MULTIARCH)
sudo ar rcs /usr/lib/${LIBDIR}/libiconv.a
```

**macOS**（Apple Silicon）：

```bash
brew install gnu-sed coreutils ninja pkg-config meson \
             glib pixman libgcrypt libslirp
python3 -m pip install --user --break-system-packages distlib
export PYTHONPATH="$(python3 -c 'import site; print(site.getusersitepackages())')"
export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH"
export OBJC=clang OBJCXX=clang++
```

GNU `sed` 必须在 `PATH` 中排在前面，因为构建脚本依赖 GNU `sed -i` 的行为。Homebrew 的 Python 不附带 QEMU 的 `mkvenv.py` 所需的 `distlib`。

## 3. 构建

两个库都由同一个脚本构建；发布用 CI 也运行这个脚本：

```bash
tar xzf velxio-qemu-src-<commit>.tar.gz
cd velxio-qemu-<commit>
bash build_libqemu-esp32.sh
```

不要自行拼写 `configure` 参数。QEMU 没有 `--enable-shared-lib` 选项（本文早期版本曾错误地写出该选项）。构建脚本会先正常构建 `qemu-system-*`，再排除 `system_main`，用相同的目标文件重新链接成库；它还会设置 ESP32 机器所需的 `-DESP32_PICSIMLAB_SOFT_CACHE=1` 标志。

在 macOS 上，脚本输出的文件仍命名为 `libqemu-*.so`；请将扩展名改为 `.dylib`。

验证构建结果：

```bash
file build/libqemu-xtensa.so
# ELF 64 位 LSB 共享对象，x86-64，动态链接

ls -lh build/libqemu-xtensa.so build/libqemu-riscv32.so
# 在 Linux x86_64 上，每个文件约 45–50 MB
```

## 4. 将二进制文件放入 Velxio

工作进程会向 QEMU 传入 `-L <.so 所在目录>`，因此启动 ROM 文件必须与库文件放在**同一目录**：

```
/app/lib/libqemu-xtensa.so      /app/lib/esp32-v3-rom.bin
/app/lib/libqemu-riscv32.so     /app/lib/esp32-v3-rom-app.bin
                                /app/lib/esp32c3-rom.bin
                                /app/lib/esp32s3_rev0_rom.bin
```

如果你使用官方 Docker 镜像自行部署：

```bash
docker cp build/libqemu-xtensa.so   velxio:/app/lib/libqemu-xtensa.so
docker cp build/libqemu-riscv32.so  velxio:/app/lib/libqemu-riscv32.so
```

工作进程每次运行时都会加载库，因此无需重启服务；下一次启动仿真时即可使用新文件。如果从源码运行，则将库和 ROM 复制到 `backend/app/services/`，或将 `VELXIO_QEMU_PATH` 指向存放这些文件的目录。

你也可以不向容器复制文件：在执行 `docker compose build` 前，将 `.so` 文件和四份 ROM 放入 `prebuilt/qemu/`，镜像构建就会使用这些文件，而不再下载。

## 5. ESP32 ROM 文件

QEMU 的构建过程不会生成 Velxio 所需的启动 ROM 转储文件（`esp32-v3-rom.bin`、`esp32-v3-rom-app.bin`、`esp32c3-rom.bin`、`esp32s3_rev0_rom.bin`）。这些文件来自 Espressif 的开源工具链，可以原样再分发。镜像的 `/app/lib/` 已包含它们；只有使用自定义版本的 esp-idf 时才需要替换。

## 6. 故障排查

**`found no usable tomli`**：Python 版本低于 3.11，且未安装 `tomli`。参见构建依赖一节。

**`No such file or directory: glib-2.0`**：通过 apt 安装时漏掉了 `libglib2.0-dev`。

**Linux 上出现涉及 `-liconv` 的链接错误**：按前文创建空的 `libiconv.a` 占位库。

**macOS 上出现 `a usable distlib could not be found`**：Homebrew 的 Python 缺少 `distlib`；安装该包并导出 `PYTHONPATH`。

**macOS 上出现 `sed: -i may not be used with stdin` 或类似错误**：BSD `sed` 在 `PATH` 中排在 GNU `sed` 前面。

**库文件只有几百 KB**：重新链接步骤没有执行。查看脚本保留的 `build/ninja-link-*.log`。

**Velxio 启动仿真后，QEMU 报告未知机器型号（`esp32s3-picsimlab`、`esp32-picsimlab`、`esp32c3-picsimlab`）**：你构建的是上游克隆仓库，而不是本文所述的源码归档。参见开头的说明。

## 许可证说明

QEMU（包括我们的修改）采用 **GPL-2.0**，Velxio 本身采用 **AGPLv3**。`dlopen` 边界使两者的许可证保持独立：QEMU 仍采用 GPL，Velxio 仍采用 AGPL，双方的许可证不会因此改变对方的适用范围。

如果你再分发 QEMU 库，需要依照 GPL-2.0 向接收者提供对应源码（上文提到的归档正是该源码）。如果你通过网络部署修改后的 Velxio，需要依照 AGPLv3 向用户提供 Velxio 的修改内容。

## 为什么仍有人选择预构建文件？

对大多数自行部署者来说，预构建文件最方便：它们已经构建完成，清单中有校验值，可以直接放到指定位置。自行构建在现代笔记本电脑上需要 15–30 分钟和约 3 GB 磁盘空间。

以下情况适合从源码构建：

- 你需要为受监管的部署审计软件供应链。
- 你需要修改 QEMU，例如新增外设或修复设备模型，并发布修改后的库。
- 你不想在自己的机器上使用第三方预构建文件。
- 你使用的是我们未提供二进制文件的平台，例如 BSD 或使用特殊 libc 的系统。

这四种需求都合理，也都不需要事先征求我们的同意。

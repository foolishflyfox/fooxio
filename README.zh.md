# Velxio：Arduino 与嵌入式开发板仿真器

**在线体验：[velxio.dev](https://velxio.dev)**

Velxio 是开源的多开发板仿真器和电路模拟器。你可以编写 Arduino C++、MicroPython、ESP-IDF 或 Python 代码，编译后通过真实的 CPU 仿真运行，并与 150 多种可交互电子元件连接。所有操作都在浏览器中完成。

**40 款开发板 &middot; 5 类 CPU**：AVR8（ATmega / ATtiny）、ARM Cortex-M（RP2040 / RP2350 / STM32）、Xtensa LX6/LX7（ESP32 / ESP32-S3）、RISC-V（ESP32-C3 / ESP32-C6）以及 ARM Cortex-A Linux（Raspberry Pi Zero 至 5）。

![访客数](https://visitor-badge.laobi.icu/badge?page_id=davidmonterocrespo24/velxio)
[![在线演示](https://img.shields.io/badge/Live%20Demo-velxio.dev-007acc?style=for-the-badge)](https://velxio.dev)
[![Docker 镜像](https://img.shields.io/badge/Docker-ghcr.io%2Fdavidmonterocrespo24%2Fvelxio-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://github.com/davidmonterocrespo24/velxio/pkgs/container/velxio)
[![GitHub 星标](https://img.shields.io/github/stars/davidmonterocrespo24/velxio?style=for-the-badge)](https://github.com/davidmonterocrespo24/velxio/stargazers)
[![Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/3mARjJrh4E)
[![许可证：AGPLv3](https://img.shields.io/badge/License-AGPL%20v3-blue?style=for-the-badge)](LICENSE)
[![商业许可证](https://img.shields.io/badge/Commercial%20License-Available-green?style=for-the-badge)](COMMERCIAL_LICENSE.md)

---

[![Product Hunt](https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=1092514&theme=dark&t=1772998619179)](https://www.producthunt.com/products/velxio)

---

## 支持项目

Velxio 免费且开源。构建和维护完整的多开发板仿真器需要大量时间。如果它为你节省了时间，或者你喜欢这个项目，直接赞助我有助于项目持续开发。

| 平台 | 链接 |
| --- | --- |
| **GitHub Sponsors**（首选） | [github.com/sponsors/davidmonterocrespo24](https://github.com/sponsors/davidmonterocrespo24) |
| **PayPal** | [paypal.me/odoonext](https://paypal.me/odoonext) |

你的支持有助于支付服务器费用、维护依赖库，并让我有更多时间添加开发板、元件和功能。谢谢！

---

## 硬件合作伙伴

以下公司为 Velxio 提供支持及硬件，使其元件能够得到准确仿真：

<p align="center">
  <a href="https://www.dfrobot.com/?tracking=rzqVux"><img src="docs/partners/dfrobot.png" alt="DFRobot" width="150"></a>&nbsp;
  <a href="https://www.espressif.com/"><img src="docs/partners/espressif.png" alt="Espressif" width="150"></a>&nbsp;
  <a href="https://shop.m5stack.com/?ref=ehphcrsn"><img src="docs/partners/m5stack.png" alt="M5Stack" width="150"></a>&nbsp;
  <a href="https://www.seeedstudio.com/"><img src="docs/partners/seeed-studio.png" alt="Seeed Studio" width="150"></a>&nbsp;
  <a href="https://pimoroni.com/"><img src="docs/partners/pimoroni.png" alt="Pimoroni" width="150"></a>
</p>

<sub>上方 DFRobot 和 M5Stack 链接为推广链接：通过这些链接购买商品时，Velxio 会获得少量佣金，你无需额外付费；这有助于支付在线服务的费用。无论是否通过这些链接购买，模拟器都按 AGPL 许可免费提供。</sub>

这些公司的硬件现已收录在元件目录中：M5Stack Cardputer 和 Core、Pimoroni Badger 2350 和 Galactic Unicorn、Seeed Studio XIAO 系列和 Grove 模块、DFRobot UNIHIKER 和 Gravity 传感器，以及包括 ESP32-C6 在内的 Espressif ESP32 全系列。其中，M5Stack、Pimoroni 和 DFRobot 开发板，Seeed XIAO Sense、C6 和 RP2040，以及 ESP32-C6 DevKit 仅可在 velxio.dev 在线使用；自托管镜像包含 Arduino、Raspberry Pi Pico 和 ESP32 系列（参见[支持的开发板](#支持的开发板)）。

---

## 立即体验

**[https://velxio.dev](https://velxio.dev)** — 无需安装。打开编辑器，编写程序，即可直接在浏览器中仿真。

使用 Docker 自托管（一条命令）：

```bash
docker run -d \
  --name velxio \
  -p 3080:80 \
  -v velxio-data:/app/data \
  -v velxio-arduino-libs:/root/.arduino15 \
  -v velxio-arduino-user-libs:/root/Arduino \
  -v velxio-ccache:/var/cache/ccache \
  -v velxio-build:/var/lib/velxio-build \
  ghcr.io/davidmonterocrespo24/velxio:master
```

然后打开 <http://localhost:3080>。随时可以使用 `docker logs -f velxio` 查看日志。

> 自托管镜像支持 Arduino、Raspberry Pi Pico 和 ESP32 系列。STM32、Raspberry Pi Linux、ESP32-C6 和合作伙伴开发板仅可在 velxio.dev 在线使用。

这些命名卷能让后续编译保持较快速度。如果不使用它们，每次重启容器都会清空 ESP-IDF 构建缓存；重启后的首次编译将耗时 5–7 分钟，而不是 5–30 秒。

---

## 截图

<p align="center"><img src="docs/img/screens/weather-station.gif" width="520" alt="ESP32 气象站驱动 ILI9341 TFT 屏幕"></p>

ESP32 气象站：在画布上连接通过 I2C 通信的 BMP280、连接 GPIO 的 DHT22，以及通过 SPI 通信的 ILI9341 TFT。三条总线同时工作，屏幕实时更新。

![ESP32 Blink 运行时打开串口监视器](docs/img/screens/editor-esp32-blink.png)

编辑器：左侧是 Monaco，右侧是电路画布，底部显示编译输出和串口监视器。图中 ESP32 DevKit 让外部 LED 闪烁，并通过 UART 输出信息。

![包含开发板和模块的元件选择器](docs/img/screens/component-picker.png)

元件选择器：每款开发板和模块都有实时预览，并支持搜索和分类筛选。目录包含 150 多种元件，涵盖显示屏、传感器、电机、逻辑 IC、模拟元件、面包板及品牌模块。

![示例项目库](docs/img/screens/examples-gallery.png)

示例项目库：400 多个可直接运行的项目，可按开发板、难度和主题筛选，其中包括 [100 Days 100 IoT Projects](https://github.com/velxio/100_Days_100_IoT_Projects) 系列。

![ESP32 上的 MicroPython 与 REPL](docs/img/screens/micropython.png)

MicroPython：同一块 ESP32 开发板运行 `main.py`，终端面板中提供 REPL。ESP32 开发板也支持纯 ESP-IDF 项目。

![ESP32 WiFi 通过 MQTT 发布和订阅消息](docs/img/screens/esp32-wifi-mqtt.png)

仿真 WiFi：ESP32 连接虚拟接入点、获取 IP 地址，并通过公共 MQTT 代理收发消息。

![示波器追踪 GPIO 信号](docs/img/screens/oscilloscope.png)

测量仪器：示波器可监测任意引脚；基于 SPICE 的电气层还会显示所绘导线中的电流、电压和短路情况。

![自定义芯片编辑器](docs/img/screens/custom-chip.png)

自定义芯片：用 C 编写自己的 IC，将其编译为 WebAssembly，再放到画布上与开发板连接。

---

## 支持的开发板

<table>
<tr>
  <td align="center"><img src="docs/img/boards/arduino-uno.png" width="120" alt="Arduino Uno"/><br/><b>Arduino Uno</b></td>
  <td align="center"><img src="docs/img/boards/arduino-nano.png" width="120" alt="Arduino Nano"/><br/><b>Arduino Nano</b></td>
  <td align="center"><img src="docs/img/boards/arduino-mega.png" width="120" alt="Arduino Mega 2560"/><br/><b>Arduino Mega 2560</b></td>
  <td align="center"><img src="docs/img/boards/attiny85.png" width="120" alt="ATtiny85"/><br/><b>ATtiny85</b></td>
  <td align="center"><img src="docs/img/boards/raspberry-pi-3.png" width="120" alt="Raspberry Pi 3"/><br/><b>Raspberry Pi 3</b></td>
  <td align="center"><img src="docs/img/boards/raspberry-pi-5.png" width="120" alt="Raspberry Pi 5"/><br/><b>Raspberry Pi 5</b></td>
</tr>
<tr>
  <td align="center"><img src="docs/img/boards/raspberry-pi-pico.png" width="70" alt="Raspberry Pi Pico"/><br/><b>Raspberry Pi Pico</b></td>
  <td align="center"><img src="docs/img/boards/pi-pico-w.png" width="70" alt="Raspberry Pi Pico W"/><br/><b>Raspberry Pi Pico W</b></td>
  <td align="center"><img src="docs/img/boards/esp32.png" width="80" alt="ESP32 DevKit V1"/><br/><b>ESP32 DevKit V1</b></td>
  <td align="center"><img src="docs/img/boards/esp32-s3.png" width="70" alt="ESP32-S3"/><br/><b>ESP32-S3</b></td>
  <td align="center"><img src="docs/img/boards/esp32-c3.png" width="80" alt="ESP32-C3"/><br/><b>ESP32-C3</b></td>
  <td align="center"><img src="docs/img/boards/esp32-cam.png" width="80" alt="ESP32-CAM"/><br/><b>ESP32-CAM</b></td>
</tr>
<tr>
  <td align="center"><img src="docs/img/boards/xiao-esp32-s3.png" width="90" alt="XIAO ESP32-S3"/><br/><b>XIAO ESP32-S3</b></td>
  <td align="center"><img src="docs/img/boards/xiao-esp32-c3.png" width="90" alt="XIAO ESP32-C3"/><br/><b>XIAO ESP32-C3</b></td>
  <td align="center"><img src="docs/img/boards/arduino-nano-esp32.png" width="120" alt="Arduino Nano ESP32"/><br/><b>Arduino Nano ESP32</b></td>
  <td align="center"><img src="docs/img/boards/stm32-bluepill.png" width="70" alt="STM32 Blue Pill"/><br/><b>STM32 Blue Pill</b></td>
  <td align="center"><img src="docs/img/boards/stm32-blackpill.png" width="70" alt="STM32 Black Pill"/><br/><b>STM32 Black Pill</b></td>
  <td align="center"><img src="docs/img/boards/stm32-f4-discovery.png" width="90" alt="STM32F4 Discovery"/><br/><b>STM32F4 Discovery</b></td>
</tr>
<tr>
  <td align="center"><img src="docs/img/boards/cardputer-adv.png" width="120" alt="M5 Cardputer ADV"/><br/><b>M5 Cardputer ADV</b></td>
  <td align="center"><img src="docs/img/boards/m5stack-core.png" width="110" alt="M5Stack Core"/><br/><b>M5Stack Core</b></td>
  <td align="center"><img src="docs/img/boards/badger-2350.png" width="120" alt="Pimoroni Badger 2350"/><br/><b>Pimoroni Badger 2350</b></td>
  <td align="center"><img src="docs/img/boards/xiao-esp32s3-sense.png" width="90" alt="XIAO ESP32S3 Sense"/><br/><b>XIAO ESP32S3 Sense</b></td>
  <td align="center"><img src="docs/img/boards/esp32-c6.png" width="70" alt="ESP32-C6 DevKit"/><br/><b>ESP32-C6 DevKit</b></td>
  <td align="center"><img src="docs/img/boards/unihiker-m10.png" width="90" alt="DFRobot UNIHIKER M10"/><br/><b>DFRobot UNIHIKER M10</b></td>
</tr>
</table>

开发板有两种运行方式。**浏览器开发板**（AVR、RP2040）通过 avr8js 和 rp2040js 完全在网页中仿真，数据不会离开你的设备。**服务器开发板**（ESP32 系列、STM32、Raspberry Pi Linux）在后端启动真正的 QEMU 虚拟机，并将 GPIO 和串口数据传送到画布。两者的操作方式相同：点击“运行”即可。

| 系列 | 开发板 | 编程语言 | 运行位置 |
| --- | --- | --- | --- |
| **Arduino / AVR** | Uno、Nano、Mega 2560、ATtiny85 | Arduino C++ | 浏览器：自托管和 velxio.dev |
| **Raspberry Pi Pico** | Pico、Pico W | Arduino C++、MicroPython | 浏览器：自托管和 velxio.dev |
| **ESP32** | ESP32 DevKit V1、DevKit-C V4、ESP32-CAM、Wemos Lolin32 Lite | Arduino C++、MicroPython、ESP-IDF | 自托管（QEMU）和 velxio.dev |
| **ESP32-S3** | ESP32-S3 DevKit、XIAO ESP32-S3、Arduino Nano ESP32 | Arduino C++、MicroPython、ESP-IDF | 自托管（QEMU）和 velxio.dev |
| **ESP32-C3** | ESP32-C3 DevKit、XIAO ESP32-C3、ESP32-C3 SuperMini | Arduino C++、MicroPython、ESP-IDF | 自托管（QEMU）和 velxio.dev |
| **STM32** | Blue Pill（F103C8 / F103CB）、Black Pill（F411CE / F401CE）、STM32F4 Discovery、Olimex STM32-H405、Netduino 2 / Plus 2 | Arduino C++ | 仅在线：velxio.dev（付费套餐）或 Velxio Desktop；自托管镜像不包含 |
| **Raspberry Pi（Linux）** | Zero、1B+、2B、3B、4B、5；启动真正的 Linux，在完整终端中运行 Python | Python | 仅在线：velxio.dev（付费套餐）或 Velxio Desktop；自托管镜像不包含 |
| **品牌开发板** | M5Stack Cardputer ADV 和 Core、Pimoroni Badger 2350、Galactic Unicorn 和 Pico Plus 2 W、Seeed XIAO ESP32S3 Sense、XIAO ESP32C6 和 XIAO RP2040、Espressif ESP32-C6 DevKit、DFRobot UNIHIKER M10 | Arduino C++、MicroPython、ESP-IDF | 仅在线：velxio.dev（免费套餐；UNIHIKER 需要付费套餐）；自托管镜像不包含 |

自托管镜像开箱即用地支持前五个系列。其他开发板仅可在 velxio.dev 在线使用：STM32 和 Raspberry Pi Linux 需要获得许可的仿真器二进制文件和数 GB 的启动镜像（付费套餐的 Velxio Desktop 也支持）；品牌开发板则从托管目录启动出厂固件，如 M5 启动器和 BadgeOS。开源版本的元件选择器会将这些开发板链接到在线编辑器。完整的引脚定义、编程语言和注意事项见[开发板参考文档](https://velxio.dev/docs/boards/overview/)。

---

## 功能

### 代码编辑

- **Monaco 编辑器**：完整的 C++ / Python 编辑器，支持语法高亮、自动补全、缩略图和深色主题。
- **多文件工作区**：创建、重命名、删除和切换多个 `.ino` / `.h` / `.cpp` / `.py` 文件。
- **Arduino 编译**：通过后端的 `arduino-cli` 将程序编译为 `.hex` / `.bin` 文件。
- **编译 / 运行 / 停止 / 重置**工具栏按钮，并显示状态消息。
- **编译控制台**：可调整大小的输出面板，显示完整的编译器输出、警告和错误。

### 多开发板仿真

#### AVR8（Arduino Uno / Nano / Mega / ATtiny85）

- 通过 avr8js 以原生时钟速度仿真 **ATmega328p / ATmega2560 / ATtiny85**。
- **完整 GPIO**：PORTB、PORTC、PORTD（Uno/Nano/Mega）；ATtiny85 的所有端口（PB0–PB5）。
- **Timer0/Timer1/Timer2**：支持 `millis()`、`delay()` 和通过 `analogWrite()` 输出 PWM。
- **USART**：完整的发送与接收功能，以及自动波特率检测。
- **ADC**：支持 `analogRead()`，并可从画布上的电位器注入电压。
- **SPI**：硬件 SPI 外设，可连接 ILI9341、SD 卡等。
- **I2C（TWI）**：带虚拟设备总线的硬件 I2C。
- **ATtiny85**：全部 6 个 I/O 引脚、USI（Wire）、Timer0/Timer1 和 10 位 ADC；使用 `AttinyCore`。
- 通过 `requestAnimationFrame` 以约 60 FPS 运行仿真循环。

#### RP2040（Raspberry Pi Pico / Pico W）

- 通过 rp2040js 以 133 MHz 仿真真正的 **RP2040**（ARM Cortex-M0+）。
- **全部 30 个 GPIO 引脚**：支持输入/输出、事件监听和引脚状态注入。
- **UART0 + UART1**：在串口监视器显示串口输出，并通过界面发送串口输入。
- **ADC**：GPIO 26–29（A0–A3）上的 12 位 ADC，以及内部温度传感器（通道 4）。
- **I2C0 + I2C1**：主机模式，连接虚拟设备总线（DS1307、TMP102、EEPROM）。
- **SPI0 + SPI1**：默认回环，也支持自定义处理程序。
- **PWM**：任意 GPIO 引脚均可使用。
- **WFI 优化**：`delay()` 可直接推进仿真时间，无需忙等待。
- **示波器**：以约 8 ns 的分辨率记录 GPIO 电平变化时间戳。
- 使用 [earlephilhower arduino-pico](https://github.com/earlephilhower/arduino-pico) 内核编译。

完整技术细节见 [docs/RP2040_EMULATION.md](docs/RP2040_EMULATION.md)。

#### ESP32、STM32 和 Raspberry Pi Linux

ESP32 系列（Xtensa 和 RISC-V）、STM32 系列以及 Raspberry Pi Linux 开发板运行在基于 QEMU 的后端上，并与浏览器开发板共用相同的画布、串口监视器和测量仪器。各开发板的设置、外设和注意事项见[文档](https://velxio.dev/docs/boards/overview/)；QEMU 桥接的技术说明见 [docs/ESP32_EMULATION.md](docs/ESP32_EMULATION.md)、[docs/RISCV_EMULATION.md](docs/RISCV_EMULATION.md) 和 [docs/RASPBERRYPI3_EMULATION.md](docs/RASPBERRYPI3_EMULATION.md)。

### 示例项目

- 示例库提供数百个可直接运行的项目（velxio.dev 上有 400 多个），可按开发板、难度和主题筛选。从 Blink 和交通灯，到 TFT 仪表盘、电子纸显示屏、通过仿真 WiFi 使用 MQTT，以及 Raspberry Pi 与 Arduino 的串口连接，均有示例。
- [100 Days 100 IoT Projects](https://github.com/velxio/100_Days_100_IoT_Projects) 系列已导入为可运行项目。
- 一键加载到编辑器。

---

## 自托管

选择适合你的安装方式。**三种方式都无需 `.env` 文件即可开箱即用**，默认配置会自动选取。

| 方式 | 可用开发板 | 构建时间 | 适用场景 |
| --- | --- | --- | --- |
| **A. Docker（预构建镜像）** | AVR、RP2040 和整个 **ESP32** 系列（Xtensa + RISC-V） | 下载约 30 秒 | 希望直接运行 |
| **B. Docker Compose（从源码构建）** | 同 A | 首次构建约 10–15 分钟 | 希望修改代码 |
| **C. 手动安装** | 仅浏览器开发板（AVR、RP2040） | 约 5 分钟 | 前端 / 后端开发 |

> ESP32 仿真依赖 Docker 镜像中附带的 QEMU `.so` 库。手动安装可直接使用浏览器端开发板；如需 ESP32，建议使用 Docker，或者按 [docs/ESP32_EMULATION.md](docs/ESP32_EMULATION.md) 手动配置 QEMU 二进制文件。STM32、Raspberry Pi Linux、ESP32-C6 和合作伙伴开发板仅可在 velxio.dev 在线使用（付费套餐的 Velxio Desktop 也支持 STM32 和 Raspberry Pi）；自托管镜像不包含它们。

---

### 方案 A：Docker（预构建镜像）

```bash
docker run -d \
  --name velxio \
  -p 3080:80 \
  -v velxio-data:/app/data \
  -v velxio-arduino-libs:/root/.arduino15 \
  -v velxio-arduino-user-libs:/root/Arduino \
  -v velxio-ccache:/var/cache/ccache \
  -v velxio-build:/var/lib/velxio-build \
  ghcr.io/davidmonterocrespo24/velxio:master
```

打开 <http://localhost:3080>。

五个命名卷保存以下数据：

- `velxio-data` → `/app/data`：SQLite 数据库、项目程序文件和自动生成的 `SECRET_KEY`。
- `velxio-arduino-libs` → `/root/.arduino15`：arduino-cli 配置和已安装的内核，避免每次重启容器后重新安装并等待 5–10 分钟。
- `velxio-arduino-user-libs` → `/root/Arduino`：通过 Library Manager 安装的 Arduino 库，例如 Adafruit_BMP280、DHT 和 GFX。没有这个卷，重启容器后的下一次编译会重新下载这些库。
- `velxio-ccache` → `/var/cache/ccache`：用于 ESP-IDF 编译的 C/C++ 对象文件缓存。首次编译时为空，随后逐步填充；后续编译可命中缓存，将耗时从几分钟缩短到几秒。
- `velxio-build` → `/var/lib/velxio-build`：持久化的 ESP-IDF 构建目录，每个目标（esp32、esp32c3、esp32s3）各有一个子目录。ninja 增量构建可跳过未更改的内容；未修改的程序重新编译只需 2–5 秒。

如果省略卷参数，Dockerfile 会将这五个路径都声明为 `VOLUME`，Docker 因而会创建匿名卷。缓存仍可跨容器重启保留，只是比命名卷更难检查和备份。只有执行 `docker rm -v` 或 `docker volume prune` 才会清除它们。

---

### 方案 B：Docker Compose（从源码构建）

```bash
git clone https://github.com/davidmonterocrespo24/velxio.git
cd velxio
docker compose up -d --build
```

首次构建约需 10–15 分钟（下载 ESP-IDF 并构建前端）；后续构建可使用缓存，约需 1 分钟。

然后打开 <http://localhost:3080>。容器首次启动时会生成随机的 `SECRET_KEY` 并将其持久化在 `./data/` 中，因此**无需 `.env` 文件**即可运行。

#### 可选：自定义环境配置

开源镜像几乎无需配置：不依赖外部数据库，不包含身份验证或第三方集成。只有想修改本地开发时的 CORS 来源，才需要创建 `backend/.env`。

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `FRONTEND_URL` | `http://localhost:5173` | 本地 Vite 开发环境中允许跨域请求的来源 |
| `VELXIO_NEWS` | `on` | 产品动态：后端从 velxio.dev 的公开订阅源获取版本说明和产品新闻（缓存约 6 小时，匿名请求，不发送标识信息）；编辑器通过“新功能”弹窗向用户展示每条消息一次。文章可能嵌入远程媒体（截图、GIF、YouTube 预览），浏览器会直接从托管网站加载这些内容；视频播放器只会在用户明确点击后加载。设为 `off` 可完全禁用；离线主机会自动退化为不显示新闻。 |

> **通过反向代理部署？** 容器在 80 端口监听普通 HTTP，并接受任意 `Host` 请求头；没有 `server_name` 白名单。

> **运行 velxio.dev 本身？** 仅用于生产环境的配置（主机 nginx + HTTPS、备份、固定上游提交）位于独立仓库：[github.com/velxio/velxio-prod](https://github.com/velxio/velxio-prod)。

---

### 方案 C：手动安装（分别启动前端和后端）

**前提条件：** Node.js 18+、Python 3.12+、arduino-cli。

```bash
git clone https://github.com/davidmonterocrespo24/velxio.git
cd velxio
```

> 无需使用 `--recurse-submodules`。`@wokwi/elements`、`avr8js` 和 `rp2040js` 均从 npm 注册表获取。开发板 SVG 文件位于 `frontend/public/boards/`。`third-party/` 下的文件夹仅供参考；只有向目录添加新元件时，才需要克隆 wokwi-elements，因为元数据生成器会扫描其 `src/` 目录。

```bash
# 终端 1：后端
cd backend
python -m venv venv
source venv/bin/activate          # Windows：venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

```bash
# 终端 2：前端
cd frontend
npm install
npm run dev
```

打开 <http://localhost:5173>。

**首次配置 arduino-cli：**

```bash
arduino-cli core update-index
arduino-cli core install arduino:avr

# Raspberry Pi Pico / Pico W：
arduino-cli config add board_manager.additional_urls \
  https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
arduino-cli core install rp2040:rp2040

# ATtiny85：
arduino-cli config add board_manager.additional_urls \
  http://drazzy.com/package_drazzy.com_index.json
arduino-cli core install ATTinyCore:avr
```

> 手动安装时，如需编译 ESP32（Xtensa / RISC-V）程序，需要在本地安装 ESP-IDF v5.5.4 和 arduino-esp32 3.3.10 内核，这与 velxio.dev 使用的版本相同。Docker 镜像已包含两者；手动安装说明见 [docs/ESP32_EMULATION.md](docs/ESP32_EMULATION.md)。如果只需要 AVR / RP2040 开发板，可以完全跳过 ESP-IDF。

---

## 文档

用户文档位于 **[velxio.dev/docs](https://velxio.dev/docs/)**，提供 9 种语言，涵盖入门、各款开发板和元件、电路编辑器、Arduino / MicroPython / ESP-IDF 编程、WiFi 与物联网、测量仪器、自定义芯片及 AI 助手。其源码位于公开的 [velxio/velxio_docs](https://github.com/velxio/velxio_docs) 仓库，欢迎提交修正和新页面。

本仓库的 `docs/` 文件夹保存面向贡献者的技术说明，包括仿真器内部实现、QEMU 桥接、MCP 服务器和路线图。

---

## 社区

加入 Discord 服务器，提问、分享项目并关注更新：

**[discord.gg/3mARjJrh4E](https://discord.gg/3mARjJrh4E)**

## 贡献

欢迎在 [github.com/davidmonterocrespo24/velxio](https://github.com/davidmonterocrespo24/velxio) 提出建议、报告问题和提交拉取请求。

如果希望提供资金支持，请参阅上方的[支持项目](#支持项目)，或直接通过 [github.com/sponsors/davidmonterocrespo24](https://github.com/sponsors/davidmonterocrespo24) 赞助。

> **注意：** 所有贡献者都必须签署贡献者许可协议（CLA），以确保双重许可模式有效。拉取请求会自动进行 CLA 检查。

## 许可证

Velxio 采用**双重许可**模式：

| 用途 | 许可证 | 费用 |
| --- | --- | --- |
| 个人、教育、开源项目（遵守 AGPLv3） | [AGPLv3](LICENSE) | 免费 |
| 专有 / 闭源产品或 SaaS | [商业许可证](COMMERCIAL_LICENSE.md) | 付费 |

AGPLv3 是经过认证的开源许可证。只要对软件的修改或可通过网络访问的部署按同一许可证公开源代码，所有用途（包括商业用途）均可免费使用。无法满足这一要求的公司可以购买商业许可证。

商业授权咨询：[davidmonterocrespo24@gmail.com](mailto:davidmonterocrespo24@gmail.com)

完整条款见 [LICENSE](LICENSE) 和 [COMMERCIAL_LICENSE.md](COMMERCIAL_LICENSE.md)。

## 星标历史

<a href="https://www.star-history.com/?type=date&repos=davidmonterocrespo24%2Fvelxio">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=davidmonterocrespo24/velxio&type=date&theme=dark&legend=top-left&sealed_token=kw0zv7Q1xq7XgYk9MJ3Tzg2RixZ8GK74heH5o8WfUzvGZyY1UbCJox3XLfg2vDtHGdDd-5NE5XQWgC57joU_MyrfKxZkvcehtOQNjmT-PuG2p6d3dUkNM2r41KRyPjthNj3bZ_geKv4v7cnQLV7sll4lQDqxwO7ViC3G" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=davidmonterocrespo24/velxio&type=date&legend=top-left&sealed_token=kw0zv7Q1xq7XgYk9MJ3Tzg2RixZ8GK74heH5o8WfUzvGZyY1UbCJox3XLfg2vDtHGdDd-5NE5XQWgC57joU_MyrfKxZkvcehtOQNjmT-PuG2p6d3dUkNM2r41KRyPjthNj3bZ_geKv4v7cnQLV7sll4lQDqxwO7ViC3G" />
   <img alt="星标历史图" src="https://api.star-history.com/chart?repos=davidmonterocrespo24/velxio&type=date&legend=top-left&sealed_token=kw0zv7Q1xq7XgYk9MJ3Tzg2RixZ8GK74heH5o8WfUzvGZyY1UbCJox3XLfg2vDtHGdDd-5NE5XQWgC57joU_MyrfKxZkvcehtOQNjmT-PuG2p6d3dUkNM2r41KRyPjthNj3bZ_geKv4v7cnQLV7sll4lQDqxwO7ViC3G" />
 </picture>
</a>

## 参考项目

- [Wokwi](https://wokwi.com) — 灵感来源
- [avr8js](https://github.com/wokwi/avr8js) — AVR8 仿真器
- [wokwi-elements](https://github.com/wokwi/wokwi-elements) — 电子元件 Web 组件
- [wokwi-boards](https://github.com/wokwi/wokwi-boards) — 开发板 SVG 素材
- [wokwi-features](https://github.com/wokwi/wokwi-features) — Wokwi 功能定义
- [rp2040js](https://github.com/wokwi/rp2040js) — RP2040 仿真器
- [ngspice-wasm](https://github.com/wokwi/ngspice-wasm) — 编译为 WebAssembly 的 ngspice（电路仿真）
- [lcgamboa/qemu](https://github.com/lcgamboa/qemu) — 用于 ESP32 Xtensa 仿真的 QEMU 分支
- [espressif/qemu](https://github.com/espressif/qemu) — Espressif QEMU ESP32 仿真器
- [esp32-camera](https://github.com/espressif/esp32-camera) — ESP32 摄像头驱动参考实现
- [fritzing-parts](https://github.com/fritzing/fritzing-parts) — 电子元件 SVG 素材
- [picowi](https://github.com/jbentham/picowi) — Raspberry Pi Pico W WiFi 参考实现
- [100 Days 100 IoT Projects](https://github.com/velxio/100_Days_100_IoT_Projects) — 物联网示例项目集
- [arduino-cli](https://github.com/arduino/arduino-cli) — Arduino 编译工具
- [Monaco Editor](https://microsoft.github.io/monaco-editor/) — 代码编辑器
- [QEMU](https://www.qemu.org) — 虚拟机仿真器（Raspberry Pi 3）

# bluefluff — Furby Connect Bluetooth Control

A Dockerized version of [bluefluff](https://github.com/Jeija/bluefluff) by Jeija — a reverse-engineered Bluetooth Low Energy API and web UI for controlling **Furby Connect** toys from your Linux computer or Raspberry Pi.

> ⚠️ **Disclaimer:** This image is for educational and hobbyist purposes only. Interfacing with Furby Connect in unwarranted ways may void your warranty or brick your device. Use at your own risk.

---

## What is bluefluff?

bluefluff reverse-engineers the Furby Connect's BLE protocol, exposing it through a simple HTTP API (`fluffd`) and a browser-based control panel (`fluffd-client`). With it you can:

- 🎛️ **Control Furby's actions** — trigger thousands of built-in action sequences
- 🌈 **Change antenna color** and LCD backlight
- 😊 **Manipulate emotions** — tune Furby's wellness, fullness, tiredness, excitedness, and displeasedness
- 📡 **Read sensor data** — antenna joystick, tickle/pet sensors, accelerometer
- 🔧 **Flash DLC updates** — apply official Hasbro DLC files or your own custom ones
- 🎵 **Inject custom audio** into DLC update packages
- 🐛 **Open Furby's secret debug eye menu**

---

## Requirements

- A Linux host with Bluetooth Low Energy support (built-in or USB BT 4.0+ adapter)
- A **Furby Connect** toy (not compatible with older Furby models)
- Docker

> **macOS / Windows:** BLE hardware passthrough through Docker Desktop's VM layer is not supported. This image is intended for **Linux hosts only**.

---

## Quick Start

```bash
docker run -it \
  --network host \
  --privileged \
  --device /dev/bus/usb \
  --device /dev/hci0 \
  erezbinyamin/bluefluff
```

> **Note:** `--network host` is required so that [noble](https://github.com/sandeepmistry/noble) (the BLE library) can access raw HCI sockets. If your Bluetooth adapter hasn't initialized yet, ensure `hciconfig` shows your adapter on the host before running.

If your Bluetooth adapter is soft-blocked, unblock it first:

```bash
rfkill unblock bluetooth
```

---

## Accessing the Web UI

Once the container is running, open your browser to:

| Interface | URL | Description |
|---|---|---|
| **fluffd-client Web UI** | `http://localhost:8000` | Browser-based Furby control panel |
| **fluffd HTTP API** | `http://localhost:3872` | Raw HTTP API for sending BLE commands |

The web UI will automatically scan for nearby Furby Connect devices advertising over BLE and connect to them.

---

## Ports

| Port | Purpose |
|---|---|
| `8000` | `fluffd-client` static web UI (served via `http-server`) |
| `3872` | `fluffd` HTTP API |

---

## Furby's Emotional State

Furby's mood is a vector of five values (each 0–100):

- **Wellness** — overall health
- **Fullness** — how recently fed
- **Displeasedness** — grumpiness level
- **Tiredness** — sleepiness
- **Excitedness** — energy and enthusiasm

These can all be set directly from the web UI.

---

## Source & Documentation

- 🐙 **GitHub:** [https://github.com/Jeija/bluefluff](https://github.com/Jeija/bluefluff)
- 📖 **BLE Protocol Docs:** [doc/bluetooth.md](https://github.com/Jeija/bluefluff/blob/master/doc/bluetooth.md)
- 🎬 **YouTube Demo:** [Watch on YouTube](https://www.youtube.com/watch?v=FkblA_CxHgU)

---

## License

The bluefluff project is licensed under the [MIT License](https://github.com/Jeija/bluefluff/blob/master/LICENSE.md).

# Gemini Boot Animation

<div align="center">

[![GitHub Release](https://img.shields.io/github/v/release/docbt/GeminiBootAnimation?style=for-the-badge&logo=github&color=4285F4)](https://github.com/docbt/GeminiBootAnimation/releases/latest)
[![Android](https://img.shields.io/badge/Android-All%20Versions-3DDC84?style=for-the-badge&logo=android)](https://github.com/docbt/GeminiBootAnimation)
[![Magisk](https://img.shields.io/badge/Magisk-Compatible-black?style=for-the-badge)](https://github.com/topjohnwu/Magisk)
[![KernelSU](https://img.shields.io/badge/KernelSU-Compatible-orange?style=for-the-badge)](https://github.com/tiann/KernelSU)
[![APatch](https://img.shields.io/badge/APatch-Compatible-blue?style=for-the-badge)](https://github.com/bmax121/APatch)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**The Gemini Boot Animation from the Google Pixel 10 — ported for all Android devices.**

</div>

---

## Preview

<div align="center">

![Preview](preview/preview.gif)

</div>

---

## Features

- Original Gemini boot animation from the **Google Pixel 10**
- Clean and modern animated splash screen
- Seamlessly integrates with the system via Magisk/KernelSU/APatch
- Lightweight — no performance impact
- Compatible with **Android 9+**
- No modifications to system partitions (fully reversible)
- Optimized and tested on devices with **1080 × 2340** pixels

## How it was ported

Modern Android versions support **offset functions** in boot animations — frames are positioned relative to the screen center. Older ROMs and custom recoveries don't understand this and render the animation incorrectly.

To fix this, a custom script was written that processes every single frame individually and bakes the position directly into each frame — stabilizing and fixing the animation so it displays correctly on all Android versions and ROMs.

---

## Requirements

| Requirement | Details |
|---|---|
| Root Solution | Magisk **v20.4+** / KernelSU / APatch |
| Android Version | Android 9+ |
| Architecture | arm64-v8a, armeabi-v7a |

---

## Download — Which ZIP do I need?

Three variants are available in [**Releases**](https://github.com/docbt/GeminiBootAnimation/releases/latest):

| File | For |
|---|---|
| `GeminiBootAnimation-standard-*.zip` | **Google Pixel**, stock Android, OnePlus, Realme, most AOSP-based ROMs |
| `GeminiBootAnimation-MIUI-*.zip` | **Xiaomi** devices running **MIUI** |
| `GeminiBootAnimation-MTK-*.zip` | Devices with **MediaTek (MTK)** chipsets on stock firmware |

> **Not sure?** Start with the **standard** variant. If the animation doesn't appear after reboot, try the variant matching your chipset or ROM.

### Which paths does each variant cover?

| Variant | Paths installed |
|---|---|
| standard | `/product/media/` · `/system/media/` |
| MIUI | `/product/media/` · `/system/media/` · `/system_ext/media/` · `/system/media/theme/` |
| MTK | `/product/media/` · `/system/media/` · `/custom/media/` |

---

## Installation

Download the correct `.zip` for your device from [**Releases**](https://github.com/docbt/GeminiBootAnimation/releases/latest), then follow the instructions for your root solution below.

### Magisk

1. Open the **Magisk** app
2. Tap the **Modules** tab at the bottom
3. Tap **Install from storage**
4. Navigate to the downloaded `.zip` and select it
5. Wait for the installation to finish
6. Tap **Reboot**

### KernelSU

1. Open the **KernelSU** app
2. Tap the **Module** tab at the bottom
3. Tap the **+** button in the top right corner
4. Navigate to the downloaded `.zip` and select it
5. Wait for the installation to finish
6. Tap **Reboot**

### APatch

1. Open the **APatch** app
2. Tap **Modules** in the navigation
3. Tap the **+** button
4. Navigate to the downloaded `.zip` and select it
5. Wait for the installation to finish
6. Tap **Reboot**

---

## Uninstallation

1. Open Magisk / KernelSU / APatch Manager
2. Find **Gemini Boot Animation** in the module list
3. Tap **Remove**
4. **Reboot** your device

Your original boot animation will be automatically restored.

---

## Compatibility

| Root Solution | Status |
|---|---|
| Magisk | Tested |
| KernelSU | Tested |
| APatch | Tested |

---

## Device-Specific Notes

This module installs `bootanimation.zip` to **both** paths for maximum compatibility:

- `/product/media/bootanimation.zip` — higher priority (Android 9+, Pixel, most modern devices)
- `/system/media/bootanimation.zip` — fallback for older devices and ROMs

Android checks paths in this priority order:

1. `/apex/com.android.bootanimation/etc/bootanimation.zip` *(Android 10+)*
2. `/oem/media/bootanimation.zip`
3. `/product/media/bootanimation.zip` ← **this module (primary)**
4. `/system/media/bootanimation.zip` ← **this module (fallback)**

Depending on your device and ROM, a file in a higher-priority path may still take precedence.
The following manufacturers are known to use non-standard paths or proprietary formats:

### Samsung (One UI)

Samsung does **not** use `bootanimation.zip`. Instead, it uses a proprietary **QMG format**:

- `/system/media/bootsamsung.qmg` — plays once at boot
- `/system/media/bootsamsungloop.qmg` — loops until boot is complete

This module **will not work** on stock Samsung One UI firmware. It may work on Samsung devices running a custom ROM (GSI or AOSP-based).

### Huawei / EMUI / HarmonyOS

Huawei uses a non-standard path and a proprietary rendering pipeline:

- EMUI: `/system/etc/media/` or `/data/cust/media/`
- HarmonyOS: proprietary pipeline — standard `bootanimation.zip` replacement is generally **ineffective**

This module is **not compatible** with Huawei/HarmonyOS devices.

### Motorola

Boot animations on Motorola devices are stored on a dedicated OEM partition at `/oem/media/bootanimation.zip`, which is a separate block device — not `/system/media/`. Replacing the file in `/system/media/` has no effect on stock Motorola firmware.

This module will **likely not work** on stock Motorola firmware.

### Xiaomi MIUI

MIUI checks multiple paths simultaneously. Reliable modules must replace the file in all of them:

- `/system/media/bootanimation.zip`
- `/system/product/media/bootanimation.zip`
- `/system_ext/media/bootanimation.zip`
- `/system/media/theme/bootanimation.zip`

Use the **MIUI variant** of this module — it automatically installs to all required paths.

### Xiaomi HyperOS (2023+)

HyperOS may bypass the standard bootanimation lookup entirely. Even replacing all known paths does not guarantee the animation plays. A dedicated Magisk module with `post-fs-data.sh` hooks may be required.

### MediaTek (MTK) devices

MTK vendor builds add an additional high-priority path checked **before** all standard paths:

- `/custom/media/bootanimation.zip`

If this file exists on your device, it will override what this module installs. Removing or replacing it manually may be necessary.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full version history.

---

## Credits

- **Google** — Original Gemini animation from the Pixel 10
- **docbt** — Porting & Magisk module packaging

---

## License

This project is licensed under the [MIT License](LICENSE).

> The boot animation itself is the property of Google LLC.
> This port is provided for personal, non-commercial use only.

---

<div align="center">

Made with love for the Android community

⭐ If you like this module, consider leaving a star!

</div>

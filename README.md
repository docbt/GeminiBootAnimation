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
- Compatible with **all Android versions**
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
| Android Version | All versions supported |
| Architecture | arm64-v8a, armeabi-v7a |

---

## Installation

Download the latest `.zip` from [**Releases**](https://github.com/docbt/GeminiBootAnimation/releases/latest), then follow the instructions for your root solution below.

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

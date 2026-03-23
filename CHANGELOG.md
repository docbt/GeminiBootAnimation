# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.2.0] - 2026-03-23

### Added
- Automatic environment detection at install time (Magisk / KernelSU / KernelSU+SUSFS)
- `service.sh` fallback: writes animation files directly to the partition on ROMs where dm-verity is disabled (e.g. crDroid + KernelSU + SUSFS)
- `system/product/media/` added as additional magic-mount target

### Fixed
- Animation not applying on KernelSU + SUSFS setups (SUSFS hides magic-mount overlays from system processes)
- `bootanimation-dark.zip` not being overlaid when the original ROM file is 0 bytes

### Changed
- Removed `post-fs-data.sh` bind-mount approach (blocked by SELinux on most devices)
- Installer now shows detected root implementation during install

---

## [1.0.0] - 2026-03-22

### Added
- Initial release
- Gemini Boot Animation ported from Google Pixel 10
- Support for Magisk, KernelSU, and APatch
- Compatible with all Android versions

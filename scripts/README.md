# PC Build Reality Pack

A set of scripts and notes to make your *real-world* Windows build smooth, fast, and tested — without paying for expensive benchmarks.

> Tested on Windows 11. Most scripts require **PowerShell (Run as Administrator)**.

## What's inside

- `slipstream-drivers.ps1` — Inject motherboard/LAN/NVMe/NVIDIA drivers into a Windows ISO using DISM (boot.wim + install.wim).
- `install-free-tools.ps1` — Installs essential free utilities via **winget**.
- `move-temp-and-pagefile.ps1` — Moves TEMP/TMP and sets a pagefile on another drive (e.g., D:\) with sensible defaults.
- `move-known-folders.ps1` — Moves Documents/Downloads/Desktop/etc. to another drive.
- `stress-test-runner.bat` — One-click launcher to run common free stress tests (after tools installed).
- `verify-hardware.ps1` — Quick inventory: CPU, RAM map/dual-channel, disks, PCIe lanes, GPU driver, SMART basics.
- `create-boot-usb.txt` — Notes for creating a bootable USB with Rufus or DiskPart.
- `fan-curve-guide.md` — Generic guidance for PWM/DC, hubs vs splitters, and positive pressure.
- `nvidia-clean-install.md` — Optional “clean install” steps (DDU) if swapping GPUs.
- `post-install-checklist.md` — A concise, printable checklist to go from first boot → stable system.
- `license.txt` — MIT license.

## Quick start

1. **Install tools:** Run PowerShell as admin, then:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\install-free-tools.ps1
   ```

2. **(Optional) Move TEMP/Pagefile/known folders** (after you have D:\ or another SSD):
   ```powershell
   .\move-temp-and-pagefile.ps1 -TargetDrive 'D'
   .\move-known-folders.ps1 -TargetDrive 'D'
   ```

3. **Stress test:**
   ```bat
   stress-test-runner.bat
   ```

## Notes
- Winget package IDs can change. If a package fails, open the script and adjust the ID (the script prints missing ones).
- DISM slipstream requires mounting ISOs and plenty of free disk space.
- Run scripts **one at a time** and reboot when asked.

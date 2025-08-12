@echo off
echo === Stress Test Runner ===
echo Ensure you've run 'install-free-tools.ps1' first.
echo.

echo 1) CPU: Prime95 small FFTs (30-60 min)
echo 2) CPU/Mem/VRM: OCCT mixed (30 min)
echo 3) GPU: FurMark (20-30 min, watch temps)
echo 4) Disk: CrystalDiskMark (run manually per drive)
echo 5) Monitoring: OpenHardwareMonitor / HWMonitor
echo.

pause

REM Launch tools if installed via winget (default paths vary)
start "" "C:\Program Files\Prime95\prime95.exe"
start "" "C:\Program Files\OCBASE\OCCT\occt.exe"
start "" "C:\Program Files\Geeks3D\FurMark\FurMark.exe"
start "" "C:\Program Files\CPUID\HWMonitor\HWMonitor.exe"

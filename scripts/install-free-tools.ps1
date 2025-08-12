# Installs essential free tools via winget. Run as Administrator.
$packages = @(
  "CPUID.CPU-Z",
  "TechPowerUp.GPU-Z",
  "CPUID.HWMonitor",        # fallback if HWiNFO not available
  "realhuhn.OpenHardwareMonitor", # community fork if HWiNFO unavailable
  "OCBASE.OCCT",
  "Prime95.Prime95",
  "Geeks3D.FurMark",
  "CrystalDewWorld.CrystalDiskInfo",
  "CrystalDewWorld.CrystalDiskMark",
  "7zip.7zip",
  "VideoLAN.VLC",
  "Microsoft.PowerShell",   # latest pwsh
  "Google.Chrome"
)

Write-Host "Installing packages via winget..."
foreach ($p in $packages) {
  try {
    winget install --id $p --silent --accept-package-agreements --accept-source-agreements -e
  } catch {
    Write-Warning "Failed to install $p. Adjust ID or install manually."
  }
}

Write-Host "Done. Consider installing HWiNFO (winget id: REALiX.HWiNFO) if available in your region/source."

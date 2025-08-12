param([Parameter(Mandatory=$true)][ValidatePattern('^[A-Z]$')][string]$TargetDrive)

# Moves TEMP/TMP for machine and user to the target drive (creates TargetDrive:\Temp)
# Sets pagefile on TargetDrive and disables on C: (system managed size by default).
# Run as Administrator. Reboot afterward.

function Ensure-Admin {
  if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    throw "Run this script in an elevated PowerShell window (Run as Administrator)."
  }
}

Ensure-Admin

$root = "$TargetDrive:\Temp"
New-Item -ItemType Directory -Path $root -ErrorAction SilentlyContinue | Out-Null

# System TEMP/TMP
[Environment]::SetEnvironmentVariable("TEMP", $root, "Machine")
[Environment]::SetEnvironmentVariable("TMP",  $root, "Machine")

# Current user TEMP/TMP
[Environment]::SetEnvironmentVariable("TEMP", $root, "User")
[Environment]::SetEnvironmentVariable("TMP",  $root, "User")

# Pagefile config: disable on C:, enable system-managed on target
wmic computersystem set AutomaticManagedPagefile=False | Out-Null
try { wmic pagefileset where name="C:\\pagefile.sys" delete | Out-Null } catch {}
$targetPath = "$TargetDrive:\\pagefile.sys"
wmic pagefileset create name="$targetPath" | Out-Null
wmic pagefileset where name="$TargetDrive:\\pagefile.sys" set InitialSize=0,MaximumSize=0 | Out-Null

Write-Host "TEMP/TMP moved to $root"
Write-Host "Pagefile moved to $TargetDrive: (system managed). Reboot to apply."

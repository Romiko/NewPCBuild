<#
.SYNOPSIS
    Inject drivers into a Windows install.wim by working on a temp copy, then copying back to an NTFS USB.

.DESCRIPTION
    - Verifies that the USB WIM path is on an NTFS volume.
    - Copies install.wim from USB to %TEMP%.
    - Lists editions and prompts for Index (unless provided).
    - Mounts the temp WIM, injects one or more driver folders (recursively), commits.
    - Copies the updated WIM back to the USB.
    - Tip of the day: Run the NVidia Install Game Ready, however do not proceed, copy the contents of the extracted files first to D:\drivers\NvidiaDrivers\Display.Driver
    - NVidia drivers are huge, not necessary but great if you want to smooth Windows Install experience. You can always install it later.

.PARAMETER UsbWimPath
    Path to the install.wim on your USB (must be on NTFS).

.PARAMETER DriverPaths
    One or more directories containing .inf-based drivers (recursed automatically).

.PARAMETER Index
    Optional WIM image index to service.

.PARAMETER MountDir
    Where to mount the WIM (must be empty). Default: $env:TEMP\WimMount

.PARAMETER WorkWimPath
    Temp working copy path for the WIM. Default: $env:TEMP\install_work.wim

.EXAMPLE
    .\inject-wimDrivers -UsbWimPath 'J:\sources\install.wim' -DriverPaths 'D:\drivers\NvidiaDrivers\Display.Driver','D:\drivers\MS870EAMD'
    .\inject-wimDrivers -UsbWimPath 'J:\sources\install.wim' -DriverPaths 'D:\drivers\MS870EAMD'

.NOTES
    Requires elevated PowerShell.
#>

[CmdletBinding()]
param(
    [string]$UsbWimPath = 'J:\sources\install.wim',
    [string[]]$DriverPaths,
    [int]$Index,
    [string]$MountDir = (Join-Path $env:TEMP 'WimMount'),
    [string]$WorkWimPath = (Join-Path $env:TEMP 'install_work.wim')
)

function Write-Section($Text) { Write-Host "`n==== $Text ====" -ForegroundColor Cyan }
function ThrowIfFailed($Code, $Context) { if ($Code -ne 0) { throw "$Context failed with exit code $Code." } }
function Ensure-Elevated {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        throw "Please run this script as Administrator."
    }
}

try {
    Ensure-Elevated

    if (-not (Test-Path $UsbWimPath)) { throw "WIM not found: $UsbWimPath" }

    # Check volume format
    $driveLetter = (Split-Path $UsbWimPath -Qualifier).TrimEnd('\')
    $vol = Get-Volume -DriveLetter $driveLetter.TrimEnd(':')
    if ($vol.FileSystem -ne 'NTFS') {
        throw "The USB drive must be formatted as NTFS. Current: $($vol.FileSystem)"
    }

    # Validate driver paths
    foreach ($dp in $DriverPaths) {
        if (-not (Test-Path $dp)) { throw "Driver path not found: $dp" }
    }

    # Prepare mount dir
    if (Test-Path $MountDir) {
        if (Get-ChildItem $MountDir -Force | Where-Object { $_.Name -notmatch '^\.\.?$' }) {
            throw "MountDir '$MountDir' must be empty."
        }
    } else {
        New-Item -ItemType Directory -Path $MountDir | Out-Null
    }

    # Copy WIM to temp
    Write-Section "Copying WIM to temp"
    Copy-Item -Path $UsbWimPath -Destination $WorkWimPath -Force

    # Get index if not supplied
    if (-not $Index) {
        Write-Section "Available WIM indexes"
        & dism /Get-WimInfo /WimFile:$WorkWimPath
        ThrowIfFailed $LASTEXITCODE "Get-WimInfo"
        $Index = Read-Host "Enter the index number to service"
        if (-not ($Index -as [int])) { throw "Invalid index." }
    }

    # Mount
    Write-Section "Mounting index $Index"
    & dism /Mount-WIM /WimFile:$WorkWimPath /Index:$Index /MountDir:$MountDir
    ThrowIfFailed $LASTEXITCODE "Mount-WIM"

    # Inject drivers
    Write-Section "Injecting drivers"
    foreach ($dp in $DriverPaths) {
        & dism /Image:$MountDir /Add-Driver /Driver:$dp /Recurse
        ThrowIfFailed $LASTEXITCODE "Add-Driver ($dp)"
    }

    # Commit & unmount
    Write-Section "Committing changes"
    & dism /Unmount-WIM /MountDir:$MountDir /Commit
    ThrowIfFailed $LASTEXITCODE "Unmount-WIM /Commit"

    # Copy back to USB
    Write-Section "Ready to copy updated WIM back to USB"
    $answer = Read-Host "Do you want to overwrite '$UsbWimPath' with the updated WIM? (Y/N)"
    if ($answer -match '^[Yy]') {
        Copy-Item -Path $WorkWimPath -Destination $UsbWimPath -Force
        Write-Host "Updated WIM copied back to USB." -ForegroundColor Green
    }
    else {
        Write-Host "Copy back to USB skipped. Updated WIM remains at: $WorkWimPath" -ForegroundColor Yellow
    }
}
catch {
    Write-Error $_
}

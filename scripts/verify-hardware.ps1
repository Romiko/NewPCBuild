# Quick inventory/verification helper
Write-Host "=== System Summary ==="
Get-ComputerInfo | Select-Object OsName,OsVersion,CsName,WindowsVersion,WindowsBuildLabEx | Format-List

Write-Host "`n=== CPU ==="
Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List

Write-Host "`n=== Memory (DIMMs) ==="
Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel,DeviceLocator,Capacity,Speed,ConfiguredClockSpeed,Manufacturer,PartNumber | Format-Table -AutoSize

Write-Host "`nTip: Ensure dual-channel by populating A2/B2 (check motherboard manual)."

Write-Host "`n=== Disks / NVMe ==="
Get-PhysicalDisk | Select-Object FriendlyName,MediaType,BusType,Size,HealthStatus | Format-Table -AutoSize
wmic diskdrive get model,serialnumber,Size,InterfaceType

Write-Host "`n=== GPU & Driver ==="
Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,DriverDate | Format-Table -AutoSize

Write-Host "`n=== Network ==="
Get-CimInstance Win32_NetworkAdapter | Where-Object {$_.PhysicalAdapter -eq $true} | Select-Object Name,Speed,MACAddress,AdapterType | Format-Table -AutoSize

Write-Host "`n=== PCIe Links (summary - may require vendor tools for detailed lanes) ==="
# Basic check via Win32_PnPEntity; for deep lane width check use GPU-Z / HWInfo
Get-PnpDevice -Class Display,Net,Storage,System | Select-Object Class, FriendlyName, Status | Format-Table -AutoSize

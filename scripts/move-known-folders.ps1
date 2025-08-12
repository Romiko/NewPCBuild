param([Parameter(Mandatory=$true)][ValidatePattern('^[A-Z]$')][string]$TargetDrive)

# Moves Known Folders (Documents/Downloads/Desktop/Pictures/Videos/Music) to <TargetDrive>:\Users\<User>\...
# Safer than full profile move. Run as current user (no admin needed).
$Shell = New-Object -ComObject Shell.Application
$map = @{
  'Desktop'   = [Environment]::GetFolderPath('Desktop')
  'Documents' = [Environment]::GetFolderPath('MyDocuments')
  'Downloads' = [Environment]::GetFolderPath('Downloads')
  'Pictures'  = [Environment]::GetFolderPath('MyPictures')
  'Music'     = [Environment]::GetFolderPath('MyMusic')
  'Videos'    = [Environment]::GetFolderPath('MyVideos')
}

$user = $env:USERNAME
foreach ($k in $map.Keys) {
  $current = $map[$k]
  $target = Join-Path "$TargetDrive`:" "Users\$user\$k"
  New-Item -ItemType Directory -Path $target -ErrorAction SilentlyContinue | Out-Null
  Write-Host "Moving $k to $target"
  # Update via registry Location
  $known = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
  $name = switch ($k) {
    'Desktop'   { 'Desktop' }
    'Documents' { 'Personal' }
    'Downloads' { '{374DE290-123F-4565-9164-39C4925E467B}' }
    'Pictures'  { 'My Pictures' }
    'Music'     { 'My Music' }
    'Videos'    { 'My Video' }
  }
  Set-ItemProperty -Path $known -Name $name -Value $target
}
Write-Host "Log off and back on (or reboot) to apply folder relocations."

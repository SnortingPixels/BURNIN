<#
  BURNIN - Windows uninstaller.
  Stops the theme helper, removes its Startup entry, restores Windows Terminal's settings.json from the
  backup made at install, and removes the Windhawk menu and burn-in mods if it installed them (asks for admin).
  Fonts stay installed (other apps may use them); remove them in Settings > Personalization > Fonts.
#>
param([string]$SettingsPath = '', [switch]$KeepFiles)
$ErrorActionPreference = 'Stop'
$InstallDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like "*$InstallDir\theme-sync.ps1*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Remove-Item (Join-Path ([Environment]::GetFolderPath('Startup')) 'CRT Terminal Theme Sync.lnk') -ErrorAction SilentlyContinue
Write-Host 'Theme helper stopped and removed from Startup.'

if (-not $SettingsPath) {
  $SettingsPath = @("$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
                    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
                    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json") | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if ($SettingsPath) {
  # the oldest backup is the settings from before the first install
  $backup = Get-ChildItem "$SettingsPath.crt-backup-*" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1
  if ($backup) {
    Copy-Item $SettingsPath "$SettingsPath.crt-before-uninstall" -Force
    Copy-Item $backup.FullName $SettingsPath -Force
    Write-Host "Windows Terminal settings restored from $($backup.Name) (current ones kept as settings.json.crt-before-uninstall)."
  } else {
    Write-Host 'No install backup of Windows Terminal settings found; settings left as they are.'
  }
}

$modKey = 'HKLM:\SOFTWARE\Windhawk\Engine\Mods\local@windows-terminal-retro-styler'
# only if this installation installed it (marker written by install.ps1 -WithMenus)
if ((Test-Path $modKey) -and (Test-Path "$InstallDir\windhawk\mod-installed.txt")) {
  Write-Host 'Removing the Windhawk menu mod (Windows will ask for admin)...'
  Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', "Remove-Item '$modKey' -Recurse -Force"
}
$burnKey = 'HKLM:\SOFTWARE\Windhawk\Engine\Mods\local@burnin-phosphor'
# only if this installation installed it (marker written by install.ps1 -WithBurnIn)
if ((Test-Path $burnKey) -and (Test-Path "$InstallDir\windhawk\burnin-installed.txt")) {
  Write-Host 'Removing the Windhawk burn-in mod (Windows will ask for admin)...'
  Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', "Remove-Item '$burnKey' -Recurse -Force"
}

if (-not $KeepFiles) {
  Set-Location $env:TEMP
  Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host "Removed $InstallDir."
}
Write-Host 'Done. Restart Windows Terminal.'

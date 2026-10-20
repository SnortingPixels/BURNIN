# CRT Terminal Themes - one-line Windows install:
#     irm https://raw.githubusercontent.com/SnortingPixels/crt-terminal-themes/main/install.ps1 | iex
# Downloads this repository and runs windows\install.ps1.
# Options (set before running):  $env:CRT_THEME = 'Commodore 64'   $env:CRT_MENUS = '1'  (Windhawk menu styling)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$repo = 'SnortingPixels/crt-terminal-themes'
$tmp = Join-Path $env:TEMP ('crt-terminal-' + [guid]::NewGuid())
New-Item -ItemType Directory $tmp | Out-Null
try {
  Write-Host "Downloading $repo ..."
  Invoke-WebRequest "https://codeload.github.com/$repo/zip/refs/heads/main" -OutFile "$tmp\repo.zip" -UseBasicParsing
  Expand-Archive "$tmp\repo.zip" $tmp
  $src = Get-ChildItem $tmp -Directory | Select-Object -First 1
  Get-ChildItem $src.FullName -Recurse -File | Unblock-File
  $psArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "$($src.FullName)\windows\install.ps1")
  if ($env:CRT_THEME) { $psArgs += '-Theme', $env:CRT_THEME }
  if ($env:CRT_MENUS -eq '1') { $psArgs += '-WithMenus' }
  & powershell.exe @psArgs
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

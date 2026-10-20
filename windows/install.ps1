<#
  CRT Terminal Themes - Windows installer (Windows Terminal).
  Part of crt-terminal-themes, GPL-3.0. The CRT shader is a port of cool-retro-term's.

  Usually run by CRT-Terminal-Setup.exe or the one-line install.ps1 at the repository root.
  Direct use, from a downloaded copy of the repository:
      powershell -ExecutionPolicy Bypass -File windows\install.ps1 [-Theme "Default Amber"] [-WithMenus]

  What it does (per user, no admin unless -WithMenus):
    1. copies the shaders and scripts to %LOCALAPPDATA%\CRT-Terminal
    2. downloads the fonts from their original sources and installs them for this user
       (the ZX Spectrum / Amstrad CPC / BBC teletext fonts are built from ROM data, which needs Python)
    3. backs up Windows Terminal's settings.json, then adds the colour scheme, one window theme per CRT
       theme ("Retro <dot> <name>") and the default profile settings, and selects -Theme
    4. starts the theme helper (theme switching from Settings > Appearance > Theme, Ctrl+Alt+T / Ctrl+Alt+B)
       and adds it to the Startup folder
    5. -WithMenus: installs Windhawk (winget) and the menu-styling mod; both ask for admin
#>
param(
  [string]$InstallDir = "$env:LOCALAPPDATA\CRT-Terminal",
  [string]$Theme = 'Default Amber',
  [switch]$WithMenus,
  [switch]$NoStartup,
  [string]$SettingsPath = '',    # testing: use this settings.json instead of Windows Terminal's
  [switch]$SkipFonts             # testing: don't download or install fonts
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Prefix = 'Retro ' + [char]0x00B7 + ' '   # window theme names: "Retro <middle dot> <theme>"
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36'

function Step([string]$m) { Write-Host "==> $m" -ForegroundColor DarkYellow }
function Note([string]$m) { Write-Host "    $m" }

# ---------------------------------------------------------------- Windows Terminal
if (-not $SettingsPath) {
  $SettingsPath = @("$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
                    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
                    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json") | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $SettingsPath -or -not (Test-Path $SettingsPath)) {
  throw "Windows Terminal's settings.json was not found. Install Windows Terminal (winget install Microsoft.WindowsTerminal), open it once, then run this again."
}

# ---------------------------------------------------------------- 1. files
Step "Copying files to $InstallDir"
New-Item -ItemType Directory -Force $InstallDir, "$InstallDir\windhawk", "$InstallDir\fontbuild" | Out-Null
Copy-Item "$repo\dist" $InstallDir -Recurse -Force
Copy-Item "$repo\themes\themes.json" "$InstallDir\themes.json" -Force
foreach ($f in 'theme-sync.ps1', 'uninstall.ps1', 'check-shaders.ps1') { Copy-Item "$repo\windows\$f" $InstallDir -Force }
Copy-Item "$repo\windows\windhawk\*" "$InstallDir\windhawk" -Force
Copy-Item "$repo\src\retro_fonts.py" "$InstallDir\fontbuild" -Force
$data = Get-Content "$InstallDir\themes.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$index = (Get-Content "$InstallDir\dist\themes-index.json" -Raw -Encoding UTF8 | ConvertFrom-Json).themes
if (-not ($index | Where-Object name -eq $Theme)) { throw "Unknown theme '$Theme'. Themes: $(($index.name) -join ', ')" }

# ---------------------------------------------------------------- 2. fonts
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$fontKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
if (-not ('CrtFontApi' -as [type])) {
  Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public static class CrtFontApi { [DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern int AddFontResource(string f); }'
}
function Install-FontFile([string]$path) {
  $dest = Join-Path $fontDir (Split-Path $path -Leaf)
  Copy-Item $path $dest -Force
  $kind = if ($dest -like '*.otf') { 'OpenType' } else { 'TrueType' }
  New-ItemProperty $fontKey -Name "$([IO.Path]::GetFileNameWithoutExtension($dest)) ($kind)" -Value $dest -PropertyType String -Force | Out-Null
  [void][CrtFontApi]::AddFontResource($dest)
}
if ($SkipFonts) {
  Step 'Skipping fonts (-SkipFonts)'
} else {
  Step 'Installing fonts for this user (downloaded from their original sources)'
  New-Item -ItemType Directory -Force $fontDir | Out-Null
  $tmp = Join-Path $env:TEMP ('crt-fonts-' + [guid]::NewGuid())
  New-Item -ItemType Directory $tmp | Out-Null
  try {
    foreach ($p in $data.fonts.PSObject.Properties) {
      $spec = $p.Value
      if ($spec.build) { continue }
      $name = if ($spec.member) { Split-Path $spec.member -Leaf } else { Split-Path ([Uri]$spec.url).LocalPath -Leaf }
      if (Test-Path (Join-Path $fontDir $name)) { Note "$name (already installed)"; continue }
      $dl = Join-Path $tmp (Split-Path ([Uri]$spec.url).LocalPath -Leaf)
      Invoke-WebRequest $spec.url -OutFile $dl -UseBasicParsing -UserAgent $UA
      if ($spec.member) {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [IO.Compression.ZipFile]::OpenRead($dl)
        try { [IO.Compression.ZipFileExtensions]::ExtractToFile(($zip.Entries | Where-Object FullName -eq $spec.member | Select-Object -First 1), (Join-Path $tmp $name), $true) }
        finally { $zip.Dispose() }
        $dl = Join-Path $tmp $name
      }
      Install-FontFile $dl
      Note $name
    }

    # ROM-built fonts (ZX Spectrum, Amstrad CPC, BBC teletext): need Python + fontTools
    $need = @($data.fonts.PSObject.Properties | Where-Object { $_.Value.build -and -not (Test-Path (Join-Path $fontDir $_.Value.build)) })
    if ($need) {
      $py = (Get-Command py -ErrorAction SilentlyContinue).Source
      $pyArgs = @('-3')
      if (-not $py) { $py = (Get-Command python -ErrorAction SilentlyContinue).Source; $pyArgs = @() }
      if ($py -and $py -notlike '*WindowsApps*') {
        Note 'Building the ZX Spectrum, Amstrad CPC and BBC teletext fonts from their ROM data'
        $venv = "$InstallDir\fontbuild\venv"
        if (-not (Test-Path "$venv\Scripts\python.exe")) { & $py @pyArgs -m venv $venv }
        & "$venv\Scripts\python.exe" -m pip install --quiet --disable-pip-version-check fonttools
        $roms = "$InstallDir\fontbuild\roms"; New-Item -ItemType Directory -Force $roms | Out-Null
        foreach ($rp in $data.roms.PSObject.Properties) {
          if (-not (Test-Path "$roms\$($rp.Name)")) { Invoke-WebRequest $rp.Value -OutFile "$roms\$($rp.Name)" -UseBasicParsing -UserAgent $UA }
        }
        & "$venv\Scripts\python.exe" -I "$InstallDir\fontbuild\retro_fonts.py" "$roms\48.rom" "$roms\cpc464.rom" "$roms\teletext_data.js" "$InstallDir\fontbuild\out" | Out-Null
        foreach ($n in $need) { Install-FontFile "$InstallDir\fontbuild\out\$($n.Value.build)"; Note $n.Value.build }
      } else {
        Note 'Python not found: the ZX Spectrum, Amstrad CPC and BBC teletext themes will use a fallback font.'
        Note 'Install Python (winget install Python.Python.3.12) and run this installer again to build them.'
      }
    }
  } finally { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}

# ---------------------------------------------------------------- 3. Windows Terminal settings
Step "Updating Windows Terminal settings ($SettingsPath)"
$backup = "$SettingsPath.crt-backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
Copy-Item $SettingsPath $backup
Note "backup: $backup"
$j = Get-Content $SettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
function Ensure($obj, [string]$name, $value) { $obj | Add-Member -Force NoteProperty $name $value }
if (-not $j.profiles.defaults) { Ensure $j.profiles 'defaults' ([pscustomobject]@{}) }

# Terminal draws plain white-on-black text; the shader turns it into each theme's phosphor colours.
$scheme = [pscustomobject][ordered]@{
  name = 'Retro Source'; background = '#000000'; foreground = '#FFFFFF'; cursorColor = '#FFFFFF'; selectionBackground = '#808080'
  black = '#000000'; red = '#C50F1F'; green = '#13A10E'; yellow = '#C19C00'; blue = '#3B78FF'; purple = '#881798'; cyan = '#3A96DD'; white = '#CCCCCC'
  brightBlack = '#767676'; brightRed = '#E74856'; brightGreen = '#16C60C'; brightYellow = '#F9F1A5'; brightBlue = '#3B78FF'; brightPurple = '#B4009E'; brightCyan = '#61D6D6'; brightWhite = '#FFFFFF'
}
Ensure $j 'schemes' (@(@($j.schemes) | Where-Object { $_ -and $_.name -ne 'Retro Source' }) + $scheme)

$wtThemes = foreach ($t in $index) {
  [pscustomobject][ordered]@{
    name   = "$Prefix$($t.name)"
    window = [pscustomobject][ordered]@{ applicationTheme = $(if ($t.light) { 'light' } else { 'dark' }); useMica = $false; frame = $t.bg; unfocusedFrame = $t.bg; rainbowFrame = $false }
    tabRow = [pscustomobject][ordered]@{ background = $t.bg; unfocusedBackground = $t.bg }
    tab    = [pscustomobject][ordered]@{ background = $t.bg; unfocusedBackground = $t.bg; showCloseButton = 'hover'; iconStyle = 'monochrome' }
  }
}
Ensure $j 'themes' (@(@($j.themes) | Where-Object { $_ -and $_.name -notlike "$Prefix*" }) + @($wtThemes))
Ensure $j 'theme' "$Prefix$Theme"
Ensure $j 'useAcrylicInTabRow' $false
[IO.File]::WriteAllText($SettingsPath, ($j | ConvertTo-Json -Depth 32), (New-Object Text.UTF8Encoding $false))

$optFile = "$InstallDir\crt-options.json"
if (-not (Test-Path $optFile)) { Set-Content $optFile '{ "bulge": "historic" }' -Encoding ASCII }

# theme-sync applies the theme's shader, font, cursor and the fixed character cell to the default profile
& "$InstallDir\theme-sync.ps1" -Once -SettingsPath $SettingsPath
Note "theme: $Prefix$Theme"

# ---------------------------------------------------------------- 4. helper
if (-not $NoStartup) {
  Step 'Starting the theme helper (and adding it to Startup)'
  $lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'CRT Terminal Theme Sync.lnk'
  $ws = New-Object -ComObject WScript.Shell
  $sc = $ws.CreateShortcut($lnk)
  $sc.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
  $sc.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$InstallDir\theme-sync.ps1`""
  $sc.WindowStyle = 7
  $sc.Description = 'CRT Terminal Themes: theme switching, Ctrl+Alt+T / Ctrl+Alt+B, menu colours'
  $sc.Save()
  Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like "*$InstallDir\theme-sync.ps1*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
  Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', "$InstallDir\theme-sync.ps1"
}

# ---------------------------------------------------------------- 5. optional menus (Windhawk)
if ($WithMenus) {
  Step 'Installing the menu styling (Windhawk + mod; Windows will ask for admin)'
  if (-not (Test-Path "$env:ProgramFiles\Windhawk\windhawk.exe")) {
    winget install --id RamenSoftware.Windhawk --exact --silent --accept-package-agreements --accept-source-agreements
  }
  if (Test-Path "$env:ProgramFiles\Windhawk\windhawk.exe") {
    & "$InstallDir\windhawk\build-mod.ps1" | Out-Null
    Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "$InstallDir\windhawk\install-mod.ps1", '-ColorsFile', "$InstallDir\ui-current.txt"
    $result = Get-Content "$InstallDir\windhawk\install-mod.log" -ErrorAction SilentlyContinue | Select-String '^OK|FAILED'
    $result | ForEach-Object { Note $_.Line }
    # marker: this installation installed the mod, so its uninstaller may remove it
    if ($result -and $result[-1].Line -eq 'OK') { Set-Content "$InstallDir\windhawk\mod-installed.txt" 'local@windows-terminal-retro-styler' -Encoding ASCII }
  } else {
    Note 'Windhawk was not installed, so the menu styling was skipped.'
  }
}

Step 'Done'
Note "Pick a look: Windows Terminal > Settings > Appearance > Theme > ""$Prefix..."""
Note 'Shortcuts while Terminal is in front: Ctrl+Alt+T next theme, Ctrl+Alt+Shift+T previous, Ctrl+Alt+B screen bulge on/off'
Note 'Restart Windows Terminal once so it loads the new fonts.'
Note "Uninstall: powershell -ExecutionPolicy Bypass -File `"$InstallDir\uninstall.ps1`""

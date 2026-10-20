# Compiles and installs the "Windows Terminal Retro Styler" Windhawk mod, the same way
# Windhawk's own editor does (bundled clang, Engine\Mods\64, HKLM\SOFTWARE\Windhawk\Engine\Mods).
# Must run as administrator. Output goes to install-mod.log next to this script.
param(
  [string]$ModId = 'local@windows-terminal-retro-styler',
  [string]$Include = 'WindowsTerminal.exe',
  [string]$ColorsFile = '',          # empty = the default themes\ui-current.txt
  [string]$LogName = 'install-mod.log',
  [string]$ModLogFile = ''          # test builds: the mod mirrors its log into this file
)
$ErrorActionPreference = 'Stop'
$here   = Split-Path -Parent $MyInvocation.MyCommand.Path
$logF   = Join-Path $here $LogName
Start-Transcript -Path $logF -Force | Out-Null
try {
  $wh      = "$env:ProgramFiles\Windhawk"
  $ini     = Get-Content "$wh\windhawk.ini"
  $engine  = Join-Path $wh (($ini | Where-Object { $_ -like 'EnginePath=*' }) -replace '^EnginePath=', '')
  $data    = "$env:ProgramData\Windhawk"
  $modId   = $ModId
  $version = '1.0'
  $src     = Join-Path $here 'windows-terminal-retro-styler.wh.cpp'
  $modsDir = Join-Path $data 'Engine\Mods\64'
  $regKey  = "HKLM:\SOFTWARE\Windhawk\Engine\Mods\$modId"
  New-Item -ItemType Directory -Force $modsDir | Out-Null

  # 1. compile (flags copied from Windhawk's editor)
  $dllName = '{0}_{1}_{2}.dll' -f $modId, $version, (Get-Random -Minimum 100000 -Maximum 999999)
  $dll = Join-Path $modsDir $dllName
  $args = @('-std=c++23', '-O2', '-shared', '-DUNICODE', '-D_UNICODE', '-DWINVER=0x0A00', '-D_WIN32_WINNT=0x0A00',
            '-D_WIN32_IE=0x0A00', '-DNTDDI_VERSION=0x0A000008', '-D__USE_MINGW_ANSI_STDIO=0', '-DWH_MOD',
            "-DWH_MOD_ID=L\`"$modId\`"", "-DWH_MOD_VERSION=L\`"$version\`"", (Join-Path $engine '64\windhawk.lib'),
            '-x', 'c++', $src, '-include', 'windhawk_api.h', '-target', 'x86_64-w64-mingw32', '-Wl,--export-all-symbols',
            '-o', $dll, '-lcomctl32', '-lole32', '-loleaut32', '-lruntimeobject')
  if ($ColorsFile) { $args += ('-DRETRO_COLORS_FILE=L\"' + $ColorsFile.Replace('\', '\\') + '\"') }
  if ($ModLogFile) { $args += ('-DRETRO_LOG_FILE=L\"' + $ModLogFile.Replace('\', '\\') + '\"') }
  Push-Location "$wh\Compiler"
  try { & "$wh\Compiler\bin\clang++.exe" @args 2>&1 | Out-Host; $code = $LASTEXITCODE } finally { Pop-Location }
  if ($code -ne 0 -or -not (Test-Path $dll)) { throw "compile failed (exit $code)" }
  "compiled $dllName"

  # 2. runtime libraries next to the mod (as the editor's copyCompilerLibs does)
  $libSrc = "$wh\Compiler\x86_64-w64-mingw32\bin"
  foreach ($pair in @(@('libc++.dll', 'libc++.whl'), @('libunwind.dll', 'libunwind.whl'), @('windhawk-mod-shim.dll', 'windhawk-mod-shim.dll'))) {
    $from = Join-Path $libSrc $pair[0]; $to = Join-Path $modsDir $pair[1]
    if (-not (Test-Path $to) -or (Get-Item $to).LastWriteTimeUtc -ne (Get-Item $from).LastWriteTimeUtc) { Copy-Item $from $to -Force }
  }

  # 3. source, so the mod shows up in Windhawk's UI
  $srcDir = Join-Path $data 'ModsSource'
  New-Item -ItemType Directory -Force $srcDir | Out-Null
  Copy-Item $src (Join-Path $srcDir "$modId.wh.cpp") -Force

  # 4. registry config; the engine picks this up and loads the mod into Windows Terminal
  $oldDll = (Get-ItemProperty $regKey -ErrorAction SilentlyContinue).LibraryFileName
  New-Item -Path $regKey -Force | Out-Null
  New-ItemProperty $regKey -Name LibraryFileName -Value $dllName -PropertyType String -Force | Out-Null
  New-ItemProperty $regKey -Name Disabled -Value 0 -PropertyType DWord -Force | Out-Null
  New-ItemProperty $regKey -Name LoggingEnabled -Value 0 -PropertyType DWord -Force | Out-Null
  New-ItemProperty $regKey -Name Include -Value $Include -PropertyType String -Force | Out-Null
  New-ItemProperty $regKey -Name Architecture -Value 'x86-64' -PropertyType String -Force | Out-Null
  New-ItemProperty $regKey -Name Version -Value $version -PropertyType String -Force | Out-Null
  if ($oldDll -and $oldDll -ne $dllName) { Remove-Item (Join-Path $modsDir $oldDll) -Force -ErrorAction SilentlyContinue }
  "registered $modId"
  'OK'
} catch {
  "FAILED: $_"
} finally {
  Stop-Transcript | Out-Null
}

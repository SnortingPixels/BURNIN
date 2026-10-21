# Makes Windows Terminal's Settings > Appearance > Theme switch the whole look.
# Checks settings.json twice a second; when "theme" is a "<name> <fire emoji>" theme, sets the default
# profile's CRT shader, colour scheme, font and cursor to match (Terminal then re-skins every open
# tab), and writes themes\ui-current.txt, the menu/Settings-page colours read by the Windhawk mod
# "Windows Terminal Retro Styler" (optional). Any other theme turns all of it off again.
# While a Terminal window is focused: Ctrl+Alt+T = next theme, Ctrl+Alt+Shift+T = previous theme,
# Ctrl+Alt+B = historic screen bulge on/off (crt-options.json).
# Part of BURNIN (GPL-3.0). Runs hidden from the Startup folder. -Once applies the current theme and exits.
param([switch]$Once, [int]$Cycle = 0, [string]$UiFor = '', [string]$UiOut = '', [string]$SettingsPath = '')   # -UiFor <theme> -UiOut <file>: write that theme's menu colours to a file (testing)   # -Cycle 1 / -1: step the theme once and exit
$ErrorActionPreference = 'Stop'
$Suffix = ' ' + [char]::ConvertFromUtf32(0x1F525)   # window theme names: "<theme> <fire emoji>"
$root     = Split-Path -Parent $MyInvocation.MyCommand.Path   # the install folder (holds dist\ and this script)
# Windows Terminal settings: -SettingsPath, else the Store, Preview or unpackaged install
$settings = if ($SettingsPath) { $SettingsPath } else { @("$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
              "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
              "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json") | Where-Object { Test-Path $_ } | Select-Object -First 1 }
if (-not $settings) { throw 'Windows Terminal settings.json not found; open Windows Terminal once, then run this again.' }
$uiFile   = Join-Path $root 'ui-current.txt'
$options  = Join-Path $root 'crt-options.json'   # { "bulge": "historic" | "flat" }, toggled with Ctrl+Alt+B
$log      = Join-Path $root 'theme-sync.log'

function Log([string]$m) { Add-Content -Path $log -Value ('{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $m) -Encoding UTF8 }

function ReadText {
  for ($i = 0; $i -lt 20; $i++) {
    try { return [IO.File]::ReadAllText($settings, [Text.Encoding]::UTF8) } catch { Start-Sleep -Milliseconds 150 }
  }
  throw 'settings.json stayed locked'
}

function WriteText([string]$path, [string]$text) {
  if ($path -eq $settings) {
    # Safety net: never write a settings file that has lost the colour scheme or the window themes,
    # and keep the previous version next to it (settings.json.crt-prev).
    if ($text -notmatch '"Retro Source"' -or $text -notmatch '(\uD83D\uDD25|\\ud83d\\udd25)"') {
      Log 'refused to write settings.json: Retro Source scheme or BURNIN window themes missing'
      return
    }
    Copy-Item $settings "$settings.crt-prev" -Force -ErrorAction SilentlyContinue
  }
  for ($i = 0; $i -lt 20; $i++) {
    try { [IO.File]::WriteAllText($path, $text, (New-Object Text.UTF8Encoding $false)); return } catch { Start-Sleep -Milliseconds 150 }
  }
  throw "could not write $path"
}

function SetProp($obj, [string]$name, $value) {
  if ($null -eq $value) { if ($obj.PSObject.Properties[$name]) { $obj.PSObject.Properties.Remove($name) } }
  else { $obj | Add-Member -Force NoteProperty $name $value }
}

# dist\themes-index.json (built by src/build.py) -> one object per theme with the paths and values the helper uses.
function LoadIndex {
  $all = (Get-Content (Join-Path $root 'dist\themes-index.json') -Raw -Encoding UTF8 | ConvertFrom-Json).themes
  foreach ($e in $all) {
    [pscustomobject]@{
      name = $e.name; font = $e.fontWindows; size = $e.size; cursor = $e.cursor; bg = $e.bg; fg = $e.fg; light = $e.light
      shader     = Join-Path $root "dist\windows-terminal\historic\$($e.slug).hlsl"
      shaderFlat = Join-Path $root "dist\windows-terminal\flat\$($e.slug).hlsl"
    }
  }
}

# --- menu / Settings-page colours for the Windhawk mod ---
function Rgb([string]$hex) { $h = $hex.TrimStart('#'); 0..2 | ForEach-Object { [Convert]::ToInt32($h.Substring($_ * 2, 2), 16) } }
function Mix([string]$a, [string]$b, [double]$t) {
  $x = Rgb $a; $y = Rgb $b
  '#FF' + ((0..2 | ForEach-Object { '{0:X2}' -f [int][Math]::Round($x[$_] + ($y[$_] - $x[$_]) * $t) }) -join '')
}
function UiColors($t) {
  # Text-mode look for Terminal's pop-up menus, tooltips and tab bar only: screen colour background,
  # phosphor text, 1 px phosphor border, inverted highlight, square corners, the theme's own font.
  # The Settings page is left stock: it can't get the CRT shader, so it is not styled at all.
  $bg = $t.bg; $fg = $t.fg
  $c = [ordered]@{ screen = Mix $bg $bg 0; phosphor = Mix $fg $fg 0; dim = Mix $bg $fg 0.72; line = Mix $bg $fg 0.4; pressed = Mix $bg $fg 0.75 }
  $map = [ordered]@{
    screen   = 'MenuFlyoutPresenterBackground','AcrylicInAppFillColorDefaultBrush','ToolTipBackground',
               'MenuFlyoutItemForegroundPointerOver','MenuFlyoutItemForegroundPressed','MenuFlyoutSubItemForegroundPointerOver',
               'MenuFlyoutSubItemForegroundSubMenuOpened','MenuFlyoutItemKeyboardAcceleratorTextForegroundPointerOver'
    phosphor = 'MenuFlyoutItemForeground','MenuFlyoutSubItemForeground','MenuFlyoutSubItemChevron','ToolTipForeground',
               'MenuFlyoutPresenterBorderBrush','ToolTipBorderBrush',
               'MenuFlyoutItemBackgroundPointerOver','MenuFlyoutSubItemBackgroundPointerOver','MenuFlyoutSubItemBackgroundSubMenuOpened',
               'TabViewItemHeaderForeground','TabViewItemHeaderForegroundSelected','TabViewItemHeaderForegroundPointerOver',
               'TabViewItemIconForeground','TabViewItemIconForegroundSelected','TabViewButtonForeground','TabViewButtonForegroundPointerOver'
    pressed  = 'MenuFlyoutItemBackgroundPressed'
    dim      = 'MenuFlyoutItemKeyboardAcceleratorTextForeground'
    line     = 'MenuFlyoutSeparatorBackground'
  }
  # Brushes are replaced with a SolidColorBrush written as XAML ("Key:=..."), which also works where the
  # original is an acrylic brush; theme-sync's later changes recolour these same brushes in place.
  $lines = foreach ($k in $map.Keys) { foreach ($key in $map[$k]) { "${key}:=<SolidColorBrush Color=`"$($c[$k])`"/>" } }
  $lines += 'OverlayCornerRadius=0'   # pop-ups only
  # Theme font: on the main window page (tab titles inherit it) and on pop-up items, which sit outside it.
  foreach ($target in 'TerminalApp.TerminalPage', 'MenuFlyoutItem', 'ToggleMenuFlyoutItem', 'MenuFlyoutSubItem', 'ToolTip') {
    $lines += "@$target|FontFamily=$($t.font)"
  }
  # Theme-name label next to the minimize button (drawn by the same Windhawk mod)
  $lines += "!ThemeLabel=$($t.name)"
  $lines += "!ThemeLabelColor=$(Mix $bg $fg 0.85)"
  $lines += "!ThemeLabelFont=$($t.font)"
  ($lines -join "`r`n") + "`r`n"
}
function Apply {
  $index = LoadIndex
  $j = ReadText | ConvertFrom-Json
  $theme = if ($j.theme -is [string]) { $j.theme } else { '' }
  $d = $j.profiles.defaults
  $t = $index | Where-Object { "$($_.name)$Suffix" -eq $theme } | Select-Object -First 1

  # menu colours first (cheap, and independent of whether the profile needs rewriting)
  $ui = if ($t) { UiColors $t } else { '' }
  $old = if (Test-Path $uiFile) { [IO.File]::ReadAllText($uiFile) } else { $null }
  if ($old -ne $ui) { WriteText $uiFile $ui }

  # Same character cell, padding and scrollbar for every theme (retro or not), so the column/row count never
  # changes on a switch; a change leaves running programs (e.g. Claude Code sessions) sized for the old width.
  $ci = (Get-Content (Join-Path $root 'dist\themes-index.json') -Raw | ConvertFrom-Json).cell
  $cell = [pscustomobject]@{ width = "$($ci.width)px"; height = "$($ci.height)px"; plainFontSize = $ci.plainFontSize }
  if ($t) {
    $bulge = try { (Get-Content $options -Raw | ConvertFrom-Json).bulge } catch { 'historic' }
    $shader = if ($bulge -eq 'flat' -and $t.shaderFlat) { $t.shaderFlat } else { $t.shader }
    $want = @{ shader = $shader; scheme = 'Retro Source'; face = $t.font; size = $t.size; cursor = $t.cursor }
  } else {
    $want = @{ shader = $null; scheme = 'One Half Dark'; face = 'Cascadia Mono'; size = $cell.plainFontSize; cursor = $null }
  }
  $same = ($d.'experimental.pixelShaderPath' -eq $want.shader) -and ($d.colorScheme -eq $want.scheme) -and
          ($d.font.face -eq $want.face) -and ($d.font.size -eq $want.size) -and ($d.cursorShape -eq $want.cursor) -and
          ($d.font.cellWidth -eq $cell.width) -and ($d.font.cellHeight -eq $cell.height) -and
          ($d.padding -eq '0') -and ($d.scrollbarState -eq 'hidden') -and (-not $d.PSObject.Properties['tabColor'])
  if ($same) { return }

  SetProp $d 'experimental.pixelShaderPath' $want.shader
  SetProp $d 'colorScheme' $want.scheme
  SetProp $d 'cursorShape' $want.cursor
  SetProp $d 'tabColor' $null
  SetProp $d 'padding' '0'
  SetProp $d 'scrollbarState' 'hidden'
  SetProp $d 'font' ([pscustomobject][ordered]@{ face = $want.face; size = $want.size; cellWidth = $cell.width; cellHeight = $cell.height })
  WriteText $settings ($j | ConvertTo-Json -Depth 32)
  Log "applied '$theme'"
}

# Step to the next/previous BURNIN theme (from the current one, or the first).
function Cycle([int]$step) {
  $index = LoadIndex
  $text = ReadText
  $current = (($text | ConvertFrom-Json).theme) -as [string]
  $names = @($index | ForEach-Object { "$($_.name)$Suffix" })
  $i = [Array]::IndexOf($names, $current)
  $next = if ($i -lt 0) { $names[0] } else { $names[($i + $step + $names.Count) % $names.Count] }
  $escaped = $next.Replace('\', '\\').Replace('"', '\"')
  $new = [regex]::Replace($text, '"theme"\s*:\s*"[^"]*"', { param($m) '"theme":  "' + $escaped + '"' })
  if ($new -eq $text) { $o = $text | ConvertFrom-Json; $o | Add-Member -Force NoteProperty theme $next; $new = $o | ConvertTo-Json -Depth 32 }
  WriteText $settings $new
  Log "cycled to '$next'"
  Apply
}

# Ctrl+Alt+B: switch every theme between its historic screen bulge and flat.
function ToggleBulge {
  $cur = try { (Get-Content $options -Raw | ConvertFrom-Json).bulge } catch { 'historic' }
  $new = if ($cur -eq 'flat') { 'historic' } else { 'flat' }
  WriteText $options (ConvertTo-Json @{ bulge = $new })
  Log "bulge -> $new"
  # The per-theme profiles (BURNIN folder of the new-tab menu) follow the same setting.
  $j = ReadText | ConvertFrom-Json
  $from = if ($new -eq 'flat') { '\historic\' } else { '\flat\' }
  $to = if ($new -eq 'flat') { '\flat\' } else { '\historic\' }
  $changed = $false
  foreach ($p in @($j.profiles.list)) {
    $sp = $p.'experimental.pixelShaderPath'
    if ($sp -and "$($p.name)".EndsWith($Suffix) -and $sp.StartsWith($root) -and $sp.Contains($from)) {
      $p.'experimental.pixelShaderPath' = $sp.Replace($from, $to); $changed = $true
    }
  }
  if ($changed) { WriteText $settings ($j | ConvertTo-Json -Depth 32) }
  Apply
}

if ($Once) { Apply; return }
if ($Cycle) { Cycle $Cycle; return }
if ($UiFor) { $t = LoadIndex | Where-Object { $_.name -eq $UiFor } | Select-Object -First 1; if (-not $t) { throw "no theme $UiFor" }; WriteText $UiOut (UiColors $t); return }

$mutex = New-Object Threading.Mutex($false, 'Local\CrtTerminalThemeSync')
if (-not $mutex.WaitOne(0)) { return }   # already running

if (-not ('RetroHotkeys' -as [type])) {
  Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
public static class RetroHotkeys {
  [StructLayout(LayoutKind.Sequential)] struct MSG { public IntPtr hwnd; public uint message; public UIntPtr wParam; public IntPtr lParam; public uint time; public int x; public int y; }
  [DllImport("user32.dll")] static extern bool RegisterHotKey(IntPtr h, int id, uint mod, uint vk);
  [DllImport("user32.dll")] static extern bool UnregisterHotKey(IntPtr h, int id);
  [DllImport("user32.dll")] static extern bool PeekMessage(out MSG m, IntPtr h, uint min, uint max, uint remove);
  [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  const uint MOD_ALT = 1, MOD_CONTROL = 2, MOD_SHIFT = 4, MOD_NOREPEAT = 0x4000, VK_T = 0x54, VK_B = 0x42, WM_HOTKEY = 0x0312;
  static bool registered;
  // Hotkeys exist only while a Windows Terminal window is in front, so other apps keep Ctrl+Alt+T.
  public static void Update() {
    var sb = new StringBuilder(64);
    GetClassName(GetForegroundWindow(), sb, sb.Capacity);
    bool terminal = sb.ToString() == "CASCADIA_HOSTING_WINDOW_CLASS";
    if (terminal && !registered) {
      registered = RegisterHotKey(IntPtr.Zero, 1, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_T);
      RegisterHotKey(IntPtr.Zero, 3, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_B);
      RegisterHotKey(IntPtr.Zero, 2, MOD_CONTROL | MOD_ALT | MOD_SHIFT | MOD_NOREPEAT, VK_T);
    } else if (!terminal && registered) {
      UnregisterHotKey(IntPtr.Zero, 1); UnregisterHotKey(IntPtr.Zero, 2); UnregisterHotKey(IntPtr.Zero, 3); registered = false;
    }
  }
  // +1 next, -1 previous, 2 toggle bulge, 0 nothing pressed.
  public static int Poll() {
    MSG m; int r = 0;
    while (PeekMessage(out m, IntPtr.Zero, WM_HOTKEY, WM_HOTKEY, 1)) { int id = (int)m.wParam; r = id == 1 ? 1 : id == 2 ? -1 : 2; }
    return r;
  }
}
'@
}

if (-not ('RetroNudge' -as [type])) {
  Add-Type -TypeDefinition @'
using System; using System.Text; using System.Threading; using System.Runtime.InteropServices;
// Claude Code puts the session name in the window title. When it changes (a session switch), the
// newly shown session often keeps stale drawing until the terminal is resized, so nudge the window
// a little narrower and back: Claude Code gets a resize and repaints everything.
public static class RetroNudge {
  [StructLayout(LayoutKind.Sequential)] struct RECT { public int L, T, R, B; }
  [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int w, int hgt, uint flags);
  const uint SWP_NOMOVE = 0x2, SWP_NOZORDER = 0x4, SWP_NOACTIVATE = 0x10;
  static IntPtr lastWindow = IntPtr.Zero;
  static string lastName = null;
  static DateTime pendingAt = DateTime.MaxValue;
  // Title without Claude Code's leading spinner glyph and spaces.
  static string Name(string title) {
    int i = 0;
    while (i < title.Length && !char.IsLetterOrDigit(title[i])) i++;
    return title.Substring(i);
  }
  // Call every ~100 ms. Returns the session name when it nudged, else null.
  public static string Check() {
    IntPtr h = GetForegroundWindow();
    var cls = new StringBuilder(64); GetClassName(h, cls, cls.Capacity);
    if (cls.ToString() != "CASCADIA_HOSTING_WINDOW_CLASS") return null;
    var t = new StringBuilder(512); GetWindowText(h, t, t.Capacity);
    string name = Name(t.ToString());
    if (h != lastWindow) { lastWindow = h; lastName = name; pendingAt = DateTime.MaxValue; return null; }
    if (name != lastName) { lastName = name; pendingAt = DateTime.UtcNow.AddMilliseconds(120); return null; }
    if (DateTime.UtcNow < pendingAt) return null;
    pendingAt = DateTime.MaxValue;
    RECT r; if (!GetWindowRect(h, out r)) return null;
    int w = r.R - r.L, hgt = r.B - r.T;
    SetWindowPos(h, IntPtr.Zero, 0, 0, w - 30, hgt, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
    Thread.Sleep(60);
    SetWindowPos(h, IntPtr.Zero, 0, 0, w, hgt, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
    return name;
  }
}
'@
}

Log 'started'
try { Apply } catch { Log "error: $_" }
$last = (Get-Item $settings).LastWriteTimeUtc
$tick = 0
while ($true) {
  Start-Sleep -Milliseconds 100
  try {
    [RetroHotkeys]::Update()
    $step = [RetroHotkeys]::Poll()
    if ($step -eq 2) { ToggleBulge; $last = (Get-Item $settings).LastWriteTimeUtc; continue }
    if ($step -ne 0) { Cycle $step; $last = (Get-Item $settings).LastWriteTimeUtc; continue }
  } catch { Log "hotkey error: $_" }
  try { $n = [RetroNudge]::Check(); if ($n) { Log "repaint nudge after switching to '$n'" } } catch { Log "nudge error: $_" }

  if ((++$tick % 5) -ne 0) { continue }   # settings file: twice a second
  try { $now = (Get-Item $settings).LastWriteTimeUtc } catch { continue }
  if ($now -eq $last) { continue }
  Start-Sleep -Milliseconds 300   # let Terminal finish writing
  try { Apply } catch { Log "error: $_" }
  $last = (Get-Item $settings).LastWriteTimeUtc
}

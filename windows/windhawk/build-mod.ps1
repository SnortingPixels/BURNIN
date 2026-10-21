# Builds windows-terminal-retro-styler.wh.cpp from the Windhawk "Windows 11 Settings Styler" engine
# (m417z, GPL-3.0). The engine is used unchanged except:
#   - targets WindowsTerminal.exe; finds its XAML thread via CASCADIA_HOSTING_WINDOW_CLASS
#   - built-in Settings-app themes and the usage-stats ping are removed
#   - colour overrides come from %LOCALAPPDATA%\CRT-Terminal\ui-current.txt (written by theme-sync.ps1),
#     re-applied whenever that file changes
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$url  = 'https://raw.githubusercontent.com/ramensoftware/windhawk-mods/main/mods/windows-11-settings-styler.wh.cpp'
$src  = Join-Path $here 'upstream-windows-11-settings-styler.wh.cpp'
$ProgressPreference = 'SilentlyContinue'
if (-not (Test-Path $src)) { Invoke-WebRequest $url -OutFile $src -UseBasicParsing }
$L = [IO.File]::ReadAllLines($src)

function LineOf([string]$pattern, [int]$after = 0) {
  for ($i = $after; $i -lt $L.Count; $i++) { if ($L[$i] -match $pattern) { return $i } }
  throw "pattern not found: $pattern"
}

$headerEnd      = LineOf '^// ==/WindhawkModSettings=='
$themeStruct    = LineOf '^struct Theme \{'
$themeStructEnd = LineOf '^\};' $themeStruct
$targetThread   = LineOf '^std::atomic<DWORD> g_targetThreadId'

$header = @'
// ==WindhawkMod==
// @id              windows-terminal-retro-styler
// @name            Windows Terminal Retro Styler
// @description     Colours Windows Terminal's menus, dropdowns and Settings page to match the active "Retro" theme
// @version         1.0
// @author          local (engine by m417z)
// @include         WindowsTerminal.exe
// @architecture    x86-64
// @compilerOptions -lcomctl32 -lole32 -loleaut32 -lruntimeobject
// ==/WindhawkMod==

// Based on "Windows 11 Settings Styler" by m417z:
// https://github.com/ramensoftware/windhawk-mods/blob/main/mods/windows-11-settings-styler.wh.cpp
// Source code is published under The GNU General Public License v3.0.

// ==WindhawkModReadme==
/*
# Windows Terminal Retro Styler

Recolours Windows Terminal's own interface (menus, the new-tab dropdown, the
right-click menu, tooltips and the Settings page) with the colours of the
active "Retro" theme.

Colours are read from `%LOCALAPPDATA%\CRT-Terminal\ui-current.txt`, one
`ResourceKey=#AARRGGBB` per line. `theme-sync.ps1` rewrites that file when
the theme changes, and this mod re-applies it within a second. An empty file
restores the normal look.
*/
// ==/WindhawkModReadme==

// ==WindhawkModSettings==
/*
- controlStyles:
  - - target: ""
      $name: Target
    - styles: [""]
      $name: Styles
  $name: Control styles
- themeResourceVariables: [""]
  $name: Extra resource variables
  $description: >-
    "Key=Value" overrides, applied on top of the theme colours file.
*/
// ==/WindhawkModSettings==
'@ -split "`r?`n"

$out = New-Object System.Collections.Generic.List[string]
$out.AddRange([string[]]$header)
$out.AddRange([string[]]([IO.File]::ReadAllLines((Join-Path $here 'retro-log.inc.cpp'))))
for ($i = $headerEnd + 1; $i -le $themeStructEnd; $i++) { $out.Add($L[$i]) }   # includes + struct Theme
$out.Add('')
for ($i = $targetThread; $i -lt $L.Count; $i++) { $out.Add($L[$i]) }          # engine
$text = ($out -join "`n")

function Replace-Function([string]$text, [string]$signature, [string]$replacement) {
  $start = $text.IndexOf($signature)
  if ($start -lt 0) { throw "function not found: $signature" }
  $open = $text.IndexOf('{', $start); $depth = 0; $j = $open
  do { $c = $text[$j]; if ($c -eq '{') { $depth++ } elseif ($c -eq '}') { $depth-- }; $j++ } while ($depth -gt 0)
  $text.Substring(0, $start) + $replacement.Trim() + $text.Substring($j)
}

$process = @'
// Colours for the active Windows Terminal theme, written by theme-sync.ps1.
#ifndef RETRO_COLORS_FILE
#define RETRO_COLORS_FILE L"C:\\CRT-Terminal\\ui-current.txt"   // install-mod.ps1 always passes the real path
#endif
constexpr WCHAR kColorsFile[] = RETRO_COLORS_FILE;

std::vector<std::wstring> ReadColorsFile() {
    std::vector<std::wstring> lines;
    HANDLE file = CreateFile(kColorsFile, GENERIC_READ,
                             FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                             nullptr, OPEN_EXISTING, 0, nullptr);
    if (file == INVALID_HANDLE_VALUE) {
        return lines;
    }

    std::string data;
    char buffer[4096];
    DWORD read = 0;
    while (ReadFile(file, buffer, sizeof(buffer), &read, nullptr) && read) {
        data.append(buffer, read);
    }
    CloseHandle(file);

    if (data.size() >= 3 && (unsigned char)data[0] == 0xEF &&
        (unsigned char)data[1] == 0xBB && (unsigned char)data[2] == 0xBF) {
        data.erase(0, 3);
    }

    int wideLength = MultiByteToWideChar(CP_UTF8, 0, data.data(),
                                         (int)data.size(), nullptr, 0);
    std::wstring wide(wideLength, L'\0');
    MultiByteToWideChar(CP_UTF8, 0, data.data(), (int)data.size(),
                        wide.data(), wideLength);

    size_t start = 0;
    while (start < wide.size()) {
        size_t end = wide.find(L'\n', start);
        if (end == std::wstring::npos) {
            end = wide.size();
        }
        std::wstring line = wide.substr(start, end - start);
        while (!line.empty() && (line.back() == L'\r' || line.back() == L' ')) {
            line.pop_back();
        }
        if (!line.empty()) {
            lines.push_back(std::move(line));
        }
        start = end + 1;
    }

    return lines;
}

void ProcessAllStylesFromSettings() {
    StyleConstants styleConstants = LoadStyleConstants({});

    for (int i = 0;; i++) {
        try {
            if (!ProcessSingleTargetStylesFromSettings(i, styleConstants)) {
                break;
            }
        } catch (winrt::hresult_error const& ex) {
            Wh_Log(L"Error %08X: %s", ex.code(), ex.message().c_str());
        } catch (std::exception const& ex) {
            Wh_Log(L"Error: %S", ex.what());
        }
    }

    std::vector<std::wstring> fileLines = ReadColorsFile();
    std::vector<PCWSTR> fileVariables;
    for (const auto& line : fileLines) {
        // "!Key=Value" lines are for the theme-name label (UpdateThemeLabels), not styles.
        if (line.starts_with(L"!")) {
            continue;
        }
        // "@Target|Property=Value|Property=Value" adds control styles; anything else is a resource variable.
        if (line.starts_with(L"@")) {
            std::vector<std::wstring> parts;
            size_t start = 1;
            while (true) {
                size_t bar = line.find(L'|', start);
                parts.push_back(line.substr(start, bar == std::wstring::npos ? std::wstring::npos : bar - start));
                if (bar == std::wstring::npos) {
                    break;
                }
                start = bar + 1;
            }
            if (parts.size() >= 2) {
                std::vector<std::wstring> styles(parts.begin() + 1, parts.end());
                try {
                    AddElementCustomizationRules(parts[0], styles);
                } catch (...) {
                    HRESULT hr = winrt::to_hresult();
                    Wh_Log(L"Error %08X in style line %s", hr, line.c_str());
                }
            }
            continue;
        }
        fileVariables.push_back(line.c_str());
    }

    g_resourceVariables =
        ProcessResourceVariablesFromSettings(styleConstants, fileVariables);
}
'@
$text = Replace-Function $text 'void ProcessAllStylesFromSettings() {' $process

$getWnd = @'
// Windows Terminal runs its XAML on the thread of its CASCADIA_HOSTING_WINDOW_CLASS
// window. Prefer the window on the thread that was already initialized.
HWND GetCoreWnd() {
    struct ENUM_WINDOWS_PARAM {
        HWND hWnd;
        DWORD threadId;
    };

    ENUM_WINDOWS_PARAM param = {nullptr, g_targetThreadId};
    EnumWindows(
        [](HWND hWnd, LPARAM lParam) -> BOOL {
            ENUM_WINDOWS_PARAM& param = *(ENUM_WINDOWS_PARAM*)lParam;

            WCHAR szClassName[64];
            if (GetClassName(hWnd, szClassName, ARRAYSIZE(szClassName)) == 0 ||
                _wcsicmp(szClassName, L"CASCADIA_HOSTING_WINDOW_CLASS") != 0) {
                return TRUE;
            }

            DWORD dwProcessId = 0;
            DWORD dwThreadId = GetWindowThreadProcessId(hWnd, &dwProcessId);
            if (dwProcessId != GetCurrentProcessId()) {
                return TRUE;
            }

            if (param.threadId && dwThreadId != param.threadId) {
                return TRUE;
            }

            param.hWnd = hWnd;
            return FALSE;
        },
        (LPARAM)&param);

    return param.hWnd;
}
'@
$text = Replace-Function $text 'HWND GetCoreWnd() {' $getWnd

$init = @'
void InitializeSettingsAndTap() {
    DWORD kNoThreadId = 0;
    if (!g_targetThreadId.compare_exchange_strong(kNoThreadId,
                                                  GetCurrentThreadId())) {
        return;
    }

    ProcessAllStylesFromSettings();

    HRESULT hr = InjectWindhawkTAP();
    if (FAILED(hr)) {
        // Windows Terminal: the core window appears before XAML is ready on the thread, so the
        // diagnostics connection doesn't exist yet. Reset so the watcher thread retries later.
        Wh_Log(L"Error %08X, will retry", hr);
        g_elementsCustomizationRules.clear();
        g_resourceVariables.clear();
        g_targetThreadId = 0;
    }
}
'@
$text = Replace-Function $text 'void InitializeSettingsAndTap() {' $init

$watch = @'
HANDLE g_colorsWatchStopEvent;
HANDLE g_colorsWatchThread;

void Wh_ModSettingsChanged();
HWND GetCoreWnd();

// The active theme's name, small, at the right of the title bar next to the minimize button. Windows Terminal's
// TitlebarControl has an empty Border "DragBar" between the tabs and the caption buttons; the label goes in it
// (not hit-testable, so the window still drags). Text, colour and font come from "!ThemeLabel*" lines in the
// colours file; no ThemeLabel line (a normal theme) removes it.
std::vector<winrt::weak_ref<winrt::Windows::UI::Xaml::Controls::Border>> g_labelHosts;

void UpdateThemeLabel(winrt::Windows::UI::Xaml::Controls::Border const& host) {
    namespace wuxc = winrt::Windows::UI::Xaml::Controls;
    std::wstring name, font;
    unsigned long color = 0;
    for (const auto& line : ReadColorsFile()) {
        if (line.starts_with(L"!ThemeLabel=")) name = line.substr(12);
        else if (line.starts_with(L"!ThemeLabelColor=#")) color = wcstoul(line.c_str() + 18, nullptr, 16);
        else if (line.starts_with(L"!ThemeLabelFont=")) font = line.substr(16);
    }
    auto label = host.Child().try_as<wuxc::TextBlock>();
    bool ours = label && label.Name() == L"BurninThemeLabel";
    if (name.empty()) {
        if (ours) host.Child(nullptr);
        return;
    }
    if (!ours) {
        if (host.Child()) return;   // something else lives there: leave it alone
        label = wuxc::TextBlock();
        label.Name(L"BurninThemeLabel");
        label.HorizontalAlignment(winrt::Windows::UI::Xaml::HorizontalAlignment::Right);
        label.VerticalAlignment(winrt::Windows::UI::Xaml::VerticalAlignment::Center);
        label.Margin(winrt::Windows::UI::Xaml::Thickness{0, 0, 10, 0});
        label.FontSize(11);
        label.Opacity(0.85);
        label.IsHitTestVisible(false);
        host.Child(label);
    }
    label.Text(name);
    if (!font.empty()) label.FontFamily(Media::FontFamily(font));
    if (color) {
        label.Foreground(Media::SolidColorBrush(winrt::Windows::UI::Color{
            (uint8_t)(color >> 24), (uint8_t)(color >> 16), (uint8_t)(color >> 8), (uint8_t)color}));
    }
}

void UpdateThemeLabels() {
    for (auto it = g_labelHosts.begin(); it != g_labelHosts.end();) {
        auto host = it->get();
        if (!host) {
            it = g_labelHosts.erase(it);
            continue;
        }
        try {
            UpdateThemeLabel(host);
        } catch (...) {
            Wh_Log(L"Error %08X updating the theme label", winrt::to_hresult());
        }
        ++it;
    }
}

void TrackThemeLabelHost(winrt::Windows::UI::Xaml::FrameworkElement element) {
    if (element.Name() != L"DragBar") return;
    auto host = element.try_as<winrt::Windows::UI::Xaml::Controls::Border>();
    if (!host) return;
    g_labelHosts.push_back(winrt::make_weak(host));
    try {
        UpdateThemeLabel(host);
    } catch (...) {
        Wh_Log(L"Error %08X adding the theme label", winrt::to_hresult());
    }
}

// Sets the colour of every brush this mod inserted ("Key:=<SolidColorBrush Color="#AARRGGBB"/>"
// lines) on the existing brush objects, so everything drawn with them updates immediately.
void UpdateColorsInPlace() {
    constexpr std::wstring_view kBrushPrefix = L":=<SolidColorBrush Color=\"#";
    auto resources = Application::Current().Resources();
    int updated = 0;
    for (const auto& line : ReadColorsFile()) {
        auto pos = line.find(kBrushPrefix);
        if (pos == std::wstring::npos || line.size() < pos + kBrushPrefix.size() + 8) {
            continue;
        }
        std::wstring key = line.substr(0, pos);
        std::wstring hex = line.substr(pos + kBrushPrefix.size(), 8);
        unsigned long v = wcstoul(hex.c_str(), nullptr, 16);
        winrt::Windows::UI::Color color{(uint8_t)(v >> 24), (uint8_t)(v >> 16),
                                        (uint8_t)(v >> 8), (uint8_t)v};
        try {
            auto value = resources.TryLookup(winrt::box_value(key));
            if (auto brush = value.try_as<Media::SolidColorBrush>()) {
                brush.Color(color);
                updated++;
            }
        } catch (...) {
            HRESULT hr = winrt::to_hresult();
            Wh_Log(L"Error %08X recolouring %s", hr, key.c_str());
        }
    }
    Wh_Log(L"Recoloured %d brushes", updated);
    UpdateThemeLabels();
}

DWORD WINAPI ColorsFileWatchThread(LPVOID) {
    WIN32_FILE_ATTRIBUTE_DATA data;
    bool lastExists = GetFileAttributesEx(kColorsFile, GetFileExInfoStandard, &data);
    FILETIME lastWrite = lastExists ? data.ftLastWriteTime : FILETIME{};

    int windowSeenTicks = 0;
    while (WaitForSingleObject(g_colorsWatchStopEvent, 1000) == WAIT_TIMEOUT) {
        // Windows Terminal is a desktop app: when the mod loads at process start there is no
        // window yet, so initialize once its window has existed for two seconds (XAML is up by then).
        if (!g_targetThreadId) {
            HWND hWnd = GetCoreWnd();
            windowSeenTicks = hWnd ? windowSeenTicks + 1 : 0;
            if (windowSeenTicks >= 2) {
                Wh_Log(L"Initializing - Terminal window found");
                RunFromWindowThread(
                    hWnd, [](PVOID) { InitializeSettingsAndTap(); }, nullptr);
            }
        }

        bool exists = GetFileAttributesEx(kColorsFile, GetFileExInfoStandard, &data);
        FILETIME write = exists ? data.ftLastWriteTime : FILETIME{};
        if (exists == lastExists && CompareFileTime(&write, &lastWrite) == 0) {
            continue;
        }

        lastExists = exists;
        lastWrite = write;
        // Recolour in place instead of the engine's full uninitialize/reinitialize, which fails
        // inside Windows Terminal (and crashed it). The UI font follows on the next Terminal start.
        HWND hWnd = GetCoreWnd();
        if (hWnd && g_targetThreadId) {
            Wh_Log(L"Colours file changed, recolouring in place");
            RunFromWindowThread(
                hWnd, [](PVOID) { UpdateColorsInPlace(); }, nullptr);
        }
    }

    return 0;
}

void StartColorsFileWatch() {
    g_colorsWatchStopEvent = CreateEvent(nullptr, TRUE, FALSE, nullptr);
    if (g_colorsWatchStopEvent) {
        g_colorsWatchThread =
            CreateThread(nullptr, 0, ColorsFileWatchThread, nullptr, 0, nullptr);
    }
}

void StopColorsFileWatch() {
    if (g_colorsWatchThread) {
        SetEvent(g_colorsWatchStopEvent);
        WaitForSingleObject(g_colorsWatchThread, INFINITE);
        CloseHandle(g_colorsWatchThread);
        g_colorsWatchThread = nullptr;
    }
    if (g_colorsWatchStopEvent) {
        CloseHandle(g_colorsWatchStopEvent);
        g_colorsWatchStopEvent = nullptr;
    }
}

BOOL Wh_ModInit() {
'@
$text = $text.Replace("BOOL Wh_ModInit() {", $watch.Trim())
# theme-name label: find Windows Terminal's DragBar as XAML elements appear
$text = $text.Replace("void TrackSplitView(winrt::Windows::UI::Xaml::FrameworkElement element);",
  "void TrackSplitView(winrt::Windows::UI::Xaml::FrameworkElement element);`nvoid TrackThemeLabelHost(winrt::Windows::UI::Xaml::FrameworkElement element);")
$text = $text.Replace("            TrackSplitView(frameworkElement);", "            TrackSplitView(frameworkElement);`n            TrackThemeLabelHost(frameworkElement);")
$text = Replace-Function $text 'bool StartStatsTimer() {' ''
$text = Replace-Function $text 'void StopStatsTimer() {' ''
$text = $text.Replace("PTP_TIMER g_statsTimer;`n", '')
$text = $text.Replace("    StartStatsTimer();`n`n    return TRUE;", "    return TRUE;")
$text = $text.Replace("void Wh_ModAfterInit() {`n    Wh_Log(L`">`");`n", "void Wh_ModAfterInit() {`n    Wh_Log(L`">`");`n`n    StartColorsFileWatch();`n")
$text = $text.Replace("    StopStatsTimer();`n", "    StopColorsFileWatch();`n")

foreach ($must in 'StartColorsFileWatch();', 'StopColorsFileWatch();', 'CASCADIA_HOSTING_WINDOW_CLASS', 'ReadColorsFile()', 'TrackThemeLabelHost(frameworkElement);', 'void TrackThemeLabelHost(winrt::Windows::UI::Xaml::FrameworkElement element);') {
  if (-not $text.Contains($must)) { throw "patch missing: $must" }
}
if ($text.Contains('StartStatsTimer();') -or $text.Contains('g_themeDensy')) { throw 'leftover stats/theme code' }

$dst = Join-Path $here 'windows-terminal-retro-styler.wh.cpp'
[IO.File]::WriteAllText($dst, $text, (New-Object Text.UTF8Encoding $false))
"wrote $dst ($(($text -split "`n").Count) lines)"

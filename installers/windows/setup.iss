; CRT Terminal Themes - Windows setup wizard (Inno Setup 6). Built by .github/workflows/release.yml:
;     iscc /DAppVersion=1.0.0 installers\windows\setup.iss
; Installs for the current user (no admin), then runs windows\install.ps1 (the same script as the one-line
; install). Uninstalling from Settings > Apps runs windows\uninstall.ps1.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define Root "..\.."

[Setup]
AppId={{470BF97E-37CD-4933-9525-AE0892567E38}
AppName=CRT Terminal Themes
AppVersion={#AppVersion}
AppPublisher=crt-terminal-themes contributors
AppPublisherURL=https://github.com/SnortingPixels/crt-terminal-themes
DefaultDirName={localappdata}\CRT-Terminal-Setup
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir={#Root}\installers\out
OutputBaseFilename=CRT-Terminal-Setup
SetupIconFile={#Root}\assets\icon.ico
UninstallDisplayIcon={app}\assets\icon.ico
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
LicenseFile={#Root}\LICENSE

[Tasks]
Name: "menus"; Description: "Also style Windows Terminal's menus to match (installs Windhawk; Windows asks for admin)"; Flags: unchecked

[Files]
Source: "{#Root}\dist\*"; DestDir: "{app}\dist"; Flags: recursesubdirs ignoreversion
Source: "{#Root}\themes\*"; DestDir: "{app}\themes"; Flags: recursesubdirs ignoreversion
Source: "{#Root}\windows\*"; DestDir: "{app}\windows"; Flags: recursesubdirs ignoreversion
Source: "{#Root}\src\retro_fonts.py"; DestDir: "{app}\src"; Flags: ignoreversion
Source: "{#Root}\assets\icon.ico"; DestDir: "{app}\assets"; Flags: ignoreversion
Source: "{#Root}\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Root}\README.md"; DestDir: "{app}"; Flags: ignoreversion isreadme

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\windows\install.ps1"""; StatusMsg: "Setting up Windows Terminal (fonts, shaders, themes)..."; Flags: waituntilterminated runhidden; Tasks: not menus
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\windows\install.ps1"" -WithMenus"; StatusMsg: "Setting up Windows Terminal (fonts, shaders, themes, menus)..."; Flags: waituntilterminated runhidden; Tasks: menus

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{localappdata}\CRT-Terminal\uninstall.ps1"""; RunOnceId: "CrtUninstall"; Flags: waituntilterminated runhidden

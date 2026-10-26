; Inno Setup script - Iqra Rozatul Atfal (School Management System)
; Place this file in the repo at: installer\setup.iss
; Build first: flutter build windows --release
; Then open this file in Inno Setup and press Compile (Ctrl+F9).

#define MyAppName "Iqra Rozatul Atfal"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Saeed ur Rahman"
#define MyAppExeName "IqraRozatulAtfal.exe"
#define MyBuildDir "..\build\windows\x64\runner\Release"

[Setup]
AppId={{8F3C2A71-5B64-4D9E-A1C7-2E9B6D40F135}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\IqraRozatulAtfal
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=IqraRozatulAtfal_Setup_{#MyAppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: checkedonce

[Files]
Source: "{#MyBuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Open {#MyAppName}"; Flags: nowait postinstall skipifsilent

; Note: school data (database, documents, backups) lives in the user's
; Documents\RozatulAtfal folder, so uninstalling or updating the app
; does NOT delete the school's data.

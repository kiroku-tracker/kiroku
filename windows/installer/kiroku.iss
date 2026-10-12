; Установщик Kiroku (Inno Setup 6).

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#define BuildDir "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{5D71B4AA-95EB-4AE8-9779-DA166CBBBA79}
AppName=Kiroku
AppVersion={#AppVersion}
AppVerName=Kiroku {#AppVersion}
AppPublisher=RLTEX
AppPublisherURL=https://github.com/kiroku-tracker/kiroku
AppSupportURL=https://github.com/kiroku-tracker/kiroku/issues
AppUpdatesURL=https://github.com/kiroku-tracker/kiroku/releases
VersionInfoVersion={#AppVersion}
DefaultDirName={autopf}\Kiroku
DefaultGroupName=Kiroku
DisableProgramGroupPage=yes
DisableReadyPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir=..\..\build\installer
OutputBaseFilename=Kiroku-Setup-{#AppVersion}
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\kiroku.exe
UninstallDisplayName=Kiroku
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=force
RestartApplications=no

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[InstallDelete]
; Старые файлы.
Type: filesandordirs; Name: "{app}\data"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Ярлык в «Пуске».
Name: "{autoprograms}\Kiroku"; Filename: "{app}\kiroku.exe"; AppUserModelID: "Kiroku.Desktop"; AppUserModelToastActivatorCLSID: "D2D1B85D-4461-4556-A754-2629540D4760"
Name: "{autodesktop}\Kiroku"; Filename: "{app}\kiroku.exe"; Tasks: desktopicon

[Registry]
; Автозапуск.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: none; ValueName: "Kiroku"; Flags: uninsdeletevalue dontcreatekey

[Run]
Filename: "{app}\kiroku.exe"; Description: "{cm:LaunchProgram,Kiroku}"; Flags: nowait postinstall

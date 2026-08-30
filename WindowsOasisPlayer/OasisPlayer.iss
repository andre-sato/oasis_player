#define MyAppName "Oasis Player"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Andre Sato"
#define MyAppExeName "OasisPlayer.Windows.exe"

[Setup]
AppId={{FB958099-6B51-4F92-8822-BF6D38E7EFD4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Oasis Player
DefaultGroupName=Oasis Player
OutputDir=..\artifacts
OutputBaseFilename=OasisPlayer-Setup-1.0.0
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "..\publish\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Oasis Player"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\Oasis Player"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na área de trabalho"; GroupDescription: "Atalhos adicionais:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Abrir Oasis Player"; Flags: nowait postinstall skipifsilent

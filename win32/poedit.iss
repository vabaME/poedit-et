﻿;
;   This file is part of Poedit (https://poedit.net)
;
;   Copyright (C) 1999-2023 Vaclav Slavik
;
;   Permission is hereby granted, free of charge, to any person obtaining a
;   copy of this software and associated Docsumentation files (the "Software"),
;   to deal in the Software without restriction, including without limitation
;   the rights to use, copy, modify, merge, publish, distribute, sublicense,
;   and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in
;   all copies or substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;   DEALINGS IN THE SOFTWARE.
;
;   Inno Setup installer script
;

#ifndef CONFIG
#define CONFIG           "Release"
#endif

#include "../" + CONFIG + "/git_build_number.h"

#define VERSION          "3.2.2"
#define VERSION_WIN      VERSION + "." + Str(POEDIT_GIT_BUILD_NUMBER)

#ifndef CRT_REDIST
#define CRT_REDIST       GetEnv("VCToolsRedistDir") + "\x86\Microsoft.VC143.CRT"
#endif
#ifndef UCRT_REDIST
#define UCRT_REDIST       GetEnv("UniversalCRTSdkDir") + "\Redist\" + GetEnv("UCRTVersion") + "\ucrt\DLLs\x86"
#endif

[Setup]
OutputBaseFilename=Poedit-{#VERSION}-setup
OutputDir=win32\distrib-{#CONFIG}-{#VERSION}

AppName=Poedit
AppVerName=Poedit {#VERSION}

ChangesAssociations=true
AlwaysShowComponentsList=false
SourceDir=..
DefaultDirName={pf}\Poedit
DefaultGroupName=Poedit
AllowNoIcons=true
LicenseFile=COPYING
InfoAfterFile=
SolidCompression=true
Compression=lzma2/ultra64
WindowShowCaption=true
WindowStartMaximized=false
FlatComponentsList=true
WindowResizable=true
ShowLanguageDialog=no
DisableWelcomePage=true
AllowUNCPath=true
InternalCompressLevel=ultra
AppID={{68EB2C37-083A-4303-B5D8-41FA67E50B8F}
VersionInfoVersion={#VERSION_WIN}
VersionInfoTextVersion={#VERSION}
AppCopyright=Copyright © 1999-2023 Vaclav Slavik
AppPublisher=Vaclav Slavik
AppSupportURL=https://poedit.net/support
AppUpdatesURL=https://poedit.net/download
AppVersion={#VERSION}
AppContact=help@poedit.net
UninstallDisplayIcon={app}\Poedit.exe
UninstallDisplayName=Poedit
MinVersion=0,6.1.7600
WizardSmallImageFile=artwork\windows\installer_wizard_image.bmp
WizardStyle=modern
AppPublisherURL=https://poedit.net/
DisableProgramGroupPage=true

#ifdef SIGNTOOL
SignTool={#SIGNTOOL}
#endif
VersionInfoCompany=Vaclav Slavik
VersionInfoDescription=Poedit Installer
VersionInfoCopyright=Copyright © 1999-2023 Vaclav Slavik
VersionInfoProductName=Poedit
VersionInfoProductVersion={#VERSION_WIN}
VersionInfoProductTextVersion={#VERSION}
DisableDirPage=auto

[Files]
Source: {#CONFIG}\Poedit.exe; DestDir: {app}; Flags: ignoreversion
Source: {#CONFIG}\*.dll; DestDir: {app}; Flags: ignoreversion
Source: {#CONFIG}\icudt*.dat; DestDir: {app}
Source: COPYING; DestDir: {app}\Docs; DestName: Copying.txt
Source: NEWS; DestDir: {app}\Docs; DestName: News.txt
Source: {#CRT_REDIST}\*.dll; DestDir: {app}
Source: {#UCRT_REDIST}\*.dll; DestDir: {app}; OnlyBelowVersion: 0,10.0
Source: "{#CONFIG}\Resources\*"; DestDir: "{app}\Resources"; Flags: recursesubdirs
Source: "{#CONFIG}\Translations\*"; DestDir: "{app}\Translations"; Flags: recursesubdirs
Source: "{#CONFIG}\GettextTools\*"; DestDir: "{app}\GettextTools"; Flags: ignoreversion recursesubdirs

[InstallDelete]
; Remove all files from previous version to have known clean state
Type: filesandordirs; Name: {group}\*;

[Registry]
; Install global settings:
Root: "HKLM"; Subkey: "Software\Vaclav Slavik\Poedit\WinSparkle"; ValueType: string; ValueName: "CheckForUpdates"; ValueData: "1"; Flags: noerror

; Uninstall Poedit settings on uninstall:
Root: "HKLM"; Subkey: "Software\Vaclav Slavik\Poedit"; Flags: noerror uninsdeletekey
Root: "HKLM"; Subkey: "Software\Vaclav Slavik"; Flags: noerror uninsdeletekeyifempty
Root: "HKCU"; Subkey: "Software\Vaclav Slavik\Poedit"; Flags: uninsdeletekey dontcreatekey
Root: "HKCU"; Subkey: "Software\Vaclav Slavik"; Flags: uninsdeletekeyifempty dontcreatekey

; Associate files with Poedit:
Root: "HKA"; Subkey: "Software\Classes\.po"; ValueType: string; ValueData: "Poedit.PO"; Flags: noerror
Root: "HKA"; Subkey: "Software\Classes\.po\OpenWithProgids"; ValueType: string; ValueName: "Poedit.PO"; ValueData: ""; Flags: uninsdeletevalue
Root: "HKA"; Subkey: "Software\Classes\Poedit.PO"; ValueType: string; ValueData: "PO Translation"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.PO"; ValueType: string; ValueName: "FriendlyTypeName"; ValueData: "@{app}\Poedit.exe,-222"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.PO\Shell\Open\Command"; ValueType: string; ValueData: """{app}\Poedit.exe"" ""%1"""; Flags: uninsdeletevalue noerror

Root: "HKA"; Subkey: "Software\Classes\.mo"; ValueType: string; ValueData: "Poedit.MO"; Flags: noerror
Root: "HKA"; Subkey: "Software\Classes\.mo\OpenWithProgids"; ValueType: string; ValueName: "Poedit.MO"; ValueData: ""; Flags: uninsdeletevalue noerror
Root: "HKA"; Subkey: "Software\Classes\.gmo"; ValueType: string; ValueData: "Poedit.MO"; Flags: noerror
Root: "HKA"; Subkey: "Software\Classes\.gmo\OpenWithProgids"; ValueType: string; ValueName: "Poedit.MO"; ValueData: ""; Flags: uninsdeletevalue noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.MO"; ValueType: string; ValueData: "Compiled Translation"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.MO"; ValueType: string; ValueName: "FriendlyTypeName"; ValueData: "@{app}\Poedit.exe,-223"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.MO\Shell\Open\Command"; ValueType: string; ValueData: """{app}\Poedit.exe"" ""%1"""; Flags: uninsdeletevalue noerror

Root: "HKA"; Subkey: "Software\Classes\.pot\OpenWithProgids"; ValueType: string; ValueName: "Poedit.POT"; ValueData: ""; Flags: uninsdeletevalue noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.POT"; ValueType: string; ValueData: "Translation Template"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.POT"; ValueType: string; ValueName: "FriendlyTypeName"; ValueData: "@{app}\Poedit.exe,-224"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.POT\Shell\Open\Command"; ValueType: string; ValueData: """{app}\Poedit.exe"" ""%1"""; Flags: uninsdeletevalue noerror

Root: "HKA"; Subkey: "Software\Classes\.xlf"; ValueType: string; ValueName: "Content Type"; ValueData: "application/x-xliff+xml"; Flags: noerror
Root: "HKA"; Subkey: "Software\Classes\.xlf\OpenWithProgids"; ValueType: string; ValueName: "Poedit.XLIFF"; ValueData: ""; Flags: uninsdeletevalue noerror
Root: "HKA"; Subkey: "Software\Classes\.xliff"; ValueType: string; ValueName: "Content Type"; ValueData: "application/x-xliff+xml"; Flags: noerror
Root: "HKA"; Subkey: "Software\Classes\.xliff\OpenWithProgids"; ValueType: string; ValueName: "Poedit.XLIFF"; ValueData: ""; Flags: uninsdeletevalue noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.XLIFF"; ValueType: string; ValueData: "XLIFF Translation"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.XLIFF"; ValueType: string; ValueName: "FriendlyTypeName"; ValueData: "@{app}\Poedit.exe,-225"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.XLIFF\Shell\Open\Command"; ValueType: string; ValueData: """{app}\Poedit.exe"" ""%1"""; Flags: uninsdeletevalue noerror

Root: "HKA"; Subkey: "Software\Classes\.json"; ValueType: string; ValueName: "Content Type"; ValueData: "application/json"; Flags: noerror
Root: "HKA"; Subkey: "Software\Classes\.json\OpenWithProgids"; ValueType: string; ValueName: "Poedit.JSON"; ValueData: ""; Flags: uninsdeletevalue noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.JSON"; ValueType: string; ValueData: "JSON Document"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.JSON"; ValueType: string; ValueName: "FriendlyTypeName"; ValueData: "@{app}\Poedit.exe,-226"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.JSON\Shell\Open\Command"; ValueType: string; ValueData: """{app}\Poedit.exe"" ""%1"""; Flags: uninsdeletevalue noerror

Root: "HKA"; Subkey: "Software\Classes\.arb\OpenWithProgids"; ValueType: string; ValueName: "Poedit.ARB"; ValueData: ""; Flags: uninsdeletevalue noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.ARB"; ValueType: string; ValueData: "Flutter Translation"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.ARB"; ValueType: string; ValueName: "FriendlyTypeName"; ValueData: "@{app}\Poedit.exe,-227"; Flags: uninsdeletekey noerror
Root: "HKA"; Subkey: "Software\Classes\Poedit.ARB\Shell\Open\Command"; ValueType: string; ValueData: """{app}\Poedit.exe"" ""%1"""; Flags: uninsdeletevalue noerror

; URL protocol for poedit:// (various custom tasks such as OAuth)
Root: HKA; Subkey: "Software\Classes\poedit"; ValueType: "string"; ValueData: "URL:Poedit Custom Protocol"; Flags: uninsdeletekey noerror
Root: HKA; Subkey: "Software\Classes\poedit"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletekey noerror
Root: HKA; Subkey: "Software\Classes\poedit\DefaultIcon"; ValueType: "string"; ValueData: "{app}\Poedit.exe,0"; Flags: uninsdeletekey noerror
Root: HKA; Subkey: "Software\Classes\poedit\shell\open\command"; ValueType: "string"; ValueData: """{app}\Poedit.exe"" --handle-poedit-uri ""%1"""; Flags: uninsdeletekey noerror

[Icons]
Name: {commonprograms}\Poedit; Filename: {app}\Poedit.exe; WorkingDir: {app}; IconIndex: 0; Comment: Translation editor.

[Run]
Filename: {app}\Poedit.exe; WorkingDir: {app}; Description: {cm:OpenAfterInstall}; Flags: postinstall nowait skipifsilent runasoriginaluser

[_ISTool]
UseAbsolutePaths=false

[Dirs]
Name: {app}\Docs
Name: {app}\Resources
Name: {app}\Translations

[ThirdParty]
CompileLogMethod=append

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[CustomMessages]
OpenAfterInstall=Open Poedit after installation
brazilianportuguese.OpenAfterInstall=Abrir o Poedit após a instalação
catalan.OpenAfterInstall=Obre el Poedit després de la instal·lació
corsican.OpenAfterInstall=Apre Poedit dopu à l'installazione
czech.OpenAfterInstall=Po instalaci otevřít Poedit
danish.OpenAfterInstall=Åbn Poedit efter installation
dutch.OpenAfterInstall=Poedit starten na installatie
finnish.OpenAfterInstall=Avaa Poedit asennuksen jälkeen
french.OpenAfterInstall=Ouvrir Poedit après l'installation
german.OpenAfterInstall=Poedit nach Abschluss der Installation öffnen
hebrew.OpenAfterInstall=פתח את Poedit לאחר ההתקנה
italian.OpenAfterInstall=Apri Poedit dopo l'installazione
japanese.OpenAfterInstall=インストール後 Poedit を開く
norwegian.OpenAfterInstall=Åpne Poedit etter installasjon
polish.OpenAfterInstall=Otwórz program Poedit po zakończeniu instalacji
portuguese.OpenAfterInstall=Abrir o Poedit após a instalação
russian.OpenAfterInstall=Открыть Poedit после окончания установки
slovenian.OpenAfterInstall=Odpri Poedit po namestitvi
spanish.OpenAfterInstall=Abrir Poedit tras la instalación
turkish.OpenAfterInstall=Kurulumdan sonra Poedit'i aç
ukrainian.OpenAfterInstall=Відкрити Poedit після встановлення

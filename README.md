# Oasis Player

Player de música local e offline para iOS 17+, feito em SwiftUI, SwiftData e AVFoundation.

## MVP incluído

- Biblioteca persistida localmente com músicas, artistas, álbuns e playlists.
- Importação pelo app Arquivos, copiando o áudio para `Documents/Media/Audio`.
- Download de uma URL direta de áudio, sem interpretar páginas ou catálogos.
- Extração de metadados por AVFoundation e fallback determinístico para título, artista e álbum.
- Player com fila, próxima/anterior, seek, shuffle/repeat e controles de tela bloqueada.
- Mini-player persistente e tela Now Playing.
- Modo de reprodução em segundo plano configurado no `Info.plist`.

## Abrir no Xcode

1. Instale o [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).
2. Na raiz, execute `xcodegen generate`.
3. Abra `OasisPlayer.xcodeproj`, escolha um simulador iOS 17+ e execute os testes.

O projeto não requer login, analytics ou serviços de streaming. URLs são usadas somente para o download solicitado pelo usuário.

## Windows

Uma edição nativa para Windows está em `WindowsOasisPlayer/`. Ela importa arquivos locais, baixa arquivos de áudio por URL direta, mantém a biblioteca offline em `%LOCALAPPDATA%\\Oasis Player` e reproduz os formatos suportados pelo Windows.

O instalador gerado localmente é `artifacts/OasisPlayer-Setup-1.0.0.exe`. Ele é auto-contido para Windows 64-bit e não exige instalar o runtime .NET.

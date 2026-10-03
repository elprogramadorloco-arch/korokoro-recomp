# KoroKoroRecomp

[English](#english) · [Español](#español)

---

## English

### What is it?

KoroKoroRecomp is a **native Windows static recompilation** of *KoroKoro Post
nin* (PlayStation, Japan, SLPS-03479, Media Entertainment 2002). It is not an
emulator: the game code is translated to C and compiled into a native `.exe`
with [psxrecomp](https://github.com/mstan/psxrecomp).

This repository **does not contain the game**. You supply your own copy and
`run.bat` builds a private copy on your PC.

### Requirements

- 64-bit Windows (10 or 11).
- Internet on the first run (about 230 MB of downloads).
- **No Visual Studio, CMake, Python or Git needed.** `run.bat` downloads a
  portable toolchain (LLVM-MinGW + CMake + Ninja + Python) and the psxrecomp
  sources at pinned commits, and verifies every download with SHA-256.
- About 3 GB of free disk space.
- Your own copy of **KoroKoro Post nin (Japan)**, `SLPS-03479`, in one of these
  formats:
  - a `.chd`, or
  - a `.cue` with its `.bin`.

  Expected data track (Redump): `88,131,792` bytes,
  MD5 `6897e2c85262456a16c579a531435268`.

### How to use it

1. Copy your `.chd` (or your `.cue` + `.bin`) into the `data` folder.
2. Run `run.bat`.
3. The first run takes a while (it downloads the toolchain, verifies the disc,
   recompiles the game and builds the executable). When it finishes, the game
   starts on its own.
4. Later runs start the game directly. You can also open
   `out\KoroKoroPostNin.exe`.

Options: `run.bat -Rebuild` forces a full rebuild; `run.bat -NoLaunch` builds
only.

Never publish `data`, `out` or `tools\.build`: they contain your disc or files
derived from it.

### Status

| Part | Status |
| --- | --- |
| Boot, title, menus, intro | OK, compared with DuckStation |
| Stage 1, pause, time up, game over, continue | OK, compared with DuckStation |
| Audio (SPU + CD music) | OK |
| Stages 2–10, memory card, ending | Not verified yet |

### Android version (alpha)

> ⚠️ **Alpha:** it works, but it is still in development; it may have bugs and
> has not been tested on many phone models yet.

It includes full-screen **widescreen** and **mobile controls**:

| Action | Control |
| --- | --- |
| Turn the maze | Tilt the phone like a steering wheel (accelerometer) |
| Title menu and はい / いいえ (yes/no) dialogs | Tap the option, like an Android button |
| "PRESS START" screen | Tap anywhere |
| Other screens | Touch zones: left third ↑/↓, centre START, right third ✕ (top) / ○ (bottom) |

🚧 **In development:** making every control fully native to the phone (touch
buttons on every screen, with no dependence on PS1 buttons).

It is built like the PC version, from a separate package:

1. Download `KoroKoroRecomp-Android-v0.1.zip` from the
   [release](https://github.com/elprogramadorloco-arch/korokoro-recomp/releases)
   and unzip it to a **short path without accents** (for example
   `C:\KoroKoroAndroid`).
2. Copy your `.chd` (or your `.cue` + `.bin`) into `data`.
3. Run `run.bat`. The first run downloads only official tools at pinned
   versions (the same portable toolchain, Eclipse Temurin JDK 17 and Google's
   Android SDK/NDK through its `sdkmanager`; about 1.5 GB) and asks you to
   **accept the Android SDK licenses** (answer `y`). No Android Studio or
   manual installs needed.
4. When it finishes (20–60 min the first time) you get
   `out\KoroKoroPostNin.apk`. Copy it to your phone any way you like (cable,
   cloud drive, etc.) and open it there; Android will ask you to allow
   "install unknown apps". No USB debugging or PC connection needed.

Requirements: 64-bit Windows 10/11, about 8 GB of free disk space and an
Android 8.0 or newer phone with a 64-bit (arm64) system, as almost every phone
from recent years has.

**The APK contains your disc:** install it on your own phone only and never
share it.

---

## Español

### ¿Qué es?

KoroKoroRecomp es una **recompilación estática nativa para Windows** de
*KoroKoro Post nin* (PlayStation, Japón, SLPS-03479, Media Entertainment 2002).
No es un emulador: el código del juego se traduce a C y se compila como un
`.exe` nativo con [psxrecomp](https://github.com/mstan/psxrecomp).

Este repositorio **no contiene el juego**. Tú aportas tu propia copia y el
`run.bat` genera en tu PC una compilación privada.

### Requisitos

- Windows de 64 bits (10 u 11).
- Conexión a Internet la primera vez (unos 230 MB de descargas).
- **No hace falta Visual Studio, CMake, Python ni Git.** `run.bat` descarga un
  toolchain portable (LLVM-MinGW + CMake + Ninja + Python) y las fuentes de
  psxrecomp en commits fijados, y verifica cada descarga con SHA-256.
- Unos 3 GB libres en disco.
- Tu copia de **KoroKoro Post nin (Japan)**, `SLPS-03479`, en uno de estos formatos:
  - un `.chd`, o
  - un `.cue` con su `.bin`.

  Pista de datos esperada (Redump): `88,131,792` bytes,
  MD5 `6897e2c85262456a16c579a531435268`.

### Cómo usarlo

1. Copia tu `.chd` (o tu `.cue` + `.bin`) en la carpeta `data`.
2. Ejecuta `run.bat`.
3. La primera vez tarda (descarga el toolchain, verifica el disco, recompila el
   juego y compila el ejecutable). Al terminar el juego se abre solo.
4. Las siguientes veces `run.bat` abre el juego directamente. También puedes
   abrir `out\KoroKoroPostNin.exe`.

Opciones: `run.bat -Rebuild` fuerza una recompilación completa;
`run.bat -NoLaunch` solo compila.

No publiques `data`, `out` ni `tools\.build`: contienen tu disco o archivos
derivados de él.

### Estado

| Parte | Estado |
| --- | --- |
| Arranque, título, menús, intro | OK, comparado con DuckStation |
| Fase 1, pausa, tiempo agotado, game over, continuar | OK, comparado con DuckStation |
| Audio (SPU + música de CD) | OK |
| Fases 2–10, tarjeta de memoria, final | Sin verificar todavía |

### Versión para Android (alfa)

> ⚠️ **Alfa:** funciona, pero sigue en desarrollo; puede tener fallos y
> todavía no se ha probado en muchos modelos de móvil.

Incluye **pantalla ancha** que llena todo el móvil y **controles para
móvil**:

| Acción | Control |
| --- | --- |
| Girar el laberinto | Inclinar el móvil como un volante (acelerómetro) |
| Menú de inicio y diálogos はい / いいえ | Tocar la opción, como un botón de Android |
| Pantalla "PRESS START" | Tocar en cualquier parte |
| Resto de pantallas | Zonas táctiles: tercio izquierdo ↑/↓, centro START, tercio derecho ✕ (arriba) / ○ (abajo) |

🚧 **En desarrollo:** hacer que todos los controles sean totalmente nativos del
móvil (botones táctiles en cada pantalla, sin depender de los botones de PS1).

Se compila igual que la versión PC, con un paquete aparte:

1. Descarga `KoroKoroRecomp-Android-v0.1.zip` de la
   [release](https://github.com/elprogramadorloco-arch/korokoro-recomp/releases)
   y descomprímelo en una ruta **corta y sin acentos** (por ejemplo
   `C:\KoroKoroAndroid`).
2. Copia tu `.chd` (o tu `.cue` + `.bin`) en `data`.
3. Ejecuta `run.bat`. La primera vez descarga solo herramientas oficiales con
   versiones fijadas (el mismo toolchain portable, Java Eclipse Temurin 17 y
   el Android SDK/NDK de Google con su `sdkmanager`; unos 1,5 GB) y te pide
   **aceptar las licencias del Android SDK** (responde `y`). No hace falta
   Android Studio ni instalar nada a mano.
4. Al terminar (20–60 min la primera vez) tendrás
   `out\KoroKoroPostNin.apk`. Pásalo al móvil como prefieras (cable, nube,
   etc.) y ábrelo allí; Android pedirá permitir "instalar apps desconocidas".
   No hace falta depuración USB ni conectar el móvil al PC.

Requisitos: Windows 10/11 de 64 bits, unos 8 GB libres y un móvil Android
8.0 o superior con sistema de 64 bits (arm64), lo habitual en casi todos los
móviles de los últimos años.

**El APK contiene tu disco:** instálalo solo en tu móvil y no lo compartas.

---

See [LEGAL.md](LEGAL.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
/ Consulta [LEGAL.md](LEGAL.md) y [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

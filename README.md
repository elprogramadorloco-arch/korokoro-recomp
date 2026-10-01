# KoroKoroRecomp

[Español](#español) · [English](#english)

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

### Planes a futuro

- **Versión para Android** con soporte de **pantalla ancha** (widescreen).

---

## English

### What is it?

KoroKoroRecomp is a **native Windows static recompilation** of *KoroKoro Post
nin* (PlayStation, Japan, SLPS-03479). It is not an emulator: the game code is
translated to C and compiled into a native `.exe` with
[psxrecomp](https://github.com/mstan/psxrecomp).

This repository **does not contain the game**. You supply your own copy and
`run.bat` builds a private copy on your PC.

### Requirements

- 64-bit Windows 10/11, Internet on the first run (~230 MB), ~3 GB free disk.
- **No Visual Studio, CMake, Python or Git needed.** `run.bat` downloads a
  pinned portable toolchain and the pinned psxrecomp sources, verifying every
  download with SHA-256.
- Your own dump of **KoroKoro Post nin (Japan)** (`SLPS-03479`) as `.chd` or
  `.cue` + `.bin` (data track `88,131,792` bytes, MD5
  `6897e2c85262456a16c579a531435268`).

### Usage

1. Put your `.chd` (or `.cue` + `.bin`) in `data`.
2. Run `run.bat`. The first run downloads, verifies, recompiles and builds, then
   starts the game. Later runs start it directly (`out\KoroKoroPostNin.exe`).

`run.bat -Rebuild` forces a full rebuild; `run.bat -NoLaunch` builds only.
Never publish `data`, `out` or `tools\.build`.

### Future plans

- An **Android version** with **widescreen** support.

---

See [LEGAL.md](LEGAL.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

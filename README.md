Support me on Ko-fi: https://ko-fi.com/sunjayy

# GoldenEye 007 — Android Recompilation

<p align="center">
  <img src="https://raw.githubusercontent.com/HyperionElectronicsCo/GoldenEye-Recomp/refs/heads/main/Screenshot_20260616-234126.png"/>
</p>


Todo:

generate - libgoldeneye.so






A native Android port of **GoldenEye 007 (Xbox 360 / XBLA)**, built by *statically
recompiling* the original game into java with the
[ReXGlue SDK](https://github.com/SunJaycy/GoldenEye-Recomp-rexglue). No emulator —
the game runs as a real native executable.

> [!IMPORTANT]
> **This repository contains _no_ game code or assets.** It is only the
> source that wraps the game (menus, hooks, online, post-FX, build
> config). You must find the game files yourself. This game never released publically

## Features

- Runs natively on Android — no emulator, no BIOS.
- Controller support.
- **Online multiplayer** — host or join matches over the internet (LAN, Hamachi,
  playit.gg, or a public server). See [Playing online](#playing-online).
- In-game **pause / settings menu** (ESC): video, resolution, frame limit,
  fullscreen, online setup.
- **Post-FX** filters (brightness, contrast, saturation, vignette, presets…).
- Smooth, stable 60 FPS (recompiled, with GPU-pacing fixes for the original's
  frame timing).

## Download & Play

Grab the latest prebuilt release from the **[Releases](../../releases)** page,
then drop your own GoldenEye 007 game files into the `assets/` folder next to
the `.exe` (the release notes explain exactly what's needed). Run `ge.exe`.

- 🎮 **Want to play online?** Someone needs to run a server. Download it here →
  **[GoldenEye-Recomp-Server](https://github.com/SunJaycy/GoldenEye-Recomp-Server)**
- 🛠️ **Want to modify the engine / recompiler?** It's built on a modified ReXGlue
  SDK →
  **[GoldenEye-Recomp-rexglue](https://github.com/SunJaycy/GoldenEye-Recomp-rexglue)**

## Playing online

1. One person runs the **[server](https://github.com/SunJaycy/GoldenEye-Recomp-Server)**
   and shares its address + port.
2. Everyone opens **ESC → ONLINE** in the game, enters their **username**, the
   **server address**, the **port**, ticks *Enable online play*, and hits
   **Save & Restart**.
3. Host a match; the others find and join it.

Because players connect *out* to the server, no port-forwarding is needed for
joiners — only the host's server port has to be reachable.

## Building from source (advanced)

Most people should just use the [Releases](../../releases). To build it yourself
you need the recompiler toolchain and your own copy of the game.

### Android
**Prerequisites**
- The [ReXGlue SDK](https://github.com/SunJaycy/GoldenEye-Recomp-rexglue) (provides the `rexglue` CLI + runtime).
- CMake 3.25+, a C++23 compiler (MSVC), Python 3.
- Your own GoldenEye 007 XBLA game files, placed in `assets/`.

**Steps**
```sh
# 1. Generate the recompiled game code from your copy (creates generated/).
rexglue codegen --max_jump_table_entries 2048 ge_config.toml

# 2. Configure, pointing at your local ReXGlue SDK checkout.
cmake --preset win-amd64-relwithdebinfo -DREXSDK_DIR=/path/to/GoldenEye-Recomp-rexglue

# 3. Build.
cmake --build --preset win-amd64-relwithdebinfo
```

### Linux
**Prerequisites**
- Clang 19+ C++23 compiler, CMake 3.25+, Ninja, Python 3, LLD linker.
- Your own GoldenEye 007 XBLA game files, placed in `assets/`.

```sh
# 1. Build the ReXGlue SDK (codegen tool + runtime library).
cd GoldenEye-Recomp-rexglue
mkdir -p build && cd build
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_LINKER_TYPE=LLD
cd ..
cmake --build build -j$(nproc)

# 2. Generate the recompiled game code from your game files.
cd ..
REX_MAX_JUMP_TABLE_ENTRIES=2048 ./GoldenEye-Recomp-rexglue/out/linux-amd64/rexglue codegen ge_manifest.toml

# 3. Configure the game project (links against the rexglue SDK in-tree).
cmake --preset linux-amd64-release \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_LINKER_TYPE=LLD \
    -DREXSDK_DIR=GoldenEye-Recomp-rexglue/

# 4. Build.
cmake --build --preset linux-amd64-release -j$(nproc)
```

The game binary is at `out/build/linux-amd64-release/ge`. All shared libraries
(`librexruntime.so`, etc.) and the config (`ge.toml`) are colocated in the same
directory.

## Legal

GoldenEye 007 and all related assets are property of their respective rights
holders. This project ships **none** of that — no ROM, XEX, textures, audio, or
recompiled game code. It only automates turning a copy *you already own* into a
PC build. Don't ask for or share game files.

## License

The original code in this repository is released into the **public domain**
([The Unlicense](LICENSE)). The ReXGlue SDK it builds against has its own
(BSD-3) license.

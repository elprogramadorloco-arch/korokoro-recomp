# Third-party notices

Nothing below is bundled in this repository. `run.bat` downloads each item from
its official source at a pinned version and verifies it with SHA-256 (see
`tools/pins.json`).

| Component | Source | License |
| --- | --- | --- |
| psxrecomp (recompiler, runtime, OpenBIOS backend) | https://github.com/mstan/psxrecomp | PolyForm Noncommercial 1.0.0 |
| recomp-ui | https://github.com/RetroPortingToolKit/recomp-ui | MIT |
| recomp-net | https://github.com/RetroPortingToolKit/recomp-net | see upstream |
| rbengine | https://github.com/RetroPortingToolKit/rbengine | see upstream |
| cmake-clang-v1 toolchain (LLVM-MinGW, CMake, Ninja, Python, SDL3, zlib) | https://github.com/RetroPortingToolKit/RetroPorting-Toolchains | per component, see the pack's LICENSE files |
| OpenBIOS (shipped by psxrecomp) | https://github.com/grumpycoders/pcsx-redux | MIT |

The files under `project/` (CMakeLists.txt, codegen_setup.*, game.toml and the
other project-layout files) were produced by psxrecomp's New Project Layout
scaffold and are distributed under the psxrecomp license (PolyForm
Noncommercial 1.0.0): **noncommercial use only**.

The launcher scripts (`run.bat`, `tools/*`) are original to this project and
are MIT-licensed (see `LICENSE`).

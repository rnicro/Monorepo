# niri

niri is a scrollable-tiling Wayland compositor. The recipe packages upstream
v26.04 using Void's Cargo build style and the locked Rust dependency graph.

## Build

The package targets `x86_64-musl` and enables D-Bus and GNOME screencast
integration without enabling the default systemd feature. The upstream test
suite is skipped on musl; its EGL-specific tests are also skipped on supported
glibc builds. Shell completions are generated from the installed executable,
and the default KDL configuration is installed as a system configuration
example.

The package depends on the Wayland runtime. A working graphics/input stack,
PipeWire for screencasting, and suitable portal backends are needed for the
corresponding desktop features.

See the upstream [build instructions](https://github.com/niri-wm/niri/blob/main/docs/wiki/Packaging-niri.md)
and [release notes](https://github.com/niri-wm/niri/releases).

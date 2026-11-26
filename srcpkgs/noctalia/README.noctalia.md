# Noctalia

Noctalia is a full Wayland desktop shell: panels, dock, launcher, notifications,
lock screen, wallpaper management and settings.

## Build

The recipe packages the upstream v5.6.0 release archive. It uses Meson and
C++23, keeps the upstream vendored libraries, disables tests for the release
package and disables jemalloc because jemalloc is not supported on musl.

The complete `assets/` tree and `noctalia-pam-helper` are installed by Meson.
Both are runtime requirements; do not split out or remove the assets tree.
Shell completions are generated from the built `noctalia` executable during
package installation.

The recipe targets `x86_64-musl`. Upstream documents GCC 13+ and the system
library requirements in its
[packaging guide](https://github.com/noctalia-dev/noctalia/blob/main/PACKAGING.md)
and [build guide](https://github.com/noctalia-dev/noctalia/blob/main/BUILDING.md).

## Runtime

PipeWire and WirePlumber are package dependencies for audio-related features.
A Secret Service provider (for example GNOME Keyring or KWallet) is optional,
but required for persistent secret storage. Install usable fonts for text
rendering. The lock screen uses the separately installed PAM helper.

Noctalia is a shell, not a Wayland compositor. It must be started from a
supported compositor session. Avoid running another notification daemon or
StatusNotifier host alongside Noctalia unless those services are disabled.

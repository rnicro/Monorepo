# Umbriel

Umbriel is a Wayland compositor built on wlroots. This recipe pins upstream
commit `ac682123129817d5ed91495efc15f48503a42cc0` (2026-11-26); upstream has
not published a tagged source release for this snapshot.

## Build constraints

Umbriel compiles against wlroots private structure layouts and requires
wlroots 0.20.1 or newer, strictly below 0.21. The recipe therefore uses
Void's `wlroots0.20-devel` package. It also requires recent Wayland protocols,
libinput, libxkbcommon, libei, libdrm and libdisplay-info versions; see
upstream's [packaging guide](https://github.com/noctalia-dev/umbriel/blob/main/PACKAGING.md).

The build targets `x86_64-musl`. Tests and jemalloc are disabled, and the
systemd-localed integration is disabled because this package targets musl
Void systems without assuming systemd.

The source URL is pinned to a full Git commit hash. GitHub does not publish a
release-asset checksum for this unreleased snapshot, so XBPS checksum
verification is skipped for this one archive. When updating it, review the
new commit and replace the pinned hash deliberately; do not change the URL to
the moving `main` branch.

## Installed session files

The package installs `umbriel`, `start-umbriel`, the Wayland session desktop
entry, the example configuration, bundled effects, and upstream systemd and
dinit session integration files. Xwayland is included as a runtime dependency.

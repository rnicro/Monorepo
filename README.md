# rnicro Void packages

A personal collection of XBPS source packages and musl/Skylake packaging tweaks for [Void Linux](https://voidlinux.org/).

This repository is an **overlay package collection**, not a fork or complete copy of [void-packages](https://github.com/void-linux/void-packages). Package recipes follow Void's `srcpkgs/<package>/` layout. The official `void-packages` tree supplies `xbps-src`, common build helpers, and the base package templates.

## Packages

| Package | Purpose |
| --- | --- |
| [aria2](srcpkgs/aria2/) | CLI-only aria2 build for `x86_64-musl`; OpenSSL and Skylake tuning |
| [brightnessctl](srcpkgs/brightnessctl/) | brightnessctl for `x86_64-musl`, tuned for Intel Skylake |
| [librewolf](srcpkgs/librewolf/) | Custom LibreWolf package for `x86_64-musl`, native Wayland |
| [linux7.3](srcpkgs/linux7.3/) | Custom Linux 7.3 kernel and headers with a device-focused configuration |
| [tofi](srcpkgs/tofi/) | tofi for `x86_64-musl`, Meson/LTO and Skylake tuning |
| [velotype](srcpkgs/velotype/) | Velotype native Rust/GPUI Markdown editor for `x86_64-musl` |
| [wlsunset](srcpkgs/wlsunset/) | wlsunset for `x86_64-musl`, Wayland and Meson/LTO |

The templates define the supported architecture and CPU tuning. Packages using `-march=skylake` are not intended for older x86_64 processors. Check each package template and its documentation before installing.

## Repository layout

- `srcpkgs/<package>/`: canonical XBPS templates, patches, and package-owned files.
- `maint/<package>/scripts/`: package-specific validation, source preparation, and retained legacy release helpers.
- `maint/librewolf/github-scripts/`: LibreWolf source fallback and package validation/signing helpers.
- `examples/<package>/`: optional runtime configuration examples.
- `docs/packages/`: original package documentation retained from the individual repositories.
- `.github/workflows/ci.yml`: consolidated validation and optional build workflow.

The original per-repository workflows have been replaced by the monorepo workflow. Legacy `legacy-publish-release.sh` helpers are retained for reference but are not invoked by CI. CI builds are uploaded as workflow artifacts; they are not automatically published as separate GitHub Releases.

## Build a package locally

Clone the official Void build tree and this package collection:

```sh
git clone https://github.com/void-linux/void-packages.git
git clone https://github.com/rnicro/Monorepo.git rnicro-packages

cd rnicro-packages
pkg=tofi # choose a package from the table above
```

Prepare the extra inputs only for the package that needs them, before overlaying its recipe:

```sh
# Velotype: download and verify the pinned upstream archive.
version="$(sed -n 's/^version=//p' srcpkgs/velotype/template)"
bash maint/velotype/scripts/prepare-source.sh \
  "../void-packages/hostdir/sources/velotype-$version"

# LibreWolf: download and verify Mozilla's pinned host-side fallback files.
bash maint/librewolf/github-scripts/prepare-source-fallbacks.sh
```

Then overlay and build the selected package:

```sh
rm -rf "../void-packages/srcpkgs/$pkg"
cp -a "srcpkgs/$pkg" "../void-packages/srcpkgs/$pkg"

cd ../void-packages
./xbps-src -A x86_64-musl binary-bootstrap
./xbps-src -A x86_64-musl pkg "$pkg"
```

For LibreWolf, run its fallback preparation command before copying `srcpkgs/librewolf`. For Velotype, the preparation helper stores the verified archive where its package template expects it. Keep `-A x86_64-musl` on both `xbps-src` commands when building from a glibc host. Packages are written under `hostdir/binpkgs/`.

## Validation and CI

The default GitHub Actions workflow validates shell syntax, package metadata, package-specific checks, the custom kernel configuration, and LibreWolf's pinned source fallbacks.

To run real `xbps-src` builds, open **Actions → Validate and build XBPS packages → Run workflow** and enable **Build all packages**. The build matrix targets `x86_64-musl` and uploads the resulting `.xbps` files as workflow artifacts. It does not publish releases or overwrite existing package releases.

## Updating recipes

Follow Void's [package contribution guide](https://github.com/void-linux/void-packages/blob/master/CONTRIBUTING.md) and [manual](https://github.com/void-linux/void-packages/blob/master/Manual.md). Verify upstream source hashes, preserve package-specific patches and dependency constraints, and increment `revision` when a packaging-only change alters the output for an unchanged upstream version.

Original project-specific notes and hardware constraints are retained in [docs/packages](docs/packages/).

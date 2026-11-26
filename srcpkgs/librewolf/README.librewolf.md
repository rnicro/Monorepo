# LibreWolf

A hardware-specific Void Linux package for [LibreWolf](https://librewolf.net/), built for `x86_64-musl` with native GTK3 Wayland support.

## Package profile

| Field | Value |
| --- | --- |
| Upstream version | `161.0` |
| Source revision | `1` |
| Package revision | `7` |
| Target | `x86_64-musl` |
| CPU baseline | Intel Skylake |
| Toolchain | LLVM / Clang / LLD 23 |
| Source | [LibreWolf source archive](https://librewolf.dev/librewolf/source/releases) |
| SHA-256 | `81646ff5d0fda58239270ede958bd6655f502b2e3891cc7e9ce95c33629640d3` |

The build enables LTO and PGO by default, uses sccache, and builds the browser with the native Wayland toolkit. PGO profile generation or use falls back to an LTO build if it cannot complete. Xvfb is used only for the isolated CI training run; it is not the shipped display backend.

The template and all downstream patches, browser preferences, desktop integration files and stylesheets are stored under this package directory. The build does not fetch any packaging files from another `rnicro` repository.

## Additional upstream source files

Some LibreWolf source archives omit Mozilla's host-side `config/nsinstall.c` and `config/pathsub.c`. The build helper downloads these files from a fixed Mozilla Gecko commit and verifies their SHA-256 before placing them in the overlaid package's `files/` directory. The pinned commit and expected hashes are recorded in [prepare-source-fallbacks.sh](../../maint/librewolf/scripts/prepare-source-fallbacks.sh).

Do not replace these sources with files from a moving branch. When updating the pinned Mozilla commit, update both hashes and verify the source files against that exact commit.

## Build

From the repository root:

```sh
git clone https://github.com/void-linux/void-packages.git ../void-packages
bash maint/build-package.sh librewolf ../void-packages
```

The shared script verifies the template, overlays the package, prepares the hash-verified Mozilla fallbacks, bootstraps `x86_64-musl` and builds with PGO enabled. The generated package is placed in `dist/`.

## Maintenance

Update `version`, `_rev`, `distfiles` and `checksum` together when changing the LibreWolf source release. Increment `revision` when package files, patches, build options or packaging logic change without an upstream source version change.

Before publishing a new build, review the patch set against the new source, validate that LLVM, Clang, LLD, Rust and wasi-sdk remain compatible, and complete a real `xbps-src` package build. Keep the browser's normal content sandbox enabled. Review the [LibreWolf source releases](https://librewolf.net/librewolf/source/releases) and [Void's Firefox recipe](https://github.com/void-linux/void-packages/tree/master/srcpkgs/firefox) for upstream build-system changes.

The recipe intentionally disables extension-signature enforcement. Only install extensions from sources you trust.

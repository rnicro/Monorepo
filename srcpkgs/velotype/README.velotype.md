# velotype

Void Linux package for [Velotype](https://github.com/manyougz/velotype), a native Rust/GPUI Markdown editor.

## Package profile

| Field | Value |
| --- | --- |
| Upstream version | `0.7.8` |
| Package revision | `1` |
| Upstream commit | `07a24a9b5b953539dede8e61a1f7d9d0adbba590` |
| Target | `x86_64-musl` |
| CPU baseline | Intel Skylake |
| Build system | Cargo |
| Source | [pinned upstream commit](https://github.com/manyougz/velotype/commit/07a24a9b5b953539dede8e61a1f7d9d0adbba590) |
| SHA-256 | `75c190c578b8dda567a6eca8ed0ad1568cd714b7f90d1966e98b2141608a5d48` |

The source commit and SHA-256 are pinned in [template](template). The package is Wayland-only: it disables GPUI's default platform features, enables the Wayland feature set, checks Cargo's resolved feature graph, and rejects direct X11 library dependencies. C/C++ and Rust code target Skylake. The release profile uses optimization level 3 and LTO; sccache and Cargo's registry are cached in CI.

## Source preparation

The build helper downloads the exact commit archive and verifies its SHA-256 before using it. The archive is stored in Void's `hostdir/sources/` so repeated builds can reuse it. A bad or stale cached archive is discarded instead of being trusted.

## Build

From the repository root:

```sh
git clone https://github.com/void-linux/void-packages.git ../void-packages
bash maint/build-package.sh velotype ../void-packages
```

The shared script prepares the pinned source archive, overlays the package recipe, bootstraps `x86_64-musl`, builds the package and copies the resulting `.xbps` file to `dist/`.

## Maintenance

When updating Velotype, review the upstream commit, update `version`, `_commit`, `distfiles` and `checksum` together, and inspect the GPUI platform dependency. Update the expected feature names in the template and tests if upstream changes its platform crate or features. Never auto-regenerate the expected checksum from a downloaded file.

Increment `revision` when package-only changes alter the output. Run the template, source-cache and Wayland feature-graph tests, then complete a real package build. Upstream reference: [Velotype](https://github.com/manyougz/velotype).

# wlsunset

Void Linux XBPS package for [wlsunset](https://git.sr.ht/~kennylevinsen/wlsunset), a colour-temperature tool for Wayland compositors.

## Package profile

| Field | Value |
| --- | --- |
| Upstream version | `0.4.0` |
| Package revision | `2` |
| Target | `x86_64-musl` |
| CPU baseline | Intel Skylake |
| Build system | Meson |
| Source | [wlsunset 0.4.0 archive](https://git.sr.ht/~kennylevinsen/wlsunset/archive/0.4.0.tar.gz) |
| SHA-256 | `a86ffb1793fe622802ec25795b69df864715986ecc175f7734e739c9e264ed72` |

The recipe enables Meson's optimization level 2 and LTO, uses Wayland protocol definitions and installs the MIT license. C uses `-O2 -march=skylake -mtune=skylake -fno-plt`.

At runtime, wlsunset needs the active compositor to expose the `wlr-gamma-control-unstable-v1` protocol. The presence of an Intel GPU alone does not guarantee compositor support.

## Build

From the repository root:

```sh
git clone https://github.com/void-linux/void-packages.git ../void-packages
bash maint/build-package.sh wlsunset ../void-packages
```

The shared script overlays this recipe, bootstraps `x86_64-musl`, builds the package and places the resulting `.xbps` file in `dist/`.

## Maintenance

For an upstream update, change `version`, `distfiles` and `checksum` in [template](template), then verify the archive SHA-256. Start a new upstream version at revision 1; increment `revision` for packaging changes that alter the output.

Re-check Wayland protocol and Meson build dependencies against [upstream wlsunset](https://git.sr.ht/~kennylevinsen/wlsunset) and [Void's wlsunset recipe](https://github.com/void-linux/void-packages/tree/master/srcpkgs/wlsunset).

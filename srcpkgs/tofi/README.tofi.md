# tofi

Void Linux XBPS package for [tofi](https://github.com/philj56/tofi), a dynamic menu for Wayland.

## Package profile

| Field | Value |
| --- | --- |
| Upstream version | `0.9.1` |
| Package revision | `2` |
| Target | `x86_64-musl` |
| CPU baseline | Intel Skylake |
| Build system | Meson |
| Source | [tofi v0.9.1](https://github.com/philj56/tofi/releases/tag/v0.9.1) |
| SHA-256 | `dd55347b509af786f133def64f3a86f1db258b5e196de80e53d62827bdcc37bc` |

The recipe enables Meson's optimization level 2 and LTO. On musl, it adds `musl-fts-devel` and `-lfts`, matching the platform-specific dependency needed by Void's package.

The optional [dwl profile](../../examples/tofi/dwl-run.conf) is kept in this repository. It uses a local font file path; confirm that font exists on the target system before using the profile.

## Build

From the repository root:

```sh
git clone https://github.com/void-linux/void-packages.git ../void-packages
bash maint/build-package.sh tofi ../void-packages
```

The shared script overlays this recipe, bootstraps `x86_64-musl`, builds the package and places the resulting `.xbps` file in `dist/`.

## Maintenance

For an upstream update, change `version`, `distfiles` and `checksum` in [template](template). Start a new upstream version at revision 1. Increment `revision` when packaging changes alter the generated package. Re-check the musl FTS dependency and Meson options against [upstream tofi](https://github.com/philj56/tofi) and [Void's tofi recipe](https://github.com/void-linux/void-packages/tree/master/srcpkgs/tofi).

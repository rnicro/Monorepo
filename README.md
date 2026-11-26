# rnicro Void packages

An XBPS source-package collection for Void Linux. The recipes are maintained in this repository and use Void's standard `srcpkgs/<package>/` layout.

**The repository is self-contained with respect to the former standalone rnicro package repositories.** Package templates, patches, configuration, scripts, tests and documentation are stored here. Builds do not clone or read sibling `rnicro` repositories. Only the upstream Void build tree and each package's official upstream source archives are fetched.

## Packages

| Package | Purpose | Guide | Manual build |
| --- | --- | --- | --- |
| [aria2](srcpkgs/aria2/) | CLI-only downloader; OpenSSL and Skylake tuning | [README](srcpkgs/aria2/README.aria2.md) | [Build](.github/workflows/build-aria2.yml) |
| [brightnessctl](srcpkgs/brightnessctl/) | Brightness and LED control utility | [README](srcpkgs/brightnessctl/README.brightnessctl.md) | [Build](.github/workflows/build-brightnessctl.yml) |
| [labwc](srcpkgs/labwc/) | Stacking Wayland compositor; wlroots 0.20 | [README](srcpkgs/labwc/README.labwc.md) | [Build](.github/workflows/build-labwc.yml) |
| [librewolf](srcpkgs/librewolf/) | Native Wayland browser build | [README](srcpkgs/librewolf/README.librewolf.md) | [Build](.github/workflows/build-librewolf.yml) |
| [linux7.3](srcpkgs/linux7.3/) | Device-specific Linux kernel and headers | [README](srcpkgs/linux7.3/README.linux7.3.md) | [Build](.github/workflows/build-linux7.3.yml) |
| [niri](srcpkgs/niri/) | Scrollable-tiling Wayland compositor | [README](srcpkgs/niri/README.niri.md) | [Build](.github/workflows/build-niri.yml) |
| [noctalia](srcpkgs/noctalia/) | Customizable Wayland desktop shell | [README](srcpkgs/noctalia/README.noctalia.md) | [Build](.github/workflows/build-noctalia.yml) |
| [tofi](srcpkgs/tofi/) | Wayland launcher; Meson and LTO | [README](srcpkgs/tofi/README.tofi.md) | [Build](.github/workflows/build-tofi.yml) |
| [umbriel](srcpkgs/umbriel/) | Wayland compositor built on wlroots 0.20 | [README](srcpkgs/umbriel/README.umbriel.md) | [Build](.github/workflows/build-umbriel.yml) |
| [velotype](srcpkgs/velotype/) | Native Rust/GPUI Markdown editor | [README](srcpkgs/velotype/README.velotype.md) | [Build](.github/workflows/build-velotype.yml) |
| [wlsunset](srcpkgs/wlsunset/) | Wayland colour-temperature utility | [README](srcpkgs/wlsunset/README.wlsunset.md) | [Build](.github/workflows/build-wlsunset.yml) |

All recipes target `x86_64-musl`. Packages using `-march=skylake` require an Intel Skylake-compatible or newer CPU. The custom `linux7.3` configuration is for the HP Pavilion x360 Convertible T0Y58PA; read its package guide before installing it on other hardware.

## Build with GitHub Actions

Open **Actions** and run the dedicated **Build <package>** workflow, or run **Validate and build XBPS packages** and choose one package or `all`. Successful builds upload ordinary `.xbps` files as workflow artifacts; there is no signed repository or release publisher. Download the artifact from the completed workflow run. Artifacts are retained for 14 days.

To install a downloaded package on a compatible Void Linux system:

```sh
sudo xbps-install ./package-version_revision.x86_64-musl.xbps
```

For `linux7.3`, install the kernel and headers packages from the same build artifact and keep a known-working kernel installed until the new kernel is verified.

## Build locally

Clone this repository and the official Void build tree:

```sh
git clone https://github.com/rnicro/Monorepo.git
git clone https://github.com/void-linux/void-packages.git
cd Monorepo
bash maint/build-package.sh tofi ../void-packages
```

Replace `tofi` with the required package name. The same helper is used by CI. It validates and overlays the local recipe, prepares any pinned extra source inputs, runs `xbps-src` for `x86_64-musl`, and places the generated packages in `dist/`. See [package maintenance](docs/MAINTAINING.md) for source updates, checksums, revisions, tests and package-specific notes.

## Repository layout

- `srcpkgs/<package>/`: full XBPS template, package files, patches, config and package guide.
- `maint/build-package.sh`: shared local and CI build entry point.
- `maint/<package>/scripts/`: package validation and source preparation helpers.
- `.github/workflows/build-<package>.yml`: small manual workflow per package.
- `.github/workflows/build-package.yml`: shared checkout, cache, build and artifact implementation.
- `examples/<package>/`: optional runtime configuration examples.
- `docs/MAINTAINING.md`: maintenance and cache policy.

For packaging conventions, follow the official Void Linux [contribution guide](https://github.com/void-linux/void-packages/blob/master/CONTRIBUTING.md) and [XBPS manual](https://github.com/void-linux/void-packages/blob/master/Manual.md).

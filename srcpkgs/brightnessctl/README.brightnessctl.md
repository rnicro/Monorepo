# brightnessctl

Void Linux XBPS package for [brightnessctl](https://github.com/Hummer12007/brightnessctl).

## Package profile

| Field | Value |
| --- | --- |
| Upstream version | `0.5.1` |
| Package revision | `2` |
| Target | `x86_64-musl` |
| CPU baseline | Intel Skylake |
| Build system | Upstream GNU Makefile |
| Source | [0.5.1 source archive](https://github.com/Hummer12007/brightnessctl/archive/0.5.1.tar.gz) |
| SHA-256 | `a68869e23f56ac4f2e28f1783002810ddbf10f95e1af9b48b2912fb169f46994` |

The recipe passes Void's build flags through the upstream Makefile and installs udev rules in `/usr/lib/udev/rules.d`. C compilation uses `-O2 -march=skylake -mtune=skylake -fno-plt`.

The program controls devices exposed by the running kernel. It does not include or install a backlight driver. Device availability and permissions depend on the kernel, udev rules and the relevant system groups.

## Build

From the repository root:

```sh
git clone https://github.com/void-linux/void-packages.git ../void-packages
bash maint/build-package.sh brightnessctl ../void-packages
```

The shared script overlays this recipe, bootstraps `x86_64-musl`, builds the package and places the resulting `.xbps` file in `dist/`.

## Maintenance

For an upstream update, change `version`, `distfiles` and `checksum` in [template](template), then verify the SHA-256 against the official source archive. Start a new upstream version at revision 1. Increment `revision` for packaging-only changes that alter the output.

Check the [upstream project](https://github.com/Hummer12007/brightnessctl) and [Void's brightnessctl recipe](https://github.com/void-linux/void-packages/tree/master/srcpkgs/brightnessctl) for changes to install paths, udev rules or build requirements.

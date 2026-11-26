# linux7.3

Hardware-specific Linux kernel and headers package for the HP Pavilion x360 Convertible T0Y58PA.

## Package profile

| Field | Value |
| --- | --- |
| Upstream version | `7.3.6` |
| Package revision | `1` |
| Target | `x86_64-musl` |
| CPU baseline | Intel Skylake |
| Source | [Linux kernel releases](https://www.kernel.org/) |
| Configuration | [x86_64-dotconfig-custom](files/x86_64-dotconfig-custom) |

Linux 7.3.6 was published on November 23, 2026. The recipe uses the unchanged 7.3 base archive plus the 7.3.6 incremental stable patch; both SHA-256 digests are sourced from kernel.org's signed [checksum list](https://kernel.org/pub/linux/kernel/v7.x/sha256sums.asc). The recipe, kernel configuration, downstream patches, debug helper and configuration validator are all stored in this package directory. The kernel compiler flags target Skylake; they are not selected from the GitHub runner's CPU.

The custom configuration is specific to the reference laptop: Intel HD Graphics 520, Intel Wireless 3165, Realtek RTL810xE Ethernet, Skylake audio, ELAN touchscreen, Synaptics touchpad, HP sensors and the built-in SATA/ext4 boot path. It is not a general-purpose kernel configuration. Review the configuration and hardware notes before installing it on another machine.

## Build

From the repository root:

```sh
git clone https://github.com/void-linux/void-packages.git ../void-packages
bash maint/build-package.sh linux7.3 ../void-packages
```

The shared script overlays the complete local recipe and configuration, bootstraps `x86_64-musl`, builds the kernel and headers packages and copies the resulting `.xbps` files into `dist/`.

## Maintenance

When updating the kernel, change `version`, the source `distfiles` and both checksums in [template](template). Refresh the custom configuration against the matching kernel release and re-check every downstream patch. Run [validate-config.sh](files/validate-config.sh) and complete a real package build before using the new kernel.

Increment `revision` when packaging changes alter output for the same kernel version. Keep a known-working kernel installed until the updated kernel has booted and its graphics, networking, audio, input devices, suspend/resume and storage have been tested.

Upstream references: [kernel.org](https://www.kernel.org/) and [Void's Linux package tree](https://github.com/void-linux/void-packages/tree/master/srcpkgs).

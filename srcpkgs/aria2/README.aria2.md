# aria2

Void Linux XBPS package for [aria2](https://github.com/aria2/aria2).

## Package profile

| Field | Value |
| --- | --- |
| Upstream version | `1.37.0` |
| Package revision | `3` |
| Target | `x86_64-musl` |
| CPU baseline | Intel Skylake |
| Build system | GNU configure |
| Source | [aria2 release archive](https://github.com/aria2/aria2/releases/tag/release-1.37.0) |
| SHA-256 | `60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b` |

The recipe builds the `aria2c` command-line program only. It enables OpenSSL, disables GnuTLS and disables the optional `libaria2` library API. Build dependencies include c-ares, Expat, GMP, OpenSSL, SQLite and zlib.

C and C++ use `-O2 -march=skylake -mtune=skylake -fno-plt`. This is a hardware-specific binary, not a generic x86_64 build.

## Included configuration

`examples/aria2/hp-pavilion-hdd-ext4.conf` is an optional runtime profile for downloads stored on ext4. It uses `file-allocation=falloc`; it does not replace the user's normal aria2 configuration. The profile is not a build dependency.

## Build

From the repository root:

```sh
git clone https://github.com/void-linux/void-packages.git ../void-packages
bash maint/build-package.sh aria2 ../void-packages
```

The shared script overlays this recipe, bootstraps `x86_64-musl`, builds the package and places the resulting `.xbps` file(s) in `dist/`.

## Maintenance

For an upstream update, change `version`, `distfiles` and `checksum` in [template](template), then verify the archive SHA-256 against the official release. Start a new upstream version at revision 1. Increment `revision` when packaging changes alter the output for the same upstream version.

Keep the CLI-only configure options and target architecture restriction intentional. Re-check the [upstream release notes](https://github.com/aria2/aria2/releases) and [Void's aria2 recipe](https://github.com/void-linux/void-packages/tree/master/srcpkgs/aria2) when updating dependencies or configure flags.

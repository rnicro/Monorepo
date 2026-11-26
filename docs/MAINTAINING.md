# Maintaining packages

This repository is the source of truth for all eleven packages. It contains each XBPS template, patch, configuration file, package-specific test, source-preparation helper and package guide. **A build does not clone or read any other `rnicro` repository.** The old standalone repositories can be archived or deleted without removing packaging inputs from this monorepo.

The build still uses the upstream [Void `void-packages` tree](https://github.com/void-linux/void-packages) for `xbps-src`, common build helpers and dependency templates. Each application source is fetched from the official upstream URL recorded in its local package template.

## Build a package

Use the same helper locally and in GitHub Actions:

```sh
git clone https://github.com/rnicro/Monorepo.git
git clone https://github.com/void-linux/void-packages.git
cd Monorepo
bash maint/build-package.sh tofi ../void-packages
```

Replace `tofi` with `aria2`, `brightnessctl`, `labwc`, `librewolf`, `linux7.3`, `niri`, `noctalia`, `umbriel`, `velotype` or `wlsunset`. The helper validates the package, overlays its complete local directory into Void's `srcpkgs/`, prepares any pinned extra source files, bootstraps `x86_64-musl`, and copies built packages into `dist/`.

The host must have the normal tools required by `xbps-src` and a working `xbps-install`. GitHub Actions installs Void's static xbps tools automatically. To build on a non-Void host, use Void's documented [cross-build instructions](https://github.com/void-linux/void-packages#building-packages-natively-for-the-musl-c-library).

## Update a package safely

1. Read the package-local `README.<package>.md` and the upstream project's release notes.
2. Update the source version, source URL and SHA-256 together in `srcpkgs/<package>/template`. For Velotype, also update its pinned commit. For LibreWolf, update its source revision.
3. Download the official archive independently and verify its SHA-256. Never replace a checksum with a value calculated from an unverified or moving download.
4. Set `revision=1` for a new upstream version. Increment the existing revision when packaging-only changes affect the output for the same upstream version.
5. Review patches, build dependencies, target flags and package-specific tests.
6. Run `bash maint/<package>/scripts/test-template.sh`, any focused tests under that package's `maint/` directory, and a complete build with `bash maint/build-package.sh <package> ../void-packages`.

Umbriel currently has no published source release archive. Its template is pinned to a full upstream commit SHA and uses `checksum=SKIP` for GitHub's generated commit archive. Review the commit and update the pin deliberately; never change that URL to a moving branch. Umbriel and labwc both depend on the wlroots 0.20 ABI, and Umbriel additionally relies on wlroots private structure layouts.

The recipes target `x86_64-musl`. Where `-march=skylake` is set, the result requires an Intel Skylake-compatible or newer CPU. Do not replace target flags with `-march=native`: GitHub's build runner is not the target laptop.

## GitHub Actions and caches

Each `Build <package>` workflow calls the shared `.github/workflows/build-package.yml`. The validation workflow checks all recipes and helper scripts; its manual dispatch can build one package or all packages.

The shared workflow maintains these caches:

- **Static xbps tools:** one stable cache key for all packages, at `/opt/xbps`. Only a cache miss downloads and extracts `xbps-static`. Bump the `xbps-static` cache-key version in the shared workflow when intentionally refreshing the cached toolchain.
- **Void build dependencies:** binary packages are cached per package for the exact Void `master` commit and target architecture. A different Void commit gets a separate cache; stale binary packages are not restored across commits.
- **Source archives:** cached per package. Velotype's source helper checks the pinned SHA-256 before reusing an archive.
- **Compiler caches:** Velotype's Cargo registry/sccache and niri's Cargo registry are cached separately from the common Void caches. LibreWolf's sccache/PGO data is also cached separately.

GitHub Actions caches are an optimization, not a build input. Deleting a cache must only make the next build slower, never change which source versions are selected or bypass checksum verification.

## What to update when changing the build

- Keep package-specific commands and flags in the package template or its helper, not duplicated across eleven workflow files.
- Keep common checkout, xbps installation, caching and artifact upload in `.github/workflows/build-package.yml`.
- Keep the manual package workflow files as small wrappers that only select a package.
- Keep package-specific tests close to their package under `maint/<package>/scripts/`.
- Change the shared build helper and this document together if build steps or cache paths move.

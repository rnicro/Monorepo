# Repository consolidation

This monorepo consolidates the XBPS package content from the following rnicro repositories:

- [aria2](https://github.com/rnicro/aria2) → `srcpkgs/aria2`
- [brightnessctl](https://github.com/rnicro/brightnessctl) → `srcpkgs/brightnessctl`
- [librewolf](https://github.com/rnicro/librewolf) → `srcpkgs/librewolf`
- [linux](https://github.com/rnicro/linux) → `srcpkgs/linux7.3`
- [tofi](https://github.com/rnicro/tofi) → `srcpkgs/tofi`
- [velotype](https://github.com/rnicro/velotype) → `srcpkgs/velotype`
- [wlsunset](https://github.com/rnicro/wlsunset) → `srcpkgs/wlsunset`

The original package documentation is retained in `docs/packages/`. Each package has a `maint/<package>/scripts/test-template.sh` validation entry point; focused tests and source-preparation helpers remain beside it. Manual builds sign and publish package archives to the persistent `xbps-repository` GitHub Release using the consolidated `.github/workflows/ci.yml` workflow.

The `setup` and `drivers` repositories are intentionally excluded. The latter contained only a placeholder README at the time of consolidation.

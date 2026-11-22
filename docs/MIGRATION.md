# Repository consolidation

This monorepo consolidates the XBPS package content from the following rnicro repositories:

- [aria2](https://github.com/rnicro/aria2) → `srcpkgs/aria2`
- [brightnessctl](https://github.com/rnicro/brightnessctl) → `srcpkgs/brightnessctl`
- [librewolf](https://github.com/rnicro/librewolf) → `srcpkgs/librewolf`
- [linux](https://github.com/rnicro/linux) → `srcpkgs/linux7.3`
- [tofi](https://github.com/rnicro/tofi) → `srcpkgs/tofi`
- [velotype](https://github.com/rnicro/velotype) → `srcpkgs/velotype`
- [wlsunset](https://github.com/rnicro/wlsunset) → `srcpkgs/wlsunset`

The original package documentation is retained in `docs/packages/`. Package validation and source preparation tools remain under `maint/<package>/`. Old per-repository release automation was removed; manual builds upload XBPS artifacts through the consolidated `.github/workflows/ci.yml` workflow.

The `setup` and `drivers` repositories are intentionally excluded. The latter contained only a placeholder README at the time of consolidation.

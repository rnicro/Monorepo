# Repository consolidation

This monorepo consolidates the XBPS package content from the following rnicro repositories:

- [aria2](https://github.com/rnicro/aria2) → `srcpkgs/aria2`
- [brightnessctl](https://github.com/rnicro/brightnessctl) → `srcpkgs/brightnessctl`
- [librewolf](https://github.com/rnicro/librewolf) → `srcpkgs/librewolf`
- [linux](https://github.com/rnicro/linux) → `srcpkgs/linux7.3`
- [tofi](https://github.com/rnicro/tofi) → `srcpkgs/tofi`
- [velotype](https://github.com/rnicro/velotype) → `srcpkgs/velotype`
- [wlsunset](https://github.com/rnicro/wlsunset) → `srcpkgs/wlsunset`

The original package READMEs are retained in `docs/packages/`. Package tests, source preparation tools, and release helpers are retained under `maint/<package>/`; GitHub Actions workflows are consolidated into `.github/workflows/ci.yml`. Retained release helpers are legacy utilities and are not automatically executed.

The `setup` and `drivers` repositories are intentionally excluded. The latter contained only a placeholder README at the time of consolidation.

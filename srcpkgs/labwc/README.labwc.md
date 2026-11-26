# labwc

labwc is a stacking Wayland compositor based on wlroots and the Openbox
configuration specification.

The recipe packages upstream 0.20.3 and uses Void's wlroots 0.20 ABI. Xwayland,
SVG rendering, icons and man-page generation are enabled through the normal
Void dependencies and Meson defaults. The optional systemd session target is
disabled for this musl-focused package.

Build target: `x86_64-musl`.

See the upstream [build instructions](https://github.com/labwc/labwc#build-and-installation)
and [documentation](https://labwc.github.io/).

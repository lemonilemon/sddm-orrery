# Orrery

https://github.com/user-attachments/assets/c8f25979-4ede-4a9e-a1e1-bc2fcbd687a7

An SDDM theme in the style of [lemonilemon.csie.org](https://lemonilemon.csie.org/)'s
night page: the same star field, and the inner planets seen from Earth. The
planets sit where they really are on the day you log in, from J2000 mean orbital
elements (good to a few degrees). On load the last five years of their paths
draw in and stop on today.

![The intro: five years of paths drawing in](https://github.com/user-attachments/assets/7ea89eb4-5001-4138-aaad-a61dfe8c4a41)

The layout follows [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme):
a centred strip holds the clock and the form, and the orrery shows through it
blurred.

- Click a planet outside the strip, or the caption in the bottom-right corner,
  to see the others from it.
- The play button runs time forward from today; the caption's date follows.
- Tab moves through the form, the power buttons, the session switch, the
  caption and the play button; Space or Return presses the one in focus.

| Seen from Mars | Seen from the Sun | Seen from Venus |
| --- | --- | --- |
| ![The planets moving with time running, seen from Mars](https://github.com/user-attachments/assets/547a164e-b168-46b5-b00c-244cf3bc37cd) | ![The planets moving with time running, seen from the Sun](https://github.com/user-attachments/assets/b054286c-7803-478b-b1cf-a0f025bc859b) | ![The planets moving with time running, seen from Venus](https://github.com/user-attachments/assets/b19c0c7d-9af0-47e5-81c8-c37f4e8c92ca) |

Needs SDDM with Qt 6.6 or later. Text is set in IBM Plex Sans and IBM Plex
Mono. The greeter only sees system fonts, so the theme loads the three faces it
uses from its own `fonts/` directory; the package puts them there and checks at
build time that they are those families.

## NixOS

```nix
# flake.nix
inputs.sddm-orrery = {
  url = "github:lemonilemon/sddm-orrery";
  inputs.nixpkgs.follows = "nixpkgs";
};

# a NixOS module
{ inputs, pkgs, ... }:
let
  orrery = inputs.sddm-orrery.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    osLabel = "NixOS 26.11 Zokor";
  };
in
{
  services.displayManager.sddm.theme = "${orrery}/share/sddm/themes/orrery";
}
```

SDDM takes a path for the theme, and the theme carries its own fonts, so this
is the whole setup: nothing goes in `environment.systemPackages` or
`fonts.packages`.

## Other distributions

Copy `theme/` to `/usr/share/sddm/themes/orrery`. The Nix package generates
`theme.conf`, so the repository doesn't have one; write it next to `Main.qml`:

```ini
[General]
Font="IBM Plex Sans"
LabelFont="IBM Plex Mono"
OsLabel=""
ShowAllPowerButtons="false"
TwelveHourClock="false"
Viewpoint="earth"
Intro="true"
```

Keep the quotes: SDDM reads an unquoted value with a comma in it as a list.

Put `IBMPlexSans-Regular.otf`, `IBMPlexSans-Medium.otf` and
`IBMPlexMono-Regular.otf` from [IBM Plex](https://github.com/IBM/plex) in a
`fonts` directory next to `Main.qml`, then select the theme:

```ini
# /etc/sddm.conf.d/theme.conf
[Theme]
Current=orrery
```

`sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/orrery` opens it
in a window, so you can check it before logging out.

## Options

`package.nix` takes these as `override` arguments; they end up in `theme.conf`
under the key in the second column.

| Argument | Key | Default | Effect |
| --- | --- | --- | --- |
| `osLabel` | `OsLabel` | `""` | Text in the bottom-left corner; empty hides it |
| `hostLabel` | `HostLabel` | `null` | Text beside the mark in the top-left corner; `null` leaves the key out and shows the hostname, empty hides it |
| `showAllPowerButtons` | `ShowAllPowerButtons` | `false` | Show every power button even when SDDM reports it unavailable |
| `twelveHourClock` | `TwelveHourClock` | `false` | Show the clock as 2:04 with AM or PM beside it instead of 02:04 |
| `viewpoint` | `Viewpoint` | `"earth"` | Body the orrery is seen from at login: `"sun"`, `"venus"`, `"earth"` or `"mars"` |
| `intro` | `Intro` | `true` | Draw the last five years of paths in on load; `false` shows them already drawn |
| `introStart` | `IntroStart` | `null` | Moment the intro starts from, as an ISO 8601 date-time such as `"1970-01-01T00:00:00Z"`; `null` leaves the key out and starts five years before today. The paths stay five years long, and the intro runs at two years a second, so 1970 takes about half a minute |

## Preview

```sh
nix run .#preview -- out.png 1920x1200 5
```

Renders the real `sddm-greeter-qt6 --test-mode` in a headless sway and saves a
screenshot after 5 seconds, once the intro has finished. Every argument is
optional. Test mode has no SDDM daemon, so the hostname is blank and the power
buttons are forced on.

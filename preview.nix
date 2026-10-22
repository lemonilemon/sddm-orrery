{
  writeShellApplication,
  makeFontsConf,
  sway,
  grim,
  kdePackages,
  theme,
}:
let
  fontsConf = makeFontsConf { fontDirectories = [ theme.fonts ]; };
in
writeShellApplication {
  name = "orrery-preview";
  runtimeInputs = [
    sway
    grim
  ];
  text = ''
    out=$(realpath -m "''${1:-orrery-preview.png}")
    size=''${2:-1920x1080}
    wait=''${3:-5}

    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    cp -r --no-preserve=mode ${theme}/share/sddm/themes/orrery "$work/theme"
    printf '[General]\nShowAllPowerButtons=true\n' > "$work/theme/theme.conf.user"

    cat > "$work/run" <<EOF
    #!/bin/sh
    ${kdePackages.sddm}/bin/sddm-greeter-qt6 --test-mode --theme "$work/theme" > "$work/greeter.log" 2>&1 &
    sleep $wait
    grim -o HEADLESS-1 "$out"
    kill \$!
    swaymsg exit
    EOF
    chmod +x "$work/run"

    cat > "$work/sway.conf" <<EOF
    output HEADLESS-1 resolution $size
    default_border none
    for_window [title=".*"] fullscreen enable
    exec "$work/run"
    EOF

    env -u WAYLAND_DISPLAY -u DISPLAY \
      FONTCONFIG_FILE=${fontsConf} WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
      sway -c "$work/sway.conf" > "$work/sway.log" 2>&1 || true

    cat "$work/greeter.log" >&2
    [ -s "$out" ] || { echo "no screenshot; sway log:" >&2; cat "$work/sway.log" >&2; exit 1; }
    echo "$out"
  '';
}

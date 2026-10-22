{
  writeShellApplication,
  makeFontsConf,
  sway,
  grim,
  util-linux,
  procps,
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
    util-linux
    procps
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
    # SDDM logs to the journal unless stderr is a terminal, so give it one.
    script -qfec '${kdePackages.sddm}/bin/sddm-greeter-qt6 --test-mode --theme "$work/theme"' /dev/null > "$work/greeter.log" 2>&1 &
    sleep $wait
    grim -o HEADLESS-1 "$out"
    pkill -P \$!
    swaymsg exit
    EOF
    chmod +x "$work/run"

    cat > "$work/sway.conf" <<EOF
    output HEADLESS-1 resolution $size
    default_border none
    for_window [title=".*"] fullscreen enable
    exec "$work/run"
    EOF

    # The real greeter doesn't inherit the desktop's Qt settings, such as its scale factor or
    # platform theme, so neither does this one.
    env -i PATH="$PATH" HOME="$HOME" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" LANG=C.UTF-8 \
      FONTCONFIG_FILE=${fontsConf} WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
      sway -c "$work/sway.conf" > "$work/sway.log" 2>&1 || true

    tr -d '\r' < "$work/greeter.log" >&2
    [ -s "$out" ] || { echo "no screenshot; sway log:" >&2; cat "$work/sway.log" >&2; exit 1; }
    echo "$out"
  '';
}

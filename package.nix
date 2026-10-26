{
  lib,
  stdenvNoCC,
  formats,
  fontconfig,
  ibm-plex,
  osLabel ? "",
  hostLabel ? null,
  showAllPowerButtons ? false,
  twelveHourClock ? false,
  viewpoint ? "earth",
  intro ? true,
  introStart ? null,
}:
let
  fonts = ibm-plex.override {
    families = [
      "sans"
      "mono"
    ];
  };

  families = {
    Font = "IBM Plex Sans";
    LabelFont = "IBM Plex Mono";
  };

  # SDDM reads theme.conf with QSettings, which splits an unquoted value at its commas.
  ini = formats.ini {
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString = v: "\"${lib.escape [ "\\" "\"" ] v}\"";
    } "=";
  };

  themeConf = ini.generate "theme.conf" {
    General =
      families
      // {
        OsLabel = osLabel;
        ShowAllPowerButtons = lib.boolToString showAllPowerButtons;
        TwelveHourClock = lib.boolToString twelveHourClock;
        Viewpoint = viewpoint;
        Intro = lib.boolToString intro;
      }
      // lib.optionalAttrs (hostLabel != null) { HostLabel = hostLabel; }
      // lib.optionalAttrs (introStart != null) { IntroStart = introStart; };
  };

  isoDateTime = "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}([.][0-9]+)?)?(Z|[+-][0-9]{2}:[0-9]{2})?)?";
in
assert lib.assertOneOf "viewpoint" viewpoint [
  "sun"
  "venus"
  "earth"
  "mars"
];
assert lib.assertMsg (
  introStart == null || builtins.match isoDateTime introStart != null
) "introStart must be an ISO 8601 date-time such as \"1970-01-01T00:00:00Z\"";
stdenvNoCC.mkDerivation {
  pname = "sddm-theme-orrery";
  version = "0.1.0";

  src = ./theme;

  nativeBuildInputs = [ fontconfig ];

  dontConfigure = true;
  dontBuild = true;

  # The greeter only sees system fonts, so Main.qml loads these faces from fonts/ itself.
  # Qt falls back to another face without a word when a family name misses.
  installPhase = ''
    runHook preInstall

    dir=$out/share/sddm/themes/orrery
    mkdir -p $dir/fonts
    cp -r . $dir
    cp ${themeConf} $dir/theme.conf
    for face in IBMPlexSans-Regular IBMPlexSans-Medium IBMPlexMono-Regular; do
      cp ${fonts}/share/fonts/opentype/$face.otf $dir/fonts/
    done

    found=$(fc-scan --format '%{family}\n' $dir/fonts | tr , '\n')
    for family in ${lib.escapeShellArgs (lib.attrValues families)}; do
      grep -qxF "$family" <<< "$found" \
        || { echo "font family '$family' is not in $dir/fonts" >&2; exit 1; }
    done

    runHook postInstall
  '';

  passthru = { inherit fonts; };

  meta = {
    description = "SDDM theme: the inner planets at their real positions, seen from Earth";
    homepage = "https://github.com/lemonilemon/sddm-orrery";
    license = [
      lib.licenses.mit
      lib.licenses.ofl
    ];
    platforms = lib.platforms.linux;
  };
}

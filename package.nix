{
  lib,
  stdenvNoCC,
  formats,
  fontconfig,
  ibm-plex,
  osLabel ? "",
  hostLabel ? null,
  showAllPowerButtons ? false,
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

  themeConf = (formats.ini { }).generate "theme.conf" {
    General =
      families
      // {
        OsLabel = osLabel;
        ShowAllPowerButtons = lib.boolToString showAllPowerButtons;
      }
      // lib.optionalAttrs (hostLabel != null) { HostLabel = hostLabel; };
  };
in
stdenvNoCC.mkDerivation {
  pname = "sddm-theme-orrery";
  version = "0.1.0";

  src = ./theme;

  nativeBuildInputs = [ fontconfig ];

  dontConfigure = true;
  dontBuild = true;

  # Qt falls back to another face without a word when a family name misses.
  installPhase = ''
    runHook preInstall

    found=$(fc-scan --format '%{family}\n' ${fonts}/share/fonts | tr , '\n')
    for family in ${lib.escapeShellArgs (lib.attrValues families)}; do
      grep -qxF "$family" <<< "$found" \
        || { echo "font family '$family' is not in ${fonts}" >&2; exit 1; }
    done

    dir=$out/share/sddm/themes/orrery
    mkdir -p $dir
    cp -r . $dir
    cp ${themeConf} $dir/theme.conf

    runHook postInstall
  '';

  passthru = { inherit fonts; };

  meta = {
    description = "SDDM theme: the inner planets at their real positions, seen from Earth";
    homepage = "https://github.com/lemonilemon/sddm-orrery";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

{
  description = "Orrery, an SDDM theme: the inner planets at their real positions, seen from Earth";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          system: f nixpkgs.legacyPackages.${system}
        );
    in
    {
      packages = eachSystem (pkgs: rec {
        default = pkgs.callPackage ./package.nix { };
        preview = pkgs.callPackage ./preview.nix { theme = default; };
      });

      apps = eachSystem (pkgs: {
        preview = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.preview}/bin/orrery-preview";
        };
      });

      checks = eachSystem (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}

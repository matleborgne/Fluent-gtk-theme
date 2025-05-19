{
  description = "Fluent-gtk-theme with customization";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let

      allSystems = [
        "x86_64-linux"
        #"aarch64-linux"
        #"x86_64-darwin"
        #"aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

    in
    {
      packages = forAllSystems ({ pkgs }: {

        default = pkgs.stdenvNoCC.mkDerivation rec {        
          name = "fluent-gtk-theme";
          src = self;

          nativeBuildInputs = with pkgs; [
            jdupes
            sassc
          ];

          buildInputs = with pkgs; [
            gnome-themes-extra
          ];

          propagatedUserEnvPkgs = with pkgs; [
            gtk-engine-murrine
          ];

          postPatch = ''
            patchShebangs install.sh
          '';

          installPhase = ''
            runHook preInstall

            name= HOME="$TMPDIR" bash ./install.sh --theme default --color dark --size standard --tweaks solid square round \
              --dest $out/share/themes

            jdupes --quiet --link-soft --recurse $out/share

            runHook postInstall
          '';

          passthru.updateScript = pkgs.gitUpdater { };

          meta = {
            description = "Fluent design gtk theme";
            homepage = "https://github.com/vinceliuice/Fluent-gtk-theme";
          };

        };
      });
    };
}

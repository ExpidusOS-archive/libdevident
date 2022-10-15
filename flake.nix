{
  description = "Device identification library";

  inputs.vadi = {
    url = github:ExpidusOS/Vadi/feat/nix;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.gxml = {
    url = "git+https://gitlab.gnome.org/RossComputerGuy/gxml.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, vadi, gxml, expidus-sdk }:
    let
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      packagesFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          vadi-pkg = vadi.packages.${system}.default;
          gxml-pkg = gxml.packages.${system}.default;
          expidus-sdk-pkg = expidus-sdk.packages.${system}.default;
        in with pkgs; rec {
          nativeBuildInputs = [
            meson
            ninja
            pkg-config
            vala
            expidus-sdk-pkg
          ];
          buildInputs = [
            glib
            libpeas
            vadi-pkg
            gxml-pkg
          ];
          propagatedBuildInputs = buildInputs;
        });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          packages = packagesFor.${system};
        in {
          default = pkgs.stdenv.mkDerivation rec {
            name = "libdevident";
            src = self;

            outputs = [ "out" "dev" "devdoc" ];

            enableParallelBuilding = true;
            inherit (packages) nativeBuildInputs buildInputs propagatedBuildInputs;

            meta = with pkgs.lib; {
              homepage = "https://github.com/ExpidusOS/libdevident";
              license = with licenses; [ gpl3Only ];
              maintainers = with expidus-sdk.lib.maintainers; [ TheComputerGuy ];
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          packages = packagesFor.${system};
        in {
          default = pkgs.mkShell {
            packages = packages.nativeBuildInputs ++ packages.buildInputs;
          };
        });
    };
}

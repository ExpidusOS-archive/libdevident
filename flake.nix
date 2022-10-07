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

  outputs = { self, nixpkgs, vadi, gxml }:
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
        in with pkgs; {
          native = [
            meson
            ninja
            pkg-config
            vala
            uncrustify
          ];
          build = [
            glib
            libpeas
            libxml2
            libgee
            vadi-pkg
            gxml-pkg
          ];
        });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          systemPackages = packagesFor.${system};
        in {
          default = pkgs.stdenv.mkDerivation rec {
            name = "libdevident";
            src = self;

            outputs = [ "out" "dev" "devdoc" ];

            enableParallelBuilding = true;
            nativeBuildInputs = systemPackages.native;
            buildInputs = systemPackages.build;
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          systemPackages = packagesFor.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gcc
              gdb
            ] ++ systemPackages.native ++ systemPackages.build;
          };
        });
    };
}

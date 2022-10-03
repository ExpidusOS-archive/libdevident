{
  description = "Device identification library";

  inputs.vadi = {
    url = github:ExpidusOS/Vadi/feat/nix;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, vadi }:
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

          darwinPackages = with pkgs; {
            native = [];
            build = [];
          };

          linuxPackages = with pkgs; {
            native = [];
            build = [];
          };

        in with pkgs; {
          native = [
            meson
            ninja
            pkg-config
            vala
            uncrustify
          ] ++ pkgs.lib.optional (pkgs.stdenv.isDarwin) darwinPackages.native;
          build = [ glib libpeas vadi-pkg ] ++ pkgs.lib.optional (pkgs.stdenv.isDarwin) darwinPackages.build;
        });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          vadi-pkg = vadi.packages.${system}.default;
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
          vadi-pkg = vadi.packages.${system}.default;
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

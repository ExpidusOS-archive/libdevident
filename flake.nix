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

      gxml-depsFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in with pkgs; [ libxml2 glib libgee ]);

      packagesFor = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          vadi-pkg = vadi.packages.${system}.default;
          gxml-deps = gxml-depsFor.${system};

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
          build = [ glib libpeas vadi-pkg ]
            ++ gxml-deps
            ++ pkgs.lib.optional (pkgs.stdenv.isDarwin) darwinPackages.build;
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

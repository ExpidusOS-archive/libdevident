{
  description = "Device identification library";

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
  };

  outputs = { self, expidus-sdk }:
    {
      overlays.default = final: prev: {
        libdevident = (prev.libdevident.overrideAttrs (old: {
          version = self.rev or "dirty";
          src = builtins.path { name = "libdevident"; path = prev.lib.cleanSource ./.; };
        }));
      };

      packages = expidus-sdk.lib.forAllSystems (system:
        let
          pkgs = expidus-sdk.lib.nixpkgsFor.${system};
        in {
          default = (self.overlays.default pkgs pkgs).libdevident;
        });

      devShells = expidus-sdk.lib.forAllSystems (system:
        let
          pkgs = expidus-sdk.lib.nixpkgsFor.${system};
          pkg = self.packages.${system}.default;
        in {
          default = pkgs.mkShell {
            packages = pkg.nativeBuildInputs ++ pkg.buildInputs;
          };
        });
    };
}

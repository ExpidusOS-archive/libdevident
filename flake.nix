{
  description = "Device identification library";

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
  };

  outputs = { self, expidus-sdk }:
    with expidus-sdk.lib;
    expidus.flake.makeOverride {
      inherit self;
      name = "libdevident";
    };
}

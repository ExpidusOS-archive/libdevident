{
  description = "Device identification library";

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
  };

  outputs = { self, expidus-sdk }: expidus-sdk.lib.expidus.flake.makeOverride { inherit self; name = "libdevident"; };
}

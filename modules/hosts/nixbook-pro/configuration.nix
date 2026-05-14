{
  inputs,
  self,
  ...
}: {
  flake.darwinConfigurations.nixbook-pro = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      {
        imports = [self.modules.darwin.base];

        networking.hostName = "nixbook-pro";
        nixpkgs.hostPlatform = "aarch64-darwin";
      }
    ];
  };
}

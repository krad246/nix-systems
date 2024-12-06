{
  getSystem,
  moduleWithSystem,
  withSystem,
  inputs,
  self,
  specialArgs,
  ...
}: {...}: {
  imports =
    [inputs.ez-configs.flakeModule]
    ++ [
      ./nixos.nix
      ./darwin.nix
      ./home.nix
    ];

  ezConfigs = {
    root = self;
    globalArgs = {
      inherit getSystem moduleWithSystem withSystem;
      inherit inputs self;
      inherit (specialArgs) krad246;
    };
  };
}

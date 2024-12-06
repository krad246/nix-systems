{
  self,
  inputs,
  ...
}: {...}: {
  imports = [inputs.ez-configs.flakeModule] ++ [./nixos.nix ./darwin.nix ./home.nix];

  ezConfigs = {
    root = self;
    globalArgs = {inherit inputs self;};
  };
}

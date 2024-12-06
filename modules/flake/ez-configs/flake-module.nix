args @ {
  inputs,
  self,
  ...
}: {...}: {
  imports = [inputs.ez-configs.flakeModule] ++ [./nixos.nix ./darwin.nix ./home.nix];

  ezConfigs = {
    root = self;
    globalArgs = args;
  };
}

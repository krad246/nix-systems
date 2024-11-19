{
  self,
  inputs,
  ...
}: {...}: {
  imports = [./nixos.nix ./darwin.nix ./home.nix];

  ezConfigs = {
    root = self;
    globalArgs = {inherit self inputs;};
  };
}

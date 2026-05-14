{self, ...}: {
  flake.modules = {
    darwin.input-registry = {
      imports = [self.modules.generic.input-registry];
    };

    homeManager.input-registry = {
      imports = [self.modules.generic.input-registry];
    };

    nixos.input-registry = {
      imports = [self.modules.generic.input-registry];
    };
  };
}

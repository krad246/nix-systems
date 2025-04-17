{
  inputs,
  self,
  ...
}: {
  imports = [inputs.mkdocs-flake.flakeModules.default];

  perSystem = _: {
    documentation = {
      mkdocs-root = self;
      strict = true;
    };
  };
}

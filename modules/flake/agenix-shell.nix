{
  inputs,
  lib,
  ...
}: {
  imports = lib.lists.optionals (inputs ? agenix-shell) [
    inputs.agenix-shell.flakeModules.default
  ];

  flake-file = {
    inputs = {
      agenix-shell.url = "github:aciceri/agenix-shell";
    };
  };

  agenix-shell.secrets =
    lib.modules.mkDefault {
    };
}

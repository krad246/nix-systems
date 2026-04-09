{inputs, ...}: {
  flake.modules.nixos.impermanence = {
    imports = [inputs.impermanence.nixosModules.impermanence];
  };
}

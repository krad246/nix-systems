{
  config,
  inputs,
  lib,
  ...
}: let
  profileDirectory = "${inputs.dendritic}/modules/profiles";
  profileNames = map (name: lib.removeSuffix ".nix" name) (
    lib.attrNames (lib.filterAttrs (_: kind: kind == "regular") (builtins.readDir profileDirectory))
  );
in {
  options.dendritic.internal.profileNames = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    readOnly = true;
    internal = true;
  };

  config.dendritic.internal.profileNames = assert lib.assertMsg
  (lib.all (name: lib.elem name profileNames) (lib.attrNames config.dendritic.configurations.perTag))
  "dendritic.configurations.perTag may only contain canonical profile names from inputs.dendritic/modules/profiles";
  assert lib.assertMsg
  (lib.all (tag:
    lib.all (className: config.dendritic.configurations.perClass ? ${className})
    (lib.attrNames (config.dendritic.configurations.perTag.${tag}.perClass or {})))
  (lib.attrNames config.dendritic.configurations.perTag))
  "dendritic.configurations.perTag.<tag>.perClass may only name classes declared by dendritic.configurations.perClass"; profileNames;
}

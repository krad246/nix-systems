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

  modulesFor = namespace: name:
    lib.optional (
      lib.hasAttr namespace inputs.dendritic.modules
      && lib.hasAttr name inputs.dendritic.modules.${namespace}
    )
    inputs.dendritic.modules.${namespace}.${name};

  baseModules = {
    nixos = inputs.dendritic.modules.nixos.base;
    darwin = inputs.dendritic.modules.darwin.base;
    homeManager = inputs.dendritic.modules.homeManager.base;
  };

  withoutBase = namespace: module:
    if lib.isAttrs module && module ? imports
    then module // {imports = lib.filter (candidate: candidate != baseModules.${namespace}) module.imports;}
    else module;

  profileLayers = lib.genAttrs profileNames (name: {
    nixos = modulesFor "nixos" name;
    darwin = modulesFor "darwin" name;
    homeManager = modulesFor "homeManager" name;
  });

  canonicalPerTag = lib.genAttrs profileNames (name: {
    nixosModules = map (withoutBase "nixos") (modulesFor "nixos" name);
    darwinModules = map (withoutBase "darwin") (modulesFor "darwin" name);
    homeModules = map (withoutBase "homeManager") (modulesFor "homeManager" name);
  });
in {
  options.dendritic.internal.profileNames = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    readOnly = true;
    internal = true;
  };

  options.dendritic.internal.profileLayers = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    readOnly = true;
    internal = true;
  };

  config = {
    dendritic = {
      internal.profileNames = profileNames;
      configurations.perTag = lib.mkDefault canonicalPerTag;
      internal.profileLayers = assert lib.assertMsg
      (lib.all (name: lib.elem name profileNames) (lib.attrNames config.dendritic.configurations.perTag))
      "dendritic.configurations.perTag may only contain canonical profile names from inputs.dendritic/modules/profiles"; profileLayers;
    };
  };
}

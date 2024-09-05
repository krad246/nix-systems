{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (inputs) agenix;

  supportedHosts = builtins.readDir ../../secrets/hosts;
  hostExists =
    if lib.attrsets.hasAttrByPath ["networking" "hostName"] config
    then lib.attrsets.hasAttrByPath [config.networking.hostName] supportedHosts
    else false;

  hostSecrets = lib.attrsets.optionalAttrs hostExists (builtins.readDir ../../secrets/hosts/${config.networking.hostName});

  secretNames = let
    files = builtins.attrNames hostSecrets;
    removeExt = x: lib.strings.removeSuffix ".age" x;
  in
    lib.lists.forEach files removeExt;

  mkSecret = name: {
    "${name}" = {
      file = ../../secrets/hosts/${config.networking.hostName}/${name}.age;
      path = "/var/agenix/secrets/${name}";
    };
  };

  mkSecrets = names: (lib.lists.forEach names mkSecret);
in {
  imports = [agenix.darwinModules.age];

  age = let
    secrets = lib.attrsets.mergeAttrsList (mkSecrets secretNames);
  in {
    # Need a master identity to unlock these.
    inherit secrets;
  };
}

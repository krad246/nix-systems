{
  inputs,
  osConfig,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs) agenix;
  inherit (config.home) homeDirectory;

  supportedHosts = builtins.readDir ./hosts;
  hostExists =
    if lib.attrsets.hasAttrByPath ["networking" "hostName"] osConfig
    then lib.attrsets.hasAttrByPath [osConfig.networking.hostName] supportedHosts
    else false;
  hostSecrets = lib.attrsets.optionalAttrs hostExists (builtins.readDir ./hosts/${osConfig.networking.hostName});

  secretNames = let
    files = builtins.attrNames hostSecrets;
    removeExt = x: lib.strings.removeSuffix ".age" x;
  in
    lib.lists.forEach files removeExt;

  mkSecret = name: {
    "${name}" = {
      file = ./hosts/${osConfig.networking.hostName}/${name}.age;
      path = "${homeDirectory}/.secrets/${name}";
    };
  };

  mkSecrets = names: (lib.lists.forEach names mkSecret);
in {
  imports = [agenix.homeManagerModules.age];
  home.packages = [agenix.packages.${pkgs.stdenv.system}.default];

  age = let
    secrets = lib.attrsets.mergeAttrsList (mkSecrets secretNames);
  in {
    # Need a master identity to unlock these.
    inherit secrets;
  };

  # Actual key points at a pointer to the real secret
  # Either the secret is decrypted and provides the backing value
  # Or there is a file named appropriately (impure-ish)
  home.file = lib.attrsets.optionalAttrs (config.age.secrets
    ? id_ed25519_pub
    && config.age.secrets
    ? id_ed25519_priv) {
    ".ssh/id_ed25519.pub".source =
      config.lib.file.mkOutOfStoreSymlink
      config.age.secrets.id_ed25519_pub.path;

    ".ssh/id_ed25519".source =
      config.lib.file.mkOutOfStoreSymlink
      config.age.secrets.id_ed25519_priv.path;
  };
}

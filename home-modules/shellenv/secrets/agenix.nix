{
  inputs,
  osConfig,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs) agenix;
  agenixMountPoint = "${config.home.homeDirectory}/.secrets";
  thisHost = osConfig.networking.hostName;

  hosts =  builtins.readDir ./hosts;
  hostNames = builtins.attrNames (hosts);
  hostSecretsDir = ./hosts/${thisHost};

  mkSecret = name: {
    "${name}" = {
      file =
        builtins.toPath "${hostSecretsDir}/${name}.age";
      path = "${agenixMountPoint}/${name}";
    };
  };

  secretNames = lib.lists.optionals (hosts ? "${thisHost}") (builtins.attrNames (builtins.readDir hostSecretsDir));
  stripAgeSuffix = x: lib.strings.removeSuffix ".age" x;
  secrets = lib.attrsets.mergeAttrsList (lib.lists.forEach secretNames (sname:
    mkSecret
    (stripAgeSuffix sname)));
in {
  imports = [agenix.homeManagerModules.age];
  age = {
    # Need a master identity to unlock these.
    inherit secrets;
  };

  # Actual key points at a pointer to the real secret
  # Either the secret is decrypted and provides the backing value
  # Or there is a file named appropriately (impure)
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

  home.packages = [agenix.packages.${pkgs.stdenv.system}.default];
}

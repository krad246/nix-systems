{
  inputs,
  config,
  lib,
  ...
}: let
  hasPubkey = lib.attrsets.hasAttrByPath ["id_ed25519_pub.age"] config.age.secrets;
  hasPrivKey = lib.attrsets.hasAttrByPath ["id_ed25519_priv.age"] config.age.secrets;
in {
  imports = [inputs.agenix.homeManagerModules.age] ++ [./secrets];

  age = {
    secretsDir = lib.mkIf (hasPrivKey && hasPubkey) "${config.home.homeDirectory}/.secrets";
  };

  # Actual key points at a pointer to the real secret
  # Either the secret is decrypted and provides the backing value
  # Or there is a file named appropriately (impure-ish)
  home.file = lib.mkIf (hasPrivKey && hasPubkey) {
    ".ssh/id_ed25519.pub".source = config.lib.file.mkOutOfStoreSymlink config.age.secrets."id_ed25519_pub.age".path;

    ".ssh/id_ed25519".source = config.lib.file.mkOutOfStoreSymlink config.age.secrets."id_ed25519_priv.age".path;
  };
}

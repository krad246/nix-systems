{
  config,
  lib,
  ...
}: let
  inherit (lib) attrsets modules;

  hasPubkey = attrsets.hasAttrByPath ["id_ed25519_pub.age"] config.age.secrets;
  hasPrivKey = attrsets.hasAttrByPath ["id_ed25519_priv.age"] config.age.secrets;
in {
  imports = [./secrets];

  environment.etc = modules.mkIf (hasPrivKey && hasPubkey) {
    "ssh/id_ed25519.pub".source = config.age.secrets."id_ed25519_pub.age".path;
    "ssh/id_ed25519".source = config.age.secrets."id_ed25519_priv.age".path;
  };
}

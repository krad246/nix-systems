{
  self,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = [self.modules.generic.nix-core self.modules.generic.unfree];

  nix = {
    package =
      lib.modules.mkDefault (lib.attrsets.attrByPath ["nix" "package"] pkgs.nixVersions.stable
        osConfig);
    checkConfig = true;
    gc.automatic = true;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = lib.attrsets.attrByPath ["nix" "settings" "keep-outputs"] false osConfig;
      keep-derivations = lib.attrsets.attrByPath ["nix" "settings" "keep-derivations"] false osConfig;
      sandbox = lib.attrsets.attrByPath ["nix" "settings" "sandbox"] "relaxed" osConfig;
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

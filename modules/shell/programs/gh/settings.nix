{
  flake.modules.homeManager.gh = {
    config,
    lib,
    ...
  }: {
    options.shell.programs.gh.identities = let
      schema = lib.types.submodule ({name, ...}: {
        options = {
          enable =
            lib.options.mkEnableOption "Enable management of the ${name} identity and its corresponding GitHub instance."
            // {
              default = true;
            };

          hostname = lib.options.mkOption {
            type = lib.types.str;
            example = "github.com";
            description = "The hostname of the GitHub instance.";
          };

          username = lib.options.mkOption {
            type = lib.types.str;
            example = "<your_username>";
            description = "The user account bound to this identity.";
          };

          tokenPath = lib.options.mkOption {
            type = lib.types.str;
            example = "/path/to/secret";
            description = ''
              Location of GitHub personal access token for this identity.
            '';
          };
        };
      });

      mkIdentitySlot = description:
        lib.options.mkOption {
          type = lib.types.nullOr schema;
          default = null;
          inherit description;
        };
    in {
      personal = mkIdentitySlot "Personal GitHub identity slot.";
      enterprise = mkIdentitySlot "Enterprise GitHub identity slot.";
    };

    config.programs.gh = {
      hosts = let
        inherit (config.shell.programs.gh) identities;

        isActive = _: v: v != null && v.enable;
        toEntry = _n: v:
          lib.attrsets.nameValuePair v.hostname {
            user = v.username;
          };
      in
        lib.trivial.pipe identities [
          (lib.attrsets.filterAttrs isActive)
          (lib.attrsets.mapAttrs' toEntry)
        ];

      gitCredentialHelper.hosts = builtins.attrNames config.programs.gh.hosts;

      settings = {
        # git_protocol = "ssh";
        prefer_editor_prompt = "enabled";
        color_labels = "enabled";
      };
    };
  };
}

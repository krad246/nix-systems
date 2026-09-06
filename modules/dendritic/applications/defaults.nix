{
  self,
  lib,
  ...
}: {
  flake.modules.darwin.applications = {
    imports = with self.modules.darwin; [
      arc-browser
      bluesnooze
      discord
      groupme
      launchcontrol
      magnet
      signal
      utm
      zoom
    ];

    appStore = {
      install = lib.modules.mkDefault (
        {
          application,
          variants,
        }: let
          tool =
            {
              arc = null;
              bluesnooze = "homebrew.casks";
              discord = "nix.packages";
              groupme = "mas.apps";
              launchcontrol = null;
              magnet = "mas.apps";
              signal = "homebrew.casks";
              utm = "homebrew.casks";
              zen = "homebrew.casks";
              zoom = "homebrew.casks";
            }
            .${
              application
            } or null;
        in
          if tool == null
          then null
          else {
            inherit tool;
            value = variants.${tool};
          }
      );

      tools = {
        "homebrew.casks".enable = true;
        "mas.apps".enable = true;
        "nix.packages".enable = true;
      };
    };
  };
}

{
  self,
  lib,
  ...
}: {
  flake.modules.darwin.applications = {
    imports = with self.modules.darwin; [
      bluesnooze
      groupme
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
              bluesnooze = "homebrew.casks";
              groupme = "mas.apps";
              magnet = "mas.apps";
              signal = "homebrew.casks";
              utm = "homebrew.casks";
              zen = "homebrew.casks";
              zoom = "homebrew.casks";
            }.${
              application
            };
        in {
          inherit tool;
          value = variants.${tool};
        }
      );

      tools = {
        "homebrew.casks".enable = true;
        "mas.apps".enable = true;
      };
    };
  };
}

{
  lib,
  symlinkJoin,
  cascadia-code,
  nerd-fonts,
  ...
}: let
  inherit (lib) attrsets;

  fonts = {
    inherit cascadia-code;

    inherit (nerd-fonts) meslo-lg symbols-only;
  };
in
  symlinkJoin {
    name = "term-fonts";
    paths = attrsets.attrValues fonts;

    passthru =
      {
        inherit fonts;
      }
      // fonts;
  }

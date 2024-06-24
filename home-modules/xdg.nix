{lib, ...}: let
  mkHidden = name: {
    "${name}" = {
      inherit name;
      noDisplay = true;
    };
  };
in {
  xdg.desktopEntries = lib.mkMerge [
    (mkHidden "Proton 8.0")
    (mkHidden "Proton 9.0 (Beta)")
    (mkHidden "Proton Experimental")
    (mkHidden "Steam Linux Runtime 2.0 (soldier)")
    (mkHidden "Steam Linux Runtime 3.0 (sniper)")
  ];
}

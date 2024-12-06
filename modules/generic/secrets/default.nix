args @ {
  inputs,
  lib,
  ...
}: let
  inherit (inputs) agenix;
  inherit (lib) attrsets fileset lists;
  hasHomeCtx = attrsets.hasAttrByPath ["osConfig"] args;
  hasSystemCtx = attrsets.hasAttrByPath ["config"] args;
  hasCtx = hasHomeCtx || hasSystemCtx;
in
  attrsets.optionalAttrs hasCtx {
    imports =
      lists.optionals hasHomeCtx [agenix.homeManagerModules.age];

    age = let
      # determine if there is a supported host
      configSrc =
        if hasHomeCtx
        then args.osConfig
        else
          (
            if hasSystemCtx
            then args.config
            else {}
          );
      hasHostName = attrsets.hasAttrByPath ["networking" "hostName"] configSrc;

      maybeHostDir = fileset.maybeMissing ./hosts/${configSrc.networking.hostName};

      # pull in the secrets bound to the host
      findAgeFiles = path: fileset.fileFilter (file: file.hasExt "age") path;
      ageFiles = findAgeFiles ./hosts;
      hits = fileset.toList (fileset.intersection maybeHostDir ageFiles);

      # for a given secret path, convert it into an agenix compatible attrset.
      mkSecret = path: let
        bname = builtins.baseNameOf path;
        attrname = bname;
      in {
        "${attrname}" = {
          file = path;
        };
      };

      hostSecrets = lists.forEach hits mkSecret;

      inherit (lib) modules;
    in
      modules.mkIf hasHostName {
        secrets = attrsets.mergeAttrsList hostSecrets;
      };
  }

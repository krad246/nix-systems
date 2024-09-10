args @ {
  inputs,
  lib,
  ...
}: let
  inherit (inputs) agenix;
  hasHomeCtx = lib.attrsets.hasAttrByPath ["osConfig"] args;
  hasSystemCtx = lib.attrsets.hasAttrByPath ["config"] args;
  hasCtx = hasHomeCtx || hasSystemCtx;
in
  lib.attrsets.optionalAttrs hasCtx {
    imports =
      lib.optionals hasHomeCtx [agenix.homeManagerModules.age];

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
      hasHostName = lib.attrsets.hasAttrByPath ["networking" "hostName"] configSrc;

      maybeHostDir = lib.fileset.maybeMissing ./hosts/${configSrc.networking.hostName};

      # pull in the secrets bound to the host
      findAgeFiles = path: lib.fileset.fileFilter (file: file.hasExt "age") path;
      ageFiles = findAgeFiles ./hosts;
      hits = lib.fileset.toList (lib.fileset.intersection maybeHostDir ageFiles);

      # for a given secret path, convert it into an agenix compatible attrset.
      mkSecret = path: let
        bname = builtins.baseNameOf path;
        attrname = bname;
      in {
        "${attrname}" = {
          file = path;
        };
      };

      hostSecrets = lib.lists.forEach hits mkSecret;
    in
      lib.mkIf hasHostName {
        secrets = lib.attrsets.mergeAttrsList hostSecrets;
      };
  }

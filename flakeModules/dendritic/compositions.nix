{lib, ...}: {
  composeProjection = {
    construct,
    includeSpecialisation ? null,
  }: let
    inheritPolicy = local: parent: global:
      if local != null
      then local
      else if parent != null
      then parent
      else global;
    resolve = policy:
      lib.mapAttrs (_: declaration:
        declaration
        // {
          variants = lib.mapAttrs (_: variant:
            variant
            // {
              publish = inheritPolicy variant.publish declaration.publish policy.publish;
              includeSpecialisation = inheritPolicy variant.includeSpecialisation declaration.includeSpecialisation policy.includeSpecialisation;
            })
          declaration.variants;
        });
    bare = context: declaration: construct context declaration;
    configuration = context: declaration: let
      root = bare context declaration;
      embedded = lib.filterAttrs (_: variant: variant.includeSpecialisation) declaration.variants;
    in
      if embedded == {}
      then root
      else if includeSpecialisation == null
      then throw "this configuration backend does not support embedded variants"
      else includeSpecialisation root embedded;
    variant = context: declaration: delta:
      (bare context declaration).extendModules {inherit (delta) modules;};
  in {
    inherit configuration resolve variant;
    definitions = context: nameFunction: declarations:
      lib.pipe declarations [
        (lib.mapAttrsToList (rootName: declaration: let
          published = lib.filterAttrs (_: variant: variant.publish) declaration.variants;
        in
          [{${rootName} = configuration context declaration;}]
          ++ lib.mapAttrsToList (variantName: delta: {
            ${nameFunction rootName variantName} = variant context declaration delta;
          })
          published))
        lib.concatLists
      ];
  };
}

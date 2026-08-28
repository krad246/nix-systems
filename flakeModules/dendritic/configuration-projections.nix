# Pure projection interpreter: evaluator closures are supplied by each module
# backend, so this intentionally remains a library rather than a module.
{
  construct,
  includeSpecialisation ? null,
  lib,
}: let
  # A leaf policy is the first defined value in leaf -> root -> global order.
  inheritPolicy = local: parent: global:
    if local != null
    then local
    else if parent != null
    then parent
    else global;

  resolve = policy:
    lib.mapAttrs (
      _: declaration:
        declaration
        // {
          variants =
            lib.mapAttrs (
              _: delta:
                delta
                // {
                  publish = inheritPolicy delta.publish declaration.publish policy.publish;
                  includeSpecialisation = inheritPolicy delta.includeSpecialisation declaration.includeSpecialisation policy.includeSpecialisation;
                }
            )
            declaration.variants;
        }
    );

  bare = context: declaration: construct context declaration;

  variantFrom = root: delta:
    root.extendModules {
      inherit (delta) modules;
    };

  configurationFrom = root: declaration: let
    embedded = lib.filterAttrs (_: delta: delta.includeSpecialisation) declaration.variants;
  in
    if embedded == {}
    then root
    else if includeSpecialisation == null
    then throw "this configuration backend does not support embedded variants"
    else includeSpecialisation root embedded;

  configuration = context: declaration:
    configurationFrom (bare context declaration) declaration;

  variant = context: declaration: delta:
    variantFrom (bare context declaration) delta;
in {
  inherit configuration resolve variant;

  # Separate module definitions make generated-name collisions ordinary merge conflicts.
  definitions = context: nameFunction: declarations:
    lib.pipe declarations [
      (lib.mapAttrsToList (
        rootName: declaration: let
          root = bare context declaration;
          published = lib.filterAttrs (_: delta: delta.publish) declaration.variants;
        in
          [{${rootName} = configurationFrom root declaration;}]
          ++ lib.mapAttrsToList (variantName: delta: {
            ${nameFunction rootName variantName} = variantFrom root delta;
          })
          published
      ))
      lib.concatLists
    ];
}

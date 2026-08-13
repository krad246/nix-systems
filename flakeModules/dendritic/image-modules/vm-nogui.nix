# Like `importApply`: the outer argument closes over the registered VM module,
# while this function returns the deferred NixOS module evaluated later.
# TODO: investigate an import-tree closure bridge built on `importApply`.
{vm}: {
  imports = [vm];

  virtualisation.graphics = false;
}

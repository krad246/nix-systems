{lib}: {
  filterExt = ext: dir:
    lib.fileset.toList (lib.fileset.fileFilter (file: file.hasExt ext) dir);
}

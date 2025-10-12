_final: prev: {
  filterExt = ext: dir:
    prev.fileset.toList (prev.fileset.fileFilter (file: file.hasExt ext) dir);
}

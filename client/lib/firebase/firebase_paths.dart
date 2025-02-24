enum FirebasePaths {
  /// top level path
  projects;

  String get path {
    switch (this) {
      case projects:
        return 'projects';
    }
  }
}

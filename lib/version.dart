class AppVersion {
  static const String version = '2.0.0';
  static const int buildNumber = 1;
  static const String releaseDate = '2025-01-18';
  static const String codeName = 'Optimized Discovery';
  
  static const String fullVersion = '$version+$buildNumber';
  
  static const Map<String, String> releaseInfo = {
    'version': version,
    'build': '$buildNumber',
    'release_date': releaseDate,
    'code_name': codeName,
    'description': 'Major optimization release with 90% faster script discovery',
  };
  
  static String get versionString => 'MikroTik SSH Script Runner v$version ($codeName)';
  static String get buildInfo => 'Build $buildNumber - Released $releaseDate';
}
import 'dart:convert';

class ScriptInfo {
  final String name;
  final String description;
  final int level;

  ScriptInfo({
    required this.name,
    required this.description,
    required this.level,
  });

  factory ScriptInfo.fromJson(Map<String, dynamic> json) {
    return ScriptInfo(
      name: json['name'],
      description: json['description'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'level': level,
      };
}

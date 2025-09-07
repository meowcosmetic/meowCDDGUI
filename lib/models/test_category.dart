class TestCategory {
  final int id;
  final String code;
  final Map<String, String> displayedName;
  final Map<String, String>? description;
  final String? createdAt;
  final String? updatedAt;

  const TestCategory({
    required this.id,
    required this.code,
    required this.displayedName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory TestCategory.fromJson(Map<String, dynamic> json) {
    return TestCategory(
      id: json['id'] as int,
      code: json['code'] as String,
      displayedName: Map<String, String>.from(json['displayedName'] as Map),
      description: json['description'] != null 
          ? Map<String, String>.from(json['description'] as Map)
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'displayedName': displayedName,
      'description': description,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  // Helper method to get display name in specific language
  String getDisplayName(String language) {
    return displayedName[language] ?? displayedName['vi'] ?? code;
  }

  // Helper method to get description in specific language
  String? getDescription(String language) {
    if (description == null) return null;
    return description![language] ?? description!['vi'];
  }
}

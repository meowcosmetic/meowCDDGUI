import 'dart:convert';

class InterventionPost {
  final int? id;
  final String title;
  final Map<String, dynamic> content;
  final PostType postType;
  final int? difficultyLevel;
  final int? targetAgeMinMonths;
  final int? targetAgeMaxMonths;
  final int? estimatedDurationMinutes;
  final String? tags;
  final bool isPublished;
  final String? author;
  final String? version;
  final int? criteriaId;
  final int? programId;

  InterventionPost({
    this.id,
    required this.title,
    required this.content,
    required this.postType,
    this.difficultyLevel,
    this.targetAgeMinMonths,
    this.targetAgeMaxMonths,
    this.estimatedDurationMinutes,
    this.tags,
    this.isPublished = false,
    this.author,
    this.version,
    this.criteriaId,
    this.programId,
  });

  factory InterventionPost.fromJson(Map<String, dynamic> json) {
    return InterventionPost(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] is Map<String, dynamic>
          ? json['content'] as Map<String, dynamic>
          : jsonDecode(json['content'] ?? '{}'),
      postType: PostType.values.firstWhere(
        (e) => e.name == json['postType'],
        orElse: () => PostType.INTERVENTION_METHOD,
      ),
      difficultyLevel: json['difficultyLevel'],
      targetAgeMinMonths: json['targetAgeMinMonths'],
      targetAgeMaxMonths: json['targetAgeMaxMonths'],
      estimatedDurationMinutes: json['estimatedDurationMinutes'],
      tags: json['tags'],
      isPublished: json['isPublished'] ?? false,
      author: json['author'],
      version: json['version'],
      criteriaId: json['criteriaId'],
      programId: json['programId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'postType': postType.name,
      if (difficultyLevel != null) 'difficultyLevel': difficultyLevel,
      if (targetAgeMinMonths != null) 'targetAgeMinMonths': targetAgeMinMonths,
      if (targetAgeMaxMonths != null) 'targetAgeMaxMonths': targetAgeMaxMonths,
      if (estimatedDurationMinutes != null)
        'estimatedDurationMinutes': estimatedDurationMinutes,
      if (tags != null) 'tags': tags,
      'isPublished': isPublished,
      if (author != null) 'author': author,
      if (version != null) 'version': version,
      if (criteriaId != null) 'criteriaId': criteriaId,
      if (programId != null) 'programId': programId,
    };
  }

  InterventionPost copyWith({
    int? id,
    String? title,
    Map<String, dynamic>? content,
    PostType? postType,
    int? difficultyLevel,
    int? targetAgeMinMonths,
    int? targetAgeMaxMonths,
    int? estimatedDurationMinutes,
    String? tags,
    bool? isPublished,
    String? author,
    String? version,
    int? criteriaId,
    int? programId,
  }) {
    return InterventionPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      targetAgeMinMonths: targetAgeMinMonths ?? this.targetAgeMinMonths,
      targetAgeMaxMonths: targetAgeMaxMonths ?? this.targetAgeMaxMonths,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
      author: author ?? this.author,
      version: version ?? this.version,
      criteriaId: criteriaId ?? this.criteriaId,
      programId: programId ?? this.programId,
    );
  }
}

enum PostType {
  INTERVENTION_METHOD, // Phương pháp can thiệp
  CHECKLIST, // Checklist
  GUIDELINE, // Hướng dẫn
  EXAMPLE, // Ví dụ cụ thể
  TIP, // Mẹo thực hành
  TROUBLESHOOTING, // Xử lý tình huống
  CONCLUSION, // Kết luận
}

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.INTERVENTION_METHOD:
        return 'Phương pháp can thiệp';
      case PostType.CHECKLIST:
        return 'Checklist';
      case PostType.GUIDELINE:
        return 'Hướng dẫn';
      case PostType.EXAMPLE:
        return 'Ví dụ cụ thể';
      case PostType.TIP:
        return 'Mẹo thực hành';
      case PostType.TROUBLESHOOTING:
        return 'Xử lý tình huống';
      case PostType.CONCLUSION:
        return 'Kết luận';
    }
  }
}

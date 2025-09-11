/// Models for Intervention Goals - Mô hình cho mục tiêu can thiệp
class InterventionGoalModel {
  final String id;
  final String name;
  final LocalizedText displayedName;
  final LocalizedText? description;
  final String category;
  final List<InterventionTargetModel> targets;
  final String createdAt;
  final String updatedAt;
  final bool isActive;

  const InterventionGoalModel({
    required this.id,
    required this.name,
    required this.displayedName,
    this.description,
    required this.category,
    required this.targets,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayedName': displayedName.toJson(),
      'description': description?.toJson(),
      'category': category,
      'targets': targets.map((t) => t.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };
  }

  factory InterventionGoalModel.fromJson(Map<String, dynamic> json) {
    return InterventionGoalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayedName: LocalizedText.fromJson(json['displayedName'] ?? {}),
      description: json['description'] != null 
          ? LocalizedText.fromJson(json['description']) 
          : null,
      category: json['category'] ?? '',
      targets: (json['targets'] as List<dynamic>? ?? [])
          .map((t) => InterventionTargetModel.fromJson(t))
          .toList(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  InterventionGoalModel copyWith({
    String? id,
    String? name,
    LocalizedText? displayedName,
    LocalizedText? description,
    String? category,
    List<InterventionTargetModel>? targets,
    String? createdAt,
    String? updatedAt,
    bool? isActive,
  }) {
    return InterventionGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayedName: displayedName ?? this.displayedName,
      description: description ?? this.description,
      category: category ?? this.category,
      targets: targets ?? this.targets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class InterventionTargetModel {
  final String id;
  final String name;
  final LocalizedText displayedName;
  final LocalizedText? description;
  final String goalId;
  final int priority;
  final String status; // 'pending', 'in_progress', 'completed'
  final String createdAt;
  final String updatedAt;

  const InterventionTargetModel({
    required this.id,
    required this.name,
    required this.displayedName,
    this.description,
    required this.goalId,
    this.priority = 1,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayedName': displayedName.toJson(),
      'description': description?.toJson(),
      'goalId': goalId,
      'priority': priority,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory InterventionTargetModel.fromJson(Map<String, dynamic> json) {
    return InterventionTargetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayedName: LocalizedText.fromJson(json['displayedName'] ?? {}),
      description: json['description'] != null 
          ? LocalizedText.fromJson(json['description']) 
          : null,
      goalId: json['goalId'] ?? '',
      priority: json['priority'] ?? 1,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  InterventionTargetModel copyWith({
    String? id,
    String? name,
    LocalizedText? displayedName,
    LocalizedText? description,
    String? goalId,
    int? priority,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return InterventionTargetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayedName: displayedName ?? this.displayedName,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LocalizedText {
  final String vi;
  final String en;

  const LocalizedText({
    required this.vi,
    required this.en,
  });

  Map<String, dynamic> toJson() {
    return {
      'vi': vi,
      'en': en,
    };
  }

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      vi: json['vi'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class PagedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;

  const PagedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse<T>(
      content: (json['content'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item))
          .toList() ?? [],
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}

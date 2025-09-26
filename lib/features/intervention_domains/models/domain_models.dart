import 'package:flutter/foundation.dart';

@immutable
class InterventionDomainModel {
  final String id;
  final String name;
  final LocalizedText displayedName;
  final LocalizedText? description;
  final String category;
  final String createdAt;
  final String updatedAt;

  const InterventionDomainModel({
    required this.id,
    required this.name,
    required this.displayedName,
    this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  InterventionDomainModel copyWith({
    String? id,
    String? name,
    LocalizedText? displayedName,
    LocalizedText? description,
    String? category,
    String? createdAt,
    String? updatedAt,
  }) {
    return InterventionDomainModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayedName: displayedName ?? this.displayedName,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory InterventionDomainModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safe conversion for displayedName
      Map<String, dynamic> displayedNameData = {};
      if (json['displayedName'] != null) {
        if (json['displayedName'] is Map<String, dynamic>) {
          displayedNameData = json['displayedName'];
        } else {
          // Handle case where displayedName might be a dynamic object
          try {
            displayedNameData = Map<String, dynamic>.from(
              json['displayedName'],
            );
          } catch (e) {
            displayedNameData = {'vi': '', 'en': ''};
          }
        }
      }

      // Safe conversion for description
      Map<String, dynamic>? descriptionData;
      if (json['description'] != null) {
        if (json['description'] is Map<String, dynamic>) {
          descriptionData = json['description'];
        } else {
          try {
            descriptionData = Map<String, dynamic>.from(json['description']);
          } catch (e) {
            descriptionData = null;
          }
        }
      }

      return InterventionDomainModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        displayedName: LocalizedText.fromJson(displayedNameData),
        description: descriptionData != null
            ? LocalizedText.fromJson(descriptionData)
            : null,
        category: json['category']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
      );
    } catch (e) {
      throw Exception('Lỗi khi phân tích dữ liệu lĩnh vực can thiệp: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description!.toJson(),
      'category': category,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

@immutable
class LocalizedText {
  final String vi;
  final String en;

  const LocalizedText({required this.vi, required this.en});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different possible key names
      String vi = '';
      String en = '';

      // Try different possible keys
      vi =
          json['vi']?.toString() ??
          json['vietnamese']?.toString() ??
          json['vietnam']?.toString() ??
          json['vn']?.toString() ??
          '';

      en =
          json['en']?.toString() ??
          json['english']?.toString() ??
          json['eng']?.toString() ??
          '';

      return LocalizedText(vi: vi, en: en);
    } catch (e) {
      // Return default values instead of throwing
      return const LocalizedText(vi: '', en: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {'vi': vi, 'en': en};
  }

  LocalizedText copyWith({String? vi, String? en}) {
    return LocalizedText(vi: vi ?? this.vi, en: en ?? this.en);
  }
}

@immutable
class PaginatedDomains {
  final List<InterventionDomainModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final bool first;
  final bool last;

  const PaginatedDomains({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.first,
    required this.last,
  });

  factory PaginatedDomains.fromJson(Map<String, dynamic> json) {
    return PaginatedDomains(
      content: (json['content'] as List<dynamic>? ?? []).map((e) {
        if (e is Map<String, dynamic>) {
          return InterventionDomainModel.fromJson(e);
        } else {
          throw Exception(
            'Phần tử trong danh sách không phải là Map<String, dynamic>: ${e.runtimeType}',
          );
        }
      }).toList(),
      pageNumber: (json['pageNumber'] ?? 0) as int,
      pageSize: (json['pageSize'] ?? 0) as int,
      totalElements: (json['totalElements'] ?? 0) as int,
      totalPages: (json['totalPages'] ?? 0) as int,
      hasNext: (json['hasNext'] ?? false) as bool,
      hasPrevious: (json['hasPrevious'] ?? false) as bool,
      first: (json['first'] ?? false) as bool,
      last: (json['last'] ?? false) as bool,
    );
  }
}

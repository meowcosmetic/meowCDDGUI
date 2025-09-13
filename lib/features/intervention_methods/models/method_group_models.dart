import 'dart:convert';
import 'package:flutter/material.dart';

/// Model for intervention method group
class InterventionMethodGroupModel {
  final String id;
  final String code;
  final LocalizedText displayedName;
  final LocalizedText? description;
  final int minAgeMonths;
  final int maxAgeMonths;
  final String status;
  final String createdAt;
  final String updatedAt;

  const InterventionMethodGroupModel({
    required this.id,
    required this.code,
    required this.displayedName,
    this.description,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InterventionMethodGroupModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing InterventionMethodGroupModel from JSON: ${json.keys.toList()}'); // Debug log
      print('🔍 InterventionMethodGroupModel JSON: $json'); // Debug log
      
      // Handle displayedName - it might be a JSON string or an object
      LocalizedText displayedName;
      if (json['displayedName'] is String) {
        // Parse JSON string
        final displayedNameJson = jsonDecode(json['displayedName']);
        displayedName = LocalizedText.fromJson(displayedNameJson);
      } else {
        // It's already an object
        displayedName = LocalizedText.fromJson(json['displayedName'] ?? {});
      }
      
      // Handle description - it might be a JSON string or an object
      LocalizedText? description;
      if (json['description'] != null) {
        if (json['description'] is String) {
          // Parse JSON string
          final descriptionJson = jsonDecode(json['description']);
          description = LocalizedText.fromJson(descriptionJson);
        } else {
          // It's already an object
          description = LocalizedText.fromJson(json['description']);
        }
      }
      
      return InterventionMethodGroupModel(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        displayedName: displayedName,
        description: description,
        minAgeMonths: json['minAgeMonths'] ?? 0,
        maxAgeMonths: json['maxAgeMonths'] ?? 0,
        status: json['status']?.toString() ?? 'ACTIVE',
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
      );
    } catch (e) {
      print('❌ Error in InterventionMethodGroupModel.fromJson: $e'); // Debug log
      print('❌ JSON data: $json'); // Debug log
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description!.toJson(),
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  InterventionMethodGroupModel copyWith({
    String? id,
    String? code,
    LocalizedText? displayedName,
    LocalizedText? description,
    int? minAgeMonths,
    int? maxAgeMonths,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return InterventionMethodGroupModel(
      id: id ?? this.id,
      code: code ?? this.code,
      displayedName: displayedName ?? this.displayedName,
      description: description ?? this.description,
      minAgeMonths: minAgeMonths ?? this.minAgeMonths,
      maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model for intervention method
class InterventionMethodModel {
  final String id;
  final String code;
  final LocalizedText displayedName;
  final LocalizedText? description;
  final int minAgeMonths;
  final int maxAgeMonths;
  final String groupId;
  final String status;
  final String createdAt;
  final String updatedAt;

  const InterventionMethodModel({
    required this.id,
    required this.code,
    required this.displayedName,
    this.description,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.groupId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InterventionMethodModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing InterventionMethodModel from JSON: ${json.keys.toList()}'); // Debug log
      print('🔍 InterventionMethodModel JSON: $json'); // Debug log
      
      // Handle displayedName - it might be a JSON string or an object
      LocalizedText displayedName;
      if (json['displayedName'] is String) {
        // Parse JSON string
        final displayedNameJson = jsonDecode(json['displayedName']);
        displayedName = LocalizedText.fromJson(displayedNameJson);
      } else {
        // It's already an object
        displayedName = LocalizedText.fromJson(json['displayedName'] ?? {});
      }
      
      // Handle description - it might be a JSON string or an object
      LocalizedText? description;
      if (json['description'] != null) {
        if (json['description'] is String) {
          // Parse JSON string
          final descriptionJson = jsonDecode(json['description']);
          description = LocalizedText.fromJson(descriptionJson);
        } else {
          // It's already an object
          description = LocalizedText.fromJson(json['description']);
        }
      }
      
      return InterventionMethodModel(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        displayedName: displayedName,
        description: description,
        minAgeMonths: json['minAgeMonths'] ?? 0,
        maxAgeMonths: json['maxAgeMonths'] ?? 0,
        groupId: json['groupId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'ACTIVE',
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
      );
    } catch (e) {
      print('❌ Error in InterventionMethodModel.fromJson: $e'); // Debug log
      print('❌ JSON data: $json'); // Debug log
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description!.toJson(),
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
      'groupId': groupId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  InterventionMethodModel copyWith({
    String? id,
    String? code,
    LocalizedText? displayedName,
    LocalizedText? description,
    int? minAgeMonths,
    int? maxAgeMonths,
    String? groupId,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return InterventionMethodModel(
      id: id ?? this.id,
      code: code ?? this.code,
      displayedName: displayedName ?? this.displayedName,
      description: description ?? this.description,
      minAgeMonths: minAgeMonths ?? this.minAgeMonths,
      maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Paginated response for method groups
class PaginatedMethodGroups {
  final List<InterventionMethodGroupModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final bool first;
  final bool last;

  const PaginatedMethodGroups({
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

  factory PaginatedMethodGroups.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing PaginatedMethodGroups from JSON: ${json.keys.toList()}'); // Debug log
      print('🔍 PaginatedMethodGroups JSON: $json'); // Debug log
      
      final List<dynamic> contentList = json['content'] ?? [];
      final List<InterventionMethodGroupModel> methodGroups = contentList
          .map((item) => InterventionMethodGroupModel.fromJson(item))
          .toList();
      
      // Handle different pagination field names from API
      final int pageNumber = json['number'] ?? json['pageNumber'] ?? 0;
      final int pageSize = json['size'] ?? json['pageSize'] ?? 10;
      final int totalElements = json['totalElements'] ?? 0;
      final int totalPages = json['totalPages'] ?? 0;
      final bool isFirst = json['first'] ?? true;
      final bool isLast = json['last'] ?? true;
      
      // Calculate hasNext and hasPrevious based on available data
      final bool hasNext = !isLast && pageNumber < totalPages - 1;
      final bool hasPrevious = !isFirst && pageNumber > 0;
      
      return PaginatedMethodGroups(
        content: methodGroups,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalElements: totalElements,
        totalPages: totalPages,
        hasNext: hasNext,
        hasPrevious: hasPrevious,
        first: isFirst,
        last: isLast,
      );
    } catch (e) {
      print('❌ Error in PaginatedMethodGroups.fromJson: $e'); // Debug log
      print('❌ JSON data: $json'); // Debug log
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((item) => item.toJson()).toList(),
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
      'first': first,
      'last': last,
    };
  }
}

/// Paginated response for methods
class PaginatedMethods {
  final List<InterventionMethodModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final bool first;
  final bool last;

  const PaginatedMethods({
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

  factory PaginatedMethods.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing PaginatedMethods from JSON: ${json.keys.toList()}'); // Debug log
      print('🔍 PaginatedMethods JSON: $json'); // Debug log
      
      final List<dynamic> contentList = json['content'] ?? [];
      final List<InterventionMethodModel> methods = contentList
          .map((item) => InterventionMethodModel.fromJson(item))
          .toList();
      
      // Handle different pagination field names from API
      final int pageNumber = json['number'] ?? json['pageNumber'] ?? 0;
      final int pageSize = json['size'] ?? json['pageSize'] ?? 10;
      final int totalElements = json['totalElements'] ?? 0;
      final int totalPages = json['totalPages'] ?? 0;
      final bool isFirst = json['first'] ?? true;
      final bool isLast = json['last'] ?? true;
      
      // Calculate hasNext and hasPrevious based on available data
      final bool hasNext = !isLast && pageNumber < totalPages - 1;
      final bool hasPrevious = !isFirst && pageNumber > 0;
      
      return PaginatedMethods(
        content: methods,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalElements: totalElements,
        totalPages: totalPages,
        hasNext: hasNext,
        hasPrevious: hasPrevious,
        first: isFirst,
        last: isLast,
      );
    } catch (e) {
      print('❌ Error in PaginatedMethods.fromJson: $e'); // Debug log
      print('❌ JSON data: $json'); // Debug log
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((item) => item.toJson()).toList(),
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
      'first': first,
      'last': last,
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
      print('🔍 Parsing LocalizedText from JSON: ${json.keys.toList()}'); // Debug log
      print('🔍 LocalizedText JSON: $json'); // Debug log
      
      // Handle different possible key names
      String vi = '';
      String en = '';
      
      // Try different possible keys
      vi = json['vi']?.toString() ?? 
           json['vietnamese']?.toString() ?? 
           json['vietnam']?.toString() ?? 
           json['vn']?.toString() ?? 
           '';
           
      en = json['en']?.toString() ?? 
           json['english']?.toString() ?? 
           json['eng']?.toString() ?? 
           '';
      
      return LocalizedText(vi: vi, en: en);
    } catch (e) {
      print('❌ Error in LocalizedText.fromJson: $e'); // Debug log
      print('❌ JSON data: $json'); // Debug log
      // Return default values instead of throwing
      return const LocalizedText(vi: '', en: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'vi': vi,
      'en': en,
    };
  }

  @override
  String toString() {
    return 'LocalizedText(vi: $vi, en: $en)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalizedText && other.vi == vi && other.en == en;
  }

  @override
  int get hashCode => vi.hashCode ^ en.hashCode;
}

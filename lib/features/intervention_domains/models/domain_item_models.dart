import 'package:flutter/foundation.dart';

@immutable
class DevelopmentalDomainItemModel {
  final String id;
  final String? name; // legacy optional
  final LocalizedText? displayedName; // legacy optional
  final LocalizedText? description; // legacy optional
  final String? category; // legacy optional
  final LocalizedText? title; // V2 field
  final String? domainId; // V2 field

  const DevelopmentalDomainItemModel({
    required this.id,
    this.name,
    this.displayedName,
    this.description,
    this.category,
    this.title,
    this.domainId,
  });

  factory DevelopmentalDomainItemModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? displayed;
    if (json['displayedName'] is Map<String, dynamic>) {
      displayed = json['displayedName'] as Map<String, dynamic>;
    } else if (json['displayed_name'] is Map<String, dynamic>) {
      displayed = json['displayed_name'] as Map<String, dynamic>;
    }

    Map<String, dynamic>? title;
    if (json['title'] is Map<String, dynamic>) {
      title = json['title'] as Map<String, dynamic>;
    }

    Map<String, dynamic>? description;
    final rawDesc = json['description'];
    if (rawDesc is Map<String, dynamic>) {
      description = rawDesc;
    }

    return DevelopmentalDomainItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      displayedName: displayed != null
          ? LocalizedText.fromJson(displayed)
          : null,
      description: description != null
          ? LocalizedText.fromJson(description)
          : null,
      category: json['category']?.toString(),
      title: title != null ? LocalizedText.fromJson(title) : null,
      domainId: json['domainId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (displayedName != null) 'displayedName': displayedName!.toJson(),
      if (description != null) 'description': description!.toJson(),
      if (category != null) 'category': category,
      if (title != null) 'title': title!.toJson(),
      if (domainId != null) 'domainId': domainId,
    };
  }
}

@immutable
class LocalizedText {
  final String vi;
  final String en;

  const LocalizedText({required this.vi, required this.en});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      vi: json['vi']?.toString() ?? '',
      en: json['en']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'vi': vi, 'en': en};

  LocalizedText copyWith({String? vi, String? en}) {
    return LocalizedText(vi: vi ?? this.vi, en: en ?? this.en);
  }
}

@immutable
class PaginatedDomainItems {
  final List<DevelopmentalDomainItemModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  const PaginatedDomainItems({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PaginatedDomainItems.fromJson(Map<String, dynamic> json) {
    return PaginatedDomainItems(
      content: (json['content'] as List<dynamic>? ?? [])
          .map(
            (e) => DevelopmentalDomainItemModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      pageNumber: (json['pageNumber'] ?? 0) as int,
      pageSize: (json['pageSize'] ?? 0) as int,
      totalElements: (json['totalElements'] ?? 0) as int,
      totalPages: (json['totalPages'] ?? 0) as int,
      first: (json['first'] ?? true) as bool,
      last: (json['last'] ?? true) as bool,
    );
  }
}

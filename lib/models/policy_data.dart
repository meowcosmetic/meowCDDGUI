class PolicyData {
  final String policyId;
  final String serviceName;
  final String policyType;
  final Map<String, String> titles;
  final List<PolicySection> sections;
  final int version;
  final bool isActive;
  final List<String> tags;
  final PolicyMetadata metadata;

  PolicyData({
    required this.policyId,
    required this.serviceName,
    required this.policyType,
    required this.titles,
    required this.sections,
    required this.version,
    required this.isActive,
    required this.tags,
    required this.metadata,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      policyId: json['policyId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      policyType: json['policyType'] ?? '',
      titles: Map<String, String>.from(json['titles'] ?? {}),
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((section) => PolicySection.fromJson(section))
              .toList() ??
          [],
      version: json['version'] ?? 1,
      isActive: json['isActive'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: PolicyMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'policyId': policyId,
      'serviceName': serviceName,
      'policyType': policyType,
      'titles': titles,
      'sections': sections.map((section) => section.toJson()).toList(),
      'version': version,
      'isActive': isActive,
      'tags': tags,
      'metadata': metadata.toJson(),
    };
  }

  String getTitle(String language) {
    return titles[language] ?? titles['vi'] ?? '';
  }
}

class PolicySection {
  final String sectionId;
  final int order;
  final Map<String, String> titles;
  final Map<String, String> contents;
  final bool isRequired;
  final String sectionType;

  PolicySection({
    required this.sectionId,
    required this.order,
    required this.titles,
    required this.contents,
    required this.isRequired,
    required this.sectionType,
  });

  factory PolicySection.fromJson(Map<String, dynamic> json) {
    return PolicySection(
      sectionId: json['sectionId'] ?? '',
      order: json['order'] ?? 0,
      titles: Map<String, String>.from(json['titles'] ?? {}),
      contents: Map<String, String>.from(json['contents'] ?? {}),
      isRequired: json['isRequired'] ?? true,
      sectionType: json['sectionType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'order': order,
      'titles': titles,
      'contents': contents,
      'isRequired': isRequired,
      'sectionType': sectionType,
    };
  }

  String getTitle(String language) {
    return titles[language] ?? titles['vi'] ?? '';
  }

  String getContent(String language) {
    return contents[language] ?? contents['vi'] ?? '';
  }

  List<String> getContentList(String language) {
    final content = getContent(language);
    return content.split('. ').where((item) => item.trim().isNotEmpty).toList();
  }
}

class PolicyMetadata {
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final String createdBy;
  final String updatedBy;
  final String deletedBy;
  final bool deleted;

  PolicyMetadata({
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    required this.deleted,
  });

  factory PolicyMetadata.fromJson(Map<String, dynamic> json) {
    return PolicyMetadata(
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      deletedBy: json['deletedBy'] ?? '',
      deleted: json['deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
      'deleted': deleted,
    };
  }
}

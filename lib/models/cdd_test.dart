import 'dart:convert';

class CDDTest {
  final String? id;
  final String assessmentCode;
  final Map<String, String> names;
  final Map<String, String> descriptions;
  final Map<String, String> instructions;
  final String category;
  final int minAgeMonths;
  final int maxAgeMonths;
  final String status;
  final String version;
  final int estimatedDuration;
  final String administrationType;
  final String requiredQualifications;
  final List<String> requiredMaterials;
  final Map<String, String> notes;
  final List<CDDQuestion> questions;
  final CDDScoringCriteria scoringCriteria;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CDDTest({
    this.id,
    required this.assessmentCode,
    required this.names,
    required this.descriptions,
    required this.instructions,
    required this.category,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.status,
    required this.version,
    required this.estimatedDuration,
    required this.administrationType,
    required this.requiredQualifications,
    required this.requiredMaterials,
    required this.notes,
    required this.questions,
    required this.scoringCriteria,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessmentCode': assessmentCode,
      'namesJson': jsonEncode(names),
      'descriptionsJson': jsonEncode(descriptions),
      'instructionsJson': jsonEncode(instructions),
      'category': category,
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
      'status': status,
      'version': version,
      'estimatedDuration': estimatedDuration,
      'administrationType': administrationType,
      'requiredQualifications': requiredQualifications,
      'requiredMaterialsJson': jsonEncode(requiredMaterials),
      'notesJson': jsonEncode(notes),
      'questionsJson': jsonEncode(questions.map((q) => q.toJson()).toList()),
      'scoringCriteriaJson': jsonEncode(scoringCriteria.toJson()),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CDDTest.fromJson(Map<String, dynamic> json) {
    return CDDTest(
      id: json['id']?.toString(),
      assessmentCode: json['assessmentCode'] ?? '',
      names: Map<String, String>.from(jsonDecode(json['namesJson'] ?? '{}')),
      descriptions: Map<String, String>.from(jsonDecode(json['descriptionsJson'] ?? '{}')),
      instructions: Map<String, String>.from(jsonDecode(json['instructionsJson'] ?? '{}')),
      category: json['category'] ?? '',
      minAgeMonths: json['minAgeMonths'] ?? 0,
      maxAgeMonths: json['maxAgeMonths'] ?? 0,
      status: json['status'] ?? 'DRAFT',
      version: json['version'] ?? '1.0',
      estimatedDuration: json['estimatedDuration'] ?? 15,
      administrationType: json['administrationType'] ?? 'PARENT_REPORT',
      requiredQualifications: json['requiredQualifications'] ?? 'NO_QUALIFICATION_REQUIRED',
      requiredMaterials: List<String>.from(jsonDecode(json['requiredMaterialsJson'] ?? '[]')),
      notes: Map<String, String>.from(jsonDecode(json['notesJson'] ?? '{}')),
      questions: (jsonDecode(json['questionsJson'] ?? '[]') as List)
          .map((q) => CDDQuestion.fromJson(q))
          .toList(),
      scoringCriteria: CDDScoringCriteria.fromJson(jsonDecode(json['scoringCriteriaJson'] ?? '{}')),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  String getName(String language) => names[language] ?? names['vi'] ?? '';
  String getDescription(String language) => descriptions[language] ?? descriptions['vi'] ?? '';
  String getInstructions(String language) => instructions[language] ?? instructions['vi'] ?? '';
  String getNotes(String language) => notes[language] ?? notes['vi'] ?? '';
}

class CDDQuestion {
  final String questionId;
  final int questionNumber;
  final Map<String, String> questionTexts;
  final String category;
  final int weight;
  final bool required;
  final Map<String, String> hints;
  final Map<String, String> explanations;

  CDDQuestion({
    required this.questionId,
    required this.questionNumber,
    required this.questionTexts,
    required this.category,
    required this.weight,
    required this.required,
    required this.hints,
    required this.explanations,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionNumber': questionNumber,
      'questionTexts': questionTexts,
      'category': category,
      'weight': weight,
      'required': required,
      'hints': hints,
      'explanations': explanations,
    };
  }

  factory CDDQuestion.fromJson(Map<String, dynamic> json) {
    return CDDQuestion(
      questionId: json['questionId'] ?? '',
      questionNumber: json['questionNumber'] ?? 0,
      questionTexts: Map<String, String>.from(json['questionTexts'] ?? {}),
      category: json['category'] ?? '',
      weight: json['weight'] ?? 1,
      required: json['required'] ?? true,
      hints: Map<String, String>.from(json['hints'] ?? {}),
      explanations: Map<String, String>.from(json['explanations'] ?? {}),
    );
  }

  String getQuestionText(String language) => questionTexts[language] ?? questionTexts['vi'] ?? '';
  String getHint(String language) => hints[language] ?? hints['vi'] ?? '';
  String getExplanation(String language) => explanations[language] ?? explanations['vi'] ?? '';
}

class CDDScoringCriteria {
  final int totalQuestions;
  final int yesScore;
  final int noScore;
  final Map<String, CDDScoreRange> scoreRanges;
  final String interpretation;

  CDDScoringCriteria({
    required this.totalQuestions,
    required this.yesScore,
    required this.noScore,
    required this.scoreRanges,
    required this.interpretation,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'yesScore': yesScore,
      'noScore': noScore,
      'scoreRanges': scoreRanges.map((key, value) => MapEntry(key, value.toJson())),
      'interpretation': interpretation,
    };
  }

  factory CDDScoringCriteria.fromJson(Map<String, dynamic> json) {
    return CDDScoringCriteria(
      totalQuestions: json['totalQuestions'] ?? 0,
      yesScore: json['yesScore'] ?? 1,
      noScore: json['noScore'] ?? 0,
      scoreRanges: (json['scoreRanges'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, CDDScoreRange.fromJson(value)),
          ) ??
          {},
      interpretation: json['interpretation'] ?? '',
    );
  }
}

class CDDScoreRange {
  final int minScore;
  final int maxScore;
  final String level;
  final Map<String, String> descriptions;
  final String recommendation;

  CDDScoreRange({
    required this.minScore,
    required this.maxScore,
    required this.level,
    required this.descriptions,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'minScore': minScore,
      'maxScore': maxScore,
      'level': level,
      'descriptions': descriptions,
      'recommendation': recommendation,
    };
  }

  factory CDDScoreRange.fromJson(Map<String, dynamic> json) {
    return CDDScoreRange(
      minScore: json['minScore'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      level: json['level'] ?? '',
      descriptions: Map<String, String>.from(json['descriptions'] ?? {}),
      recommendation: json['recommendation'] ?? '',
    );
  }

  String getDescription(String language) => descriptions[language] ?? descriptions['vi'] ?? '';
}

// Enums
class CDDTestStatus {
  static const String DRAFT = 'DRAFT';
  static const String ACTIVE = 'ACTIVE';
  static const String INACTIVE = 'INACTIVE';
  static const String ARCHIVED = 'ARCHIVED';
}

class CDDAdministrationType {
  static const String PARENT_REPORT = 'PARENT_REPORT';
  static const String PROFESSIONAL_OBSERVATION = 'PROFESSIONAL_OBSERVATION';
  static const String DIRECT_ASSESSMENT = 'DIRECT_ASSESSMENT';
  static const String SELF_REPORT = 'SELF_REPORT';
}

class CDDRequiredQualifications {
  static const String NO_QUALIFICATION_REQUIRED = 'NO_QUALIFICATION_REQUIRED';
  static const String PSYCHOLOGIST_REQUIRED = 'PSYCHOLOGIST_REQUIRED';
  static const String PEDIATRICIAN_REQUIRED = 'PEDIATRICIAN_REQUIRED';
  static const String DEVELOPMENTAL_SPECIALIST_REQUIRED = 'DEVELOPMENTAL_SPECIALIST_REQUIRED';
  static const String THERAPIST_REQUIRED = 'THERAPIST_REQUIRED';
  static const String NURSE_REQUIRED = 'NURSE_REQUIRED';
  static const String TEACHER_REQUIRED = 'TEACHER_REQUIRED';
}

class CDDQuestionCategory {
  static const String COMMUNICATION_LANGUAGE = 'COMMUNICATION_LANGUAGE';
  static const String GROSS_MOTOR = 'GROSS_MOTOR';
  static const String FINE_MOTOR = 'FINE_MOTOR';
  static const String IMITATION_LEARNING = 'IMITATION_LEARNING';
  static const String PERSONAL_SOCIAL = 'PERSONAL_SOCIAL';
  static const String OTHER = 'OTHER';
}

class TestResultModel {
  final String? id;
  final String childId;
  final String testId;
  final String testType;
  final DateTime testDate;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double totalScore;
  final double maxScore;
  final double percentageScore;
  final String resultLevel;
  final String interpretation;
  final String questionAnswers;
  final int correctAnswers;
  final int totalQuestions;
  final int skippedQuestions;
  final String notes;
  final String environment;
  final String assessor;
  final bool parentPresent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TestResultModel({
    this.id,
    required this.childId,
    required this.testId,
    required this.testType,
    required this.testDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalScore,
    required this.maxScore,
    required this.percentageScore,
    required this.resultLevel,
    required this.interpretation,
    required this.questionAnswers,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.skippedQuestions,
    required this.notes,
    required this.environment,
    required this.assessor,
    required this.parentPresent,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'childId': childId,
      'testId': testId,
      'testType': testType,
      'testDate': testDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'totalScore': totalScore,
      'maxScore': maxScore,
      'percentageScore': percentageScore,
      'resultLevel': resultLevel,
      'interpretation': interpretation,
      'questionAnswers': questionAnswers,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'skippedQuestions': skippedQuestions,
      'notes': notes,
      'environment': environment,
      'assessor': assessor,
      'parentPresent': parentPresent,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      id: json['id']?.toString(),
      childId: json['childId'].toString(),
      testId: json['testId'].toString(),
      testType: json['testType'],
      testDate: DateTime.parse(json['testDate']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'],
      totalScore: (json['totalScore'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      percentageScore: (json['percentageScore'] as num).toDouble(),
      resultLevel: json['resultLevel'],
      interpretation: json['interpretation'],
      questionAnswers: json['questionAnswers'],
      correctAnswers: json['correctAnswers'],
      totalQuestions: json['totalQuestions'],
      skippedQuestions: json['skippedQuestions'],
      notes: json['notes'],
      environment: json['environment'],
      assessor: json['assessor'],
      parentPresent: json['parentPresent'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  TestResultModel copyWith({
    String? id,
    String? childId,
    String? testId,
    String? testType,
    DateTime? testDate,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    double? totalScore,
    double? maxScore,
    double? percentageScore,
    String? resultLevel,
    String? interpretation,
    String? questionAnswers,
    int? correctAnswers,
    int? totalQuestions,
    int? skippedQuestions,
    String? notes,
    String? environment,
    String? assessor,
    bool? parentPresent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestResultModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      testId: testId ?? this.testId,
      testType: testType ?? this.testType,
      testDate: testDate ?? this.testDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalScore: totalScore ?? this.totalScore,
      maxScore: maxScore ?? this.maxScore,
      percentageScore: percentageScore ?? this.percentageScore,
      resultLevel: resultLevel ?? this.resultLevel,
      interpretation: interpretation ?? this.interpretation,
      questionAnswers: questionAnswers ?? this.questionAnswers,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      notes: notes ?? this.notes,
      environment: environment ?? this.environment,
      assessor: assessor ?? this.assessor,
      parentPresent: parentPresent ?? this.parentPresent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

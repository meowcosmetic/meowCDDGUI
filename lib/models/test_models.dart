import 'package:flutter/material.dart';

/// Model cho câu hỏi trong bài test
class TestQuestion {
  final String questionId;
  final int questionNumber;
  final Map<String, String> questionTexts; // vi, en
  final String category;
  final int weight;
  final bool required;
  final Map<String, String> hints; // vi, en
  final Map<String, String> explanations; // vi, en

  const TestQuestion({
    required this.questionId,
    required this.questionNumber,
    required this.questionTexts,
    required this.category,
    required this.weight,
    required this.required,
    required this.hints,
    required this.explanations,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
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

  /// Lấy text câu hỏi theo ngôn ngữ
  String getQuestionText([String language = 'vi']) {
    return questionTexts[language] ?? questionTexts['vi'] ?? '';
  }

  /// Lấy hint theo ngôn ngữ
  String getHint([String language = 'vi']) {
    return hints[language] ?? hints['vi'] ?? '';
  }

  /// Lấy giải thích theo ngôn ngữ
  String getExplanation([String language = 'vi']) {
    return explanations[language] ?? explanations['vi'] ?? '';
  }

  /// Lấy text category
  String getCategoryText() {
    switch (category) {
      case 'COMMUNICATION_LANGUAGE':
        return 'Giao tiếp - Ngôn ngữ';
      case 'GROSS_MOTOR':
        return 'Vận động thô';
      case 'FINE_MOTOR':
        return 'Vận động tinh';
      case 'IMITATION_LEARNING':
        return 'Bắt chước và học';
      case 'PERSONAL_SOCIAL':
        return 'Cá nhân - Xã hội';
      case 'OTHER':
        return 'Khác';
      default:
        return category;
    }
  }

  /// Lấy màu category
  Color getCategoryColor() {
    switch (category) {
      case 'COMMUNICATION_LANGUAGE':
        return Colors.blue;
      case 'GROSS_MOTOR':
        return Colors.green;
      case 'FINE_MOTOR':
        return Colors.orange;
      case 'IMITATION_LEARNING':
        return Colors.purple;
      case 'PERSONAL_SOCIAL':
        return Colors.pink;
      case 'OTHER':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

/// Model cho tiêu chí chấm điểm
class ScoringCriteria {
  final int totalQuestions;
  final int yesScore;
  final int noScore;
  final Map<String, ScoreRange> scoreRanges;
  final String interpretation;

  const ScoringCriteria({
    required this.totalQuestions,
    required this.yesScore,
    required this.noScore,
    required this.scoreRanges,
    required this.interpretation,
  });

  factory ScoringCriteria.fromJson(Map<String, dynamic> json) {
    final ranges = <String, ScoreRange>{};
    final scoreRangesData = json['scoreRanges'] as Map<String, dynamic>? ?? {};
    
    scoreRangesData.forEach((key, value) {
      ranges[key] = ScoreRange.fromJson(value);
    });

    return ScoringCriteria(
      totalQuestions: json['totalQuestions'] ?? 0,
      yesScore: json['yesScore'] ?? 1,
      noScore: json['noScore'] ?? 0,
      scoreRanges: ranges,
      interpretation: json['interpretation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final ranges = <String, dynamic>{};
    scoreRanges.forEach((key, value) {
      ranges[key] = value.toJson();
    });

    return {
      'totalQuestions': totalQuestions,
      'yesScore': yesScore,
      'noScore': noScore,
      'scoreRanges': ranges,
      'interpretation': interpretation,
    };
  }
}

/// Model cho khoảng điểm
class ScoreRange {
  final int minScore;
  final int maxScore;
  final String level;
  final Map<String, String> descriptions;
  final String recommendation;

  const ScoreRange({
    required this.minScore,
    required this.maxScore,
    required this.level,
    required this.descriptions,
    required this.recommendation,
  });

  factory ScoreRange.fromJson(Map<String, dynamic> json) {
    return ScoreRange(
      minScore: json['minScore'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      level: json['level'] ?? '',
      descriptions: Map<String, String>.from(json['descriptions'] ?? {}),
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minScore': minScore,
      'maxScore': maxScore,
      'level': level,
      'descriptions': descriptions,
      'recommendation': recommendation,
    };
  }

  /// Lấy mô tả theo ngôn ngữ
  String getDescription([String language = 'vi']) {
    return descriptions[language] ?? descriptions['vi'] ?? '';
  }

  /// Lấy màu level
  Color getLevelColor() {
    switch (level) {
      case 'LOW_RISK':
        return Colors.green;
      case 'MEDIUM_RISK':
        return Colors.orange;
      case 'HIGH_RISK':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Lấy text level
  String getLevelText() {
    switch (level) {
      case 'LOW_RISK':
        return 'Nguy cơ thấp';
      case 'MEDIUM_RISK':
        return 'Nguy cơ trung bình';
      case 'HIGH_RISK':
        return 'Nguy cơ cao';
      default:
        return level;
    }
  }
}

/// Model cho bài test
class Test {
  final String id;
  final String assessmentCode;
  final Map<String, String> names; // vi, en
  final Map<String, String> descriptions; // vi, en
  final Map<String, String> instructions; // vi, en
  final String category;
  final int minAgeMonths;
  final int maxAgeMonths;
  final String status;
  final List<TestQuestion> questions;
  final ScoringCriteria scoringCriteria;
  final Map<String, String> notes; // vi, en

  const Test({
    required this.id,
    required this.assessmentCode,
    required this.names,
    required this.descriptions,
    required this.instructions,
    required this.category,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.status,
    required this.questions,
    required this.scoringCriteria,
    required this.notes,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id']?.toString() ?? '',
      assessmentCode: json['assessmentCode'] ?? '',
      names: Map<String, String>.from(json['names'] ?? {}),
      descriptions: Map<String, String>.from(json['descriptions'] ?? {}),
      instructions: Map<String, String>.from(json['instructions'] ?? {}),
      category: json['category'] ?? '',
      minAgeMonths: json['minAgeMonths'] ?? 0,
      maxAgeMonths: json['maxAgeMonths'] ?? 0,
      status: json['status'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
          ?.map((question) => TestQuestion.fromJson(question))
          .toList() ?? [],
      scoringCriteria: ScoringCriteria.fromJson(json['scoringCriteria'] ?? {}),
      notes: Map<String, String>.from(json['notes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessmentCode': assessmentCode,
      'names': names,
      'descriptions': descriptions,
      'instructions': instructions,
      'category': category,
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
      'status': status,
      'questions': questions.map((question) => question.toJson()).toList(),
      'scoringCriteria': scoringCriteria.toJson(),
      'notes': notes,
    };
  }

  /// Lấy tên theo ngôn ngữ
  String getName([String language = 'vi']) {
    return names[language] ?? names['vi'] ?? '';
  }

  /// Lấy mô tả theo ngôn ngữ
  String getDescription([String language = 'vi']) {
    return descriptions[language] ?? descriptions['vi'] ?? '';
  }

  /// Lấy hướng dẫn theo ngôn ngữ
  String getInstruction([String language = 'vi']) {
    return instructions[language] ?? instructions['vi'] ?? '';
  }

  /// Lấy ghi chú theo ngôn ngữ
  String getNote([String language = 'vi']) {
    return notes[language] ?? notes['vi'] ?? '';
  }

  /// Lấy text category
  String getCategoryText() {
    switch (category) {
      case 'DEVELOPMENTAL_SCREENING':
        return 'Sàng lọc phát triển';
      default:
        return category;
    }
  }

  /// Lấy màu category
  Color getCategoryColor() {
    switch (category) {
      case 'DEVELOPMENTAL_SCREENING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Lấy text độ tuổi
  String getAgeRangeText() {
    if (minAgeMonths == 0 && maxAgeMonths == 0) {
      return 'Tất cả độ tuổi';
    }
    if (minAgeMonths == maxAgeMonths) {
      return '${minAgeMonths} tháng';
    }
    return '${minAgeMonths}-${maxAgeMonths} tháng';
  }

  /// Lấy text trạng thái
  String getStatusText() {
    switch (status) {
      case 'ACTIVE':
        return 'Hoạt động';
      case 'INACTIVE':
        return 'Không hoạt động';
      case 'DRAFT':
        return 'Bản nháp';
      default:
        return status;
    }
  }

  /// Lấy màu trạng thái
  Color getStatusColor() {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.red;
      case 'DRAFT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Tính tổng điểm tối đa
  int getMaxScore() {
    return questions.fold(0, (sum, question) => sum + question.weight);
  }

  /// Tính số câu hỏi bắt buộc
  int getRequiredQuestionsCount() {
    return questions.where((q) => q.required).length;
  }
}

/// Model cho kết quả test
class TestResult {
  final String id;
  final String testId;
  final String userId;
  final String userName;
  final int score;
  final int totalQuestions;
  final int answeredQuestions;
  final int timeSpent; // seconds
  final DateTime completedAt;
  final List<QuestionResult> questionResults;
  final String? notes;

  const TestResult({
    required this.id,
    required this.testId,
    required this.userId,
    required this.userName,
    required this.score,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.timeSpent,
    required this.completedAt,
    required this.questionResults,
    this.notes,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] ?? '',
      testId: json['testId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      answeredQuestions: json['answeredQuestions'] ?? 0,
      timeSpent: json['timeSpent'] ?? 0,
      completedAt: DateTime.parse(json['completedAt'] ?? DateTime.now().toIso8601String()),
      questionResults: (json['questionResults'] as List<dynamic>?)
          ?.map((result) => QuestionResult.fromJson(result))
          .toList() ?? [],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'userId': userId,
      'userName': userName,
      'score': score,
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'timeSpent': timeSpent,
      'completedAt': completedAt.toIso8601String(),
      'questionResults': questionResults.map((result) => result.toJson()).toList(),
      'notes': notes,
    };
  }

  /// Tính phần trăm hoàn thành
  double getCompletionPercentage() {
    if (totalQuestions == 0) return 0.0;
    return (answeredQuestions / totalQuestions) * 100;
  }

  /// Lấy text kết quả
  String getResultText() {
    if (score <= 2) return 'Nguy cơ thấp';
    if (score <= 5) return 'Nguy cơ trung bình';
    return 'Nguy cơ cao';
  }

  /// Lấy màu kết quả
  Color getResultColor() {
    if (score <= 2) return Colors.green;
    if (score <= 5) return Colors.orange;
    return Colors.red;
  }
}

/// Model cho kết quả từng câu hỏi
class QuestionResult {
  final String questionId;
  final bool answer; // true = yes, false = no
  final int timeSpent; // seconds
  final DateTime answeredAt;

  const QuestionResult({
    required this.questionId,
    required this.answer,
    required this.timeSpent,
    required this.answeredAt,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] ?? '',
      answer: json['answer'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
      answeredAt: DateTime.parse(json['answeredAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'timeSpent': timeSpent,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }
}

/// Dữ liệu mẫu cho bài test (legacy - giữ lại để tương thích)
class SampleTests {
  static List<Test> getSampleTests() {
    return [
      Test(
        id: '1',
        assessmentCode: 'DEVELOPMENTAL_SCREENING_V1',
        names: {'vi': 'Bảng câu hỏi sàng lọc phát triển trẻ em'},
        descriptions: {'vi': 'Bảng câu hỏi đánh giá các kỹ năng phát triển của trẻ em'},
        instructions: {'vi': 'Hãy trả lời các câu hỏi dựa trên quan sát về trẻ'},
        category: 'DEVELOPMENTAL_SCREENING',
        minAgeMonths: 0,
        maxAgeMonths: 6,
        status: 'ACTIVE',
        questions: [],
        scoringCriteria: ScoringCriteria(
          totalQuestions: 20,
          yesScore: 1,
          noScore: 0,
          scoreRanges: {},
          interpretation: '',
        ),
        notes: {'vi': 'Bảng câu hỏi sàng lọc sớm'},
      ),
    ];
  }
}

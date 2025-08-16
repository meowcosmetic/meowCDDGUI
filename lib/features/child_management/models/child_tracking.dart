class ChildTracking {
  final String id;
  final String childId;
  final DateTime date;
  final Map<String, int> scores;
  final String notes;
  final double totalScore;

  ChildTracking({
    required this.id,
    required this.childId,
    required this.date,
    required this.scores,
    this.notes = '',
  }) : totalScore = _calculateTotalScore(scores);

  static double _calculateTotalScore(Map<String, int> scores) {
    if (scores.isEmpty) return 0;
    int total = scores.values.reduce((a, b) => a + b);
    return total / scores.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'date': date.toIso8601String(),
      'scores': scores,
      'notes': notes,
    };
  }

  factory ChildTracking.fromJson(Map<String, dynamic> json) {
    return ChildTracking(
      id: json['id'],
      childId: json['childId'],
      date: DateTime.parse(json['date']),
      scores: Map<String, int>.from(json['scores']),
      notes: json['notes'] ?? '',
    );
  }
}

class TrackingQuestion {
  final String id;
  final String category;
  final String question;
  final List<String> options;
  final List<int> scores;

  const TrackingQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.scores,
  });
}

class TrackingCategory {
  final String name;
  final List<TrackingQuestion> questions;
  final int maxScore;

  const TrackingCategory({
    required this.name,
    required this.questions,
    required this.maxScore,
  });
}

class TrackingData {
  static const List<TrackingCategory> categories = [
    TrackingCategory(
      name: 'Giao tiếp',
      maxScore: 2,
      questions: [
        TrackingQuestion(
          id: 'comm_1',
          category: 'Giao tiếp',
          question: 'Hôm nay trẻ có chủ động nói hoặc ra hiệu để giao tiếp không?',
          options: ['Không', 'Chỉ khi được nhắc', 'Chủ động'],
          scores: [0, 1, 2],
        ),
        TrackingQuestion(
          id: 'comm_2',
          category: 'Giao tiếp',
          question: 'Trẻ có trả lời khi được gọi tên hoặc hỏi không?',
          options: ['Không', 'Đôi khi', 'Thường xuyên'],
          scores: [0, 1, 2],
        ),
      ],
    ),
    TrackingCategory(
      name: 'Tương tác xã hội',
      maxScore: 2,
      questions: [
        TrackingQuestion(
          id: 'social_1',
          category: 'Tương tác xã hội',
          question: 'Trẻ có nhìn vào mắt khi giao tiếp không?',
          options: ['Không', 'Thỉnh thoảng', 'Tự nhiên'],
          scores: [0, 1, 2],
        ),
        TrackingQuestion(
          id: 'social_2',
          category: 'Tương tác xã hội',
          question: 'Trẻ có chủ động tham gia chơi cùng người khác không?',
          options: ['Không', 'Khi được mời', 'Chủ động'],
          scores: [0, 1, 2],
        ),
      ],
    ),
    TrackingCategory(
      name: 'Hành vi & cảm xúc',
      maxScore: 2,
      questions: [
        TrackingQuestion(
          id: 'behavior_1',
          category: 'Hành vi & cảm xúc',
          question: 'Hôm nay trẻ có hành vi lặp lại hoặc khó kiểm soát không?',
          options: ['Nhiều', 'Thỉnh thoảng', 'Không đáng kể'],
          scores: [0, 1, 2],
        ),
        TrackingQuestion(
          id: 'behavior_2',
          category: 'Hành vi & cảm xúc',
          question: 'Trẻ có dễ nổi nóng hoặc lo âu quá mức không?',
          options: ['Rất thường', 'Thỉnh thoảng', 'Hầu như không'],
          scores: [0, 1, 2],
        ),
      ],
    ),
    TrackingCategory(
      name: 'Kỹ năng nhận thức',
      maxScore: 2,
      questions: [
        TrackingQuestion(
          id: 'cognitive_1',
          category: 'Kỹ năng nhận thức',
          question: 'Trẻ có hoàn thành nhiệm vụ đơn giản (xếp hình, ghép tranh) không?',
          options: ['Không', 'Có hỗ trợ', 'Tự làm'],
          scores: [0, 1, 2],
        ),
        TrackingQuestion(
          id: 'cognitive_2',
          category: 'Kỹ năng nhận thức',
          question: 'Trẻ có hiểu và làm theo hướng dẫn đơn giản không?',
          options: ['Không', 'Đôi khi', 'Thường xuyên'],
          scores: [0, 1, 2],
        ),
      ],
    ),
    TrackingCategory(
      name: 'Tự lập',
      maxScore: 2,
      questions: [
        TrackingQuestion(
          id: 'independence_1',
          category: 'Tự lập',
          question: 'Trẻ có tự ăn, uống hoặc mặc quần áo không?',
          options: ['Không', 'Có hỗ trợ', 'Tự làm'],
          scores: [0, 1, 2],
        ),
        TrackingQuestion(
          id: 'independence_2',
          category: 'Tự lập',
          question: 'Trẻ có tự dọn dẹp hoặc cất đồ sau khi chơi không?',
          options: ['Không', 'Khi được nhắc', 'Tự giác'],
          scores: [0, 1, 2],
        ),
      ],
    ),
  ];

  static List<TrackingQuestion> getAllQuestions() {
    List<TrackingQuestion> allQuestions = [];
    for (var category in categories) {
      allQuestions.addAll(category.questions);
    }
    return allQuestions;
  }

  static TrackingCategory? getCategoryByName(String name) {
    try {
      return categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }
}

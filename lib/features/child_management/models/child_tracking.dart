class ChildTracking {
  final String id;
  final String childId;
  final DateTime date;
  final Map<String, int> scores;
  final String notes;
  final double totalScore;
  final EmotionLevel emotionLevel;
  final ParticipationLevel participationLevel;
  final List<InterventionGoal> selectedGoals;

  ChildTracking({
    required this.id,
    required this.childId,
    required this.date,
    required this.scores,
    this.notes = '',
    required this.emotionLevel,
    required this.participationLevel,
    required this.selectedGoals,
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
      'emotionLevel': emotionLevel.index,
      'participationLevel': participationLevel.index,
      'selectedGoals': selectedGoals.map((goal) => goal.toJson()).toList(),
    };
  }

  factory ChildTracking.fromJson(Map<String, dynamic> json) {
    return ChildTracking(
      id: json['id'],
      childId: json['childId'],
      date: DateTime.parse(json['date']),
      scores: Map<String, int>.from(json['scores']),
      notes: json['notes'] ?? '',
      emotionLevel: EmotionLevel.values[json['emotionLevel'] ?? 0],
      participationLevel:
          ParticipationLevel.values[json['participationLevel'] ?? 0],
      selectedGoals:
          (json['selectedGoals'] as List?)
              ?.map((goal) => InterventionGoal.fromJson(goal))
              .toList() ??
          [],
    );
  }
}

enum EmotionLevel {
  veryHappy('😀 Rất vui, hợp tác tốt'),
  happy('😃 Vui, tham gia ổn'),
  normal('🙂 Bình thường, ít hứng thú'),
  indifferent('😐 Chưa hợp tác, thờ ơ'),
  upset('😢 Khó chịu, từ chối');

  const EmotionLevel(this.label);
  final String label;
}

enum ParticipationLevel {
  level1('⭐ Thờ ơ, bùng nổ, không tham gia'),
  level2('⭐⭐ Tham gia ít, không chú ý, hứng thú kém'),
  level3('⭐⭐⭐ Tham gia vừa, chú ý ngắn, cần nhắc nhở nhiều'),
  level4('⭐⭐⭐⭐ Tham gia tốt, có chú ý, cần nhắc nhở ít'),
  level5('⭐⭐⭐⭐⭐ Chủ động, tích cực, chú ý tốt, không nhắc nhở');

  const ParticipationLevel(this.label);
  final String label;
}

class InterventionGoal {
  final String id;
  final String title;
  final String description;
  final List<InterventionQuestion> questions;
  final bool isVisible;

  const InterventionGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.isVisible = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'isVisible': isVisible,
    };
  }

  factory InterventionGoal.fromJson(Map<String, dynamic> json) {
    return InterventionGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => InterventionQuestion.fromJson(q))
          .toList(),
      isVisible: json['isVisible'] ?? true,
    );
  }
}

class InterventionQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final String? answer;
  final bool isVisible;

  const InterventionQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.answer,
    this.isVisible = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type.index,
      'options': options,
      'answer': answer,
      'isVisible': isVisible,
    };
  }

  factory InterventionQuestion.fromJson(Map<String, dynamic> json) {
    return InterventionQuestion(
      id: json['id'],
      question: json['question'],
      type: QuestionType.values[json['type']],
      options: List<String>.from(json['options']),
      answer: json['answer'],
      isVisible: json['isVisible'] ?? true,
    );
  }
}

enum QuestionType { yesNo, supportLevel, environment }

class TrackingData {
  static const List<InterventionGoal> interventionGoals = [
    InterventionGoal(
      id: 'goal_1',
      title: 'Giao tiếp bằng lời nói',
      description: 'Trẻ có thể giao tiếp bằng lời nói với người khác',
      questions: [
        InterventionQuestion(
          id: 'goal_1_lv1',
          question: 'Con bạn có thực hiện được không?',
          type: QuestionType.yesNo,
          options: ['Có', 'Không'],
        ),
        InterventionQuestion(
          id: 'goal_1_lv2',
          question: 'Con bạn có cần trợ giúp không?',
          type: QuestionType.supportLevel,
          options: [
            'Hỗ trợ toàn phần',
            'Hỗ trợ bằng nhiều (cầm tay, nhắc liên tục)',
            'Hỗ trợ bằng cử chỉ (chỉ tay, gợi ý)',
            'Hỗ trợ bằng lời',
            'Không cần hỗ trợ',
          ],
        ),
        InterventionQuestion(
          id: 'goal_1_lv3',
          question:
              'Con bạn có làm được điều đó ở nhiều môi trường khác nhau không?',
          type: QuestionType.environment,
          options: ['Chỉ ở nhà', 'Ở nhà và trường học', 'Ở mọi nơi'],
        ),
      ],
    ),
    InterventionGoal(
      id: 'goal_2',
      title: 'Tương tác xã hội',
      description: 'Trẻ có thể tương tác với bạn bè và người lớn',
      questions: [
        InterventionQuestion(
          id: 'goal_2_lv1',
          question: 'Con bạn có thực hiện được không?',
          type: QuestionType.yesNo,
          options: ['Có', 'Không'],
        ),
        InterventionQuestion(
          id: 'goal_2_lv2',
          question: 'Con bạn có cần trợ giúp không?',
          type: QuestionType.supportLevel,
          options: [
            'Hỗ trợ toàn phần',
            'Hỗ trợ bằng nhiều (cầm tay, nhắc liên tục)',
            'Hỗ trợ bằng cử chỉ (chỉ tay, gợi ý)',
            'Hỗ trợ bằng lời',
            'Không cần hỗ trợ',
          ],
        ),
        InterventionQuestion(
          id: 'goal_2_lv3',
          question:
              'Con bạn có làm được điều đó ở nhiều môi trường khác nhau không?',
          type: QuestionType.environment,
          options: ['Chỉ ở nhà', 'Ở nhà và trường học', 'Ở mọi nơi'],
        ),
      ],
    ),
    InterventionGoal(
      id: 'goal_3',
      title: 'Tự lập trong sinh hoạt',
      description: 'Trẻ có thể tự thực hiện các hoạt động sinh hoạt hàng ngày',
      questions: [
        InterventionQuestion(
          id: 'goal_3_lv1',
          question: 'Con bạn có thực hiện được không?',
          type: QuestionType.yesNo,
          options: ['Có', 'Không'],
        ),
        InterventionQuestion(
          id: 'goal_3_lv2',
          question: 'Con bạn có cần trợ giúp không?',
          type: QuestionType.supportLevel,
          options: [
            'Hỗ trợ toàn phần',
            'Hỗ trợ bằng nhiều (cầm tay, nhắc liên tục)',
            'Hỗ trợ bằng cử chỉ (chỉ tay, gợi ý)',
            'Hỗ trợ bằng lời',
            'Không cần hỗ trợ',
          ],
        ),
        InterventionQuestion(
          id: 'goal_3_lv3',
          question:
              'Con bạn có làm được điều đó ở nhiều môi trường khác nhau không?',
          type: QuestionType.environment,
          options: ['Chỉ ở nhà', 'Ở nhà và trường học', 'Ở mọi nơi'],
        ),
      ],
    ),
    InterventionGoal(
      id: 'goal_4',
      title: 'Kỹ năng vận động tinh',
      description:
          'Trẻ có thể thực hiện các hoạt động cần sự khéo léo của bàn tay',
      questions: [
        InterventionQuestion(
          id: 'goal_4_lv1',
          question: 'Con bạn có thực hiện được không?',
          type: QuestionType.yesNo,
          options: ['Có', 'Không'],
        ),
        InterventionQuestion(
          id: 'goal_4_lv2',
          question: 'Con bạn có cần trợ giúp không?',
          type: QuestionType.supportLevel,
          options: [
            'Hỗ trợ toàn phần',
            'Hỗ trợ bằng nhiều (cầm tay, nhắc liên tục)',
            'Hỗ trợ bằng cử chỉ (chỉ tay, gợi ý)',
            'Hỗ trợ bằng lời',
            'Không cần hỗ trợ',
          ],
        ),
        InterventionQuestion(
          id: 'goal_4_lv3',
          question:
              'Con bạn có làm được điều đó ở nhiều môi trường khác nhau không?',
          type: QuestionType.environment,
          options: ['Chỉ ở nhà', 'Ở nhà và trường học', 'Ở mọi nơi'],
        ),
      ],
    ),
    InterventionGoal(
      id: 'goal_5',
      title: 'Kỹ năng nhận thức',
      description:
          'Trẻ có thể hiểu và thực hiện các nhiệm vụ nhận thức đơn giản',
      questions: [
        InterventionQuestion(
          id: 'goal_5_lv1',
          question: 'Con bạn có thực hiện được không?',
          type: QuestionType.yesNo,
          options: ['Có', 'Không'],
        ),
        InterventionQuestion(
          id: 'goal_5_lv2',
          question: 'Con bạn có cần trợ giúp không?',
          type: QuestionType.supportLevel,
          options: [
            'Hỗ trợ toàn phần',
            'Hỗ trợ bằng nhiều (cầm tay, nhắc liên tục)',
            'Hỗ trợ bằng cử chỉ (chỉ tay, gợi ý)',
            'Hỗ trợ bằng lời',
            'Không cần hỗ trợ',
          ],
        ),
        InterventionQuestion(
          id: 'goal_5_lv3',
          question:
              'Con bạn có làm được điều đó ở nhiều môi trường khác nhau không?',
          type: QuestionType.environment,
          options: ['Chỉ ở nhà', 'Ở nhà và trường học', 'Ở mọi nơi'],
        ),
      ],
    ),
    InterventionGoal(
      id: 'goal_6',
      title: 'Kiểm soát cảm xúc',
      description: 'Trẻ có thể kiểm soát và thể hiện cảm xúc một cách phù hợp',
      questions: [
        InterventionQuestion(
          id: 'goal_6_lv1',
          question: 'Con bạn có thực hiện được không?',
          type: QuestionType.yesNo,
          options: ['Có', 'Không'],
        ),
        InterventionQuestion(
          id: 'goal_6_lv2',
          question: 'Con bạn có cần trợ giúp không?',
          type: QuestionType.supportLevel,
          options: [
            'Hỗ trợ toàn phần',
            'Hỗ trợ bằng nhiều (cầm tay, nhắc liên tục)',
            'Hỗ trợ bằng cử chỉ (chỉ tay, gợi ý)',
            'Hỗ trợ bằng lời',
            'Không cần hỗ trợ',
          ],
        ),
        InterventionQuestion(
          id: 'goal_6_lv3',
          question:
              'Con bạn có làm được điều đó ở nhiều môi trường khác nhau không?',
          type: QuestionType.environment,
          options: ['Chỉ ở nhà', 'Ở nhà và trường học', 'Ở mọi nơi'],
        ),
      ],
    ),
  ];

  // Legacy tracking data for backward compatibility
  static const List<TrackingCategory> categories = [
    TrackingCategory(
      name: 'Giao tiếp',
      maxScore: 2,
      questions: [
        TrackingQuestion(
          id: 'comm_1',
          category: 'Giao tiếp',
          question:
              'Hôm nay trẻ có chủ động nói hoặc ra hiệu để giao tiếp không?',
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
          question:
              'Trẻ có hoàn thành nhiệm vụ đơn giản (xếp hình, ghép tranh) không?',
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

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/test_models.dart';
import '../../../models/child.dart';
import '../extension_test/q_001.dart';
import '../extension_test/q_002.dart';
import '../extension_test/q_003.dart';
import '../extension_test/q_004.dart';
import '../extension_test/q_005.dart';
import '../extension_test/q_006.dart';

class TestTakingPage extends StatefulWidget {
  final Test test;
  final Child? child; // Thêm thông tin về trẻ

  const TestTakingPage({
    super.key,
    required this.test,
    this.child, // Optional parameter
  });

  @override
  State<TestTakingPage> createState() => _TestTakingPageState();
}

class _TestTakingPageState extends State<TestTakingPage> {
  int currentQuestionIndex = 0;
  Map<String, bool> answers = {}; // questionId -> true (yes) / false (no)
  DateTime startTime = DateTime.now();
  bool isCompleted = false;
  TestResult? result;
  

  // Check if this is M-CHAT-R test
  bool _isMCHATRTest() {
    return widget.test.assessmentCode == 'M-CHAT-R';
  }


  @override
  Widget build(BuildContext context) {
    if (isCompleted && result != null) {
      return _buildResultPage();
    }

    final currentQuestion = widget.test.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / widget.test.questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          widget.test.getName(),
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Câu ${currentQuestionIndex + 1}/${widget.test.questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: currentQuestion
                                    .getCategoryColor()
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(currentQuestion.category),
                                color: currentQuestion.getCategoryColor(),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Câu ${currentQuestion.questionNumber}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    currentQuestion.getCategoryText(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: currentQuestion.getCategoryColor(),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Question Text
                        Text(
                          currentQuestion.getQuestionText(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textPrimary,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Hint
                        if (currentQuestion.getHint().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    currentQuestion.getHint(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer Options
                  Text(
                    'Chọn câu trả lời:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Yes Option
                  _buildAnswerOption(
                    true,
                    'Có',
                    Icons.check_circle,
                    Colors.green,
                  ),

                  const SizedBox(height: 12),

                  // No Option
                  _buildAnswerOption(false, 'Không', Icons.cancel, Colors.red),

                  // Extension Test (inline)
                  if (_isMCHATRTest() && (currentQuestionIndex == 0 || currentQuestionIndex == 1 || currentQuestionIndex == 2 || currentQuestionIndex == 3 || currentQuestionIndex == 4 || currentQuestionIndex == 5) && answers.containsKey(currentQuestion.questionId))
                    _buildInlineExtensionTest(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      child: const Text('Câu trước'),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: answers.containsKey(currentQuestion.questionId)
                        ? _nextQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(
                      currentQuestionIndex == widget.test.questions.length - 1
                          ? 'Hoàn thành'
                          : 'Câu tiếp',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(
    bool value,
    String label,
    IconData icon,
    Color color,
  ) {
    final currentQuestion = widget.test.questions[currentQuestionIndex];
    final isSelected = answers[currentQuestion.questionId] == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          answers[currentQuestion.questionId] = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? color : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Kết quả'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Result Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Result Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: result!.getResultColor().withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getResultIcon(),
                      size: 40,
                      color: result!.getResultColor(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Result Text
                  Text(
                    result!.getResultText(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: result!.getResultColor(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Điểm: ${result!.score}/${result!.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Score Details
                  Row(
                    children: [
                      Expanded(
                        child: _buildScoreItem(
                          'Đã trả lời',
                          result!.answeredQuestions.toString(),
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildScoreItem(
                          'Chưa trả lời',
                          (result!.totalQuestions - result!.answeredQuestions)
                              .toString(),
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Time Spent
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Thời gian: ${_formatTime(result!.timeSpent)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Trả về kết quả chi tiết khi về trang chủ
                      final detailedResult = {
                        'startTime': startTime.toIso8601String(),
                        'endTime': DateTime.now().toIso8601String(),
                        'totalScore': result!.score.toDouble(),
                        'maxScore': result!.totalQuestions.toDouble(),
                        'percentageScore': (result!.score / result!.totalQuestions) * 100,
                        'correctAnswers': result!.score,
                        'totalQuestions': result!.totalQuestions,
                        'skippedQuestions': result!.totalQuestions - result!.answeredQuestions,
                        'timeSpent': result!.timeSpent,
                        'interpretation': _getInterpretation((result!.score / result!.totalQuestions) * 100),
                        'notes': 'Hoàn thành bài test ${widget.test.getName()}',
                      };
                      Navigator.pop(context, detailedResult);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Về trang chủ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _retakeTest(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.test.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _completeTest();
    }
  }


  // Build inline extension test
  Widget _buildInlineExtensionTest() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.extension,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi mở rộng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Show extension question content inline
          _getExtensionQuestionContent(),
        ],
      ),
    );
  }

  // Get extension question content (flow assessment version)
  Widget _getExtensionQuestionContent() {
    final currentQuestion = widget.test.questions[currentQuestionIndex];
    final mainAnswer = answers[currentQuestion.questionId];
    
    // Show Q_001 for question 0, Q_002 for question 1, Q_003 for question 2, Q_004 for question 3, Q_005 for question 4, Q_006 for question 5
    if (currentQuestionIndex == 0) {
      return ExtensionTestQ001(
        mainQuestionAnswer: mainAnswer,
        onUpdateMainResult: (bool newResult) {
          // Cập nhật kết quả câu hỏi chính
          final currentQuestion = widget.test.questions[currentQuestionIndex];
          setState(() {
            answers[currentQuestion.questionId] = newResult;
          });
        },
        onReturnToMainTest: () {
          // No need to return, just continue with main test
          setState(() {});
        },
      );
    } else if (currentQuestionIndex == 1) {
      return ExtensionTestQ002(
        mainQuestionAnswer: mainAnswer,
        onUpdateMainResult: (bool newResult) {
          // Cập nhật kết quả câu hỏi chính
          final currentQuestion = widget.test.questions[currentQuestionIndex];
          setState(() {
            answers[currentQuestion.questionId] = newResult;
          });
        },
        onReturnToMainTest: () {
          // No need to return, just continue with main test
          setState(() {});
        },
      );
    } else if (currentQuestionIndex == 2) {
      return ExtensionTestQ003(
        mainQuestionAnswer: mainAnswer,
        onUpdateMainResult: (bool newResult) {
          // Cập nhật kết quả câu hỏi chính
          final currentQuestion = widget.test.questions[currentQuestionIndex];
          setState(() {
            answers[currentQuestion.questionId] = newResult;
          });
        },
        onReturnToMainTest: () {
          // No need to return, just continue with main test
          setState(() {});
        },
      );
    } else if (currentQuestionIndex == 3) {
      return ExtensionTestQ004(
        mainQuestionAnswer: mainAnswer,
        onUpdateMainResult: (bool newResult) {
          // Cập nhật kết quả câu hỏi chính
          final currentQuestion = widget.test.questions[currentQuestionIndex];
          setState(() {
            answers[currentQuestion.questionId] = newResult;
          });
        },
        onReturnToMainTest: () {
          // No need to return, just continue with main test
          setState(() {});
        },
      );
    } else if (currentQuestionIndex == 4) {
      return ExtensionTestQ005(
        mainQuestionAnswer: mainAnswer,
        onUpdateMainResult: (bool newResult) {
          // Cập nhật kết quả câu hỏi chính
          final currentQuestion = widget.test.questions[currentQuestionIndex];
          setState(() {
            answers[currentQuestion.questionId] = newResult;
          });
        },
        onReturnToMainTest: () {
          // No need to return, just continue with main test
          setState(() {});
        },
      );
    } else if (currentQuestionIndex == 5) {
      return ExtensionTestQ006(
        mainQuestionAnswer: mainAnswer,
        onUpdateMainResult: (bool newResult) {
          // Cập nhật kết quả câu hỏi chính
          final currentQuestion = widget.test.questions[currentQuestionIndex];
          setState(() {
            answers[currentQuestion.questionId] = newResult;
          });
        },
        onReturnToMainTest: () {
          // No need to return, just continue with main test
          setState(() {});
        },
      );
    }
    
    // Fallback (should not reach here)
    return const SizedBox.shrink();
  }



  void _completeTest() {
    final endTime = DateTime.now();
    final timeSpent = endTime.difference(startTime).inSeconds;

    int score = 0;
    int answeredQuestions = 0;
    int correctAnswers = 0;
    final questionResults = <QuestionResult>[];
    final questionAnswersMap = <String, Map<String, dynamic>>{};

    for (int i = 0; i < widget.test.questions.length; i++) {
      final question = widget.test.questions[i];
      final answer = answers[question.questionId];

      if (answer != null) {
        answeredQuestions++;
        if (answer) {
          // If answered "Yes"
          score += question.weight;
          correctAnswers++;
        }

        questionResults.add(
          QuestionResult(
            questionId: question.questionId,
            answer: answer,
            timeSpent: 0, // TODO: Track individual question time
            answeredAt: DateTime.now(),
          ),
        );

        // Tạo map cho questionAnswers JSON
        questionAnswersMap[question.questionId] = {
          'answer': answer ? 'YES' : 'NO',
          'score': answer ? question.weight : 0,
        };
      }
    }

    // Tính percentage score
    final maxPossibleScore = widget.test.questions.fold<int>(
      0,
      (sum, q) => sum + q.weight,
    );
    final percentageScore = maxPossibleScore > 0
        ? (score / maxPossibleScore) * 100
        : 0.0;

    // Tạo TestResult cho hiển thị
    final result = TestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: widget.test.id,
      userId: widget.child?.id ?? 'user123',
      userName: widget.child?.name ?? 'Người dùng',
      score: score,
      totalQuestions: widget.test.questions.length,
      answeredQuestions: answeredQuestions,
      timeSpent: timeSpent,
      completedAt: endTime,
      questionResults: questionResults,
    );

    // Tạo kết quả chi tiết để trả về cho TestDetailView
    final detailedResult = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalScore': score.toDouble(),
      'maxScore': maxPossibleScore.toDouble(),
      'percentageScore': percentageScore,
      'correctAnswers': correctAnswers,
      'totalQuestions': widget.test.questions.length,
      'skippedQuestions': widget.test.questions.length - answeredQuestions,
      'questionAnswers': questionAnswersMap,
      'interpretation': _getInterpretation(percentageScore),
      'notes': 'Hoàn thành bài test ${widget.test.getName()}',
    };

    setState(() {
      this.result = result;
      isCompleted = true;
    });

    // Trả về kết quả chi tiết cho TestDetailView
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Navigator.pop(context, detailedResult);
    // });
  }

  String _getInterpretation(double percentageScore) {
    if (percentageScore >= 80) {
      return 'Trẻ có khả năng phát triển xuất sắc trong các lĩnh vực được đánh giá. Kết quả cho thấy trẻ đạt mức độ phát triển vượt trội so với độ tuổi.';
    } else if (percentageScore >= 70) {
      return 'Trẻ có khả năng phát triển tốt trong các lĩnh vực được đánh giá. Kết quả cho thấy trẻ đạt mức độ phát triển phù hợp với độ tuổi.';
    } else if (percentageScore >= 60) {
      return 'Trẻ có khả năng phát triển ở mức trung bình. Cần theo dõi và hỗ trợ thêm để cải thiện các kỹ năng.';
    } else if (percentageScore >= 50) {
      return 'Trẻ có một số khó khăn trong phát triển. Cần can thiệp sớm và hỗ trợ chuyên môn.';
    } else {
      return 'Trẻ cần được đánh giá chi tiết hơn và can thiệp chuyên môn ngay lập tức. Kết quả cho thấy có dấu hiệu chậm phát triển.';
    }
  }

  void _retakeTest() {
    setState(() {
      currentQuestionIndex = 0;
      answers.clear();
      startTime = DateTime.now();
      isCompleted = false;
      result = null;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát bài test?'),
        content: const Text(
          'Bạn có chắc muốn thoát? Tiến độ hiện tại sẽ bị mất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  IconData _getResultIcon() {
    if (result!.score <= 2) return Icons.check_circle;
    if (result!.score <= 5) return Icons.warning;
    return Icons.error;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'COMMUNICATION_LANGUAGE':
        return Icons.chat;
      case 'GROSS_MOTOR':
        return Icons.accessibility;
      case 'FINE_MOTOR':
        return Icons.handyman;
      case 'IMITATION_LEARNING':
        return Icons.school;
      case 'PERSONAL_SOCIAL':
        return Icons.people;
      case 'OTHER':
        return Icons.more_horiz;
      default:
        return Icons.quiz;
    }
  }
}

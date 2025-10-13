import 'package:flutter/material.dart';

class ExtensionTestQ010 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final Function(bool)?
  onUpdateMainResult; // Callback để cập nhật kết quả chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính

  const ExtensionTestQ010({
    Key? key,
    this.mainQuestionAnswer,
    this.onUpdateMainResult,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ010> createState() => _ExtensionTestQ010State();
}

class _ExtensionTestQ010State extends State<ExtensionTestQ010> {
  Map<String, bool?> selectedAnswers = {}; // questionId -> true/false/null
  bool? finalResult; // Kết quả cuối cùng của flow assessment
  String parentExample = ''; // Ví dụ từ phụ huynh
  String currentCase = ''; // Trường hợp hiện tại: 'case1', 'case2'
  bool showComparisonQuestion = false; // Hiển thị câu hỏi so sánh

  // Questions for Case 1 - Positive responses (ĐẠT)
  final List<Map<String, String>> positiveResponses = [
    {'id': 'positive_1', 'question': 'Tìm kiếm người gọi không?'},
    {'id': 'positive_2', 'question': 'Nói hoặc bập bẹ không?'},
    {'id': 'positive_3', 'question': 'Ngừng việc đang làm lại không?'},
  ];

  // Questions for Case 2 - Negative responses (KHÔNG ĐẠT)
  final List<Map<String, String>> negativeResponses = [
    {'id': 'negative_1', 'question': 'Không trả lời / phản ứng gì không?'},
    {'id': 'negative_2', 'question': 'Có vẻ nghe nhưng phớt lờ bố mẹ không?'},
    {
      'id': 'negative_3',
      'question': 'Trả lời / phản ứng chỉ khi bố mẹ đứng trước mặt không?',
    },
    {
      'id': 'negative_4',
      'question': 'Trả lời / phản ứng chỉ khi có người chạm vào không?',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isTruePath = widget.mainQuestionAnswer == true;
    final pathColor = isTruePath ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với thông tin từ câu hỏi chính
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pathColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: pathColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isTruePath ? Icons.check_circle : Icons.cancel,
                    color: pathColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kết quả câu hỏi chính: ${isTruePath ? 'Có' : 'Không'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: pathColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Đánh giá chi tiết - Phản ứng khi được gọi tên',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: pathColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Case Selection Logic
        if (currentCase.isEmpty) _buildCaseSelection(),

        // Case 1 - Parent answered "Có"
        if (currentCase == 'case1') _buildCase1Assessment(),

        // Case 2 - Parent answered "Không"
        if (currentCase == 'case2') _buildCase2Assessment(),

        // Comparison question (if needed)
        if (showComparisonQuestion) ...[
          const SizedBox(height: 20),
          _buildComparisonQuestion(),
        ],

        // Final result (nếu có)
        if (finalResult != null) ...[
          const SizedBox(height: 20),
          _buildFinalResult(),
        ],
      ],
    );
  }

  Widget _buildCaseSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Xác định trường hợp đánh giá',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dựa trên câu trả lời của phụ huynh, hãy chọn trường hợp đánh giá phù hợp:',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => currentCase = 'case1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Trường hợp 1: Phụ huynh trả lời "Có"'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => currentCase = 'case2'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Trường hợp 2: Phụ huynh trả lời "Không"'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCase1Assessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trường hợp 1: Phụ huynh trả lời "Có" - Đánh giá phản ứng tích cực',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Parent example field
        _buildParentExampleField(),

        const SizedBox(height: 20),

        // Positive response questions
        _buildQuestionSection(
          'Các phản ứng được xem là ĐẠT:',
          positiveResponses,
          Colors.green,
          Icons.check_circle,
        ),

        const SizedBox(height: 20),

        // Summary và button
        if (finalResult == null && !showComparisonQuestion)
          _buildSummarySection(Colors.green),
      ],
    );
  }

  Widget _buildCase2Assessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trường hợp 2: Phụ huynh trả lời "Không" - Đánh giá phản ứng tiêu cực',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Parent example field
        _buildParentExampleField(),

        const SizedBox(height: 20),

        // Negative response questions
        _buildQuestionSection(
          'Các phản ứng được xem là KHÔNG ĐẠT:',
          negativeResponses,
          Colors.red,
          Icons.cancel,
        ),

        const SizedBox(height: 20),

        // Summary và button
        if (finalResult == null && !showComparisonQuestion)
          _buildSummarySection(Colors.red),
      ],
    );
  }

  Widget _buildParentExampleField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: Colors.indigo, size: 24),
              const SizedBox(width: 8),
              Text(
                'Ví dụ từ phụ huynh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentCase == 'case1'
                ? 'Cho ví dụ về cách mà trẻ phản ứng khi bạn gọi tên trẻ.'
                : 'Khi con bạn đang mải tập trung vào một việc gì vui hoặc thú vị, con bạn làm gì khi bạn gọi tên trẻ?',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            currentCase == 'case1'
                ? '(Nếu cha/mẹ không đưa ra ví dụ cụ thể, gợi ý bằng các ví dụ đạt:)'
                : '(Nếu cha/mẹ không đưa ra ví dụ cụ thể, hỏi thêm theo khung dưới)',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.indigo.shade700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              setState(() {
                parentExample = value;
              });
            },
            decoration: const InputDecoration(
              hintText:
                  'Nhập ví dụ từ phụ huynh về cách trẻ phản ứng khi được gọi tên...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(
    String title,
    List<Map<String, String>> questions,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...questions
              .map(
                (questionData) => _buildQuestionCard(
                  questionData['id']!,
                  questionData['question']!,
                  color,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    String questionId,
    String question,
    Color pathColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Có'),
                  value: true,
                  groupValue: selectedAnswers[questionId],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedAnswers[questionId] = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Không'),
                  value: false,
                  groupValue: selectedAnswers[questionId],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedAnswers[questionId] = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonQuestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi so sánh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Những phản ứng nào con bạn thể hiện nhiều hơn?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleComparisonAnswer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Nhiều phản ứng ĐẠT'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleComparisonAnswer(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Nhiều phản ứng KHÔNG ĐẠT'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(Color pathColor) {
    int totalQuestions = 0;
    if (currentCase == 'case1') {
      totalQuestions = positiveResponses.length;
    } else if (currentCase == 'case2') {
      totalQuestions = negativeResponses.length;
    }

    final answeredQuestions = selectedAnswers.values
        .where((answer) => answer != null)
        .length;
    final isComplete = answeredQuestions == totalQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.info,
                color: isComplete ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isComplete ? 'Đã hoàn thành đánh giá' : 'Tiến độ đánh giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isComplete ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Đã trả lời: $answeredQuestions/$totalQuestions câu hỏi',
            style: const TextStyle(fontSize: 14),
          ),
          if (isComplete) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Xử lý kết quả
                _processResults();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pathColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hoàn thành đánh giá'),
            ),
          ],
        ],
      ),
    );
  }

  void _processResults() {
    if (currentCase == 'case1') {
      // Case 1: Check positive responses
      int positiveYesCount = 0;
      for (var question in positiveResponses) {
        if (selectedAnswers[question['id']] == true) {
          positiveYesCount++;
        }
      }

      if (positiveYesCount > 0) {
        // Has positive responses -> ĐẠT
        _setFinalResult(
          true,
          'ĐẠT - Con bạn có phản ứng tích cực khi được gọi tên',
        );
      } else {
        // No positive responses -> KHÔNG ĐẠT
        _setFinalResult(
          false,
          'KHÔNG ĐẠT - Con bạn không có phản ứng tích cực khi được gọi tên',
        );
      }
    } else if (currentCase == 'case2') {
      // Case 2: Check negative responses
      int negativeYesCount = 0;
      for (var question in negativeResponses) {
        if (selectedAnswers[question['id']] == true) {
          negativeYesCount++;
        }
      }

      if (negativeYesCount > 0) {
        // Has negative responses -> KHÔNG ĐẠT
        _setFinalResult(
          false,
          'KHÔNG ĐẠT - Con bạn có phản ứng tiêu cực khi được gọi tên',
        );
      } else {
        // No negative responses -> Check if there are any positive responses
        // This would be a mixed case, so we need to show comparison question
        setState(() {
          showComparisonQuestion = true;
        });
      }
    }
  }

  void _handleComparisonAnswer(bool morePositive) {
    if (morePositive) {
      // More positive responses -> ĐẠT
      _setFinalResult(
        true,
        'ĐẠT - Con bạn có nhiều phản ứng tích cực hơn khi được gọi tên',
      );
    } else {
      // More negative responses -> KHÔNG ĐẠT
      _setFinalResult(
        false,
        'KHÔNG ĐẠT - Con bạn có nhiều phản ứng tiêu cực hơn khi được gọi tên',
      );
    }
  }

  void _setFinalResult(bool result, String message) {
    setState(() {
      finalResult = result;
    });

    // Cập nhật kết quả chính
    if (widget.onUpdateMainResult != null) {
      widget.onUpdateMainResult!(result);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kết quả cuối cùng: $message'),
        backgroundColor: result ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildFinalResult() {
    // Tính toán thống kê
    int positiveYesCount = 0;
    int negativeYesCount = 0;

    for (var question in positiveResponses) {
      if (selectedAnswers[question['id']] == true) {
        positiveYesCount++;
      }
    }

    for (var question in negativeResponses) {
      if (selectedAnswers[question['id']] == true) {
        negativeYesCount++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: finalResult!
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: finalResult!
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                finalResult! ? Icons.check_circle : Icons.cancel,
                color: finalResult! ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kết quả đánh giá cuối cùng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: finalResult! ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      finalResult!
                          ? 'ĐẠT - Con bạn phản ứng tốt khi được gọi tên'
                          : 'KHÔNG ĐẠT - Con bạn cần hỗ trợ phát triển kỹ năng phản ứng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: finalResult! ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Thống kê chi tiết
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thống kê chi tiết:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: finalResult! ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Trường hợp',
                        currentCase == 'case1'
                            ? 'Trường hợp 1'
                            : 'Trường hợp 2',
                        Colors.blue,
                        Icons.account_tree,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Phản ứng tích cực',
                        '$positiveYesCount/${positiveResponses.length}',
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Phản ứng tiêu cực',
                        '$negativeYesCount/${negativeResponses.length}',
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Kết quả',
                        finalResult! ? 'ĐẠT' : 'KHÔNG ĐẠT',
                        finalResult! ? Colors.green : Colors.red,
                        finalResult! ? Icons.check_circle : Icons.cancel,
                      ),
                    ),
                  ],
                ),
                if (parentExample.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.indigo.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ví dụ từ phụ huynh:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parentExample,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onReturnToMainTest != null) {
                      widget.onReturnToMainTest!();
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Tiếp tục bài test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: finalResult! ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

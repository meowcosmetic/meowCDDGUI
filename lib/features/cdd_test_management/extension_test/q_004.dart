import 'package:flutter/material.dart';

class ExtensionTestQ004 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final Function(bool)? onUpdateMainResult; // Callback để cập nhật kết quả chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ004({
    Key? key,
    this.mainQuestionAnswer,
    this.onUpdateMainResult,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ004> createState() => _ExtensionTestQ004State();
}

class _ExtensionTestQ004State extends State<ExtensionTestQ004> {
  Map<String, bool?> selectedAnswers = {}; // questionId -> true/false/null
  bool? finalResult; // Kết quả cuối cùng của flow assessment
  String parentExample = ''; // Ví dụ từ phụ huynh

  // Questions for climbing behavior assessment
  final List<Map<String, String>> climbingQuestions = [
    {
      'id': 'climbing_1',
      'question': 'Trẻ có thích trèo lên cầu thang không?',
    },
    {
      'id': 'climbing_2', 
      'question': 'Trẻ có thích trèo lên ghế không?',
    },
    {
      'id': 'climbing_3',
      'question': 'Trẻ có thích trèo lên đồ đạc trong nhà không?',
    },
    {
      'id': 'climbing_4',
      'question': 'Trẻ có thích trèo lên thiết bị sân chơi ngoài trời không?',
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
                'Đánh giá chi tiết - Hành vi trèo leo',
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
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hãy đánh giá hành vi trèo leo của con bạn. Trả lời Có/Không cho từng câu hỏi dưới đây:',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
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
        
        // Climbing Questions
        _buildQuestionSection(
          'Các câu hỏi gợi ý (trả lời Có/Không)',
          climbingQuestions,
          Colors.teal,
          Icons.stairs,
        ),
        
        const SizedBox(height: 20),
        
        // Summary và button
        if (finalResult == null)
          _buildSummarySection(pathColor),
        
        // Final result (nếu có)
        if (finalResult != null) ...[
          const SizedBox(height: 20),
          _buildFinalResult(),
        ],
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
              Icon(Icons.help_outline, color: Colors.indigo, size: 24),
              const SizedBox(width: 8),
              Text(
                'Hướng dẫn hỏi phụ huynh',
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
            'Hãy ví dụ cho tôi về một thứ nào đó mà trẻ thích trèo lên.',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(Nếu cha/mẹ không đưa ra được ví dụ thì ĐẠT nếu trả lời Có ở bất kỳ câu hỏi nào dưới đây, hoặc hỏi riêng từng câu)',
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
              hintText: 'Nhập ví dụ từ phụ huynh về những thứ trẻ thích trèo lên...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(String title, List<Map<String, String>> questions, Color color, IconData icon) {
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
          ...questions.map((questionData) => _buildQuestionCard(
            questionData['id']!,
            questionData['question']!,
            color,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String questionId, String question, Color pathColor) {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildSummarySection(Color pathColor) {
    final answeredQuestions = selectedAnswers.values.where((answer) => answer != null).length;
    final totalQuestions = climbingQuestions.length;
    final isComplete = answeredQuestions == totalQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
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
    // Đếm số câu trả lời "Có" (có thích trèo leo)
    int yesCount = 0;
    for (var question in climbingQuestions) {
      if (selectedAnswers[question['id']] == true) {
        yesCount++;
      }
    }
    
    // Assessment Logic:
    // ✅ ĐẠT: Có ít nhất một câu trả lời "Có"
    // ❌ KHÔNG ĐẠT: Tất cả các câu trả lời là "Không"
    bool hasAnyYes = yesCount > 0;
    
    if (hasAnyYes) {
      // Có ít nhất 1 câu trả lời "Có" → ĐẠT
      _setFinalResult(true, 'ĐẠT - Con bạn có hành vi trèo leo');
    } else {
      // Không có câu trả lời "Có" nào → KHÔNG ĐẠT
      _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không có hành vi trèo leo');
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
    int yesCount = 0;
    for (var question in climbingQuestions) {
      if (selectedAnswers[question['id']] == true) {
        yesCount++;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: finalResult! ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: finalResult! ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
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
                      finalResult! ? 'ĐẠT - Con bạn có hành vi trèo leo tốt' : 'KHÔNG ĐẠT - Con bạn cần hỗ trợ phát triển hành vi trèo leo',
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
                        'Có trèo leo',
                        '$yesCount/${climbingQuestions.length}',
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Không trèo leo',
                        '${climbingQuestions.length - yesCount}/${climbingQuestions.length}',
                        Colors.red,
                        Icons.cancel,
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
                      border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
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
  
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
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
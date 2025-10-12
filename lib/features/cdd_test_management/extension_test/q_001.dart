import 'package:flutter/material.dart';

class ExtensionTestQ001 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final Function(bool)? onUpdateMainResult; // Callback để cập nhật kết quả chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ001({
    Key? key,
    this.mainQuestionAnswer,
    this.onUpdateMainResult,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ001> createState() => _ExtensionTestQ001State();
}

class _ExtensionTestQ001State extends State<ExtensionTestQ001> {
  Map<String, bool?> selectedAnswers = {}; // questionId -> true/false/null
  bool? finalResult; // Kết quả cuối cùng của flow assessment
  bool showFrequencyQuestion = false; // Hiển thị câu hỏi về tần suất

  // Questions for TRUE path (ĐẠT examples)
  final List<Map<String, String>> truePathQuestions = [
    {
      'id': 'true_1',
      'question': 'Trẻ có nhìn vào đồ vật không?',
    },
    {
      'id': 'true_2', 
      'question': 'Trẻ có chỉ vào đồ vật không?',
    },
    {
      'id': 'true_3',
      'question': 'Trẻ có nhìn và nhận xét về đồ vật không?',
    },
    {
      'id': 'true_4',
      'question': 'Trẻ có nhìn nếu cha/mẹ chỉ và nói "nhìn kìa!" không?',
    },
  ];

  // Questions for FALSE path (KHÔNG ĐẠT examples)
  final List<Map<String, String>> falsePathQuestions = [
    {
      'id': 'false_1',
      'question': 'Trẻ không phản ứng gì / lờ cha/mẹ đi',
    },
    {
      'id': 'false_2',
      'question': 'Trẻ nhìn xung quanh hoặc chỗ khác',
    },
    {
      'id': 'false_3',
      'question': 'Trẻ nhìn vào ngón tay của cha/mẹ',
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
                'Đánh giá chi tiết - Tất cả các ví dụ',
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
                  'Hãy đánh giá tất cả các hành vi của con bạn. Trả lời Có/Không cho từng câu hỏi dưới đây:',
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
        
        // TRUE Path Questions (ĐẠT examples)
        _buildQuestionSection(
          'Các ví dụ ĐẠT (Hành vi tích cực)',
          truePathQuestions,
          Colors.green,
          Icons.check_circle,
        ),
        
        const SizedBox(height: 20),
        
        // FALSE Path Questions (KHÔNG ĐẠT examples)
        _buildQuestionSection(
          'Các ví dụ KHÔNG ĐẠT (Hành vi cần hỗ trợ)',
          falsePathQuestions,
          Colors.red,
          Icons.cancel,
        ),
        
        const SizedBox(height: 20),
        
        // Summary và button
        _buildSummarySection(pathColor),
        
        // Frequency question (nếu cần)
        if (showFrequencyQuestion) ...[
          const SizedBox(height: 20),
          _buildFrequencyQuestion(),
        ],
        
        // Final result (nếu có)
        if (finalResult != null) ...[
          const SizedBox(height: 20),
          _buildFinalResult(),
        ],
      ],
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
    final totalQuestions = truePathQuestions.length + falsePathQuestions.length;
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
                
                // Quay lại test chính
                if (widget.onReturnToMainTest != null) {
                  widget.onReturnToMainTest!();
                }
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
    // Đếm số câu trả lời "Có" cho TRUE path (ĐẠT examples)
    int trueYesCount = 0;
    for (var question in truePathQuestions) {
      if (selectedAnswers[question['id']] == true) {
        trueYesCount++;
      }
    }
    
    // Đếm số câu trả lời "Có" cho FALSE path (KHÔNG ĐẠT examples)
    int falseYesCount = 0;
    for (var question in falsePathQuestions) {
      if (selectedAnswers[question['id']] == true) {
        falseYesCount++;
      }
    }
    
    // Flow Assessment Logic
    bool hasTrueExamples = trueYesCount > 0;
    bool hasFalseExamples = falseYesCount > 0;
    
    if (hasTrueExamples && !hasFalseExamples) {
      // Chỉ có ví dụ ĐẠT -> Kết quả cuối cùng: ĐẠT
      _setFinalResult(true, 'ĐẠT - Trẻ chỉ có hành vi tích cực');
    } else if (!hasTrueExamples && hasFalseExamples) {
      // Chỉ có ví dụ KHÔNG ĐẠT -> Kết quả cuối cùng: KHÔNG ĐẠT
      _setFinalResult(false, 'KHÔNG ĐẠT - Trẻ chỉ có hành vi cần hỗ trợ');
    } else if (hasTrueExamples && hasFalseExamples) {
      // Có cả hai -> Cần hỏi về tần suất
      setState(() {
        showFrequencyQuestion = true;
      });
    } else {
      // Không có ví dụ nào -> Cần đánh giá thêm
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần đánh giá thêm - Không có ví dụ cụ thể nào'),
          backgroundColor: Colors.orange,
        ),
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
  
  Widget _buildFrequencyQuestion() {
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
              Icon(Icons.help, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi bổ sung',
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
            'Hành động nào con bạn thực hiện thường xuyên hơn?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleFrequencyAnswer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hành vi tích cực'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleFrequencyAnswer(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hành vi cần hỗ trợ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFinalResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: finalResult! ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: finalResult! ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                finalResult! ? Icons.check_circle : Icons.cancel,
                color: finalResult! ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Kết quả cuối cùng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: finalResult! ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            finalResult! ? 'ĐẠT - Trẻ có hành vi phù hợp' : 'KHÔNG ĐẠT - Trẻ cần hỗ trợ thêm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: finalResult! ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onReturnToMainTest != null) {
                  widget.onReturnToMainTest!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: finalResult! ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hoàn thành đánh giá'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleFrequencyAnswer(bool isPositive) {
    String message = isPositive 
        ? 'ĐẠT - Trẻ thường xuyên có hành vi tích cực hơn'
        : 'KHÔNG ĐẠT - Trẻ thường xuyên có hành vi cần hỗ trợ hơn';
    
    _setFinalResult(isPositive, message);
  }
}
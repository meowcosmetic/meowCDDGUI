import 'package:flutter/material.dart';

class ExtensionTestQ001 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ001({
    Key? key,
    this.mainQuestionAnswer,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ001> createState() => _ExtensionTestQ001State();
}

class _ExtensionTestQ001State extends State<ExtensionTestQ001> {
  Map<String, bool?> selectedAnswers = {}; // questionId -> true/false/null

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
    final questions = isTruePath ? truePathQuestions : falsePathQuestions;
    final pathTitle = isTruePath ? 'Các ví dụ ĐẠT' : 'Các ví dụ KHÔNG ĐẠT';
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
                pathTitle,
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
                  'Hãy cho tôi một ví dụ về cách phản hồi của con bạn khi bạn chỉ vào một điểm nào đó. (Nếu cha/mẹ không đưa ra được một ví dụ ${isTruePath ? 'ĐẠT' : 'KHÔNG ĐẠT'} như dưới đây, hỏi từng câu)',
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
        
        // Questions list
        ...questions.map((questionData) => _buildQuestionCard(
          questionData['id']!,
          questionData['question']!,
          pathColor,
        )).toList(),
        
        const SizedBox(height: 20),
        
        // Summary và button
        _buildSummarySection(pathColor),
      ],
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
    final totalQuestions = widget.mainQuestionAnswer == true ? truePathQuestions.length : falsePathQuestions.length;
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
    final isTruePath = widget.mainQuestionAnswer == true;
    final questions = isTruePath ? truePathQuestions : falsePathQuestions;
    
    // Đếm số câu trả lời "Có"
    int yesCount = 0;
    for (var question in questions) {
      if (selectedAnswers[question['id']] == true) {
        yesCount++;
      }
    }
    
    // Hiển thị kết quả
    String result = '';
    if (isTruePath) {
      if (yesCount > 0) {
        result = 'ĐẠT - Trẻ có các hành vi tích cực';
      } else {
        result = 'Cần đánh giá thêm';
      }
    } else {
      if (yesCount > 0) {
        result = 'KHÔNG ĐẠT - Trẻ có các hành vi cần hỗ trợ';
      } else {
        result = 'Cần đánh giá thêm';
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kết quả: $result'),
        backgroundColor: isTruePath ? Colors.green : Colors.red,
      ),
    );
  }
}
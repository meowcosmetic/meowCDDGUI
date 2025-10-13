import 'package:flutter/material.dart';

class ExtensionTestQ006 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final Function(bool)? onUpdateMainResult; // Callback để cập nhật kết quả chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ006({
    Key? key,
    this.mainQuestionAnswer,
    this.onUpdateMainResult,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ006> createState() => _ExtensionTestQ006State();
}

class _ExtensionTestQ006State extends State<ExtensionTestQ006> {
  Map<String, bool?> selectedAnswers = {}; // questionId -> true/false/null
  bool? finalResult; // Kết quả cuối cùng của flow assessment
  String parentExample = ''; // Ví dụ từ phụ huynh

  // Follow-up questions for "Không" case
  final List<Map<String, String>> followUpQuestions = [
    {
      'id': 'followup_1',
      'question': 'Với đồ vật đó bằng cả tay không?',
    },
    {
      'id': 'followup_2', 
      'question': 'Dẫn bạn đến đồ vật đó không?',
    },
    {
      'id': 'followup_3',
      'question': 'Cố gắng tự lấy đồ vật đó không?',
    },
    {
      'id': 'followup_4',
      'question': 'Yêu cầu lấy đồ vật bằng từ ngữ hoặc tạo ra âm thanh không?',
    },
  ];

  // Additional question
  final String additionalQuestion = 'Nếu bạn nói "Chỉ cho cha/mẹ xem nào", con bạn có chỉ vào không?';

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
                'Đánh giá chi tiết - Hành vi chỉ tay yêu cầu',
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
        
        // Case 1: Parent answered "Có" - Immediate ĐẠT
        if (isTruePath) _buildCase1Result(),
        
        // Case 2: Parent answered "Không" - Follow-up questions
        if (!isTruePath) _buildCase2Assessment(),
        
        // Final result (nếu có)
        if (finalResult != null) ...[
          const SizedBox(height: 20),
          _buildFinalResult(),
        ],
      ],
    );
  }

  Widget _buildCase1Result() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trường hợp 1 - Kết quả ngay lập tức',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ĐẠT - Con bạn có dùng ngón tay trỏ để yêu cầu việc gì đó',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _setFinalResult(true, 'ĐẠT - Con bạn có dùng ngón tay trỏ để yêu cầu việc gì đó');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Tiếp tục bài test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
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
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trường hợp 2: Phụ huynh trả lời "Không" - Cần đánh giá thêm',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
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
        
        // Follow-up Questions
        _buildQuestionSection(
          'Các ví dụ gợi ý (trả lời Có/Không)',
          followUpQuestions,
          Colors.blue,
          Icons.help_outline,
        ),
        
        const SizedBox(height: 20),
        
        // Additional Question
        _buildAdditionalQuestion(),
        
        const SizedBox(height: 20),
        
        // Summary và button
        if (finalResult == null)
          _buildSummarySection(Colors.orange),
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
            'Nếu có thứ gì con bạn muốn nhưng ngoài tầm với (ví dụ như bím bim, đồ chơi, đồ ngoại tầm với), làm thế nào để con bạn lấy được chúng?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(Nếu cha/mẹ không đưa ra được ví dụ thì hỏi lần lượt từng câu dưới đây)',
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
              hintText: 'Nhập ví dụ từ phụ huynh về cách trẻ lấy đồ vật ngoài tầm với...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 3,
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

  Widget _buildAdditionalQuestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi bổ sung',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            additionalQuestion,
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
                  groupValue: selectedAnswers['additional'],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedAnswers['additional'] = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Không'),
                  value: false,
                  groupValue: selectedAnswers['additional'],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedAnswers['additional'] = value;
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
    final totalQuestions = followUpQuestions.length + 1; // +1 for additional question
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
    // Đếm số câu trả lời "Có" trong follow-up questions
    int followUpYesCount = 0;
    for (var question in followUpQuestions) {
      if (selectedAnswers[question['id']] == true) {
        followUpYesCount++;
      }
    }
    
    // Kiểm tra câu hỏi bổ sung
    bool additionalYes = selectedAnswers['additional'] == true;
    
    // Assessment Logic:
    // ✅ ĐẠT nếu có "Có" ở bất kỳ câu hỏi phụ nào
    // ✅ ĐẠT nếu trẻ chỉ khi được yêu cầu (additional question = true)
    // ❌ KHÔNG ĐẠT nếu không có "Có" nào trong các câu phụ và trẻ không chỉ khi được yêu cầu
    
    if (followUpYesCount > 0 || additionalYes) {
      // Có ít nhất 1 câu trả lời "Có" trong follow-up hoặc trẻ chỉ khi được yêu cầu
      _setFinalResult(true, 'ĐẠT - Con bạn có khả năng chỉ tay hoặc yêu cầu giúp đỡ');
    } else {
      // Không có câu trả lời "Có" nào và trẻ không chỉ khi được yêu cầu
      _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không có khả năng chỉ tay hoặc yêu cầu giúp đỡ');
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
    int followUpYesCount = 0;
    for (var question in followUpQuestions) {
      if (selectedAnswers[question['id']] == true) {
        followUpYesCount++;
      }
    }
    bool additionalYes = selectedAnswers['additional'] == true;
    
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
                      finalResult! ? 'ĐẠT - Con bạn có khả năng chỉ tay và yêu cầu giúp đỡ' : 'KHÔNG ĐẠT - Con bạn cần hỗ trợ phát triển khả năng chỉ tay',
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
                        'Có khả năng yêu cầu',
                        '$followUpYesCount/${followUpQuestions.length}',
                        Colors.blue,
                        Icons.help_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Chỉ khi được yêu cầu',
                        additionalYes ? 'Có' : 'Không',
                        Colors.purple,
                        Icons.quiz,
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
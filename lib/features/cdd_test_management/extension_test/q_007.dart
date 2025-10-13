import 'package:flutter/material.dart';

class ExtensionTestQ007 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final Function(bool)? onUpdateMainResult; // Callback để cập nhật kết quả chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ007({
    Key? key,
    this.mainQuestionAnswer,
    this.onUpdateMainResult,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ007> createState() => _ExtensionTestQ007State();
}

class _ExtensionTestQ007State extends State<ExtensionTestQ007> {
  Map<String, bool?> selectedAnswers = {}; // questionId -> true/false/null
  bool? finalResult; // Kết quả cuối cùng của flow assessment
  String parentExample = ''; // Ví dụ từ phụ huynh
  String currentCase = ''; // Trường hợp hiện tại: 'case1', 'case2'
  bool showInterestQuestion = false; // Hiển thị câu hỏi về thích thú

  // Questions for Case 2 - Interesting things
  final List<Map<String, String>> interestingThingsQuestions = [
    {
      'id': 'interesting_1',
      'question': 'Một cái máy bay trên trời?',
    },
    {
      'id': 'interesting_2', 
      'question': 'Một chiếc xe tải trên đường?',
    },
    {
      'id': 'interesting_3',
      'question': 'Một con bò trên mặt đất?',
    },
    {
      'id': 'interesting_4',
      'question': 'Một con vật trong sân?',
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
                'Đánh giá chi tiết - Chỉ tay để thể hiện sự thích thú',
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
        
        // Interest question (if needed)
        if (showInterestQuestion) ...[
          const SizedBox(height: 20),
          _buildInterestQuestion(),
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
                    backgroundColor: Colors.orange,
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
                  'Trường hợp 1: Phụ huynh trả lời "Có" - Cần ví dụ và đánh giá chi tiết',
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
        
        // Follow-up questions
        _buildFollowUpQuestions(),
        
        const SizedBox(height: 20),
        
        // Summary và button
        if (finalResult == null && !showInterestQuestion)
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
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trường hợp 2: Phụ huynh trả lời "Không" - Đánh giá các thứ thú vị',
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
        
        // Interesting things questions
        _buildQuestionSection(
          'Có bao giờ trẻ muốn bạn nhìn thấy những thứ thú vị như:',
          interestingThingsQuestions,
          Colors.blue,
          Icons.visibility,
        ),
        
        const SizedBox(height: 20),
        
        // Summary và button
        if (finalResult == null && !showInterestQuestion)
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
            'Cho tôi 1 ví dụ về thứ mà con bạn thường chỉ cho bạn xem.',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(Nếu cha/mẹ không đưa ra được ví dụ, hỏi tiếp các câu gợi ý bên dưới.)',
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
              hintText: 'Nhập ví dụ từ phụ huynh về thứ trẻ thường chỉ...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpQuestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi phụ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Question 1: How does child get attention
          _buildQuestionCard(
            'attention',
            'Làm thế nào để con thu hút sự chú ý của bạn đến thứ đó?',
            Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // Question 2: Does child use finger to point
          _buildQuestionCard(
            'finger_point',
            'Con bạn có dùng 1 ngón tay để chỉ không?',
            Colors.blue,
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

  Widget _buildInterestQuestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi về sự thích thú',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Con bạn làm vậy để thể hiện sự thích thú, chứ không phải để được giúp đỡ phải không?',
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
                  onPressed: () => _handleInterestAnswer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Có (chỉ để thể hiện thích thú)'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleInterestAnswer(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Không (chỉ để được giúp đỡ)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleInterestAnswer(true), // Both reasons
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Vừa để thể hiện thích thú vừa để được giúp đỡ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(Color pathColor) {
    final answeredQuestions = selectedAnswers.values.where((answer) => answer != null).length;
    int totalQuestions = 0;
    
    if (currentCase == 'case1') {
      totalQuestions = 2; // attention + finger_point
    } else if (currentCase == 'case2') {
      totalQuestions = interestingThingsQuestions.length;
    }
    
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
    if (currentCase == 'case1') {
      // Case 1: Check if child uses finger to point
      bool usesFinger = selectedAnswers['finger_point'] == true;
      
      if (usesFinger) {
        // Show interest question
        setState(() {
          showInterestQuestion = true;
        });
      } else {
        // No finger pointing -> KHÔNG ĐẠT
        _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không dùng ngón tay để chỉ');
      }
    } else if (currentCase == 'case2') {
      // Case 2: Check if any interesting things
      int yesCount = 0;
      for (var question in interestingThingsQuestions) {
        if (selectedAnswers[question['id']] == true) {
          yesCount++;
        }
      }
      
      if (yesCount > 0) {
        // Has interesting things -> Check if uses finger
        bool usesFinger = selectedAnswers['finger_point'] == true;
        
        if (usesFinger) {
          // Show interest question
          setState(() {
            showInterestQuestion = true;
          });
        } else {
          // No finger pointing -> KHÔNG ĐẠT
          _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không dùng ngón tay để chỉ');
        }
      } else {
        // No interesting things -> KHÔNG ĐẠT
        _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không có hành vi chỉ tay thú vị');
      }
    }
  }

  void _handleInterestAnswer(bool isForInterest) {
    if (isForInterest) {
      // For interest (or both) -> ĐẠT
      _setFinalResult(true, 'ĐẠT - Con bạn chỉ tay để thể hiện sự thích thú');
    } else {
      // Only for help -> KHÔNG ĐẠT
      _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn chỉ tay chỉ để được giúp đỡ');
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
    int interestingYesCount = 0;
    if (currentCase == 'case2') {
      for (var question in interestingThingsQuestions) {
        if (selectedAnswers[question['id']] == true) {
          interestingYesCount++;
        }
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
                      finalResult! ? 'ĐẠT - Con bạn chỉ tay để thể hiện sự thích thú' : 'KHÔNG ĐẠT - Con bạn cần hỗ trợ phát triển khả năng chỉ tay thú vị',
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
                        currentCase == 'case1' ? 'Trường hợp 1' : 'Trường hợp 2',
                        Colors.blue,
                        Icons.account_tree,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Dùng ngón tay chỉ',
                        selectedAnswers['finger_point'] == true ? 'Có' : 'Không',
                        Colors.purple,
                        Icons.back_hand,
                      ),
                    ),
                  ],
                ),
                if (currentCase == 'case2') ...[
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'Thứ thú vị',
                    '$interestingYesCount/${interestingThingsQuestions.length}',
                    Colors.orange,
                    Icons.visibility,
                  ),
                ],
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
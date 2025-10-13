import 'package:flutter/material.dart';

class ExtensionTestQ008 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final Function(bool)? onUpdateMainResult; // Callback để cập nhật kết quả chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ008({
    Key? key,
    this.mainQuestionAnswer,
    this.onUpdateMainResult,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ008> createState() => _ExtensionTestQ008State();
}

class _ExtensionTestQ008State extends State<ExtensionTestQ008> {
  Map<String, bool?> selectedAnswers = {}; // questionId -> true/false/null
  bool? finalResult; // Kết quả cuối cùng của flow assessment
  String parentDescription = ''; // Mô tả từ phụ huynh
  String currentCase = ''; // Trường hợp hiện tại: 'case1', 'case2'

  // Questions for Case 1 - Follow-up behaviors
  final List<Map<String, String>> behaviorQuestions = [
    {
      'id': 'behavior_1',
      'question': 'Chơi với 1 trẻ khác không?',
    },
    {
      'id': 'behavior_2', 
      'question': 'Nói chuyện với trẻ khác không?',
    },
    {
      'id': 'behavior_3',
      'question': 'Bập bẹ hoặc phát ra âm thanh với trẻ khác không?',
    },
    {
      'id': 'behavior_4',
      'question': 'Quan sát hoặc nhìn trẻ khác không?',
    },
    {
      'id': 'behavior_5',
      'question': 'Cười với trẻ khác không?',
    },
    {
      'id': 'behavior_6',
      'question': 'Ban đầu ngại ngùng nhưng sau đó cười?',
    },
    {
      'id': 'behavior_7',
      'question': 'Hào hứng với một trẻ khác không?',
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
                'Đánh giá chi tiết - Hứng thú với trẻ khác',
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
                  'Trường hợp 1: Phụ huynh trả lời "Có" - Đánh giá chi tiết',
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
        
        // First question: Interest in non-siblings
        _buildQuestionCard(
          'non_siblings',
          'Con bạn có hứng thú với những đứa trẻ khác mà không phải anh/chị/em trong nhà không?',
          Colors.blue,
        ),
        
        const SizedBox(height: 20),
        
        // Parent description field (if needed)
        if (selectedAnswers['non_siblings'] == false) _buildParentDescriptionField(),
        
        const SizedBox(height: 20),
        
        // Behavior questions (if needed)
        if (selectedAnswers['non_siblings'] == false) _buildBehaviorQuestions(),
        
        const SizedBox(height: 20),
        
        // Summary và button
        if (finalResult == null)
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
                  'Trường hợp 2: Phụ huynh trả lời "Không" - Đánh giá tương tác',
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
        
        // First question: Interaction in public places
        _buildQuestionCard(
          'public_interaction',
          'Khi bạn và con ở sân chơi hoặc siêu thị, con bạn có biểu hiện tương tác với những đứa trẻ khác không?',
          Colors.orange,
        ),
        
        const SizedBox(height: 20),
        
        // Follow-up question (if needed)
        if (selectedAnswers['public_interaction'] == true) ...[
          _buildQuestionCard(
            'reaction_frequency',
            'Con của bạn có phản ứng với những trẻ em khác hơn một nửa thời gian chúng chơi với nhau không?',
            Colors.orange,
          ),
          const SizedBox(height: 20),
        ],
        
        // Summary và button
        if (finalResult == null)
          _buildSummarySection(Colors.orange),
      ],
    );
  }

  Widget _buildParentDescriptionField() {
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
                'Mô tả từ phụ huynh',
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
            'Con bạn biểu hiện tương tác như thế nào?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(Nếu cha/mẹ không mô tả được, hỏi thêm các ví dụ dưới đây.)',
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
                parentDescription = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Nhập mô tả từ phụ huynh về cách trẻ tương tác...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorQuestions() {
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
                'Các câu hỏi phụ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...behaviorQuestions.map((questionData) => _buildQuestionCard(
            questionData['id']!,
            questionData['question']!,
            Colors.blue,
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
    int totalQuestions = 0;
    if (currentCase == 'case1') {
      if (selectedAnswers['non_siblings'] == false) {
        totalQuestions = 1 + behaviorQuestions.length; // non_siblings + behavior questions
      } else {
        totalQuestions = 1; // just non_siblings
      }
    } else if (currentCase == 'case2') {
      if (selectedAnswers['public_interaction'] == true) {
        totalQuestions = 2; // public_interaction + reaction_frequency
      } else {
        totalQuestions = 1; // just public_interaction
      }
    }
    
    final answeredQuestions = selectedAnswers.values.where((answer) => answer != null).length;
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
      // Case 1: Check non-siblings interest first
      bool nonSiblingsInterest = selectedAnswers['non_siblings'] == true;
      
      if (nonSiblingsInterest) {
        // Interested in non-siblings -> ĐẠT
        _setFinalResult(true, 'ĐẠT - Con bạn hứng thú với trẻ khác không phải anh/chị/em');
      } else {
        // Not interested in non-siblings -> Check behavior questions
        int behaviorYesCount = 0;
        for (var question in behaviorQuestions) {
          if (selectedAnswers[question['id']] == true) {
            behaviorYesCount++;
          }
        }
        
        if (behaviorYesCount > 0) {
          // Has some behaviors -> ĐẠT
          _setFinalResult(true, 'ĐẠT - Con bạn có ít nhất một hành vi tương tác');
        } else {
          // No behaviors -> KHÔNG ĐẠT
          _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không có hành vi tương tác nào');
        }
      }
    } else if (currentCase == 'case2') {
      // Case 2: Check public interaction
      bool publicInteraction = selectedAnswers['public_interaction'] == true;
      
      if (!publicInteraction) {
        // No public interaction -> KHÔNG ĐẠT
        _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không tương tác với trẻ khác ở nơi công cộng');
      } else {
        // Has public interaction -> Check reaction frequency
        bool reactionFrequency = selectedAnswers['reaction_frequency'] == true;
        
        if (reactionFrequency) {
          // Reacts more than half the time -> ĐẠT
          _setFinalResult(true, 'ĐẠT - Con bạn phản ứng với trẻ khác hơn một nửa thời gian');
        } else {
          // Doesn't react enough -> KHÔNG ĐẠT
          _setFinalResult(false, 'KHÔNG ĐẠT - Con bạn không phản ứng đủ với trẻ khác');
        }
      }
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
    int behaviorYesCount = 0;
    if (currentCase == 'case1' && selectedAnswers['non_siblings'] == false) {
      for (var question in behaviorQuestions) {
        if (selectedAnswers[question['id']] == true) {
          behaviorYesCount++;
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
                      finalResult! ? 'ĐẠT - Con bạn có hứng thú xã hội tốt' : 'KHÔNG ĐẠT - Con bạn cần hỗ trợ phát triển kỹ năng xã hội',
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
                        'Hành vi tương tác',
                        currentCase == 'case1' ? '$behaviorYesCount/${behaviorQuestions.length}' : 'N/A',
                        Colors.purple,
                        Icons.people,
                      ),
                    ),
                  ],
                ),
                if (currentCase == 'case1') ...[
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'Hứng thú với trẻ khác',
                    selectedAnswers['non_siblings'] == true ? 'Có' : 'Không',
                    Colors.green,
                    Icons.child_care,
                  ),
                ],
                if (currentCase == 'case2') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Tương tác nơi công cộng',
                          selectedAnswers['public_interaction'] == true ? 'Có' : 'Không',
                          Colors.orange,
                          Icons.public,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Phản ứng >50% thời gian',
                          selectedAnswers['reaction_frequency'] == true ? 'Có' : 'Không',
                          Colors.red,
                          Icons.timer,
                        ),
                      ),
                    ],
                  ),
                ],
                if (parentDescription.isNotEmpty) ...[
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
                          'Mô tả từ phụ huynh:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parentDescription,
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
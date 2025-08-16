import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/child.dart';
import '../models/child_tracking.dart';

class ChildTrackingView extends StatefulWidget {
  final Child child;

  const ChildTrackingView({super.key, required this.child});

  @override
  State<ChildTrackingView> createState() => _ChildTrackingViewState();
}

class _ChildTrackingViewState extends State<ChildTrackingView> {
  final Map<String, int> _answers = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize answers with default values
    for (var category in TrackingData.categories) {
      for (var question in category.questions) {
        _answers[question.id] = 0;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          'Tracking: ${widget.child.name}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              children: [
                Text(
                  'Bảng câu hỏi chấm điểm hằng ngày',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ngày: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Questions
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hãy đánh giá tình trạng của trẻ hôm nay theo từng câu hỏi. Chọn mức độ phù hợp nhất.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Categories
                  ...TrackingData.categories.map((category) => _buildCategorySection(category)),
                  
                  const SizedBox(height: 20),
                  
                  // Notes section
                  _buildNotesSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Summary
                  _buildSummarySection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Submit button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang lưu...'),
                        ],
                      )
                    : const Text(
                        'Lưu kết quả tracking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(TrackingCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category.name),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tối đa: ${category.maxScore} điểm',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Questions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: category.questions.map((question) => _buildQuestion(question)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(TrackingQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...question.options.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            int score = question.scores[index];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<int>(
                value: score,
                groupValue: _answers[question.id],
                onChanged: (value) {
                  setState(() {
                    _answers[question.id] = value!;
                  });
                },
                title: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${score} điểm',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.note,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ghi chú bổ sung',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú về tình trạng trẻ hôm nay...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    Map<String, double> categoryScores = {};
    
    for (var category in TrackingData.categories) {
      List<int> scores = [];
      for (var question in category.questions) {
        scores.add(_answers[question.id] ?? 0);
      }
      categoryScores[category.name] = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0;
    }
    
    double totalScore = categoryScores.values.isNotEmpty 
        ? categoryScores.values.reduce((a, b) => a + b) / categoryScores.length 
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tổng kết điểm số',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category scores
          ...categoryScores.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${entry.value.toStringAsFixed(1)}/2.0',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const Divider(height: 24),
          
          // Total score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Điểm trung bình tổng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(totalScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getScoreColor(totalScore)),
                ),
                child: Text(
                  '${totalScore.toStringAsFixed(1)}/2.0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(totalScore),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Giao tiếp':
        return Icons.chat;
      case 'Tương tác xã hội':
        return Icons.people;
      case 'Hành vi & cảm xúc':
        return Icons.psychology;
      case 'Kỹ năng nhận thức':
        return Icons.psychology_outlined;
      case 'Tự lập':
        return Icons.person_outline;
      default:
        return Icons.assessment;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 1.5) return AppColors.success;
    if (score >= 1.0) return AppColors.warning;
    return AppColors.error;
  }

  void _submitTracking() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create tracking data
      final tracking = ChildTracking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childId: widget.child.id,
        date: DateTime.now(),
        scores: Map<String, int>.from(_answers),
        notes: _notesController.text.trim(),
      );

      // TODO: Save to database/API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã lưu kết quả tracking thành công!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        Navigator.pop(context, tracking);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

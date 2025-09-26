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

  // New tracking fields
  EmotionLevel? _selectedEmotion;
  ParticipationLevel? _selectedParticipation;
  final List<InterventionGoal> _selectedGoals = [];
  final Map<String, Map<String, String>> _goalAnswers = {};

  @override
  void initState() {
    super.initState();
    // Initialize answers with default values for legacy tracking
    for (var category in TrackingData.categories) {
      for (var question in category.questions) {
        _answers[question.id] = 0;
      }
    }

    // Initialize goal answers
    for (var goal in TrackingData.interventionGoals) {
      _goalAnswers[goal.id] = {};
      for (var question in goal.questions) {
        _goalAnswers[goal.id]![question.id] = '';
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              children: [
                Text(
                  'Bảng câu hỏi tracking hằng ngày',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ngày: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(fontSize: 14, color: AppColors.white),
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
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hãy đánh giá tình trạng của trẻ hôm nay và chọn 3 mục tiêu can thiệp quan trọng nhất.',
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

                  // Emotion Section
                  _buildEmotionSection(),

                  const SizedBox(height: 20),

                  // Participation Section
                  _buildParticipationSection(),

                  const SizedBox(height: 20),

                  // Intervention Goals Section
                  _buildInterventionGoalsSection(),

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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
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

  Widget _buildEmotionSection() {
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
                Icons.emoji_emotions,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Cảm xúc của con hôm nay thế nào?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...EmotionLevel.values
              .map(
                (emotion) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<EmotionLevel>(
                    value: emotion,
                    groupValue: _selectedEmotion,
                    onChanged: (value) {
                      setState(() {
                        _selectedEmotion = value;
                      });
                    },
                    title: Text(
                      emotion.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildParticipationSection() {
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
              const Icon(Icons.star, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Mức độ tham gia của con',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...ParticipationLevel.values
              .map(
                (participation) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<ParticipationLevel>(
                    value: participation,
                    groupValue: _selectedParticipation,
                    onChanged: (value) {
                      setState(() {
                        _selectedParticipation = value;
                      });
                    },
                    title: Text(
                      participation.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInterventionGoalsSection() {
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
              const Icon(Icons.flag, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Chương trình can thiệp (Chọn 3 mục tiêu)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Đã chọn: ${_selectedGoals.length}/3',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...TrackingData.interventionGoals
              .map((goal) => _buildGoalCard(goal))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildGoalCard(InterventionGoal goal) {
    final isSelected = _selectedGoals.contains(goal);
    final isExpanded = isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryLight.withOpacity(0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Goal header
          InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedGoals.remove(goal);
                } else if (_selectedGoals.length < 3) {
                  _selectedGoals.add(goal);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn chỉ có thể chọn tối đa 3 mục tiêu'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          goal.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Goal questions (only show if selected)
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: goal.questions
                    .map((question) => _buildGoalQuestion(goal, question))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalQuestion(
    InterventionGoal goal,
    InterventionQuestion question,
  ) {
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
            String option = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: RadioListTile<String>(
                value: option,
                groupValue: _goalAnswers[goal.id]![question.id],
                onChanged: (value) {
                  setState(() {
                    _goalAnswers[goal.id]![question.id] = value!;
                  });
                },
                title: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
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
              const Icon(Icons.note, color: AppColors.primary, size: 20),
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
              const Icon(Icons.analytics, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tổng kết tracking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Emotion summary
          if (_selectedEmotion != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cảm xúc:',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
                Text(
                  _selectedEmotion!.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Participation summary
          if (_selectedParticipation != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mức độ tham gia:',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
                Text(
                  _selectedParticipation!.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Selected goals summary
          if (_selectedGoals.isNotEmpty) ...[
            const Text(
              'Mục tiêu đã chọn:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._selectedGoals
                .map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${goal.title}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  void _submitTracking() async {
    // Validate required fields
    if (_selectedEmotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn cảm xúc của trẻ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedParticipation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn mức độ tham gia của trẻ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 mục tiêu can thiệp'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
        emotionLevel: _selectedEmotion!,
        participationLevel: _selectedParticipation!,
        selectedGoals: _selectedGoals,
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

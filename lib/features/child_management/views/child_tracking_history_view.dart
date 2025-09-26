import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/child.dart';
import '../models/child_tracking.dart';
import '../models/child_tracking.dart' as tracking_data;

class ChildTrackingHistoryView extends StatelessWidget {
  final Child child;
  final List<ChildTracking> trackingHistory;

  const ChildTrackingHistoryView({
    super.key,
    required this.child,
    required this.trackingHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          'Lịch sử Tracking: ${child.name}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: trackingHistory.isEmpty
          ? _buildEmptyState()
          : _buildTrackingHistory(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu tracking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy bắt đầu tracking để theo dõi tiến độ của trẻ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingHistory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview section
          _buildOverviewSection(),
          
          const SizedBox(height: 20),
          
          // History list
          Text(
            'Lịch sử tracking',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          ...trackingHistory.map((tracking) => _buildTrackingCard(tracking)).toList(),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    if (trackingHistory.isEmpty) return const SizedBox.shrink();

    // Calculate averages for legacy tracking
    Map<String, List<int>> categoryScores = {};
    for (var category in tracking_data.TrackingData.categories) {
      categoryScores[category.name] = [];
      for (var tracking in trackingHistory) {
        for (var question in category.questions) {
          categoryScores[category.name]!.add(tracking.scores[question.id] ?? 0);
        }
      }
    }

    double overallAverage = trackingHistory.map((t) => t.totalScore).reduce((a, b) => a + b) / trackingHistory.length;
    
    double recentAverage = 0;
    double previousAverage = 0;
    
    if (trackingHistory.length >= 2) {
      recentAverage = trackingHistory.take(3).map((t) => t.totalScore).reduce((a, b) => a + b) /
          (trackingHistory.length >= 3 ? 3 : trackingHistory.length);
      previousAverage = trackingHistory.skip(3).map((t) => t.totalScore).reduce((a, b) => a + b) /
          (trackingHistory.length - 3);
    }

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
                'Tổng quan tracking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Số lần tracking',
                  '${trackingHistory.length}',
                  Icons.history,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Điểm trung bình',
                  '${overallAverage.toStringAsFixed(1)}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          
          if (trackingHistory.length >= 2) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Gần đây',
                    '${recentAverage.toStringAsFixed(1)}',
                    Icons.trending_up,
                    color: recentAverage > previousAverage ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Trước đó',
                    '${previousAverage.toStringAsFixed(1)}',
                    Icons.trending_down,
                    color: previousAverage > recentAverage ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tracking gần nhất',
                  '${trackingHistory.first.date.day}/${trackingHistory.first.date.month}',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Tracking đầu tiên',
                  '${trackingHistory.last.date.day}/${trackingHistory.last.date.month}',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color ?? AppColors.primary),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color ?? AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.primary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(ChildTracking tracking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          // Header
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(tracking.totalScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getScoreColor(tracking.totalScore)),
                  ),
                  child: Text(
                    '${tracking.totalScore.toStringAsFixed(1)}/2.0',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(tracking.totalScore),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${tracking.date.day}/${tracking.date.month}/${tracking.date.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emotion and Participation
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Cảm xúc',
                        tracking.emotionLevel.label,
                        Icons.emoji_emotions,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        'Tham gia',
                        tracking.participationLevel.label,
                        Icons.star,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Selected Goals
                if (tracking.selectedGoals.isNotEmpty) ...[
                  const Text(
                    'Chương trình can thiệp:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tracking.selectedGoals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flag,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
                
                // Notes
                if (tracking.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Ghi chú:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tracking.notes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 1.5) return AppColors.success;
    if (score >= 1.0) return AppColors.warning;
    return AppColors.error;
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/child.dart';
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
            Icons.assessment_outlined,
            size: 80,
            color: AppColors.grey300,
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
          // Summary card
          _buildSummaryCard(),
          
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

  Widget _buildSummaryCard() {
    if (trackingHistory.isEmpty) return const SizedBox.shrink();

    // Calculate average scores
    Map<String, List<double>> categoryAverages = {};
    
    for (var category in tracking_data.TrackingData.categories) {
      categoryAverages[category.name] = [];
    }

    for (var tracking in trackingHistory) {
      for (var category in tracking_data.TrackingData.categories) {
        List<int> scores = [];
        for (var question in category.questions) {
          scores.add(tracking.scores[question.id] ?? 0);
        }
        if (scores.isNotEmpty) {
          double avg = scores.reduce((a, b) => a + b) / scores.length;
          categoryAverages[category.name]!.add(avg);
        }
      }
    }

    // Calculate overall trends
    double overallAverage = trackingHistory.map((t) => t.totalScore).reduce((a, b) => a + b) / trackingHistory.length;
    
    // Get recent vs previous average for trend
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
          
          // Overall score
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Điểm trung bình',
                  '${overallAverage.toStringAsFixed(1)}/2.0',
                  _getScoreColor(overallAverage),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Số lần tracking',
                  '${trackingHistory.length}',
                  AppColors.primary,
                ),
              ),
            ],
          ),
          
          if (trackingHistory.length >= 2) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Xu hướng gần đây',
                    recentAverage > previousAverage ? 'Tăng' : 'Giảm',
                    recentAverage > previousAverage ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Tracking gần nhất',
                    '${trackingHistory.first.date.day}/${trackingHistory.first.date.month}',
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
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
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${tracking.date.day}/${tracking.date.month}/${tracking.date.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(tracking.totalScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getScoreColor(tracking.totalScore)),
                  ),
                  child: Text(
                    '${tracking.totalScore.toStringAsFixed(1)}/2.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(tracking.totalScore),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Category scores
                ...tracking_data.TrackingData.categories.map((category) {
                  List<int> scores = [];
                  for (var question in category.questions) {
                    scores.add(tracking.scores[question.id] ?? 0);
                  }
                  double avgScore = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${avgScore.toStringAsFixed(1)}/2.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(avgScore),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                // Notes if any
                if (tracking.notes.isNotEmpty) ...[
                  const Divider(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tracking.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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

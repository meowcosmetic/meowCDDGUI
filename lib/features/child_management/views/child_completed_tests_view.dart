import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/child.dart';
import '../../../models/test_models.dart';

class ChildCompletedTestsView extends StatelessWidget {
  final Child child;
  final List<TestResult> results;

  const ChildCompletedTestsView({super.key, required this.child, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text('Bài test đã làm: ${child.name}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: results.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return _buildResultCard(result);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có bài test nào được hoàn thành',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Khi hoàn thành bài test, kết quả sẽ hiển thị tại đây.'),
        ],
      ),
    );
  }

  Widget _buildResultCard(TestResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.getResultColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics,
                color: result.getResultColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                     Text(
                     'Bài test: ${result.testId}',
                     style: const TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                       color: AppColors.textPrimary,
                     ),
                   ),
                   if (result.notes?.isNotEmpty == true) ...[
                     const SizedBox(height: 4),
                     Text(
                       result.notes ?? '',
                       style: const TextStyle(
                         fontSize: 12,
                         color: AppColors.textSecondary,
                         fontStyle: FontStyle.italic,
                       ),
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.score, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                                             Text(
                         'Điểm: ${result.score}/${result.totalQuestions} (${result.answeredQuestions}/${result.totalQuestions} câu đúng)',
                         style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                       ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${result.timeSpent}s',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: result.getResultColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result.getResultText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: result.getResultColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hoàn thành lúc: ${_formatDateTime(result.completedAt)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}



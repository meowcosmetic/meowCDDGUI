import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../constants/app_colors.dart';
import '../../../models/intervention_post.dart';

class PostDetailPage extends StatelessWidget {
  final InterventionPost post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, style: const TextStyle(fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _sharePost(context),
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with post type and status
            _buildHeader(),
            const SizedBox(height: 24),

            // Content
            _buildContent(),

            const SizedBox(height: 24),

            // Additional information
            _buildAdditionalInfo(),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post type and status badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: post.postType == PostType.INTERVENTION_METHOD
                      ? Colors.blue
                      : post.postType == PostType.CHECKLIST
                      ? Colors.green
                      : post.postType == PostType.GUIDELINE
                      ? Colors.orange
                      : Colors.purple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  post.postType.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: post.isPublished ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  post.isPublished ? 'Đã xuất bản' : 'Chưa xuất bản',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          if (post.author != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tác giả: ${post.author}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (post.content.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'Không có nội dung',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildContentDisplay(post.content),
    );
  }

  Widget _buildContentDisplay(Map<String, dynamic> content) {
    // Ưu tiên hiển thị nội dung tiếng Việt
    String displayText = '';

    if (content.containsKey('vi') && content['vi'] != null) {
      // Nội dung mới có cấu trúc {"vi": "...", "en": "..."}
      displayText = content['vi'].toString();
    } else if (content.containsKey('text') && content['text'] != null) {
      // Format cũ với text field
      displayText = content['text'].toString();
    } else {
      // Fallback to old format
      displayText = content.toString();
    }

    return Html(
      data: displayText,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(15),
          color: AppColors.textPrimary,
          lineHeight: LineHeight(1.6),
        ),
        "p": Style(margin: Margins.only(bottom: 12), fontSize: FontSize(15)),
        "strong": Style(fontWeight: FontWeight.bold),
        "em": Style(fontStyle: FontStyle.italic),
        "ul": Style(margin: Margins.only(left: 20, bottom: 12)),
        "ol": Style(margin: Margins.only(left: 20, bottom: 12)),
        "li": Style(margin: Margins.only(bottom: 6), fontSize: FontSize(15)),
        "h1": Style(
          fontSize: FontSize(20),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 16),
          color: AppColors.primary,
        ),
        "h2": Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 12),
          color: AppColors.primary,
        ),
        "h3": Style(
          fontSize: FontSize(16),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 8),
          color: AppColors.textPrimary,
        ),
        "blockquote": Style(
          padding: HtmlPaddings.only(left: 16),
          margin: Margins.only(bottom: 12),
          border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        ),
      },
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin bổ sung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Age range
          if (post.targetAgeMinMonths != null &&
              post.targetAgeMaxMonths != null) ...[
            _buildInfoRow(
              Icons.child_care,
              'Độ tuổi',
              '${post.targetAgeMinMonths}-${post.targetAgeMaxMonths} tháng',
            ),
            const SizedBox(height: 8),
          ],

          // Duration
          if (post.estimatedDurationMinutes != null) ...[
            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              '${post.estimatedDurationMinutes} phút',
            ),
            const SizedBox(height: 8),
          ],

          // Difficulty level
          if (post.difficultyLevel != null) ...[
            _buildInfoRow(
              Icons.trending_up,
              'Độ khó',
              'Cấp ${post.difficultyLevel}/5',
            ),
            const SizedBox(height: 8),
          ],

          // Version
          if (post.version != null) ...[
            _buildInfoRow(Icons.info_outline, 'Phiên bản', post.version!),
            const SizedBox(height: 8),
          ],

          // Tags
          if (post.tags != null && post.tags!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.label,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tags:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: post.tags!.split(',').map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag.trim(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sharePost(context),
            icon: const Icon(Icons.share),
            label: const Text('Chia sẻ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _printPost(context),
            icon: const Icon(Icons.print),
            label: const Text('In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _sharePost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng chia sẻ sẽ được thêm sau'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _printPost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng in sẽ được thêm sau'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

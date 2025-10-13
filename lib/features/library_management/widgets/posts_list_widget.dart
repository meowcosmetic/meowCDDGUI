import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../constants/app_colors.dart';
import '../../../models/intervention_post.dart';
import '../../../models/api_service.dart';

class PostsListWidget extends StatefulWidget {
  final List<InterventionPost> posts;
  final List<InterventionPost> filteredPosts;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final Function() onLoadMore;
  final Function(InterventionPost) onViewPost;
  final Function(InterventionPost) onDeletePost;
  final Widget Function() emptyStateBuilder;

  const PostsListWidget({
    super.key,
    required this.posts,
    required this.filteredPosts,
    required this.isLoading,
    required this.hasMoreData,
    required this.currentPage,
    required this.onLoadMore,
    required this.onViewPost,
    required this.onDeletePost,
    required this.emptyStateBuilder,
  });

  @override
  State<PostsListWidget> createState() => _PostsListWidgetState();
}

class _PostsListWidgetState extends State<PostsListWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.filteredPosts.isEmpty) {
      return widget.emptyStateBuilder();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.filteredPosts.length + (widget.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.filteredPosts.length) {
          // Load more button
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: widget.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: widget.onLoadMore,
                      child: const Text('Tải thêm'),
                    ),
            ),
          );
        }

        final post = widget.filteredPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(InterventionPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  post.postType == PostType.INTERVENTION_METHOD
                                  ? Colors.blue
                                  : post.postType == PostType.CHECKLIST
                                  ? Colors.green
                                  : post.postType == PostType.GUIDELINE
                                  ? Colors.orange
                                  : Colors.purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.postType.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: post.isPublished
                                  ? Colors.green
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.isPublished
                                  ? 'Đã xuất bản'
                                  : 'Chưa xuất bản',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => widget.onViewPost(post),
                      icon: const Icon(Icons.visibility),
                      tooltip: 'Xem chi tiết',
                    ),
                    IconButton(
                      onPressed: () => _confirmDeletePost(post),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ],
            ),
            if (post.tags != null && post.tags!.isNotEmpty) ...[
              const SizedBox(height: 8),
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag.trim(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (post.targetAgeMinMonths != null &&
                post.targetAgeMaxMonths != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.child_care, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Độ tuổi: ${post.targetAgeMinMonths}-${post.targetAgeMaxMonths} tháng',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (post.estimatedDurationMinutes != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Thời gian: ${post.estimatedDurationMinutes} phút',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
            if (post.author != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Tác giả: ${post.author}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onViewPost(post),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Xem'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onViewPost(post),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Chi tiết'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletePost(InterventionPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bài post "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDeletePost(post);
    }
  }
}

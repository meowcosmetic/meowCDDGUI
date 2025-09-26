import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/library_item.dart';
import '../../../models/api_service.dart';
import '../pdf_viewer.dart';

class PdfListWidget extends StatefulWidget {
  final List<LibraryItem> items;
  final List<LibraryItem> filteredItems;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final VoidCallback onLoadMore;
  final Function(LibraryItem) onReadItem;
  final Function(LibraryItem) onShowItemDetails;
  final Function(LibraryItem) onDeleteItem;
  final Widget Function() emptyStateBuilder;

  const PdfListWidget({
    Key? key,
    required this.items,
    required this.filteredItems,
    required this.isLoading,
    required this.hasMoreData,
    required this.currentPage,
    required this.onLoadMore,
    required this.onReadItem,
    required this.onShowItemDetails,
    required this.onDeleteItem,
    required this.emptyStateBuilder,
  }) : super(key: key);

  @override
  State<PdfListWidget> createState() => _PdfListWidgetState();
}

class _PdfListWidgetState extends State<PdfListWidget> {
  @override
  Widget build(BuildContext context) {
    // Prefer items detected as PDF; if none detected, show all book items
    final pdfItems = widget.filteredItems.where((item) {
      final ft = item.fileType.toLowerCase();
      final title = item.title.toLowerCase();
      return ft.contains('pdf') || title.endsWith('.pdf');
    }).toList();
    final listToShow = pdfItems.isNotEmpty ? pdfItems : widget.filteredItems;

    if (widget.isLoading && widget.currentPage == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (listToShow.isEmpty) {
      return widget.emptyStateBuilder();
    }

    return ListView(
      children: [
        ...listToShow.map(_buildLibraryItemCard).toList(),
        if (widget.hasMoreData)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.isLoading ? null : widget.onLoadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('Tải thêm sách'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLibraryItemCard(LibraryItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    _getFileTypeIcon(item.fileType),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.author,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.category,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.domain,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${item.rating.toStringAsFixed(1)} (${item.ratingCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.viewCount} lượt xem',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onDeleteItem(item),
                  tooltip: 'Xóa',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onReadItem(item),
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
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onShowItemDetails(item),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Chi tiết'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: BorderSide(color: AppColors.info),
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

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'epub':
        return Icons.menu_book;
      default:
        return Icons.insert_drive_file;
    }
  }
}

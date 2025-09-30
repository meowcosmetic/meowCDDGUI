import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../constants/app_colors.dart';
import '../pages/add_criteria_page.dart';

class CriteriaListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> criteria;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final VoidCallback? onAddNew;

  const CriteriaListWidget({
    super.key,
    required this.criteria,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (onRefresh != null)
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Thử lại'),
              ),
          ],
        ),
      );
    }

    if (criteria.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Chưa có mục tiêu can thiệp nhỏ nào',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút làm mới để tải lại dữ liệu',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRefresh != null)
                  ElevatedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới'),
                  ),
                if (onRefresh != null && onAddNew != null) const SizedBox(width: 16),
                if (onAddNew != null)
                  ElevatedButton.icon(
                    onPressed: onAddNew,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm mục tiêu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: criteria.length,
          itemBuilder: (context, index) {
        final c = criteria[index];
        String name = '';
        final dn = c['displayedName'] ?? c['name'];
        if (dn is Map) {
          final m = dn.cast<String, dynamic>();
          name = (m['vi'] ?? m['en'] ?? '').toString();
        } else if (dn != null) {
          name = dn.toString();
        }

        String? desc;
        final d = c['description'];
        if (d is Map) {
          final m = d.cast<String, dynamic>();
          desc = (m['vi'] ?? m['en'])?.toString();
        } else if (d is String) {
          desc = d;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.flag,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name.isEmpty ? 'Mục tiêu can thiệp nhỏ' : name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (desc != null && desc.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Html(
                      data: desc,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(13),
                          color: AppColors.textSecondary,
                          lineHeight: LineHeight(1.3),
                        ),
                        "p": Style(margin: Margins.only(bottom: 6)),
                        "strong": Style(fontWeight: FontWeight.bold),
                        "em": Style(fontStyle: FontStyle.italic),
                        "ul": Style(margin: Margins.only(left: 16)),
                        "ol": Style(margin: Margins.only(left: 16)),
                        "li": Style(margin: Margins.only(bottom: 4)),
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mục tiêu can thiệp',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
        if (onAddNew != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: onAddNew,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

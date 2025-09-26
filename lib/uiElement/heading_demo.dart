import 'package:flutter/material.dart';
import 'heading.dart';
import '../constants/app_colors.dart';

class HeadingDemo extends StatelessWidget {
  final bool showAppBar;

  const HeadingDemo({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Heading Components Demo'),
              backgroundColor: AppColors.cardBorder,
              foregroundColor: AppColors.white,
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Các cấp độ Heading',
              'Từ H1 đến H6 với kích thước và trọng lượng mặc định',
              [
                const H1(text: 'Heading 1 - Tiêu đề chính'),
                const SizedBox(height: 16),
                const H2(text: 'Heading 2 - Tiêu đề phụ'),
                const SizedBox(height: 16),
                const H3(text: 'Heading 3 - Tiêu đề nhỏ'),
                const SizedBox(height: 16),
                const H4(text: 'Heading 4 - Tiêu đề nhỏ hơn'),
                const SizedBox(height: 16),
                const H5(text: 'Heading 5 - Tiêu đề rất nhỏ'),
                const SizedBox(height: 16),
                const H6(text: 'Heading 6 - Tiêu đề nhỏ nhất'),
              ],
            ),
            _buildSection(
              context,
              'Special Heading Components',
              'Các component heading đặc biệt',
              [
                const PageTitle(text: 'Page Title - Tiêu đề trang'),
                const SizedBox(height: 16),
                const SectionTitle(text: 'Section Title - Tiêu đề phần'),
                const SizedBox(height: 16),
                const SubsectionTitle(
                  text: 'Subsection Title - Tiêu đề mục con',
                ),
              ],
            ),
            _buildSection(
              context,
              'Kích thước khác nhau',
              'Các kích thước heading từ nhỏ đến lớn',
              [
                H1(text: 'Heading với kích thước nhỏ', size: HeadingSize.small),
                const SizedBox(height: 16),
                H1(
                  text: 'Heading với kích thước vừa',
                  size: HeadingSize.medium,
                ),
                const SizedBox(height: 16),
                H1(text: 'Heading với kích thước lớn', size: HeadingSize.large),
                const SizedBox(height: 16),
                H1(
                  text: 'Heading với kích thước rất lớn',
                  size: HeadingSize.xlarge,
                ),
              ],
            ),
            _buildSection(
              context,
              'Trọng lượng font khác nhau',
              'Các trọng lượng font từ nhẹ đến đậm',
              [
                H2(text: 'Heading với font nhẹ', weight: HeadingWeight.light),
                const SizedBox(height: 16),
                H2(
                  text: 'Heading với font bình thường',
                  weight: HeadingWeight.normal,
                ),
                const SizedBox(height: 16),
                H2(text: 'Heading với font vừa', weight: HeadingWeight.medium),
                const SizedBox(height: 16),
                H2(
                  text: 'Heading với font bán đậm',
                  weight: HeadingWeight.semibold,
                ),
                const SizedBox(height: 16),
                H2(text: 'Heading với font đậm', weight: HeadingWeight.bold),
                const SizedBox(height: 16),
                H2(
                  text: 'Heading với font rất đậm',
                  weight: HeadingWeight.extrabold,
                ),
              ],
            ),
            _buildSection(
              context,
              'Heading với icon',
              'Heading có thể có icon ở đầu',
              [
                H2(text: 'Heading với icon', icon: Icons.star),
                const SizedBox(height: 16),
                H3(
                  text: 'Heading với icon khác',
                  icon: Icons.favorite,
                  color: AppColors.red,
                ),
                const SizedBox(height: 16),
                H4(
                  text: 'Heading với icon và màu tùy chỉnh',
                  icon: Icons.check_circle,
                  color: AppColors.green,
                ),
              ],
            ),
            _buildSection(
              context,
              'Heading với trailing widget',
              'Heading có thể có widget ở cuối',
              [
                H2(
                  text: 'Heading với badge',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                H3(
                  text: 'Heading với button',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Xem thêm'),
                  ),
                ),
                const SizedBox(height: 16),
                H4(
                  text: 'Heading với icon trailing',
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: AppColors.cardBorder,
                  ),
                ),
              ],
            ),
            _buildSection(
              context,
              'Heading có thể click',
              'Heading có thể có sự kiện onTap',
              [
                H2(
                  text: 'Heading có thể click (nhấn để thử)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Heading đã được nhấn!')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                H3(
                  text: 'Heading với icon và có thể click',
                  icon: Icons.touch_app,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Heading với icon đã được nhấn!'),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Heading với style đặc biệt',
              'Heading với underline, italic và màu sắc tùy chỉnh',
              [
                H2(text: 'Heading với gạch chân', underline: true),
                const SizedBox(height: 16),
                H3(text: 'Heading với chữ nghiêng', italic: true),
                const SizedBox(height: 16),
                H4(text: 'Heading với màu tùy chỉnh', color: AppColors.purple),
                const SizedBox(height: 16),
                H5(
                  text: 'Heading với gạch chân và màu đỏ',
                  underline: true,
                  color: AppColors.red,
                ),
              ],
            ),
            _buildSection(
              context,
              'Heading với căn chỉnh text',
              'Heading với các căn chỉnh text khác nhau',
              [
                H2(
                  text: 'Heading căn trái (mặc định)',
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                H2(text: 'Heading căn giữa', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                H2(text: 'Heading căn phải', textAlign: TextAlign.right),
              ],
            ),
            _buildSection(
              context,
              'Heading với margin và padding',
              'Heading với margin và padding tùy chỉnh',
              [
                H2(
                  text: 'Heading với margin',
                  margin: const EdgeInsets.all(16),
                  color: AppColors.cardBorder,
                ),
                const SizedBox(height: 16),
                H3(
                  text: 'Heading với padding',
                  padding: const EdgeInsets.all(16),
                  color: AppColors.green,
                ),
                const SizedBox(height: 16),
                H4(
                  text: 'Heading với margin và padding',
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  color: AppColors.orange,
                ),
              ],
            ),
            _buildSection(
              context,
              'Heading với maxLines và overflow',
              'Heading với giới hạn số dòng và xử lý overflow',
              [
                H2(
                  text:
                      'Heading này rất dài và sẽ bị cắt nếu vượt quá số dòng cho phép. Đây là một ví dụ về heading dài.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                H3(
                  text: 'Heading này cũng dài nhưng sẽ hiển thị đầy đủ',
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
            _buildSection(
              context,
              'Ví dụ thực tế',
              'Cách sử dụng heading trong thực tế',
              [
                const PageTitle(text: 'Dashboard', icon: Icons.dashboard),
                const SizedBox(height: 16),
                const SectionTitle(text: 'Thống kê', icon: Icons.analytics),
                const SizedBox(height: 16),
                const SubsectionTitle(
                  text: 'Doanh thu tháng này',
                  trailing: Icon(Icons.trending_up, color: AppColors.green),
                ),
                const SizedBox(height: 16),
                H4(
                  text: 'Chi tiết',
                  icon: Icons.info,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xem chi tiết')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.cardBorder),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

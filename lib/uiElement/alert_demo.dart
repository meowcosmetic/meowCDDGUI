import 'package:flutter/material.dart';
import 'alert.dart';
import 'button.dart';
import '../constants/app_colors.dart';


class AlertDemo extends StatefulWidget {
  final bool showAppBar;
  
  const AlertDemo({super.key, this.showAppBar = true});

  @override
  State<AlertDemo> createState() => _AlertDemoState();
}

class _AlertDemoState extends State<AlertDemo> {
  final List<Widget> _alerts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: widget.showAppBar ? AppBar(
          title: const Text('Alert Components Demo'),
          backgroundColor: AppColors.cardBorder,
          foregroundColor: AppColors.white,
        ) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Success Alerts',
              'Thông báo thành công với màu xanh lá',
              [
                SuccessAlert(
                  title: 'Thành công!',
                  message: 'Dữ liệu đã được lưu thành công.',
                  onDismiss: () => _removeAlert(0),
                ),
                const SizedBox(height: 12),
                SuccessAlert(
                  title: 'Đăng ký thành công',
                  message: 'Tài khoản của bạn đã được tạo thành công. Vui lòng kiểm tra email để xác nhận.',
                  size: AlertSize.large,
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Xem chi tiết'),
                    ),
                  ],
                  onDismiss: () => _removeAlert(1),
                ),
              ],
            ),
            _buildSection(
              context,
              'Error Alerts',
              'Thông báo lỗi với màu đỏ',
              [
                ErrorAlert(
                  title: 'Lỗi!',
                  message: 'Không thể kết nối đến máy chủ.',
                  onDismiss: () => _removeAlert(2),
                ),
                const SizedBox(height: 12),
                ErrorAlert(
                  title: 'Đăng nhập thất bại',
                  message: 'Email hoặc mật khẩu không chính xác. Vui lòng thử lại.',
                  size: AlertSize.large,
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Quên mật khẩu?'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Thử lại'),
                    ),
                  ],
                  onDismiss: () => _removeAlert(3),
                ),
              ],
            ),
            _buildSection(
              context,
              'Warning Alerts',
              'Cảnh báo với màu vàng',
              [
                WarningAlert(
                  title: 'Cảnh báo!',
                  message: 'Bạn sắp hết dung lượng lưu trữ.',
                  onDismiss: () => _removeAlert(4),
                ),
                const SizedBox(height: 12),
                WarningAlert(
                  title: 'Xác nhận xóa',
                  message: 'Bạn có chắc chắn muốn xóa mục này? Hành động này không thể hoàn tác.',
                  size: AlertSize.large,
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.red,
                      ),
                      child: const Text('Xóa'),
                    ),
                  ],
                  onDismiss: () => _removeAlert(5),
                ),
              ],
            ),
            _buildSection(
              context,
              'Info Alerts',
              'Thông tin với màu xanh dương',
              [
                InfoAlert(
                  title: 'Thông tin',
                  message: 'Có bản cập nhật mới cho ứng dụng.',
                  onDismiss: () => _removeAlert(6),
                ),
                const SizedBox(height: 12),
                InfoAlert(
                  title: 'Hướng dẫn',
                  message: 'Để sử dụng tính năng này, bạn cần cấp quyền truy cập camera.',
                  size: AlertSize.large,
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Cấp quyền'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Bỏ qua'),
                    ),
                  ],
                  onDismiss: () => _removeAlert(7),
                ),
              ],
            ),
            _buildSection(
              context,
              'Kích thước khác nhau',
              'Các kích thước alert từ nhỏ đến lớn',
              [
                Row(
                  children: [
                    Expanded(
                      child: SuccessAlert(
                        title: 'Nhỏ',
                        message: 'Alert kích thước nhỏ',
                        size: AlertSize.small,
                        onDismiss: () => _removeAlert(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InfoAlert(
                        title: 'Vừa',
                        message: 'Alert kích thước vừa',
                        size: AlertSize.medium,
                        onDismiss: () => _removeAlert(9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WarningAlert(
                        title: 'Lớn',
                        message: 'Alert kích thước lớn',
                        size: AlertSize.large,
                        onDismiss: () => _removeAlert(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(
              context,
              'Alert không có icon',
              'Alert có thể ẩn icon',
              [
                ErrorAlert(
                  title: 'Không có icon',
                  message: 'Alert này không hiển thị icon.',
                  showIcon: false,
                  onDismiss: () => _removeAlert(11),
                ),
              ],
            ),
            _buildSection(
              context,
              'Alert không thể đóng',
              'Alert không có nút đóng',
              [
                InfoAlert(
                  title: 'Không thể đóng',
                  message: 'Alert này không thể đóng bằng nút X.',
                  dismissible: false,
                ),
              ],
            ),
            _buildSection(
              context,
              'Alert tùy chỉnh màu sắc',
              'Alert với màu sắc tùy chỉnh',
              [
                Alert(
                  title: 'Màu tùy chỉnh',
                  message: 'Alert với màu nền và viền tùy chỉnh.',
                  type: AlertType.info,
                  backgroundColor: AppColors.purple.withValues(alpha: 0.1),
                  borderColor: AppColors.purple,
                  onDismiss: () => _removeAlert(12),
                ),
                const SizedBox(height: 12),
                Alert(
                  title: 'Màu gradient',
                  message: 'Alert với màu sắc gradient.',
                  type: AlertType.success,
                  backgroundColor: AppColors.orange.withValues(alpha: 0.1),
                  borderColor: AppColors.orange,
                  onDismiss: () => _removeAlert(13),
                ),
              ],
            ),
            _buildSection(
              context,
              'Alert với actions phức tạp',
              'Alert có nhiều actions khác nhau',
              [
                Alert(
                  title: 'Cập nhật ứng dụng',
                  message: 'Phiên bản mới 2.1.0 đã có sẵn với nhiều tính năng mới.',
                  type: AlertType.info,
                  size: AlertSize.large,
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Bỏ qua'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Xem chi tiết'),
                    ),
                    PrimaryButton(
                      text: 'Cập nhật ngay',
                      size: ButtonSize.small,
                      onPressed: () {},
                    ),
                  ],
                  onDismiss: () => _removeAlert(14),
                ),
              ],
            ),
            _buildSection(
              context,
              'Dynamic Alerts',
              'Thêm và xóa alert động',
              [
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Thêm Success Alert',
                        onPressed: _addSuccessAlert,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Thêm Error Alert',
                        onPressed: _addErrorAlert,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Thêm Warning Alert',
                        onPressed: _addWarningAlert,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Thêm Info Alert',
                        onPressed: _addInfoAlert,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._alerts,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.cardBorder,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  void _removeAlert(int index) {
    // This is a placeholder for demo purposes
    // In real app, you would remove the alert from a list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert $index đã được đóng'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addSuccessAlert() {
    setState(() {
      _alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SuccessAlert(
            title: 'Thành công!',
            message: 'Alert động được thêm thành công.',
            onDismiss: () {
              setState(() {
                _alerts.removeAt(_alerts.length - 1);
              });
            },
          ),
        ),
      );
    });
  }

  void _addErrorAlert() {
    setState(() {
      _alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ErrorAlert(
            title: 'Lỗi!',
            message: 'Alert lỗi động được thêm.',
            onDismiss: () {
              setState(() {
                _alerts.removeAt(_alerts.length - 1);
              });
            },
          ),
        ),
      );
    });
  }

  void _addWarningAlert() {
    setState(() {
      _alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: WarningAlert(
            title: 'Cảnh báo!',
            message: 'Alert cảnh báo động được thêm.',
            onDismiss: () {
              setState(() {
                _alerts.removeAt(_alerts.length - 1);
              });
            },
          ),
        ),
      );
    });
  }

  void _addInfoAlert() {
    setState(() {
      _alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InfoAlert(
            title: 'Thông tin',
            message: 'Alert thông tin động được thêm.',
            onDismiss: () {
              setState(() {
                _alerts.removeAt(_alerts.length - 1);
              });
            },
          ),
        ),
      );
    });
  }
} 

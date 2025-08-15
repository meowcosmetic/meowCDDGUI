# Alert Component

Alert component cung cấp các thông báo với nhiều loại khác nhau cho Flutter app với khả năng tùy chỉnh cao.

## Các loại Alert

### 1. SuccessAlert
Alert thành công với màu xanh lá, thường dùng cho thông báo thành công.

```dart
// Cơ bản
SuccessAlert(
  title: 'Thành công!',
  message: 'Dữ liệu đã được lưu thành công.',
)

// Với actions
SuccessAlert(
  title: 'Đăng ký thành công',
  message: 'Tài khoản của bạn đã được tạo thành công.',
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('Xem chi tiết'),
    ),
  ],
)
```

### 2. ErrorAlert
Alert lỗi với màu đỏ, thường dùng cho thông báo lỗi.

```dart
// Cơ bản
ErrorAlert(
  title: 'Lỗi!',
  message: 'Không thể kết nối đến máy chủ.',
)

// Với nhiều actions
ErrorAlert(
  title: 'Đăng nhập thất bại',
  message: 'Email hoặc mật khẩu không chính xác.',
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('Quên mật khẩu?'),
    ),
    TextButton(
      onPressed: () {},
      child: Text('Thử lại'),
    ),
  ],
)
```

### 3. WarningAlert
Alert cảnh báo với màu vàng, thường dùng cho cảnh báo.

```dart
// Cơ bản
WarningAlert(
  title: 'Cảnh báo!',
  message: 'Bạn sắp hết dung lượng lưu trữ.',
)

// Xác nhận xóa
WarningAlert(
  title: 'Xác nhận xóa',
  message: 'Bạn có chắc chắn muốn xóa mục này?',
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('Hủy'),
    ),
    TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
      child: Text('Xóa'),
    ),
  ],
)
```

### 4. InfoAlert
Alert thông tin với màu xanh dương, thường dùng cho thông tin.

```dart
// Cơ bản
InfoAlert(
  title: 'Thông tin',
  message: 'Có bản cập nhật mới cho ứng dụng.',
)

// Với actions
InfoAlert(
  title: 'Hướng dẫn',
  message: 'Để sử dụng tính năng này, bạn cần cấp quyền.',
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('Cấp quyền'),
    ),
    TextButton(
      onPressed: () {},
      child: Text('Bỏ qua'),
    ),
  ],
)
```

## Kích thước

Có 3 kích thước có sẵn:
- `AlertSize.small`: Nhỏ (12px padding)
- `AlertSize.medium`: Vừa (16px padding) - Mặc định
- `AlertSize.large`: Lớn (20px padding)

```dart
SuccessAlert(
  title: 'Kích thước nhỏ',
  message: 'Alert với kích thước nhỏ.',
  size: AlertSize.small,
)

InfoAlert(
  title: 'Kích thước lớn',
  message: 'Alert với kích thước lớn.',
  size: AlertSize.large,
)
```

## Tùy chỉnh

### Màu sắc tùy chỉnh
```dart
Alert(
  title: 'Màu tùy chỉnh',
  message: 'Alert với màu nền và viền tùy chỉnh.',
  type: AlertType.info,
  backgroundColor: Colors.purple[50],
  borderColor: Colors.purple[300],
)
```

### Ẩn icon
```dart
ErrorAlert(
  title: 'Không có icon',
  message: 'Alert này không hiển thị icon.',
  showIcon: false,
)
```

### Không thể đóng
```dart
InfoAlert(
  title: 'Không thể đóng',
  message: 'Alert này không thể đóng bằng nút X.',
  dismissible: false,
)
```

### Tùy chỉnh padding
```dart
SuccessAlert(
  title: 'Padding tùy chỉnh',
  message: 'Alert với padding tùy chỉnh.',
  padding: EdgeInsets.all(24),
)
```

## Actions

Alert có thể có nhiều actions khác nhau:

```dart
Alert(
  title: 'Cập nhật ứng dụng',
  message: 'Phiên bản mới 2.1.0 đã có sẵn.',
  type: AlertType.info,
  size: AlertSize.large,
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('Bỏ qua'),
    ),
    TextButton(
      onPressed: () {},
      child: Text('Xem chi tiết'),
    ),
    PrimaryButton(
      text: 'Cập nhật ngay',
      size: ButtonSize.small,
      onPressed: () {},
    ),
  ],
)
```

## Sử dụng Alert chung

Có thể sử dụng class `Alert` chính với enum `AlertType`:

```dart
Alert(
  title: 'Custom Alert',
  message: 'Alert tùy chỉnh với type.',
  type: AlertType.success,
  size: AlertSize.medium,
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('OK'),
    ),
  ],
  onDismiss: () {
    print('Alert dismissed');
  },
)
```

## Ví dụ thực tế

### Alert trong form validation
```dart
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });

      try {
        // Gọi API login
        await Future.delayed(Duration(seconds: 2));
        // Xử lý thành công
      } catch (e) {
        setState(() {
          _errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null)
            ErrorAlert(
              title: 'Lỗi đăng nhập',
              message: _errorMessage!,
              onDismiss: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
          
          // Form fields...
          
          PrimaryButton(
            text: 'Đăng nhập',
            onPressed: _login,
          ),
        ],
      ),
    );
  }
}
```

### Alert với auto-dismiss
```dart
class NotificationWidget extends StatefulWidget {
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  bool _showNotification = false;

  void _showSuccessNotification() {
    setState(() {
      _showNotification = true;
    });

    // Tự động ẩn sau 3 giây
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showNotification)
          SuccessAlert(
            title: 'Thành công!',
            message: 'Thao tác đã được thực hiện thành công.',
            onDismiss: () {
              setState(() {
                _showNotification = false;
              });
            },
          ),
        
        PrimaryButton(
          text: 'Thực hiện thao tác',
          onPressed: _showSuccessNotification,
        ),
      ],
    );
  }
}
```

### Alert với confirmation
```dart
class DeleteConfirmation extends StatelessWidget {
  final String itemName;
  final VoidCallback onDelete;

  const DeleteConfirmation({
    required this.itemName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return WarningAlert(
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc chắn muốn xóa "$itemName"? Hành động này không thể hoàn tác.',
      size: AlertSize.large,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            onDelete();
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: Text('Xóa'),
        ),
      ],
    );
  }
}
```

## Demo

Để xem demo của tất cả các loại alert, hãy chạy:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AlertDemo()),
);
```

## Lưu ý

- Tất cả alert components đều có thiết kế responsive
- Có thể tùy chỉnh màu sắc, kích thước và actions
- Hỗ trợ cả light và dark theme
- Có thể tích hợp với Button component
- Performance tốt với việc sử dụng StatelessWidget
- Có thể sử dụng trong form validation, notifications, confirmations 
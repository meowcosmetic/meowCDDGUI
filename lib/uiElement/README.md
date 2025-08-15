# UI Elements Documentation

Tài liệu về các UI elements được sử dụng trong ứng dụng.

## Components

### Button System
Hệ thống button hoàn chỉnh với các loại button khác nhau, kích thước và tùy chọn icon.

### Loading System
Hệ thống loading với nhiều kiểu loading khác nhau cho các tình huống sử dụng khác nhau.

### Alert System
Hệ thống alert với nhiều loại thông báo khác nhau cho các tình huống sử dụng khác nhau.

### Pagination System
Hệ thống pagination với nhiều kiểu phân trang khác nhau cho danh sách và carousel.

### Heading System
Hệ thống heading với các cấp độ tiêu đề khác nhau cho layout và typography.

---

## Button System Documentation

## Các loại Button

### 1. PrimaryButton
Button chính với màu nền xanh lá, thường dùng cho các hành động quan trọng.

```dart
PrimaryButton(
  text: 'Submit',
  onPressed: () => print('Button pressed'),
)
```

### 2. SecondaryButton
Button phụ với màu nền xám, thường dùng cho các hành động thứ yếu.

```dart
SecondaryButton(
  text: 'Cancel',
  onPressed: () => print('Button pressed'),
)
```

### 3. OutlineButton
Button với viền, không có màu nền, thường dùng cho các hành động phụ.

```dart
OutlineButton(
  text: 'Download',
  onPressed: () => print('Button pressed'),
)
```

### 4. GhostButton
Button trong suốt, chỉ có text, thường dùng cho các liên kết hoặc hành động nhẹ.

```dart
GhostButton(
  text: 'Learn More',
  onPressed: () => print('Button pressed'),
)
```

### 5. DestructiveButton
Button màu đỏ, thường dùng cho các hành động nguy hiểm như xóa.

```dart
DestructiveButton(
  text: 'Delete',
  onPressed: () => print('Button pressed'),
)
```

## Kích thước Button

Có 3 kích thước: `small`, `medium`, `large`

```dart
PrimaryButton(
  text: 'Small Button',
  size: ButtonSize.small,
  onPressed: () {},
)

PrimaryButton(
  text: 'Medium Button',
  size: ButtonSize.medium, // Mặc định
  onPressed: () {},
)

PrimaryButton(
  text: 'Large Button',
  size: ButtonSize.large,
  onPressed: () {},
)
```

## Button với Icon

Tất cả các loại button đều hỗ trợ icon:

```dart
PrimaryButton(
  text: 'Add Item',
  icon: Icons.add,
  onPressed: () {},
)

OutlineButton(
  text: 'Download',
  icon: Icons.download,
  onPressed: () {},
)
```

## Trạng thái Loading

Button có thể hiển thị trạng thái loading với spinner:

```dart
PrimaryButton(
  text: 'Loading...',
  isLoading: true,
  onPressed: () {},
)
```

## Trạng thái Disabled

Button có thể bị vô hiệu hóa:

```dart
PrimaryButton(
  text: 'Disabled Button',
  disabled: true,
  onPressed: () {},
)
```

## Tùy chỉnh kích thước

Có thể tùy chỉnh width và height:

```dart
PrimaryButton(
  text: 'Full Width Button',
  width: double.infinity,
  onPressed: () {},
)

OutlineButton(
  text: 'Custom Size',
  width: 200,
  height: 50,
  onPressed: () {},
)
```

## Sử dụng Button chung

Có thể sử dụng class `Button` chính với enum `ButtonType`:

```dart
Button(
  text: 'Custom Button',
  type: ButtonType.primary,
  size: ButtonSize.medium,
  icon: Icons.star,
  onPressed: () {},
)
```

## Các thuộc tính có sẵn

- `text`: Text hiển thị trên button (bắt buộc)
- `onPressed`: Callback khi button được nhấn
- `type`: Loại button (ButtonType.primary, secondary, outline, ghost, destructive)
- `size`: Kích thước button (ButtonSize.small, medium, large)
- `icon`: Icon hiển thị bên cạnh text
- `isLoading`: Hiển thị spinner thay vì text
- `disabled`: Vô hiệu hóa button
- `width`: Chiều rộng tùy chỉnh
- `height`: Chiều cao tùy chỉnh

## Ví dụ sử dụng trong thực tế

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Save Changes',
          icon: Icons.save,
          onPressed: () => _saveData(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DestructiveButton(
                text: 'Delete',
                icon: Icons.delete,
                onPressed: () => _showDeleteDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## Loading System Documentation

### Các loại Loading

#### 1. CircularLoading
Loading dạng tròn xoay, phù hợp cho các tác vụ không xác định thời gian.

```dart
CircularLoading(
  text: 'Loading...',
  showText: true,
)
```

#### 2. LinearLoading
Loading dạng thanh ngang, phù hợp cho các tác vụ có thể hiển thị tiến trình.

```dart
LinearLoading(
  text: 'Uploading...',
  showText: true,
)
```

#### 3. SkeletonLoading
Loading dạng skeleton, phù hợp cho việc hiển thị placeholder cho content.

```dart
SkeletonLoading(
  width: double.infinity,
  height: 20,
)
```

#### 4. DotsLoading
Loading dạng chấm nhấp nháy, phù hợp cho các tác vụ ngắn.

```dart
DotsLoading(
  text: 'Connecting...',
  showText: true,
)
```

#### 5. PulseLoading
Loading dạng xung động, phù hợp cho các tác vụ đang chờ.

```dart
PulseLoading(
  text: 'Searching...',
  showText: true,
)
```

### Kích thước Loading

Có 3 kích thước: `LoadingSize.small`, `LoadingSize.medium`, `LoadingSize.large`

### Tùy chỉnh

```dart
Loading(
  type: LoadingType.circular,
  size: LoadingSize.large,
  color: Colors.blue,
  text: 'Processing...',
  showText: true,
  width: 40,
  height: 40,
)
```

### Sử dụng với Button

```dart
PrimaryButton(
  text: 'Submit',
  isLoading: true,
  onPressed: () {},
)
```

### Demo

Để xem demo của tất cả các loại loading:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => LoadingDemo()),
);
```

Chi tiết đầy đủ xem tại: [LOADING_README.md](LOADING_README.md)

---

## Alert System Documentation

### Các loại Alert

#### 1. SuccessAlert
Alert thành công với màu xanh lá, thường dùng cho thông báo thành công.

```dart
SuccessAlert(
  title: 'Thành công!',
  message: 'Dữ liệu đã được lưu thành công.',
)
```

#### 2. ErrorAlert
Alert lỗi với màu đỏ, thường dùng cho thông báo lỗi.

```dart
ErrorAlert(
  title: 'Lỗi!',
  message: 'Không thể kết nối đến máy chủ.',
)
```

#### 3. WarningAlert
Alert cảnh báo với màu vàng, thường dùng cho cảnh báo.

```dart
WarningAlert(
  title: 'Cảnh báo!',
  message: 'Bạn sắp hết dung lượng lưu trữ.',
)
```

#### 4. InfoAlert
Alert thông tin với màu xanh dương, thường dùng cho thông tin.

```dart
InfoAlert(
  title: 'Thông tin',
  message: 'Có bản cập nhật mới cho ứng dụng.',
)
```

### Kích thước Alert

Có 3 kích thước: `AlertSize.small`, `AlertSize.medium`, `AlertSize.large`

### Tùy chỉnh

```dart
Alert(
  title: 'Custom Alert',
  message: 'Alert tùy chỉnh với type.',
  type: AlertType.success,
  size: AlertSize.large,
  backgroundColor: Colors.purple[50],
  borderColor: Colors.purple[300],
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('OK'),
    ),
  ],
)
```

### Demo

Để xem demo của tất cả các loại alert:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AlertDemo()),
);
```

Chi tiết đầy đủ xem tại: [ALERT_README.md](ALERT_README.md)

---

## Pagination System Documentation

### Các loại Pagination

#### 1. NumbersPagination
Pagination với số trang và nút điều hướng, phù hợp cho danh sách dài.

```dart
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

#### 2. DotsPagination
Pagination dạng chấm tròn, phù hợp cho carousel hoặc gallery.

```dart
DotsPagination(
  currentPage: 1,
  totalPages: 5,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

#### 3. ArrowsPagination
Pagination với mũi tên điều hướng, phù hợp cho mobile.

```dart
ArrowsPagination(
  currentPage: 1,
  totalPages: 10,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

#### 4. SimplePagination
Pagination đơn giản với nút Trước/Sau, phù hợp cho danh sách ngắn.

```dart
SimplePagination(
  currentPage: 1,
  totalPages: 5,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

### Kích thước Pagination

Có 3 kích thước: `PaginationSize.small`, `PaginationSize.medium`, `PaginationSize.large`

### Tùy chỉnh

```dart
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  totalItems: 100,
  itemsPerPage: 10,
  showInfo: true,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey[400],
  onPageChanged: (page) {},
)
```

### Demo

Để xem demo của tất cả các loại pagination:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => PaginationDemo()),
);
```

Chi tiết đầy đủ xem tại: [PAGINATION_README.md](PAGINATION_README.md)

---

## Heading System Documentation

### Các cấp độ Heading

#### 1. H1 - Tiêu đề chính
Tiêu đề cấp cao nhất, thường dùng cho tiêu đề trang.

```dart
H1(text: 'Tiêu đề chính')
```

#### 2. H2 - Tiêu đề phụ
Tiêu đề cấp hai, thường dùng cho tiêu đề phần.

```dart
H2(text: 'Tiêu đề phụ')
```

#### 3. H3 - Tiêu đề nhỏ
Tiêu đề cấp ba, thường dùng cho tiêu đề mục con.

```dart
H3(text: 'Tiêu đề nhỏ')
```

### Special Heading Components

#### PageTitle
Tiêu đề trang với kích thước lớn và font đậm.

```dart
PageTitle(
  text: 'Dashboard',
  icon: Icons.dashboard,
)
```

#### SectionTitle
Tiêu đề phần với kích thước vừa.

```dart
SectionTitle(
  text: 'Thống kê',
  icon: Icons.analytics,
)
```

#### SubsectionTitle
Tiêu đề mục con với kích thước nhỏ.

```dart
SubsectionTitle(
  text: 'Doanh thu tháng này',
  trailing: Icon(Icons.trending_up, color: Colors.green),
)
```

### Kích thước và Trọng lượng

Có 4 kích thước: `HeadingSize.small`, `HeadingSize.medium`, `HeadingSize.large`, `HeadingSize.xlarge`

Có 6 trọng lượng: `HeadingWeight.light`, `HeadingWeight.normal`, `HeadingWeight.medium`, `HeadingWeight.semibold`, `HeadingWeight.bold`, `HeadingWeight.extrabold`

### Tùy chỉnh

```dart
H2(
  text: 'Heading tùy chỉnh',
  size: HeadingSize.large,
  weight: HeadingWeight.bold,
  color: Colors.blue,
  icon: Icons.star,
  onTap: () {
    print('Heading được nhấn');
  },
)
```

### Demo

Để xem demo của tất cả các loại heading:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => HeadingDemo()),
);
```

Chi tiết đầy đủ xem tại: [HEADING_README.md](HEADING_README.md) 
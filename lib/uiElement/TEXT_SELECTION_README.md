# Text Selection Configuration

## Tổng quan
Tính năng cho phép người dùng chọn và copy text trong toàn bộ ứng dụng, có thể bật/tắt thông qua config.

## Cấu hình

### 1. Bật/tắt tính năng
Trong `lib/constants/app_config.dart`:
```dart
// Text Selection Configuration - Cấu hình chọn text
static const bool enableTextSelection = true;   // Bật chọn và copy text
```

### 2. Sử dụng SelectableTextWidget

#### Cách 1: Sử dụng trực tiếp
```dart
import '../uiElement/selectable_text_widget.dart';

SelectableTextWidget(
  text: 'Nội dung có thể chọn',
  style: TextStyle(fontSize: 16),
  enableSelection: true, // Override config nếu cần
)
```

#### Cách 2: Sử dụng extension
```dart
import '../uiElement/selectable_text_widget.dart';

Text('Nội dung').toSelectable()
```

### 3. Các thuộc tính có sẵn
- `text`: Nội dung text
- `style`: Style của text
- `textAlign`: Căn chỉnh text
- `maxLines`: Số dòng tối đa
- `overflow`: Xử lý khi text bị tràn
- `enableSelection`: Override config (optional)

## Ví dụ sử dụng

### Trong table/card
```dart
Container(
  padding: EdgeInsets.all(12),
  child: SelectableTextWidget(
    text: 'Thông tin quan trọng',
    style: TextStyle(fontSize: 14),
  ),
)
```

### Trong form field
```dart
SelectableTextWidget(
  text: formData['email'] ?? '',
  style: TextStyle(color: Colors.grey),
)
```

### Với config override
```dart
SelectableTextWidget(
  text: 'Chỉ cho phép copy trong màn hình này',
  enableSelection: true, // Bật bất kể config global
)
```

## Lưu ý
- Khi `enableTextSelection = false`: Hiển thị như Text bình thường
- Khi `enableTextSelection = true`: Hiển thị như SelectableText
- Có thể override config cho từng widget cụ thể
- Tự động có menu context để copy khi chọn text

## Migration từ Text sang SelectableTextWidget

### Trước:
```dart
Text(
  'Nội dung',
  style: TextStyle(fontSize: 16),
)
```

### Sau:
```dart
SelectableTextWidget(
  text: 'Nội dung',
  style: TextStyle(fontSize: 16),
)
```

Hoặc sử dụng extension:
```dart
Text('Nội dung', style: TextStyle(fontSize: 16)).toSelectable()
```

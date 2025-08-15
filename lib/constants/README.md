# App Colors - Hướng dẫn sử dụng

## Tổng quan
File `app_colors.dart` định nghĩa tất cả các màu sắc được sử dụng trong ứng dụng The Happiness Journey. Việc tập trung tất cả màu sắc vào một file giúp:

- Dễ dàng thay đổi theme màu sắc
- Đảm bảo tính nhất quán trong toàn bộ ứng dụng
- Hỗ trợ dark mode và light mode
- Tăng khả năng bảo trì code

## Cách sử dụng

### Import
```dart
import '../constants/app_colors.dart';
```

### Sử dụng màu cơ bản
```dart
// Màu chính
Color primaryColor = AppColors.primary;
Color secondaryColor = AppColors.secondary;

// Màu trạng thái
Color successColor = AppColors.success;
Color errorColor = AppColors.error;
Color warningColor = AppColors.warning;
Color infoColor = AppColors.info;

// Màu trung tính
Color whiteColor = AppColors.white;
Color blackColor = AppColors.black;
```

### Sử dụng màu với độ trong suốt
```dart
// Màu chính với độ trong suốt khác nhau
Color primary10 = AppColors.primaryWithOpacity10;  // 10% opacity
Color primary40 = AppColors.primaryWithOpacity40;  // 40% opacity
Color primary70 = AppColors.primaryWithOpacity70;  // 70% opacity

// Màu đen với độ trong suốt
Color black10 = AppColors.blackWithOpacity10;      // 10% opacity
Color black50 = AppColors.blackWithOpacity50;      // 50% opacity
```

### Sử dụng màu text
```dart
Text(
  'Tiêu đề chính',
  style: TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
);

Text(
  'Mô tả phụ',
  style: TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  ),
);
```

### Sử dụng màu background
```dart
Container(
  color: AppColors.background,
  child: Container(
    color: AppColors.surface,
    child: Text('Nội dung'),
  ),
);
```

### Sử dụng màu border
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: AppColors.border,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Container có viền'),
);
```

### Sử dụng gradient
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
  child: Text(
    'Text với gradient background',
    style: TextStyle(color: AppColors.white),
  ),
);
```

## Cấu trúc màu sắc

### Primary Colors (Màu chính)
- `primary`: Màu chính của ứng dụng (#4CAF50)
- `primaryLight`: Màu chính nhạt hơn (#E8F5E8)
- `primaryLighter`: Màu chính nhạt nhất (#F0F8F0)

### Secondary Colors (Màu phụ)
- `secondary`: Màu phụ (#2196F3)
- `secondaryLight`: Màu phụ nhạt (#E3F2FD)

### Status Colors (Màu trạng thái)
- `success`: Màu thành công (#4CAF50)
- `error`: Màu lỗi (#F44336)
- `warning`: Màu cảnh báo (#FF9800)
- `info`: Màu thông tin (#2196F3)

### Text Colors (Màu chữ)
- `textPrimary`: Màu chữ chính (#212121)
- `textSecondary`: Màu chữ phụ (#757575)
- `textDisabled`: Màu chữ bị vô hiệu hóa (#BDBDBD)
- `textOnPrimary`: Màu chữ trên nền chính (trắng)
- `textOnSecondary`: Màu chữ trên nền phụ (trắng)

### Background Colors (Màu nền)
- `background`: Màu nền chính (#FAFAFA)
- `surface`: Màu nền bề mặt (trắng)
- `surfaceVariant`: Màu nền bề mặt biến thể (#F5F5F5)

### Border Colors (Màu viền)
- `border`: Màu viền chính (#E0E0E0)
- `borderLight`: Màu viền nhạt (#F0F0F0)
- `borderDark`: Màu viền đậm (#BDBDBD)

### Grey Scale (Thang màu xám)
- `grey50` đến `grey900`: Các mức độ xám từ nhạt đến đậm

## Migration Guide (Hướng dẫn chuyển đổi)

### Thay thế màu cũ
```dart
// Cũ
Color(0xFF4CAF50)
Colors.black.withOpacity(0.1)
Colors.grey[100]

// Mới
AppColors.primary
AppColors.blackWithOpacity10
AppColors.grey100
```

### Thay thế Colors.white/black
```dart
// Cũ
Colors.white
Colors.black

// Mới
AppColors.white
AppColors.black
```

### Thay thế màu text
```dart
// Cũ
Colors.black87
Colors.grey[600]

// Mới
AppColors.textPrimary
AppColors.textSecondary
```

## Best Practices (Thực hành tốt nhất)

1. **Luôn sử dụng AppColors thay vì hardcode màu**
2. **Sử dụng màu có ý nghĩa ngữ nghĩa** (success, error, warning)
3. **Sử dụng opacity variants** thay vì tạo màu mới
4. **Test trên cả light mode và dark mode**
5. **Đảm bảo contrast ratio** đủ để dễ đọc

## Dark Mode Support

Các màu cho dark mode đã được định nghĩa sẵn:
- `darkBackground`
- `darkSurface`
- `darkTextPrimary`
- `darkTextSecondary`
- `darkBorder`

## Accessibility (Tiếp cận)

Các màu hỗ trợ accessibility:
- `highContrast`: Màu có độ tương phản cao
- `lowContrast`: Màu có độ tương phản thấp
- `focusRing`: Màu viền focus cho accessibility 
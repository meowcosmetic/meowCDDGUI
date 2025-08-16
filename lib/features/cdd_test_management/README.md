# CDD Test Management Feature

Tính năng quản lý bài test CDD (Child Developmental Disorder) cho phép tạo và quản lý các bài test đánh giá phát triển trẻ em.

## Cấu trúc thư mục

```
lib/features/cdd_test_management/
├── models/
│   └── cdd_test.dart          # Data models cho CDD Test
├── views/
│   └── create_test_view.dart  # UI để tạo bài test mới
├── index.dart                 # Export các thành phần chính
└── README.md                  # Tài liệu này
```

## Các thành phần chính

### Models
- **CDDTest**: Model chính cho bài test
- **CDDQuestion**: Model cho câu hỏi trong bài test
- **CDDScoringCriteria**: Model cho tiêu chí chấm điểm
- **CDDScoreRange**: Model cho khoảng điểm

### Views
- **CreateTestView**: Form tạo bài test mới với:
  - Thông tin cơ bản (tên, mô tả, hướng dẫn)
  - Cấu hình bài test (độ tuổi, trạng thái, thời gian)
  - Vật liệu cần thiết
  - Danh sách câu hỏi (thêm/xóa/sửa)
  - Tiêu chí chấm điểm

## Cách sử dụng

### Import feature
```dart
import 'package:your_app/features/cdd_test_management/index.dart';
```

### Sử dụng CreateTestView
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CreateTestView()),
);
```

### Tạo CDDTest object
```dart
final test = CDDTest(
  assessmentCode: 'TEST_001',
  names: {'vi': 'Tên bài test', 'en': 'Test Name'},
  // ... các thuộc tính khác
);
```

## Tính năng

- ✅ Tạo bài test mới với form đầy đủ
- ✅ Thêm/xóa câu hỏi với dialog
- ✅ ID câu hỏi tự động generate
- ✅ Hỗ trợ đa ngôn ngữ (VI/EN)
- ✅ Validation form
- ✅ Gửi dữ liệu lên API
- ✅ Hiển thị thông báo thành công/lỗi

## API Integration

Feature này tích hợp với API thông qua `ApiService.createTest()` để gửi dữ liệu bài test lên server.

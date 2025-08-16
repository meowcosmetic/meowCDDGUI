# Child Management Feature

Tính năng quản lý trẻ em cho phép xem chi tiết thông tin trẻ, theo dõi tình trạng phát triển và xem lịch sử tracking.

## Cấu trúc thư mục

```
lib/features/child_management/
├── models/
│   └── child_tracking.dart          # Data models cho child tracking
├── views/
│   ├── child_detail_view.dart       # Chi tiết thông tin trẻ
│   ├── child_tracking_view.dart     # Form tracking tình trạng hàng ngày
│   └── child_tracking_history_view.dart # Lịch sử tracking
├── index.dart                       # Export các thành phần chính
└── README.md                        # Tài liệu này
```

## Các thành phần chính

### Models
- **ChildTracking**: Model chính cho dữ liệu tracking
- **TrackingQuestion**: Model cho câu hỏi tracking
- **TrackingCategory**: Model cho danh mục tracking
- **TrackingData**: Model cho dữ liệu tracking

### Views
- **ChildDetailView**: Hiển thị chi tiết thông tin trẻ với:
  - Thông tin cơ bản
  - Tiến độ phát triển
  - Nút tracking tình trạng
  - Nút xem lịch sử tracking

- **ChildTrackingView**: Form tracking tình trạng hàng ngày với:
  - Bảng câu hỏi chấm điểm (0-2 điểm)
  - 5 danh mục: Giao tiếp, Tương tác xã hội, Hành vi & cảm xúc, Kỹ năng nhận thức, Tự lập
  - Tính điểm trung bình và tổng điểm

- **ChildTrackingHistoryView**: Hiển thị lịch sử tracking với:
  - Danh sách các lần tracking
  - Biểu đồ tiến độ
  - Chi tiết từng lần tracking

## Cách sử dụng

### Import feature
```dart
import 'package:your_app/features/child_management/index.dart';
```

### Sử dụng ChildDetailView
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChildDetailView(child: childObject),
  ),
);
```

### Sử dụng ChildTrackingView
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChildTrackingView(child: childObject),
  ),
);
```

### Sử dụng ChildTrackingHistoryView
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChildTrackingHistoryView(child: childObject),
  ),
);
```

## Tính năng

- ✅ Xem chi tiết thông tin trẻ
- ✅ Tracking tình trạng phát triển hàng ngày
- ✅ Bảng câu hỏi chấm điểm 5 danh mục
- ✅ Tính điểm trung bình và tổng điểm
- ✅ Xem lịch sử tracking
- ✅ Biểu đồ tiến độ phát triển
- ✅ Lưu trữ dữ liệu local

## Danh mục tracking

1. **Giao tiếp (0-2 điểm)**
   - Trẻ có chủ động nói hoặc ra hiệu để giao tiếp không?
   - Trẻ có trả lời khi được gọi tên hoặc hỏi không?

2. **Tương tác xã hội (0-2 điểm)**
   - Trẻ có nhìn vào mắt khi giao tiếp không?
   - Trẻ có chủ động tham gia chơi cùng người khác không?

3. **Hành vi & cảm xúc (0-2 điểm)**
   - Trẻ có hành vi lặp lại hoặc khó kiểm soát không?
   - Trẻ có dễ nổi nóng hoặc lo âu quá mức không?

4. **Kỹ năng nhận thức (0-2 điểm)**
   - Trẻ có hoàn thành nhiệm vụ đơn giản không?
   - Trẻ có hiểu và làm theo hướng dẫn đơn giản không?

5. **Tự lập (0-2 điểm)**
   - Trẻ có tự ăn, uống hoặc mặc quần áo không?
   - Trẻ có tự dọn dẹp hoặc cất đồ sau khi chơi không?

## Lưu trữ dữ liệu

Dữ liệu tracking được lưu trữ local bằng SharedPreferences để theo dõi tiến độ phát triển của trẻ theo thời gian.

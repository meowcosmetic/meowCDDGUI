# Hệ Thống Tracking Tình Trạng Trẻ

## Tổng quan

Hệ thống tracking tình trạng trẻ là một tính năng quan trọng giúp theo dõi và đánh giá tiến độ phát triển của trẻ theo thời gian thông qua bảng câu hỏi chấm điểm hằng ngày.

## Các thành phần chính

### 1. Models

#### `ChildTracking` (`lib/models/child_tracking.dart`)
- Lưu trữ dữ liệu tracking của một lần đánh giá
- Bao gồm: ID, childId, ngày tracking, điểm số, ghi chú, điểm tổng

#### `TrackingQuestion` 
- Định nghĩa một câu hỏi trong bảng tracking
- Bao gồm: ID, danh mục, câu hỏi, các lựa chọn, điểm số tương ứng

#### `TrackingCategory`
- Nhóm các câu hỏi theo lĩnh vực
- Bao gồm: tên danh mục, danh sách câu hỏi, điểm tối đa

#### `TrackingData`
- Chứa tất cả dữ liệu câu hỏi tracking được định nghĩa sẵn
- 5 danh mục chính với 10 câu hỏi tổng cộng

### 2. Views

#### `ChildTrackingView` (`lib/view/child_tracking_view.dart`)
- Giao diện chính để thực hiện tracking
- Hiển thị bảng câu hỏi theo từng danh mục
- Cho phép chọn đáp án và nhập ghi chú
- Tính toán và hiển thị điểm số tổng kết

#### `ChildTrackingHistoryView` (`lib/view/child_tracking_history_view.dart`)
- Hiển thị lịch sử tracking của trẻ
- Tổng quan điểm số và xu hướng
- Chi tiết từng lần tracking

## Cấu trúc bảng câu hỏi

### 1. Giao tiếp (0-2 điểm)
- **Câu 1**: Hôm nay trẻ có chủ động nói hoặc ra hiệu để giao tiếp không?
  - 0 = Không
  - 1 = Chỉ khi được nhắc  
  - 2 = Chủ động

- **Câu 2**: Trẻ có trả lời khi được gọi tên hoặc hỏi không?
  - 0 = Không
  - 1 = Đôi khi
  - 2 = Thường xuyên

### 2. Tương tác xã hội (0-2 điểm)
- **Câu 1**: Trẻ có nhìn vào mắt khi giao tiếp không?
  - 0 = Không
  - 1 = Thỉnh thoảng
  - 2 = Tự nhiên

- **Câu 2**: Trẻ có chủ động tham gia chơi cùng người khác không?
  - 0 = Không
  - 1 = Khi được mời
  - 2 = Chủ động

### 3. Hành vi & cảm xúc (0-2 điểm)
- **Câu 1**: Hôm nay trẻ có hành vi lặp lại hoặc khó kiểm soát không?
  - 0 = Nhiều
  - 1 = Thỉnh thoảng
  - 2 = Không đáng kể

- **Câu 2**: Trẻ có dễ nổi nóng hoặc lo âu quá mức không?
  - 0 = Rất thường
  - 1 = Thỉnh thoảng
  - 2 = Hầu như không

### 4. Kỹ năng nhận thức (0-2 điểm)
- **Câu 1**: Trẻ có hoàn thành nhiệm vụ đơn giản (xếp hình, ghép tranh) không?
  - 0 = Không
  - 1 = Có hỗ trợ
  - 2 = Tự làm

- **Câu 2**: Trẻ có hiểu và làm theo hướng dẫn đơn giản không?
  - 0 = Không
  - 1 = Đôi khi
  - 2 = Thường xuyên

### 5. Tự lập (0-2 điểm)
- **Câu 1**: Trẻ có tự ăn, uống hoặc mặc quần áo không?
  - 0 = Không
  - 1 = Có hỗ trợ
  - 2 = Tự làm

- **Câu 2**: Trẻ có tự dọn dẹp hoặc cất đồ sau khi chơi không?
  - 0 = Không
  - 1 = Khi được nhắc
  - 2 = Tự giác

## Cách tính điểm

### Điểm danh mục
- Trung bình của các câu hỏi trong danh mục
- Ví dụ: Giao tiếp có 2 câu, tổng điểm 3 → điểm danh mục = 1.5/2.0

### Điểm tổng
- Trung bình của tất cả 5 danh mục
- Thang điểm: 0.0 - 2.0

### Màu sắc đánh giá
- **Xanh lá (1.5-2.0)**: Tốt
- **Vàng (1.0-1.4)**: Trung bình  
- **Đỏ (0.0-0.9)**: Cần cải thiện

## Cách sử dụng

### 1. Truy cập tracking
- Vào trang chi tiết trẻ
- Nhấn nút "Bắt đầu tracking" trong phần "Tracking Tình Trạng"

### 2. Thực hiện tracking
- Đọc và trả lời từng câu hỏi theo 5 danh mục
- Chọn đáp án phù hợp nhất với tình trạng trẻ hôm nay
- Nhập ghi chú bổ sung (tùy chọn)
- Xem tổng kết điểm số

### 3. Lưu kết quả
- Nhấn "Lưu kết quả tracking"
- Hệ thống sẽ lưu dữ liệu và quay về trang chi tiết

### 4. Xem lịch sử
- Nhấn nút "Xem lịch sử" để xem các lần tracking trước
- Theo dõi xu hướng tiến độ của trẻ

## Tính năng nâng cao (TODO)

### 1. Lưu trữ dữ liệu
- Tích hợp với database để lưu trữ lâu dài
- API endpoints cho CRUD operations

### 2. Báo cáo và phân tích
- Biểu đồ xu hướng theo thời gian
- So sánh giữa các giai đoạn
- Xuất báo cáo PDF

### 3. Nhắc nhở
- Lịch tracking định kỳ
- Thông báo khi quên tracking

### 4. Chia sẻ
- Gửi báo cáo cho phụ huynh
- Chia sẻ với chuyên gia điều trị

## Cấu trúc file

```
lib/
├── models/
│   └── child_tracking.dart          # Models cho tracking system
├── view/
│   ├── child_tracking_view.dart     # Giao diện tracking
│   └── child_tracking_history_view.dart  # Giao diện lịch sử
└── view/child_detail_view.dart      # Tích hợp nút tracking
```

## Lưu ý phát triển

1. **Validation**: Đảm bảo tất cả câu hỏi đều được trả lời trước khi lưu
2. **Performance**: Tối ưu hóa việc load dữ liệu lịch sử lớn
3. **UX**: Giao diện thân thiện, dễ sử dụng cho người dùng
4. **Data integrity**: Backup và đồng bộ dữ liệu tracking
5. **Privacy**: Bảo mật thông tin tracking của trẻ

# Hệ Thống Bài Test Phân Biệt Theo Độ Tuổi Và Chứng Bệnh

## Tổng Quan

Hệ thống bài test được thiết kế để đánh giá khả năng của trẻ em dựa trên độ tuổi và chứng bệnh cụ thể. Hệ thống này cung cấp các bài test chuyên biệt cho từng nhóm đối tượng.

## Tính Năng Chính

### 1. Phân Loại Theo Độ Tuổi
- **2-6 tuổi**: Bài test cơ bản cho trẻ mầm non
- **3-8 tuổi**: Bài test trung bình cho trẻ tiểu học
- **4-7 tuổi**: Bài test vận động tinh
- **6-12 tuổi**: Bài test nâng cao cho trẻ lớn hơn

### 2. Phân Loại Theo Chứng Bệnh
- **Tự kỷ (Autism)**: Bài test giao tiếp, tương tác xã hội
- **Tăng động giảm chú ý (ADHD)**: Bài test tập trung, cảm xúc
- **Hội chứng Down**: Bài test phù hợp với khả năng đặc biệt
- **Khuyết tật học tập**: Bài test nhận thức nâng cao
- **Chậm nói**: Bài test giao tiếp cơ bản
- **Chậm vận động**: Bài test vận động tinh

### 3. Phân Loại Theo Lĩnh Vực
- **Giao tiếp**: Đánh giá khả năng ngôn ngữ và tương tác
- **Vận động**: Đánh giá kỹ năng vận động thô và tinh
- **Nhận thức**: Đánh giá tư duy logic và học tập
- **Xã hội**: Đánh giá kỹ năng tương tác với người khác
- **Cảm xúc**: Đánh giá khả năng nhận diện và thể hiện cảm xúc

### 4. Phân Loại Theo Độ Khó
- **Cơ bản**: Dành cho trẻ mới bắt đầu
- **Trung bình**: Dành cho trẻ có khả năng trung bình
- **Nâng cao**: Dành cho trẻ có khả năng tốt

## Cấu Trúc Dữ Liệu

### Test Model
```dart
class Test {
  final String id;
  final String title;
  final String description;
  final List<TestQuestion> questions;
  final String targetAge;
  final List<String> conditions;
  final String category;
  final String difficulty;
  final int estimatedTime;
  final int totalQuestions;
  final int passingScore;
  // ...
}
```

### TestQuestion Model
```dart
class TestQuestion {
  final String id;
  final String questionText;
  final List<TestAnswer> answers;
  final String category;
  final String difficulty;
  final String? imageUrl;
  final String? audioUrl;
  final int timeLimit;
  final String? explanation;
  // ...
}
```

### TestResult Model
```dart
class TestResult {
  final String id;
  final String testId;
  final String userId;
  final String userName;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final int timeSpent;
  final DateTime completedAt;
  final List<QuestionResult> questionResults;
  // ...
}
```

## Cách Sử Dụng

### 1. Lọc Bài Test
- Sử dụng bộ lọc theo độ tuổi, chứng bệnh, lĩnh vực, độ khó
- Tìm kiếm theo từ khóa
- Xem chi tiết bài test trước khi làm

### 2. Làm Bài Test
- Chọn câu trả lời cho từng câu hỏi
- Có thể quay lại câu trước để sửa
- Theo dõi tiến độ qua thanh progress
- Hoàn thành bài test để xem kết quả

### 3. Xem Kết Quả
- Hiển thị điểm số và phần trăm đúng
- Phân tích chi tiết: đúng, sai, bỏ qua
- Thời gian hoàn thành
- Đánh giá mức độ (Xuất sắc, Tốt, Khá, Trung bình, Cần cải thiện)

## Các File Chính

### Models
- `lib/models/test_models.dart`: Định nghĩa các model cho test system

### Views
- `lib/view/test_view.dart`: Màn hình danh sách bài test với bộ lọc
- `lib/view/test_taking_page.dart`: Màn hình làm bài test và hiển thị kết quả

### Navigation
- `lib/navigation/app_navigation.dart`: Thêm "Bài Test" vào navigation

## Dữ Liệu Mẫu

Hệ thống bao gồm 5 bài test mẫu:

1. **Test Giao Tiếp Cơ Bản (2-6 tuổi)**
   - Dành cho trẻ tự kỷ và chậm nói
   - 10 câu hỏi, 15 phút
   - Điểm đạt: 70%

2. **Test Vận Động Tinh (4-7 tuổi)**
   - Dành cho trẻ tự kỷ và chậm vận động
   - 12 câu hỏi, 20 phút
   - Điểm đạt: 75%

3. **Test Nhận Thức Nâng Cao (6-12 tuổi)**
   - Dành cho trẻ tự kỷ có khả năng học tập tốt
   - 15 câu hỏi, 30 phút
   - Điểm đạt: 80%

4. **Test Tương Tác Xã Hội (3-8 tuổi)**
   - Dành cho trẻ tự kỷ
   - 12 câu hỏi, 25 phút
   - Điểm đạt: 70%

5. **Test Cảm Xúc (2-6 tuổi)**
   - Dành cho trẻ tự kỷ và ADHD
   - 8 câu hỏi, 15 phút
   - Điểm đạt: 65%

## Tính Năng Nâng Cao

### 1. Hỗ Trợ Đa Phương Tiện
- Hình ảnh minh họa cho câu hỏi
- Âm thanh hỗ trợ
- Video hướng dẫn

### 2. Theo Dõi Tiến Độ
- Lưu lịch sử làm bài test
- So sánh kết quả theo thời gian
- Phân tích xu hướng phát triển

### 3. Tùy Chỉnh
- Tạo bài test mới
- Chỉnh sửa câu hỏi
- Điều chỉnh điểm đạt

## Hướng Dẫn Phát Triển

### Thêm Bài Test Mới
1. Tạo câu hỏi trong `SampleTests._getXXXQuestions()`
2. Thêm bài test vào `SampleTests.getSampleTests()`
3. Cập nhật bộ lọc nếu cần

### Tùy Chỉnh Giao Diện
1. Chỉnh sửa `test_view.dart` cho màn hình danh sách
2. Chỉnh sửa `test_taking_page.dart` cho màn hình làm bài
3. Cập nhật màu sắc và style trong `app_colors.dart`

### Tích Hợp Backend
1. Thay thế `SampleTests.getSampleTests()` bằng API call
2. Lưu kết quả test vào database
3. Thêm authentication cho user

## Lưu Ý

- Hệ thống hiện tại sử dụng dữ liệu mẫu
- Cần tích hợp với backend để lưu trữ dữ liệu thực
- Có thể mở rộng thêm các loại câu hỏi khác
- Nên thêm tính năng xuất báo cáo kết quả

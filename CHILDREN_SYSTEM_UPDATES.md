# Cập Nhật Hệ Thống Quản Lý Trẻ

## Tổng Quan

Đã thực hiện các cập nhật quan trọng cho hệ thống quản lý trẻ theo yêu cầu:

1. **Thay đổi navigation**: Khi bấm vào trẻ trong danh sách, sẽ navigate đến trang chi tiết thay vì hiện popup
2. **Cập nhật form thêm trẻ**: Sử dụng dữ liệu mới và gửi API đến `http://localhost:8101/api/v1/children`

## Các Thay Đổi Chi Tiết

### 1. Navigation Mới

#### File: `lib/view/child_detail_view.dart` (Mới)
- Tạo trang chi tiết trẻ mới với giao diện đẹp và đầy đủ thông tin
- Hiển thị thông tin cơ bản, chẩn đoán, phụ huynh, tiến độ, hoạt động, ghi chú
- Có nút edit để sửa thông tin (đang phát triển)

#### File: `lib/view/children_list_view.dart`
- Thay đổi `_showChildDetails()` từ `showModalBottomSheet` thành `Navigator.push`
- Thêm import cho `ChildDetailView`
- Xóa các class cũ không còn sử dụng (`_AddChildSheet`, `_ChildDetailsSheet`)

### 2. Form Thêm Trẻ Mới

#### File: `lib/view/children/add_child_sheet.dart`
- **Cập nhật hoàn toàn** với các trường mới theo yêu cầu:
  - `externalId`: ID bên ngoài (tự động tạo)
  - `fullName`: Họ và tên đầy đủ
  - `gender`: Giới tính (MALE/FEMALE/OTHER)
  - `dateOfBirth`: Ngày sinh (YYYY-MM-DD)
  - `height`: Chiều cao (cm)
  - `weight`: Cân nặng (kg)
  - `bloodType`: Nhóm máu
  - `allergies`: Dị ứng
  - `medicalHistory`: Tiền sử bệnh lý
  - `specialMedicalConditions`: Tình trạng y tế đặc biệt
  - `isPremature`: Sinh non (checkbox)
  - `primaryLanguage`: Ngôn ngữ chính
  - `developmentalDisorderDiagnosis`: Chẩn đoán rối loạn phát triển
  - `hasEarlyIntervention`: Có can thiệp sớm (checkbox)
  - `familyDevelopmentalIssues`: Vấn đề phát triển gia đình

- **Thêm API call**:
  - Gửi POST request đến `http://localhost:8101/api/v1/children`
  - Xử lý loading state và error handling
  - Hiển thị thông báo thành công/thất bại

#### File: `lib/view/children_list_view.dart`
- Cập nhật xử lý khi thêm trẻ mới:
  - Tính tuổi từ ngày sinh
  - Chuyển đổi gender từ API format sang hiển thị
  - Tạo notes với thông tin từ API
  - Đặt các trường chưa có dữ liệu thành "Chưa cập nhật"

## Cấu Trúc Dữ Liệu API

### Request Body
```json
{
  "externalId": "CHILD_008",
  "fullName": "Vũ Thị Hương",
  "gender": "FEMALE",
  "dateOfBirth": "2020-06-18",
  "height": 103.5,
  "weight": 17.0,
  "bloodType": "A+",
  "allergies": "Trứng, sữa",
  "medicalHistory": "Tiền sử viêm phổi nhẹ",
  "specialMedicalConditions": "Dị ứng thực phẩm - cần theo dõi chặt chẽ",
  "isPremature": false,
  "primaryLanguage": "Vietnamese",
  "developmentalDisorderDiagnosis": "NO",
  "hasEarlyIntervention": false,
  "familyDevelopmentalIssues": "NO"
}
```

### API Endpoint
- **URL**: `http://localhost:8101/api/v1/children`
- **Method**: POST
- **Headers**: 
  - `Content-Type: application/json`
  - `Accept: application/json`

## Tính Năng Mới

### 1. Trang Chi Tiết Trẻ
- Giao diện đẹp với cards riêng biệt cho từng loại thông tin
- Hiển thị tiến độ chi tiết với progress bars
- Danh sách hoạt động can thiệp
- Lịch sử hoạt động gần đây
- Ghi chú và thông tin bổ sung

### 2. Form Thêm Trẻ Nâng Cao
- Validation đầy đủ cho tất cả trường
- Dropdown cho các trường có giá trị cố định
- Checkbox cho các trường boolean
- Loading state khi gửi API
- Error handling và thông báo

### 3. Navigation Cải Tiến
- Thay vì popup, sử dụng full-page navigation
- Có thể quay lại danh sách bằng nút back
- Trải nghiệm người dùng tốt hơn

## Dependencies

Đã sử dụng các dependencies có sẵn:
- `http: ^1.2.1` - Cho API calls
- `flutter` - UI framework

## Hướng Dẫn Sử Dụng

### 1. Xem Chi Tiết Trẻ
1. Vào danh sách trẻ
2. Bấm vào card của trẻ bất kỳ
3. Sẽ navigate đến trang chi tiết với đầy đủ thông tin

### 2. Thêm Trẻ Mới
1. Bấm nút "Thêm Trẻ" (FAB)
2. Điền thông tin vào form mới
3. Bấm "Thêm Trẻ" để gửi API
4. Trẻ sẽ được thêm vào danh sách nếu thành công

## Lưu Ý

- API server cần chạy tại `http://localhost:8101`
- Các trường phụ huynh, địa chỉ, trường học sẽ hiển thị "Chưa cập nhật" cho trẻ mới thêm
- Tính năng edit trẻ đang được phát triển
- Form có validation đầy đủ để đảm bảo dữ liệu hợp lệ

## Tương Lai

- Thêm tính năng edit thông tin trẻ
- Tích hợp với API để lấy danh sách trẻ từ server
- Thêm tính năng upload ảnh
- Cải thiện UI/UX dựa trên feedback

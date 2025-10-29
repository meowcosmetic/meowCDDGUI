# Hướng Dẫn Quản Lý Cộng Tác Viên

## Tổng Quan
Trang quản lý cộng tác viên đã được cập nhật với đầy đủ các tính năng CRUD (Create, Read, Update, Delete) và tìm kiếm nâng cao.

## Các Tính Năng Mới

### 1. Tìm Kiếm Cộng Tác Viên
- **Tìm kiếm theo từ khóa**: Tìm kiếm theo chuyên môn, tổ chức, vai trò, ghi chú
- **Tìm kiếm API**: Sử dụng API endpoint `/neon/collaborators/search`
- **Tìm kiếm local**: Lọc dữ liệu đã tải về

### 2. Quản Lý Cộng Tác Viên
- **Thêm mới**: Nút "+" trên AppBar để thêm cộng tác viên mới
- **Sửa**: Nút "Sửa" trên mỗi card cộng tác viên
- **Xóa**: Nút "Xóa" với xác nhận trước khi xóa
- **Xem chi tiết**: Hiển thị đầy đủ thông tin cộng tác viên

### 3. Lọc Dữ Liệu
- **Lọc theo trạng thái**: Hoạt động, Chờ duyệt, Không hoạt động
- **Quick filters**: Các nút lọc nhanh ở đầu trang
- **Advanced filters**: Modal bottom sheet với các tùy chọn lọc chi tiết

### 4. Phân Trang
- **Load more**: Tải thêm dữ liệu khi cuộn xuống cuối danh sách
- **Pagination**: Hỗ trợ phân trang với API

## API Endpoints Được Sử Dụng

### 1. Lấy Danh Sách Cộng Tác Viên
```
GET /neon/collaborators?page=0&size=10&sortBy=createdAt&sortDir=desc
```

### 2. Tìm Kiếm Cộng Tác Viên
```
GET /neon/collaborators/search?keyword=psychology&page=0&size=10
```

### 3. Lấy Chi Tiết Cộng Tác Viên
```
GET /neon/collaborators/{collaboratorId}
```

### 4. Tạo Cộng Tác Viên Mới
```
POST /neon/collaborators
Content-Type: application/json

{
  "userId": "{{userId}}",
  "roleId": "{{roleId}}",
  "specialization": "Child Psychology",
  "experienceYears": 3,
  "certification": {
    "vi": "Chứng chỉ hành nghề tâm lý học số 12345",
    "en": "Psychology Practice License #12345"
  },
  "organization": "ABC Therapy Center",
  "availability": {
    "vi": "Thứ 2-6: 8h-17h, Thứ 7: 8h-12h",
    "en": "Mon-Fri: 8AM-5PM, Sat: 8AM-12PM"
  },
  "status": "PENDING",
  "notes": {
    "vi": "Chuyên về điều trị tự kỷ và ADHD",
    "en": "Specializes in autism and ADHD treatment"
  }
}
```

### 5. Cập Nhật Cộng Tác Viên
```
PUT /neon/collaborators/{collaboratorId}
Content-Type: application/json

{
  "specialization": "Advanced Child Psychology",
  "experienceYears": 5,
  "status": "ACTIVE",
  "organization": "XYZ Advanced Therapy Center"
}
```

### 6. Xóa Cộng Tác Viên
```
DELETE /neon/collaborators/{collaboratorId}
```

### 7. Lấy Cộng Tác Viên Theo User ID
```
GET /neon/collaborators/user/{userId}
```

### 8. Lấy Cộng Tác Viên Theo Role ID
```
GET /neon/collaborators/role/{roleId}
```

### 9. Lấy Cộng Tác Viên Theo Status
```
GET /neon/collaborators/status/{status}
```

## Cấu Trúc Dữ Liệu

### CollaboratorDetail
```dart
{
  "collaboratorId": "UUID",
  "userId": "UUID", 
  "roleId": "UUID",
  "roleName": "string",
  "specialization": "string",
  "experienceYears": "integer",
  "certification": {
    "vi": "string",
    "en": "string"
  },
  "organization": "string",
  "availability": {
    "vi": "string", 
    "en": "string"
  },
  "status": "ACTIVE|INACTIVE|PENDING",
  "notes": {
    "vi": "string",
    "en": "string"
  },
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

## Các File Đã Được Tạo/Cập Nhật

### 1. `lib/services/collaborator_service.dart`
- Service xử lý tất cả API calls
- Hỗ trợ tất cả CRUD operations
- Error handling và response parsing

### 2. `lib/view/collaborator_form_dialog.dart`
- Dialog form để thêm/sửa cộng tác viên
- Validation form đầy đủ
- Hỗ trợ đa ngôn ngữ (Vi/En)

### 3. `lib/models/collaborator_models.dart`
- Cập nhật model để phù hợp với API mới
- Thêm các class: `CollaboratorDetail`, `CreateCollaboratorRequest`, `UpdateCollaboratorRequest`
- Hỗ trợ đa ngôn ngữ với các class: `Certification`, `Availability`, `Notes`

### 4. `lib/view/collaborator_search_view.dart`
- Cập nhật UI để hiển thị dữ liệu mới
- Thêm các tính năng CRUD
- Cải thiện UX với loading states và error handling

## Hướng Dẫn Sử Dụng

### 1. Thêm Cộng Tác Viên Mới
1. Nhấn nút "+" trên AppBar
2. Điền đầy đủ thông tin trong form
3. Nhấn "Thêm" để lưu

### 2. Sửa Cộng Tác Viên
1. Nhấn nút "Sửa" trên card cộng tác viên
2. Chỉnh sửa thông tin cần thiết
3. Nhấn "Cập nhật" để lưu

### 3. Xóa Cộng Tác Viên
1. Nhấn nút "Xóa" trên card cộng tác viên
2. Xác nhận trong dialog
3. Cộng tác viên sẽ bị xóa

### 4. Tìm Kiếm
1. Nhập từ khóa vào ô tìm kiếm
2. Nhấn nút tìm kiếm hoặc để tự động lọc
3. Sử dụng quick filters để lọc nhanh

### 5. Lọc Dữ Liệu
1. Sử dụng quick filters ở đầu trang
2. Hoặc nhấn nút "tune" để mở advanced filters
3. Chọn các tiêu chí lọc và nhấn "Áp dụng"

## Lưu Ý Kỹ Thuật

1. **API Base URL**: Cần cập nhật `baseUrl` trong `CollaboratorService` để phù hợp với server thực tế
2. **Error Handling**: Tất cả API calls đều có error handling
3. **Loading States**: UI hiển thị loading indicator khi đang tải dữ liệu
4. **Validation**: Form validation đầy đủ cho tất cả trường bắt buộc
5. **Responsive**: UI responsive trên các kích thước màn hình khác nhau

## Tương Lai

- [ ] Thêm tính năng export dữ liệu
- [ ] Thêm tính năng import từ file Excel/CSV
- [ ] Thêm tính năng bulk actions (xóa nhiều, cập nhật nhiều)
- [ ] Thêm tính năng thống kê và báo cáo
- [ ] Thêm tính năng gửi email thông báo


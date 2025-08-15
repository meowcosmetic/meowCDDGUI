# Hệ Thống Authentication - The Happiness Journey

## Tổng Quan

Đã cải thiện hệ thống authentication với các tính năng mới:

### 1. Màn Hình Đăng Ký (RegisterView)

**Cải tiến:**
- ✅ Nút "Tạo tài khoản" bị **disable mặc định**
- ✅ Chỉ **enable** khi tất cả thông tin hợp lệ
- ✅ **Không validate ngay từ đầu** - chỉ validate khi user nhập liệu
- ✅ **Navigate đến màn hình đăng nhập** sau khi đăng ký thành công
- ✅ Thêm link "Đăng nhập ngay" để chuyển sang màn hình đăng nhập

**Validation Rules:**
- Họ tên: Không được để trống
- Email: Phải có định dạng email hợp lệ (@)
- Mật khẩu: Tối thiểu 6 ký tự
- Số điện thoại: Không được để trống
- Năm sinh: Phải từ 1900 đến năm hiện tại

### 2. Màn Hình Đăng Nhập (LoginView) - MỚI

**Tính năng:**
- ✅ Form đăng nhập với email và mật khẩu
- ✅ Validation real-time
- ✅ Nút đăng nhập bị disable mặc định
- ✅ Chỉ enable khi form hợp lệ
- ✅ Lưu token vào SharedPreferences sau khi đăng nhập thành công
- ✅ Navigate đến MainAppView sau khi đăng nhập
- ✅ Link "Đăng ký ngay" để chuyển sang màn hình đăng ký

**UI/UX:**
- Giao diện đẹp với logo và tiêu đề
- Form fields với prefix icons
- Loading indicator khi đang đăng nhập
- Thông báo lỗi/thành công rõ ràng

### 3. Cải Tiến Navigation

**AuthGate:**
- ✅ Kiểm tra user token khi khởi động
- ✅ Tự động navigate đến MainAppView nếu đã đăng nhập
- ✅ Các nút đăng nhập/đăng ký navigate đến màn hình tương ứng

**Routes:**
- `/` - AuthGate (màn hình chính)
- `/login` - LoginView
- `/register` - RegisterView

### 4. API Service

**Thêm method mới:**
```dart
Future<http.Response> login({required String email, required String password})
```

**Endpoints:**
- `POST /auth/register` - Đăng ký tài khoản
- `POST /auth/login` - Đăng nhập

### 5. Flow Hoạt Động

1. **Khởi động app** → AuthGate
2. **Chưa đăng nhập** → Hiển thị màn hình chào mừng
3. **Chọn "Đăng ký"** → RegisterView
4. **Điền thông tin** → Nút "Tạo tài khoản" enable khi hợp lệ
5. **Đăng ký thành công** → Navigate đến LoginView
6. **Đăng nhập** → Navigate đến MainAppView
7. **Lần sau khởi động** → Tự động vào MainAppView (nếu đã đăng nhập)

### 6. Lưu Trữ Dữ Liệu

**SharedPreferences Keys:**
- `user_token` - Token đăng nhập
- `user_email` - Email đã đăng nhập
- `current_user` - Thông tin user (legacy)
- `guest_mode_enabled` - Chế độ khách
- `guest_policy_accepted` - Đã đồng ý chính sách

### 7. Debug Mode

- ✅ Nút "Điền dữ liệu mẫu" trong debug mode
- ✅ Sử dụng dummy data từ `dummy_users.dart`

## Cách Sử Dụng

### Để Test:

1. **Chạy app** → Màn hình chào mừng
2. **Nhấn "Đăng ký"** → Điền thông tin (nút sẽ enable khi hợp lệ)
3. **Nhấn "Tạo tài khoản"** → Chuyển đến màn hình đăng nhập
4. **Nhập email/mật khẩu** → Đăng nhập
5. **Thành công** → Vào màn hình chính

### Trong Debug Mode:

- Nhấn nút "auto_fix_high" để điền dữ liệu mẫu
- Dữ liệu mẫu từ `dummyDevUser` trong `dummy_users.dart`

## Files Đã Thay Đổi

1. `lib/view/register_view.dart` - Cải tiến validation và navigation
2. `lib/view/login_view.dart` - Tạo mới
3. `lib/view/auth_gate.dart` - Cập nhật navigation
4. `lib/models/api_service.dart` - Thêm method login
5. `lib/main.dart` - Thêm routes

## Lưu Ý

- Form validation được thực hiện real-time
- Nút submit bị disable mặc định và chỉ enable khi form hợp lệ
- Không có validation ngay từ đầu như yêu cầu
- Navigation flow mượt mà giữa các màn hình
- Tự động đăng nhập nếu đã có token

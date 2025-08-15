# Policy API Integration

## Tổng quan

Ứng dụng đã được tích hợp với Policy API để lấy nội dung chính sách và điều khoản sử dụng từ server. Hệ thống bao gồm:

- **Cache local**: Lưu trữ policy data trong SharedPreferences
- **Auto refresh**: Tự động cập nhật khi cache hết hạn (24 giờ)
- **Fallback**: Hiển thị nội dung mặc định nếu API không khả dụng
- **Error handling**: Xử lý lỗi mạng và hiển thị thông báo phù hợp

## Cấu trúc API

### 1. Get Policy Endpoint
```
GET http://localhost:8000/policy/get?serviceName=CDD&policyType=terms
```

### 2. Mark Policy as Read Endpoint
```
POST http://localhost:8000/policy/read/mark
```

**Request Body:**
```json
{
  "customerId": "6898206d72a4fe2d1d105e0e",
  "policyId": "689eb3c3e8c05f6c8a6044f1",
  "id": "6898206d72a4fe2d1d105e0e"
}
```

**Response:** HTTP 200 OK (success) hoặc error status

### Response Format
```json
{
  "policyId": "689eb3c3e8c05f6c8a6044f1",
  "serviceName": "CDD",
  "policyType": "terms",
  "titles": {
    "vi": "Chính sách & Điều khoản sử dụng - Ứng dụng hỗ trợ can thiệp rối loạn phát triển tại nhà",
    "en": "Policies & Terms of Use - Home Support App for Developmental Disorders"
  },
  "sections": [
    {
      "sectionId": "privacy",
      "order": 1,
      "titles": {
        "vi": "Chính sách bảo mật thông tin",
        "en": "Privacy Policy"
      },
      "contents": {
        "vi": "Bảo vệ dữ liệu: Tất cả thông tin cá nhân...",
        "en": "Data Protection: All personal information..."
      },
      "isRequired": true,
      "sectionType": "privacy"
    }
  ],
  "version": 1,
  "isActive": true,
  "tags": ["legal", "terms", "developmental-disorder"],
  "metadata": {
    "createdAt": "2025-08-15T04:12:51.224+00:00",
    "updatedAt": "2025-08-15T04:12:51.224+00:00",
    "createdBy": "admin_developmental_001",
    "updatedBy": "admin_developmental_001"
  }
}
```

## Các file đã tạo/cập nhật

### 1. Models
- `lib/models/policy_data.dart` - Model cho policy data
- `lib/models/policy_service.dart` - Service để gọi API và quản lý cache

### 2. Views
- `lib/view/policy_view.dart` - Cập nhật để sử dụng API data

## Cách hoạt động

### 1. Load Policy
```dart
// Tự động gọi khi màn hình policy được mở
final policy = await PolicyService.getPolicy();
```

### 2. Cache Management
- **Cache key**: `policy_cache_cdd_terms`
- **Cache time key**: `policy_cache_time_cdd_terms`
- **Expiry**: 24 giờ
- **Auto cleanup**: Tự động xóa cache hết hạn

### 3. Error Handling
- **Network error**: Hiển thị màn hình lỗi với nút "Thử lại"
- **API error**: Fallback về cached data hoặc nội dung mặc định
- **Cache error**: Gọi API trực tiếp

### 4. UI Features
- **Loading indicator**: Hiển thị khi đang tải data
- **Refresh button**: Nút làm mới trong AppBar
- **Error screen**: Màn hình lỗi với hướng dẫn
- **Version info**: Hiển thị phiên bản và ngày cập nhật

### 5. Policy Acceptance Tracking
- **Auto mark**: Tự động gửi request mark policy khi user đồng ý
- **Customer tracking**: Lưu và sử dụng customer ID cho tracking
- **Guest mode**: Không gửi mark request cho guest users
- **Error handling**: Xử lý lỗi khi gửi mark request

## Cấu hình

### 1. API Base URL
```dart
// Trong PolicyService
static const String _baseUrl = 'http://localhost:8000';
```

### 2. Cache Settings
```dart
static const Duration _cacheExpiry = Duration(hours: 24);
static const String _policyCacheKey = 'policy_cache_cdd_terms';
```

### 3. Language Support
```dart
String _language = 'vi'; // Default language
// Hỗ trợ: 'vi', 'en'
```

## Cách sử dụng

### 1. Chạy ứng dụng
```bash
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0
```

### 2. Truy cập Policy Screen
- Màn hình policy sẽ tự động load data từ API
- Nếu có cache, sẽ hiển thị ngay lập tức
- Nếu không có cache, sẽ gọi API và hiển thị loading

### 3. Refresh Policy
- Nhấn nút refresh trong AppBar để force update
- Hoặc đợi cache hết hạn để tự động update

## Troubleshooting

### 1. API không khả dụng
- Ứng dụng sẽ hiển thị nội dung mặc định
- Không ảnh hưởng đến chức năng khác

### 2. Cache lỗi
- Tự động clear cache và gọi API mới
- Fallback về nội dung mặc định

### 3. Network timeout
- Timeout 10 giây cho API call
- Hiển thị error screen với nút retry

## Development Notes

### 1. Testing
- Có thể test offline bằng cách tắt network
- Cache sẽ được sử dụng nếu có
- Fallback content sẽ hiển thị nếu không có cache

### 2. Debug
- Logs được in ra console cho các lỗi
- Có thể inspect cache trong DevTools

### 3. Performance
- Cache giảm số lượng API calls
- Lazy loading cho policy sections
- Optimized UI rendering

## Future Enhancements

1. **Multi-language support**: Thêm ngôn ngữ khác
2. **Offline mode**: Sync policy khi có network
3. **Version control**: So sánh version để update
4. **Analytics**: Track policy acceptance
5. **A/B testing**: Test different policy versions

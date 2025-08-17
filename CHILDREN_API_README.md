# Children API Integration - Tính năng thêm trẻ mới

## Tổng quan

Tính năng thêm trẻ đã được cập nhật để sử dụng format JSON mới và tự động thêm `parentId` từ user session. Parent ID sẽ không hiển thị trên màn hình và sẽ được tự động thêm vào request khi gửi đi.

## Format JSON mới

### Request Payload
```json
{
  "parentId": 1,
  "fullName": "Nguyễn Hoàng Minh",
  "gender": "MALE",
  "dateOfBirth": "2020-03-15",
  "isPremature": false,
  "gestationalWeek": null,
  "birthWeightGrams": 3200,
  "specialMedicalConditions": "Không có tình trạng y tế đặc biệt",
  "developmentalDisorderDiagnosis": "NOT_EVALUATED",
  "hasEarlyIntervention": false,
  "earlyInterventionDetails": null,
  "primaryLanguage": "Tiếng Việt",
  "familyDevelopmentalIssues": "NO",
  "height": 95.5,
  "weight": 14.2,
  "bloodType": "A+",
  "allergies": "Không có dị ứng",
  "medicalHistory": "Tiêm chủng đầy đủ theo lịch, không có bệnh lý đặc biệt",
  "status": "ACTIVE"
}
```

### Các trường dữ liệu

| Trường | Kiểu dữ liệu | Bắt buộc | Mô tả |
|--------|-------------|----------|-------|
| parentId | int | ✅ | ID của phụ huynh (tự động từ user session) |
| fullName | string | ✅ | Họ và tên đầy đủ của trẻ |
| gender | string | ✅ | Giới tính (MALE/FEMALE/OTHER) |
| dateOfBirth | string | ✅ | Ngày sinh (YYYY-MM-DD) |
| isPremature | boolean | ✅ | Có phải sinh non không |
| gestationalWeek | int | ❌ | Tuần thai (nếu sinh non) |
| birthWeightGrams | int | ❌ | Cân nặng lúc sinh (gram) |
| specialMedicalConditions | string | ✅ | Tình trạng y tế đặc biệt |
| developmentalDisorderDiagnosis | string | ✅ | Chẩn đoán rối loạn phát triển |
| hasEarlyIntervention | boolean | ✅ | Có can thiệp sớm không |
| earlyInterventionDetails | string | ❌ | Chi tiết can thiệp sớm |
| primaryLanguage | string | ✅ | Ngôn ngữ chính |
| familyDevelopmentalIssues | string | ✅ | Vấn đề phát triển gia đình |
| height | double | ❌ | Chiều cao (cm) |
| weight | double | ❌ | Cân nặng (kg) |
| bloodType | string | ✅ | Nhóm máu |
| allergies | string | ✅ | Dị ứng |
| medicalHistory | string | ✅ | Tiền sử bệnh lý |
| status | string | ✅ | Trạng thái (ACTIVE) |

## Các giá trị enum

### Gender
- `MALE` - Nam
- `FEMALE` - Nữ  
- `OTHER` - Khác

### Developmental Disorder Diagnosis
- `NOT_EVALUATED` - Chưa đánh giá
- `NO` - Không có
- `YES` - Có
- `UNDER_INVESTIGATION` - Đang tìm hiểu

### Blood Type
- `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-`, `OTHER`

### Family Developmental Issues
- `NO` - Không có
- `YES` - Có
- `UNDER_INVESTIGATION` - Đang tìm hiểu

## Cách hoạt động

### 1. Lấy Parent ID từ User Session
```dart
final parentId = UserSession.userId;
if (parentId == null || parentId.isEmpty) {
  throw Exception('User ID not found. Please login first.');
}
```

### 2. Tạo ChildData Object
```dart
final childData = ChildData(
  fullName: 'Nguyễn Hoàng Minh',
  gender: 'MALE',
  dateOfBirth: '2020-03-15',
  // ... các trường khác
);
```

### 3. Gửi Request với Parent ID
```dart
final payload = childData.copyWith(
  parentId: int.tryParse(parentId) ?? 1,
).toJson();
```

## API Endpoint

- **URL**: `POST /api/supabase/children`
- **Base URL**: `http://localhost:8080`
- **Headers**: 
  - `Content-Type: application/json`
  - `Accept: application/json`

## Model Classes

### ChildData
Model mới cho dữ liệu trẻ em với format JSON mới:

```dart
class ChildData {
  final int? parentId;
  final String fullName;
  final String gender;
  final String dateOfBirth;
  final bool isPremature;
  final int? gestationalWeek;
  final int? birthWeightGrams;
  final String specialMedicalConditions;
  final String developmentalDisorderDiagnosis;
  final bool hasEarlyIntervention;
  final String? earlyInterventionDetails;
  final String primaryLanguage;
  final String familyDevelopmentalIssues;
  final double? height;
  final double? weight;
  final String bloodType;
  final String allergies;
  final String medicalHistory;
  final String status;
  
  // Constructor, fromJson, toJson, copyWith methods
}
```

### ApiService.createChild()
Method mới trong ApiService để tạo trẻ:

```dart
Future<http.Response> createChild(ChildData childData) async {
  // Lấy parentId từ user session
  final parentId = UserSession.userId;
  
  // Tạo payload với parentId
  final payload = childData.copyWith(
    parentId: int.tryParse(parentId) ?? 1,
  ).toJson();
  
  // Gửi request
  return await http.post(uri, headers: headers, body: jsonEncode(payload));
}
```

## Màn hình thêm trẻ

### AddChildSheet
Màn hình thêm trẻ đã được cập nhật với:

1. **Các trường mới**:
   - Tuần thai (nếu sinh non)
   - Cân nặng lúc sinh (gram)
   - Chi tiết can thiệp sớm

2. **Validation**:
   - Kiểm tra các trường bắt buộc
   - Validate định dạng ngày tháng
   - Validate số liệu (chiều cao, cân nặng)

3. **UI/UX**:
   - Form layout responsive
   - Dropdown cho các trường enum
   - Checkbox cho các trường boolean
   - Loading state khi submit

## Lưu ý quan trọng

1. **Parent ID**: Tự động lấy từ user session, không hiển thị trên UI
2. **Validation**: Kiểm tra user đã đăng nhập trước khi thêm trẻ
3. **Error Handling**: Xử lý lỗi và hiển thị thông báo phù hợp
4. **Data Types**: Đảm bảo kiểu dữ liệu đúng (int, double, boolean, string)
5. **Null Safety**: Xử lý các trường có thể null

## Testing

### Test Cases
1. Thêm trẻ với đầy đủ thông tin
2. Thêm trẻ với thông tin tối thiểu
3. Test validation các trường bắt buộc
4. Test với user chưa đăng nhập
5. Test với network error

### Sample Data
```dart
final sampleChild = ChildData(
  fullName: 'Nguyễn Hoàng Minh',
  gender: 'MALE',
  dateOfBirth: '2020-03-15',
  isPremature: false,
  specialMedicalConditions: 'Không có tình trạng y tế đặc biệt',
  developmentalDisorderDiagnosis: 'NOT_EVALUATED',
  hasEarlyIntervention: false,
  primaryLanguage: 'Tiếng Việt',
  familyDevelopmentalIssues: 'NO',
  height: 95.5,
  weight: 14.2,
  bloodType: 'A+',
  allergies: 'Không có dị ứng',
  medicalHistory: 'Tiêm chủng đầy đủ theo lịch',
  status: 'ACTIVE',
);
```

## Migration từ version cũ

### Thay đổi chính:
1. Format JSON mới với parentId
2. Model ChildData mới
3. ApiService.createChild() method mới
4. UI form với các trường mới
5. Validation và error handling cải thiện

### Backward Compatibility:
- Giữ nguyên model Child cũ cho backward compatibility
- Thêm model ChildData mới cho API mới
- Có thể chạy song song cả hai version

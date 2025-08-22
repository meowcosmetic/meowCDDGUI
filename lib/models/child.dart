/// Model cho thông tin trẻ em
class Child {
  final String id;
  final String name;
  final String avatar;
  final int age;
  final String gender;
  final String diagnosis;
  final String parentName;
  final String parentPhone;
  final String parentEmail;
  final DateTime joinDate;
  final String status; // active, inactive, completed
  final Map<String, double> progress; // Tiến độ các kỹ năng
  final List<String> notes; // Ghi chú
  final String address;
  final String school;
  final String therapist; // Chuyên gia điều trị

  const Child({
    required this.id,
    required this.name,
    required this.avatar,
    required this.age,
    required this.gender,
    required this.diagnosis,
    required this.parentName,
    required this.parentPhone,
    required this.parentEmail,
    required this.joinDate,
    required this.status,
    required this.progress,
    required this.notes,
    required this.address,
    required this.school,
    required this.therapist,
  });

  /// Tạo trẻ em từ JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      parentName: json['parentName'] ?? '',
      parentPhone: json['parentPhone'] ?? '',
      parentEmail: json['parentEmail'] ?? '',
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
      progress: Map<String, double>.from(json['progress'] ?? {}),
      notes: List<String>.from(json['notes'] ?? []),
      address: json['address'] ?? '',
      school: json['school'] ?? '',
      therapist: json['therapist'] ?? '',
    );
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'age': age,
      'gender': gender,
      'diagnosis': diagnosis,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'joinDate': joinDate.toIso8601String(),
      'status': status,
      'progress': progress,
      'notes': notes,
      'address': address,
      'school': school,
      'therapist': therapist,
    };
  }

  /// Tạo bản sao với thay đổi
  Child copyWith({
    String? id,
    String? name,
    String? avatar,
    int? age,
    String? gender,
    String? diagnosis,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    DateTime? joinDate,
    String? status,
    Map<String, double>? progress,
    List<String>? notes,
    String? address,
    String? school,
    String? therapist,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      diagnosis: diagnosis ?? this.diagnosis,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      notes: notes ?? this.notes,
      address: address ?? this.address,
      school: school ?? this.school,
      therapist: therapist ?? this.therapist,
    );
  }

  /// Lấy trung bình tiến độ
  double get averageProgress {
    if (progress.isEmpty) return 0.0;
    return progress.values.reduce((a, b) => a + b) / progress.length;
  }

  /// Lấy màu trạng thái
  int getStatusColor() {
    switch (status) {
      case 'active':
        return 0xFF4CAF50; // Xanh lá
      case 'inactive':
        return 0xFFFF9800; // Cam
      case 'completed':
        return 0xFF2196F3; // Xanh dương
      default:
        return 0xFF9E9E9E; // Xám
    }
  }

  /// Lấy text trạng thái
  String getStatusText() {
    switch (status) {
      case 'active':
        return 'Đang điều trị';
      case 'inactive':
        return 'Tạm dừng';
      case 'completed':
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

  @override
  String toString() {
    return 'Child(id: $id, name: $name, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Child && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model mới cho child data với format JSON mới
class ChildData {
  final String? parentId;
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

  const ChildData({
    this.parentId,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.isPremature,
    this.gestationalWeek,
    this.birthWeightGrams,
    required this.specialMedicalConditions,
    required this.developmentalDisorderDiagnosis,
    required this.hasEarlyIntervention,
    this.earlyInterventionDetails,
    required this.primaryLanguage,
    required this.familyDevelopmentalIssues,
    this.height,
    this.weight,
    required this.bloodType,
    required this.allergies,
    required this.medicalHistory,
    required this.status,
  });

  /// Tạo ChildData từ JSON
  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      parentId: json['parentId']?.toString(),
      fullName: json['fullName'] as String? ?? '',
      gender: json['gender'] as String? ?? 'MALE',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      isPremature: json['isPremature'] as bool? ?? false,
      gestationalWeek: json['gestationalWeek'] as int?,
      birthWeightGrams: json['birthWeightGrams'] as int?,
      specialMedicalConditions: json['specialMedicalConditions'] as String? ?? '',
      developmentalDisorderDiagnosis: json['developmentalDisorderDiagnosis'] as String? ?? 'NOT_EVALUATED',
      hasEarlyIntervention: json['hasEarlyIntervention'] as bool? ?? false,
      earlyInterventionDetails: json['earlyInterventionDetails'] as String?,
      primaryLanguage: json['primaryLanguage'] as String? ?? 'Tiếng Việt',
      familyDevelopmentalIssues: json['familyDevelopmentalIssues'] as String? ?? 'NO',
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      bloodType: json['bloodType'] as String? ?? 'A+',
      allergies: json['allergies'] as String? ?? '',
      medicalHistory: json['medicalHistory'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'parentId': parentId,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'isPremature': isPremature,
      'gestationalWeek': gestationalWeek,
      'birthWeightGrams': birthWeightGrams,
      'specialMedicalConditions': specialMedicalConditions,
      'developmentalDisorderDiagnosis': developmentalDisorderDiagnosis,
      'hasEarlyIntervention': hasEarlyIntervention,
      'earlyInterventionDetails': earlyInterventionDetails,
      'primaryLanguage': primaryLanguage,
      'familyDevelopmentalIssues': familyDevelopmentalIssues,
      'height': height,
      'weight': weight,
      'bloodType': bloodType,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'status': status,
    };
  }

  /// Tạo bản sao với thay đổi
  ChildData copyWith({
    String? parentId,
    String? fullName,
    String? gender,
    String? dateOfBirth,
    bool? isPremature,
    int? gestationalWeek,
    int? birthWeightGrams,
    String? specialMedicalConditions,
    String? developmentalDisorderDiagnosis,
    bool? hasEarlyIntervention,
    String? earlyInterventionDetails,
    String? primaryLanguage,
    String? familyDevelopmentalIssues,
    double? height,
    double? weight,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? status,
  }) {
    return ChildData(
      parentId: parentId ?? this.parentId,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isPremature: isPremature ?? this.isPremature,
      gestationalWeek: gestationalWeek ?? this.gestationalWeek,
      birthWeightGrams: birthWeightGrams ?? this.birthWeightGrams,
      specialMedicalConditions: specialMedicalConditions ?? this.specialMedicalConditions,
      developmentalDisorderDiagnosis: developmentalDisorderDiagnosis ?? this.developmentalDisorderDiagnosis,
      hasEarlyIntervention: hasEarlyIntervention ?? this.hasEarlyIntervention,
      earlyInterventionDetails: earlyInterventionDetails ?? this.earlyInterventionDetails,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      familyDevelopmentalIssues: familyDevelopmentalIssues ?? this.familyDevelopmentalIssues,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ChildData(fullName: $fullName, gender: $gender, dateOfBirth: $dateOfBirth)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildData && 
           other.fullName == fullName && 
           other.dateOfBirth == dateOfBirth;
  }

  @override
  int get hashCode => fullName.hashCode ^ dateOfBirth.hashCode;
}

/// Dữ liệu mẫu cho trẻ em
class SampleChildren {
  static List<Child> getSampleData() {
    return [
      Child(
        id: '1',
        name: 'Nguyễn Minh An',
        avatar: '',
        age: 6,
        gender: 'Nam',
        diagnosis: 'Rối loạn phổ tự kỷ nhẹ',
        parentName: 'Nguyễn Văn A',
        parentPhone: '0901234567',
        parentEmail: 'nguyenvana@email.com',
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        status: 'active',
        progress: {
          'Giao tiếp': 0.75,
          'Vận động': 0.60,
          'Nhận thức': 0.85,
          'Xã hội': 0.45,
        },
        notes: [
          'Trẻ có tiến bộ tốt trong giao tiếp',
          'Cần tập trung vào kỹ năng xã hội',
        ],
        address: '123 Đường ABC, Quận 1, TP.HCM',
        school: 'Trường Tiểu học ABC',
        therapist: 'Bác sĩ Nguyễn Thị B',
      ),
      Child(
        id: '2',
        name: 'Trần Thị Bình',
        avatar: '',
        age: 5,
        gender: 'Nữ',
        diagnosis: 'Rối loạn phổ tự kỷ trung bình',
        parentName: 'Trần Văn C',
        parentPhone: '0901234568',
        parentEmail: 'tranvanc@email.com',
        joinDate: DateTime.now().subtract(const Duration(days: 45)),
        status: 'active',
        progress: {
          'Giao tiếp': 0.50,
          'Vận động': 0.70,
          'Nhận thức': 0.65,
          'Xã hội': 0.30,
        },
        notes: [
          'Trẻ cần hỗ trợ nhiều trong giao tiếp',
          'Vận động tinh khá tốt',
        ],
        address: '456 Đường XYZ, Quận 2, TP.HCM',
        school: 'Trường Mầm non XYZ',
        therapist: 'Bác sĩ Lê Văn D',
      ),
      Child(
        id: '3',
        name: 'Lê Hoàng Cường',
        avatar: '',
        age: 7,
        gender: 'Nam',
        diagnosis: 'Rối loạn phổ tự kỷ nhẹ',
        parentName: 'Lê Thị E',
        parentPhone: '0901234569',
        parentEmail: 'lethie@email.com',
        joinDate: DateTime.now().subtract(const Duration(days: 60)),
        status: 'completed',
        progress: {
          'Giao tiếp': 0.90,
          'Vận động': 0.85,
          'Nhận thức': 0.95,
          'Xã hội': 0.80,
        },
        notes: [
          'Trẻ đã hoàn thành chương trình điều trị',
          'Có thể hòa nhập tốt với môi trường học tập',
        ],
        address: '789 Đường DEF, Quận 3, TP.HCM',
        school: 'Trường Tiểu học DEF',
        therapist: 'Bác sĩ Phạm Thị F',
      ),
      Child(
        id: '4',
        name: 'Phạm Thị Dung',
        avatar: '',
        age: 4,
        gender: 'Nữ',
        diagnosis: 'Rối loạn phổ tự kỷ nặng',
        parentName: 'Phạm Văn G',
        parentPhone: '0901234570',
        parentEmail: 'phamvang@email.com',
        joinDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'active',
        progress: {
          'Giao tiếp': 0.25,
          'Vận động': 0.40,
          'Nhận thức': 0.35,
          'Xã hội': 0.20,
        },
        notes: [
          'Trẻ cần hỗ trợ đặc biệt',
          'Gia đình cần kiên nhẫn và hỗ trợ tích cực',
        ],
        address: '321 Đường GHI, Quận 4, TP.HCM',
        school: 'Trường Mầm non GHI',
        therapist: 'Bác sĩ Võ Văn H',
      ),
      Child(
        id: '5',
        name: 'Võ Minh Đức',
        avatar: '',
        age: 6,
        gender: 'Nam',
        diagnosis: 'Rối loạn phổ tự kỷ nhẹ',
        parentName: 'Võ Thị I',
        parentPhone: '0901234571',
        parentEmail: 'vothii@email.com',
        joinDate: DateTime.now().subtract(const Duration(days: 90)),
        status: 'inactive',
        progress: {
          'Giao tiếp': 0.65,
          'Vận động': 0.55,
          'Nhận thức': 0.70,
          'Xã hội': 0.50,
        },
        notes: [
          'Gia đình tạm dừng điều trị do lý do cá nhân',
          'Có thể tiếp tục khi gia đình sẵn sàng',
        ],
        address: '654 Đường JKL, Quận 5, TP.HCM',
        school: 'Trường Tiểu học JKL',
        therapist: 'Bác sĩ Đặng Văn K',
      ),
    ];
  }
}

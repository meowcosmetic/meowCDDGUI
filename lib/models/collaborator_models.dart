import 'package:flutter/material.dart';

// Enum cho trạng thái collaborator
enum CollaboratorStatus { ACTIVE, INACTIVE, PENDING }

// Class cho thông tin đa ngôn ngữ
class LocalizedText {
  final String vi;
  final String en;

  const LocalizedText({required this.vi, required this.en});

  Map<String, dynamic> toJson() => {'vi': vi, 'en': en};

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      LocalizedText(vi: json['vi'] ?? '', en: json['en'] ?? '');

  String getText(String locale) {
    return locale == 'vi' ? vi : en;
  }
}

// Class cho thông tin chứng chỉ
class Certification {
  final String vi;
  final String en;

  const Certification({required this.vi, required this.en});

  Map<String, dynamic> toJson() => {'vi': vi, 'en': en};

  factory Certification.fromJson(Map<String, dynamic> json) =>
      Certification(vi: json['vi'] ?? '', en: json['en'] ?? '');
}

// Class cho thông tin khả dụng
class Availability {
  final String vi;
  final String en;

  const Availability({required this.vi, required this.en});

  Map<String, dynamic> toJson() => {'vi': vi, 'en': en};

  factory Availability.fromJson(Map<String, dynamic> json) =>
      Availability(vi: json['vi'] ?? '', en: json['en'] ?? '');
}

// Class cho ghi chú
class Notes {
  final String vi;
  final String en;

  const Notes({required this.vi, required this.en});

  Map<String, dynamic> toJson() => {'vi': vi, 'en': en};

  factory Notes.fromJson(Map<String, dynamic> json) =>
      Notes(vi: json['vi'] ?? '', en: json['en'] ?? '');
}

// Class chi tiết collaborator từ API
class CollaboratorDetail {
  final String collaboratorId;
  final String userId;
  final String roleId;
  final String roleName;
  final String specialization;
  final int experienceYears;
  final Certification certification;
  final String organization;
  final Availability availability;
  final CollaboratorStatus status;
  final Notes notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollaboratorDetail({
    required this.collaboratorId,
    required this.userId,
    required this.roleId,
    required this.roleName,
    required this.specialization,
    required this.experienceYears,
    required this.certification,
    required this.organization,
    required this.availability,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollaboratorDetail.fromJson(Map<String, dynamic> json) {
    return CollaboratorDetail(
      collaboratorId: json['collaboratorId'] ?? '',
      userId: json['userId'] ?? '',
      roleId: json['roleId'] ?? '',
      roleName: json['roleName'] ?? '',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      certification: Certification.fromJson(json['certification'] ?? {}),
      organization: json['organization'] ?? '',
      availability: Availability.fromJson(json['availability'] ?? {}),
      status: CollaboratorStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CollaboratorStatus.PENDING,
      ),
      notes: Notes.fromJson(json['notes'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collaboratorId': collaboratorId,
      'userId': userId,
      'roleId': roleId,
      'roleName': roleName,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'certification': certification.toJson(),
      'organization': organization,
      'availability': availability.toJson(),
      'status': status.name,
      'notes': notes.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getStatusText() {
    switch (status) {
      case CollaboratorStatus.ACTIVE:
        return 'Hoạt động';
      case CollaboratorStatus.INACTIVE:
        return 'Không hoạt động';
      case CollaboratorStatus.PENDING:
        return 'Chờ duyệt';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case CollaboratorStatus.ACTIVE:
        return Colors.green;
      case CollaboratorStatus.INACTIVE:
        return Colors.red;
      case CollaboratorStatus.PENDING:
        return Colors.orange;
    }
  }
}

// Class cho request tạo collaborator
class CreateCollaboratorRequest {
  final String userId;
  final String roleId;
  final String specialization;
  final int experienceYears;
  final Certification certification;
  final String organization;
  final Availability availability;
  final CollaboratorStatus status;
  final Notes notes;

  const CreateCollaboratorRequest({
    required this.userId,
    required this.roleId,
    required this.specialization,
    required this.experienceYears,
    required this.certification,
    required this.organization,
    required this.availability,
    required this.status,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roleId': roleId,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'certification': certification.toJson(),
      'organization': organization,
      'availability': availability.toJson(),
      'status': status.name,
      'notes': notes.toJson(),
    };
  }
}

// Class cho request cập nhật collaborator
class UpdateCollaboratorRequest {
  final String? specialization;
  final int? experienceYears;
  final Certification? certification;
  final String? organization;
  final Availability? availability;
  final CollaboratorStatus? status;
  final Notes? notes;

  const UpdateCollaboratorRequest({
    this.specialization,
    this.experienceYears,
    this.certification,
    this.organization,
    this.availability,
    this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (specialization != null) data['specialization'] = specialization;
    if (experienceYears != null) data['experienceYears'] = experienceYears;
    if (certification != null) data['certification'] = certification!.toJson();
    if (organization != null) data['organization'] = organization;
    if (availability != null) data['availability'] = availability!.toJson();
    if (status != null) data['status'] = status!.name;
    if (notes != null) data['notes'] = notes!.toJson();
    return data;
  }
}

class Collaborator {
  final String id;
  final String name;
  final String title; // e.g., Chuyên viên trị liệu, Giáo viên đặc biệt
  final List<String>
  specialties; // giao_tiep, van_dong, nhan_thuc, xa_hoi, cam_xuc
  final String city; // Tỉnh/Thành phố
  final double rating; // 0.0 - 5.0
  final int reviews; // number of reviews
  final int yearsExperience; // years
  final String description;
  final List<String> availability; // e.g., 'Sáng', 'Chiều', 'Tối', 'Cuối tuần'
  final String phone;
  final String email;
  final int pricePerSession; // VND per session
  final bool isVerified;

  const Collaborator({
    required this.id,
    required this.name,
    required this.title,
    required this.specialties,
    required this.city,
    required this.rating,
    required this.reviews,
    required this.yearsExperience,
    required this.description,
    required this.availability,
    required this.phone,
    required this.email,
    required this.pricePerSession,
    this.isVerified = false,
  });

  Color getRatingColor() {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.teal;
    if (rating >= 3.0) return Colors.orange;
    return Colors.redAccent;
  }

  String getPriceText() => '${pricePerSession.toString()} đ/buổi';

  String getSpecialtyText(String spec) {
    switch (spec) {
      case 'giao_tiep':
        return 'Giao tiếp';
      case 'van_dong':
        return 'Vận động';
      case 'nhan_thuc':
        return 'Nhận thức';
      case 'xa_hoi':
        return 'Xã hội';
      case 'cam_xuc':
        return 'Cảm xúc';
      default:
        return spec;
    }
  }
}

class SampleCollaborators {
  static List<Collaborator> all() {
    return [
      Collaborator(
        id: 'c1',
        name: 'Nguyễn Thị Lan',
        title: 'Chuyên viên trị liệu ngôn ngữ',
        specialties: ['giao_tiep', 'cam_xuc'],
        city: 'Hà Nội',
        rating: 4.8,
        reviews: 124,
        yearsExperience: 6,
        description:
            'Kinh nghiệm làm việc với trẻ chậm nói và tự kỷ, tập trung vào phát triển giao tiếp và cảm xúc.',
        availability: ['Sáng', 'Chiều', 'Cuối tuần'],
        phone: '0901 234 567',
        email: 'lan.slp@example.com',
        pricePerSession: 350000,
        isVerified: true,
      ),
      Collaborator(
        id: 'c2',
        name: 'Trần Minh Đức',
        title: 'Giáo viên giáo dục đặc biệt',
        specialties: ['nhan_thuc', 'xa_hoi'],
        city: 'TP. Hồ Chí Minh',
        rating: 4.5,
        reviews: 89,
        yearsExperience: 8,
        description:
            'Tập trung phát triển kỹ năng nhận thức và kỹ năng xã hội cho trẻ từ 4-10 tuổi.',
        availability: ['Chiều', 'Tối'],
        phone: '0908 765 432',
        email: 'duc.sped@example.com',
        pricePerSession: 300000,
        isVerified: true,
      ),
      Collaborator(
        id: 'c3',
        name: 'Phạm Thu Hà',
        title: 'Chuyên viên vận động trị liệu',
        specialties: ['van_dong'],
        city: 'Đà Nẵng',
        rating: 4.1,
        reviews: 42,
        yearsExperience: 4,
        description:
            'Hỗ trợ trẻ chậm vận động cải thiện kỹ năng vận động tinh và thô, an toàn và hiệu quả.',
        availability: ['Sáng', 'Cuối tuần'],
        phone: '0912 333 888',
        email: 'ha.ot@example.com',
        pricePerSession: 280000,
        isVerified: false,
      ),
      Collaborator(
        id: 'c4',
        name: 'Lê Quốc An',
        title: 'Nhà tâm lý học lâm sàng',
        specialties: ['cam_xuc', 'xa_hoi'],
        city: 'Cần Thơ',
        rating: 4.9,
        reviews: 210,
        yearsExperience: 10,
        description:
            'Đánh giá và can thiệp cảm xúc – hành vi, đồng hành cùng gia đình trong quá trình can thiệp.',
        availability: ['Tối', 'Cuối tuần'],
        phone: '0987 000 555',
        email: 'an.clp@example.com',
        pricePerSession: 450000,
        isVerified: true,
      ),
    ];
  }

  static List<String> cities() {
    return ['Tất cả', 'Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Cần Thơ'];
  }

  static List<String> specialties() {
    return [
      'Tất cả',
      'giao_tiep',
      'van_dong',
      'nhan_thuc',
      'xa_hoi',
      'cam_xuc',
    ];
  }

  static List<String> ratings() {
    return ['Tất cả', '4.5+', '4.0+', '3.0+'];
  }
}

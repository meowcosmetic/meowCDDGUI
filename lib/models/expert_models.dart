import 'package:flutter/material.dart';

class ExpertTimeSlot {
  final String start; // HH:mm
  final String end; // HH:mm
  final bool available;

  const ExpertTimeSlot({
    required this.start,
    required this.end,
    this.available = true,
  });
}

class ExpertDaySchedule {
  final String day; // Mon, Tue, Wed, Thu, Fri, Sat, Sun
  final List<ExpertTimeSlot> slots;

  const ExpertDaySchedule({required this.day, required this.slots});
}

class Expert {
  final String id;
  final String name;
  final String title;
  final List<String>
  specialties; // giao_tiep, van_dong, nhan_thuc, xa_hoi, cam_xuc
  final String city;
  final double rating;
  final int reviews;
  final int yearsExperience;
  final String description;
  final int pricePerSession;
  final bool isVerified;
  final List<ExpertDaySchedule> weeklySchedule;
  final String phone;
  final String email;

  const Expert({
    required this.id,
    required this.name,
    required this.title,
    required this.specialties,
    required this.city,
    required this.rating,
    required this.reviews,
    required this.yearsExperience,
    required this.description,
    required this.pricePerSession,
    required this.isVerified,
    required this.weeklySchedule,
    required this.phone,
    required this.email,
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

class SampleExperts {
  static List<Expert> all() {
    return [
      Expert(
        id: 'e1',
        name: 'BS. Nguyễn Hồng Anh',
        title: 'Bác sĩ Tâm lý lâm sàng',
        specialties: ['cam_xuc', 'xa_hoi'],
        city: 'Hà Nội',
        rating: 4.9,
        reviews: 182,
        yearsExperience: 12,
        description:
            'Chẩn đoán và can thiệp hành vi-cảm xúc cho trẻ rối loạn phổ tự kỷ. Đồng hành cùng gia đình.',
        pricePerSession: 600000,
        isVerified: true,
        weeklySchedule: _wk([true, true, true, true, true, false, false]),
        phone: '0909 111 222',
        email: 'honganh.expert@example.com',
      ),
      Expert(
        id: 'e2',
        name: 'ThS. Lê Minh Trang',
        title: 'Chuyên gia Ngôn ngữ trị liệu',
        specialties: ['giao_tiep'],
        city: 'TP. Hồ Chí Minh',
        rating: 4.7,
        reviews: 133,
        yearsExperience: 8,
        description:
            'Tập trung phát triển ngôn ngữ tiếp nhận và diễn đạt cho trẻ chậm nói và tự kỷ.',
        pricePerSession: 450000,
        isVerified: true,
        weeklySchedule: _wk([false, true, true, true, false, true, false]),
        phone: '0911 333 444',
        email: 'trang.slp@example.com',
      ),
      Expert(
        id: 'e3',
        name: 'CN. Phạm Quang Vinh',
        title: 'Chuyên viên Vận động trị liệu',
        specialties: ['van_dong'],
        city: 'Đà Nẵng',
        rating: 4.3,
        reviews: 58,
        yearsExperience: 5,
        description:
            'Can thiệp vận động tinh và thô, cải thiện phối hợp và kỹ năng tự lập hằng ngày.',
        pricePerSession: 380000,
        isVerified: false,
        weeklySchedule: _wk([true, false, true, false, true, false, true]),
        phone: '0933 777 999',
        email: 'vinh.ot@example.com',
      ),
    ];
  }

  static List<ExpertDaySchedule> _wk(List<bool> workDays) {
    // days order: Mon..Sun
    final dayNames = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];
    final List<ExpertDaySchedule> days = [];
    for (int i = 0; i < 7; i++) {
      if (workDays[i]) {
        days.add(ExpertDaySchedule(day: dayNames[i], slots: _defaultSlots()));
      } else {
        days.add(const ExpertDaySchedule(day: '', slots: []));
      }
    }
    return days;
  }

  static List<ExpertTimeSlot> _defaultSlots() {
    return const [
      ExpertTimeSlot(start: '09:00', end: '09:45', available: true),
      ExpertTimeSlot(start: '10:00', end: '10:45', available: true),
      ExpertTimeSlot(start: '14:00', end: '14:45', available: true),
      ExpertTimeSlot(start: '15:00', end: '15:45', available: false),
      ExpertTimeSlot(start: '16:00', end: '16:45', available: true),
    ];
  }

  static List<String> cities() => [
    'Tất cả',
    'Hà Nội',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
  ];
  static List<String> specialties() => [
    'Tất cả',
    'giao_tiep',
    'van_dong',
    'nhan_thuc',
    'xa_hoi',
    'cam_xuc',
  ];
  static List<String> ratings() => ['Tất cả', '4.5+', '4.0+', '3.0+'];
}

import '../services/host_service.dart';

/// App Configuration - Cấu hình hiển thị các tính năng trong ứng dụng
class AppConfig {
  // Dashboard Categories - Các danh mục trong trang chủ
  static const bool showLibrary = true;           // Thư viện
  static const bool showTests = true;             // Bài test
  static const bool showChildrenList = true;      // Danh sách trẻ
  static const bool showCollaboratorSearch = true; // Tìm kiếm cộng tác viên
  static const bool showExpertConnection = true;  // Liên kết với chuyên gia
  static const bool showStore = true;             // Cửa hàng
  static const bool showDonation = true;          // Đóng góp
  static const bool showInterventions = true;     // Mục tiêu can thiệp
  static const bool showInterventionDomains = true; // Lĩnh vực can thiệp
  static const bool showInterventionMethods = true; // Nhóm phương pháp can thiệp
  
  // Feature Flags - Cờ bật/tắt tính năng
  static const bool enableNotifications = true;   // Thông báo
  static const bool enableOfflineMode = true;     // Chế độ offline
  static const bool enableDataSync = true;        // Đồng bộ dữ liệu
  static const bool enableAnalytics = true;       // Phân tích dữ liệu
  static const bool enableAddTestCategory = true; // Bật nút thêm category bài test
  static const bool enableInterventions = true;   // Bật tính năng mục tiêu can thiệp
  static const bool enableInterventionDomains = true; // Bật tính năng lĩnh vực can thiệp
  static const bool enableInterventionMethods = true; // Bật tính năng nhóm phương pháp can thiệp
  
  // UI Configuration - Cấu hình giao diện
  static const bool showWelcomeMessage = true;    // Hiển thị tin nhắn chào mừng
  static const bool showProgressTips = true;      // Hiển thị mẹo tiến độ
  static const bool showQuickActions = true;      // Hiển thị hành động nhanh
  
  // Content Configuration - Cấu hình nội dung
  static const bool showSampleData = true;        // Hiển thị dữ liệu mẫu
  static const bool enableContentFiltering = true; // Lọc nội dung
  static const bool enableContentSearch = true;   // Tìm kiếm nội dung
  
  // Security Configuration - Cấu hình bảo mật
  static const bool requireBiometricAuth = false; // Yêu cầu xác thực sinh trắc học
  static const bool enableDataEncryption = true;  // Mã hóa dữ liệu
  static const bool enableAuditLog = true;        // Nhật ký kiểm tra
  
  // Performance Configuration - Cấu hình hiệu suất
  static const bool enableCaching = true;         // Bật cache
  static const bool enableLazyLoading = true;     // Tải lười
  static const bool enableImageOptimization = true; // Tối ưu hình ảnh
  
  // Development Configuration - Cấu hình phát triển
  static const bool enableDebugMode = false;      // Chế độ debug
  static const bool enableLogging = true;         // Ghi log
  static const bool enableCrashReporting = true;  // Báo cáo lỗi

  // Text Selection Configuration - Cấu hình chọn text
  static const bool enableTextSelection = true;   // Bật chọn và copy text

  // Entry/Gating Screens - Cấu hình màn hình đầu vào
  static const bool showLoginScreen = true;       // Hiển thị màn hình đăng nhập
  static const bool showPolicyScreen = true;      // Hiển thị màn hình chính sách

  // API Configuration - Sử dụng hostname động
  static String get apiBaseUrl => HostService.getApiBaseUrl();
  static String get cddAPI => HostService.getCddApiUrl();
  
  /// Lấy danh sách các danh mục được bật
  static List<DashboardCategory> getEnabledCategories() {
    final categories = <DashboardCategory>[];
    
    if (showLibrary) {
      categories.add(DashboardCategory(
        id: 'library',
        title: 'Thư Viện',
        subtitle: 'Tài liệu và tài nguyên hỗ trợ',
        icon: 'library_books',
        color: 0xFF4CAF50,
        route: '/library',
      ));
    }
    
    if (showTests) {
      categories.add(DashboardCategory(
        id: 'tests',
        title: 'Bài Test',
        subtitle: 'Đánh giá và kiểm tra tiến độ',
        icon: 'quiz',
        color: 0xFF2196F3,
        route: '/tests',
      ));
    }
    
    if (showChildrenList) {
      categories.add(DashboardCategory(
        id: 'children',
        title: 'Danh Sách Trẻ',
        subtitle: 'Quản lý thông tin trẻ em',
        icon: 'child_care',
        color: 0xFFFF9800,
        route: '/children',
      ));
    }
    
    if (showCollaboratorSearch) {
      categories.add(DashboardCategory(
        id: 'collaborators',
        title: 'Tìm Cộng Tác Viên',
        subtitle: 'Kết nối với người hỗ trợ',
        icon: 'people',
        color: 0xFF9C27B0,
        route: '/collaborators',
      ));
    }
    
    if (showExpertConnection) {
      categories.add(DashboardCategory(
        id: 'experts',
        title: 'Liên Kết Chuyên Gia',
        subtitle: 'Tư vấn từ chuyên gia',
        icon: 'psychology',
        color: 0xFFF44336,
        route: '/experts',
      ));
    }
    
    if (showStore) {
      categories.add(DashboardCategory(
        id: 'store',
        title: 'Cửa Hàng',
        subtitle: 'Đồ chơi và tài liệu giáo dục',
        icon: 'store',
        color: 0xFF00BCD4,
        route: '/store',
      ));
    }
    
    if (showDonation) {
      categories.add(DashboardCategory(
        id: 'donation',
        title: 'Đóng Góp',
        subtitle: 'Hỗ trợ phát triển dự án',
        icon: 'volunteer_activism',
        color: 0xFF4CAF50,
        route: '/donation',
      ));
    }
    
    if (showInterventions && enableInterventions) {
      categories.add(DashboardCategory(
        id: 'interventions',
        title: 'Mục Tiêu Can Thiệp',
        subtitle: 'Quản lý lĩnh vực và mục tiêu',
        icon: 'flag',
        color: 0xFF3F51B5,
        route: '/interventions',
      ));
    }
    
    if (showInterventionDomains && enableInterventionDomains) {
      categories.add(DashboardCategory(
        id: 'intervention-domains',
        title: 'Lĩnh Vực Can Thiệp',
        subtitle: 'Quản lý các lĩnh vực can thiệp',
        icon: 'category',
        color: 0xFF9C27B0,
        route: '/intervention-domains',
      ));
    }
    
    if (showInterventionMethods && enableInterventionMethods) {
      categories.add(DashboardCategory(
        id: 'intervention-methods',
        title: 'Nhóm Phương Pháp',
        subtitle: 'Quản lý nhóm phương pháp can thiệp',
        icon: 'science',
        color: 0xFF607D8B,
        route: '/intervention-methods',
      ));
    }
    
    return categories;
  }
  
  /// Kiểm tra xem một danh mục có được bật hay không
  static bool isCategoryEnabled(String categoryId) {
    switch (categoryId) {
      case 'library':
        return showLibrary;
      case 'tests':
        return showTests;
      case 'children':
        return showChildrenList;
      case 'collaborators':
        return showCollaboratorSearch;
      case 'experts':
        return showExpertConnection;
      case 'store':
        return showStore;
      case 'donation':
        return showDonation;
      case 'interventions':
        return showInterventions && enableInterventions;
      case 'intervention-domains':
        return showInterventionDomains && enableInterventionDomains;
      case 'intervention-methods':
        return showInterventionMethods && enableInterventionMethods;
      default:
        return false;
    }
  }
  
  /// Lấy thông tin danh mục theo ID
  static DashboardCategory? getCategoryById(String categoryId) {
    final categories = getEnabledCategories();
    try {
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }
}

/// Model cho danh mục dashboard
class DashboardCategory {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int color;
  final String route;
  
  const DashboardCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
  
  @override
  String toString() {
    return 'DashboardCategory(id: $id, title: $title)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardCategory && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

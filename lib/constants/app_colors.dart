import 'package:flutter/material.dart';

/// App Colors - Định nghĩa tất cả màu sắc được sử dụng trong ứng dụng
class AppColors {
  // Primary Colors - Màu chính
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFFE8F5E8);
  static const Color primaryLighter = Color(0xFFF0F8F0);

  // Secondary Colors - Màu phụ
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFFE3F2FD);

  // Success Colors - Màu thành công
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E8);

  // Warning Colors - Màu cảnh báo
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);

  // Error Colors - Màu lỗi
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Info Colors - Màu thông tin
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Neutral Colors - Màu trung tính
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Text Colors - Màu chữ
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // Background Colors - Màu nền
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Border Colors - Màu viền
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Shadow Colors - Màu bóng
  static const Color shadow = Color(0x1A000000); // 10% opacity
  static const Color shadowLight = Color(0x0A000000); // 4% opacity

  // Status Colors - Màu trạng thái
  static const Color active = Color(0xFF4CAF50);
  static const Color inactive = Color(0xFF9E9E9E);
  static const Color disabled = Color(0xFFE0E0E0);

  // Theme Colors - Màu theo chủ đề
  static const Color green = Colors.green;
  static const Color purple = Colors.purple;
  static const Color orange = Colors.orange;
  static const Color red = Colors.red;
  static const Color teal = Colors.teal;
  static const Color indigo = Colors.indigo;
  static const Color deepPurple = Colors.deepPurple;
  static const Color amber = Colors.amber;
  static const Color pink = Colors.pink;

  // Opacity Variants - Các biến thể độ trong suốt
  static Color get primaryWithOpacity10 => primary.withValues(alpha: 0.1);
  static Color get primaryWithOpacity20 => primary.withValues(alpha: 0.2);
  static Color get primaryWithOpacity30 => primary.withValues(alpha: 0.3);
  static Color get primaryWithOpacity40 => primary.withValues(alpha: 0.4);
  static Color get primaryWithOpacity50 => primary.withValues(alpha: 0.5);
  static Color get primaryWithOpacity60 => primary.withValues(alpha: 0.6);
  static Color get primaryWithOpacity70 => primary.withValues(alpha: 0.7);
  static Color get primaryWithOpacity80 => primary.withValues(alpha: 0.8);
  static Color get primaryWithOpacity90 => primary.withValues(alpha: 0.9);

  static Color get blackWithOpacity10 => black.withValues(alpha: 0.1);
  static Color get blackWithOpacity20 => black.withValues(alpha: 0.2);
  static Color get blackWithOpacity30 => black.withValues(alpha: 0.3);
  static Color get blackWithOpacity40 => black.withValues(alpha: 0.4);
  static Color get blackWithOpacity50 => black.withValues(alpha: 0.5);
  static Color get blackWithOpacity60 => black.withValues(alpha: 0.6);
  static Color get blackWithOpacity70 => black.withValues(alpha: 0.7);
  static Color get blackWithOpacity80 => black.withValues(alpha: 0.8);
  static Color get blackWithOpacity90 => black.withValues(alpha: 0.9);

  // Grey Scale - Thang màu xám
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Material Design Colors - Màu Material Design
  static const Color materialGrey = Colors.grey;
  static const Color materialBlack87 = Color(0xDD000000); // 87% opacity
  static const Color materialBlack54 = Color(0x8A000000); // 54% opacity
  static const Color materialBlack38 = Color(0x61000000); // 38% opacity
  static const Color materialBlack12 = Color(0x1F000000); // 12% opacity

  // Custom Colors - Màu tùy chỉnh
  static const Color cardBackground = Color(0xFFF0F8F0);
  static const Color cardBorder = Color(0xFF4CAF50);
  static const Color iconDefault = Color(0xFF4CAF50);
  static const Color iconSuccess = Color(0xFF4CAF50);
  static const Color iconWarning = Color(0xFFFF9800);
  static const Color iconError = Color(0xFFF44336);
  static const Color iconInfo = Color(0xFF2196F3);

  // Alert Colors - Màu cho alert
  static const Color alertSuccessBackground = Color(0xFFF0F9FF);
  static const Color alertSuccessBorder = Color(0xFF10B981);
  static const Color alertSuccessIcon = Color(0xFF10B981);
  static const Color alertSuccessText = Color(0xFF065F46);
  static Color get alertSuccessShadow =>
      alertSuccessBorder.withValues(alpha: 0.1);

  static const Color alertErrorBackground = Color(0xFFFEF2F2);
  static const Color alertErrorBorder = Color(0xFFEF4444);
  static const Color alertErrorIcon = Color(0xFFEF4444);
  static const Color alertErrorText = Color(0xFF991B1B);
  static Color get alertErrorShadow => alertErrorBorder.withValues(alpha: 0.1);

  static const Color alertWarningBackground = Color(0xFFFFFBEB);
  static const Color alertWarningBorder = Color(0xFFF59E0B);
  static const Color alertWarningIcon = Color(0xFFF59E0B);
  static const Color alertWarningText = Color(0xFF92400E);
  static Color get alertWarningShadow =>
      alertWarningBorder.withValues(alpha: 0.1);

  static const Color alertInfoBackground = Color(0xFFEFF6FF);
  static const Color alertInfoBorder = Color(0xFF3B82F6);
  static const Color alertInfoIcon = Color(0xFF3B82F6);
  static const Color alertInfoText = Color(0xFF1E40AF);
  static Color get alertInfoShadow => alertInfoBorder.withValues(alpha: 0.1);

  // Gradient Colors - Màu gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic Colors - Màu ngữ nghĩa
  static const Color positive = success;
  static const Color negative = error;
  static const Color neutral = grey500;
  static const Color highlight = amber;

  // Accessibility Colors - Màu hỗ trợ tiếp cận
  static const Color highContrast = Color(0xFF000000);
  static const Color lowContrast = Color(0xFF666666);
  static const Color focusRing = Color(0xFF2196F3);

  // Dark Theme Colors - Màu cho chế độ tối
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF424242);

  // Light Theme Colors - Màu cho chế độ sáng
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);
}

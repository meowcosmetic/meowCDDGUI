# Navigation System Documentation

Hệ thống navigation hoàn chỉnh với bottom navigation và drawer menu cho ứng dụng Flutter.

## Tính năng chính

### 1. Bottom Navigation Bar
- **3 tab chính**: Buttons, Cards, Forms
- **Animation mượt mà**: Chuyển đổi giữa các tab với animation
- **Icon và label**: Mỗi tab có icon và tên riêng
- **Màu sắc tùy chỉnh**: Selected/Unselected states

### 2. Drawer Menu
- **Header đẹp**: Logo và thông tin ứng dụng
- **Navigation items**: Danh sách các trang có thể truy cập
- **About dialog**: Thông tin về ứng dụng
- **Settings dialog**: Cài đặt (có thể mở rộng)

### 3. PageView Integration
- **Smooth scrolling**: Chuyển đổi trang mượt mà
- **Synchronized**: Bottom navigation và PageView đồng bộ
- **Performance**: Lazy loading các trang

## Cách sử dụng

### 1. Import và sử dụng
```dart
import 'navigation/app_navigation.dart';

// Trong main.dart
MaterialApp(
  home: const AppNavigation(),
)
```

### 2. Thêm trang mới
```dart
// Trong _navigationItems list
NavigationItem(
  title: 'New Page',
  icon: Icons.new_page,
  page: const NewPageDemo(),
),
```

### 3. Tùy chỉnh theme
```dart
// Thay đổi màu sắc trong AppNavigation
selectedItemColor: Colors.blue, // Màu tab được chọn
unselectedItemColor: Colors.grey[600], // Màu tab không được chọn
backgroundColor: Colors.white, // Màu nền bottom navigation
```

## Cấu trúc file

### AppNavigation
- **StatefulWidget**: Quản lý state của navigation
- **PageController**: Điều khiển PageView
- **NavigationItem**: Model cho mỗi item navigation

### NavigationItem
```dart
class NavigationItem {
  final String title;    // Tên hiển thị
  final IconData icon;   // Icon
  final Widget page;     // Widget trang
}
```

## Tính năng nâng cao

### 1. Drawer Header
- Logo ứng dụng với Flutter Dash icon
- Tên ứng dụng "The Happiness Journey"
- Subtitle "UI Component Library"

### 2. Navigation Items trong Drawer
- Hiển thị tất cả các trang có sẵn
- Highlight trang hiện tại
- Tap để chuyển trang và đóng drawer

### 3. Additional Menu Items
- **About**: Hiển thị thông tin ứng dụng
- **Settings**: Cài đặt (placeholder)

### 4. Responsive Design
- Hoạt động tốt trên mobile và tablet
- Drawer có thể mở từ bên phải (endDrawer)
- Bottom navigation fixed cho mobile

## Customization

### 1. Thay đổi màu sắc
```dart
// AppBar
backgroundColor: Colors.black87,
foregroundColor: Colors.white,

// Bottom Navigation
selectedItemColor: Colors.black87,
unselectedItemColor: Colors.grey[600],

// Drawer Header
decoration: BoxDecoration(color: Colors.black87),
```

### 2. Thêm animation
```dart
_pageController.animateToPage(
  index,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);
```

### 3. Thêm trang mới
1. Tạo widget trang mới
2. Import vào `app_navigation.dart`
3. Thêm vào `_navigationItems` list
4. Cập nhật icon và title

## Best Practices

### 1. Performance
- Sử dụng `PageView` để lazy load
- Dispose `PageController` khi widget bị destroy
- Sử dụng `const` constructor khi có thể

### 2. UX
- Animation mượt mà (300ms duration)
- Visual feedback cho user interactions
- Consistent color scheme

### 3. Code Organization
- Tách biệt logic navigation
- Sử dụng model class cho navigation items
- Clean separation of concerns

## Future Enhancements

### 1. Deep Linking
- Support cho deep linking
- URL routing
- State persistence

### 2. Custom Transitions
- Custom page transitions
- Hero animations
- Shared element transitions

### 3. Advanced Features
- Tab badges (notifications)
- Custom drawer animations
- Nested navigation
- Tab persistence

## Troubleshooting

### 1. Page không hiển thị
- Kiểm tra import đúng
- Đảm bảo widget được export
- Verify trong `_navigationItems` list

### 2. Animation không mượt
- Kiểm tra `PageController` được dispose đúng
- Verify `duration` và `curve` settings
- Test trên device thật

### 3. Drawer không mở
- Kiểm tra `Scaffold.of(context).openEndDrawer()`
- Verify `endDrawer` property được set
- Test gesture detection 
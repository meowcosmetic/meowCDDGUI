# Navigation Components Documentation

Bộ sưu tập các component navigation hoàn chỉnh cho ứng dụng Flutter, bao gồm Breadcrumb, Tabs, và Navigation Menu.

## 🍞 Breadcrumb Component

### Tính năng chính
- **4 loại style**: Default, Outlined, Filled, Minimal
- **3 kích thước**: Small, Medium, Large
- **Icon support**: Mỗi item có thể có icon riêng
- **Active state**: Highlight item hiện tại
- **Custom separators**: Tùy chỉnh icon phân cách
- **Clickable items**: Mỗi item có thể click được

### Cách sử dụng

```dart
import 'uiElement/breadcrumb.dart';

final breadcrumbItems = [
  const BreadcrumbItem(
    label: 'Home',
    icon: Icons.home,
    onTap: () => print('Home clicked'),
  ),
  const BreadcrumbItem(
    label: 'Products',
    icon: Icons.shopping_bag,
    onTap: () => print('Products clicked'),
  ),
  const BreadcrumbItem(
    label: 'Electronics',
    icon: Icons.devices,
    isActive: true, // Item hiện tại
  ),
];

// Default breadcrumb
Breadcrumb(items: breadcrumbItems)

// Outlined breadcrumb
OutlinedBreadcrumb(items: breadcrumbItems)

// Filled breadcrumb
FilledBreadcrumb(items: breadcrumbItems)

// Minimal breadcrumb
MinimalBreadcrumb(items: breadcrumbItems)
```

### Tùy chỉnh

```dart
Breadcrumb(
  items: breadcrumbItems,
  size: BreadcrumbSize.large,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey,
  showIcons: true,
  showSeparators: true,
  separatorIcon: Icons.arrow_forward,
  borderRadius: 8,
)
```

## 📑 Tabs Component

### Tính năng chính
- **5 loại style**: Default, Outlined, Filled, Pills, Underline
- **4 vị trí**: Top, Bottom, Left, Right
- **3 kích thước**: Small, Medium, Large
- **Icon và label**: Hỗ trợ cả icon và text
- **Disabled state**: Tab có thể bị disable
- **Scrollable**: Hỗ trợ scroll khi có nhiều tab
- **Custom indicators**: Tùy chỉnh indicator

### Cách sử dụng

```dart
import 'uiElement/tabs.dart';

final tabItems = [
  const TabItem(
    label: 'Overview',
    icon: Icons.dashboard,
    content: Center(child: Text('Overview Content')),
  ),
  const TabItem(
    label: 'Details',
    icon: Icons.info,
    content: Center(child: Text('Details Content')),
  ),
  const TabItem(
    label: 'Settings',
    icon: Icons.settings,
    content: Center(child: Text('Settings Content')),
    disabled: true, // Tab bị disable
  ),
];

// Default tabs
MeowTabs(
  tabs: tabItems,
  onTabChanged: (index) => print('Tab $index selected'),
)

// Outlined tabs
OutlinedTabs(tabs: tabItems)

// Filled tabs
FilledTabs(tabs: tabItems)

// Pill tabs
PillTabs(tabs: tabItems)

// Underline tabs
UnderlineTabs(tabs: tabItems)
```

### Tùy chỉnh

```dart
MeowTabs(
  tabs: tabItems,
  size: TabSize.large,
  position: TabPosition.left, // Vertical tabs
  style: TabStyle.filled,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey,
  showIcons: true,
  showLabels: true,
  scrollable: true,
  showIndicator: true,
  indicatorColor: Colors.blue,
  indicatorHeight: 3,
  onTabChanged: (index) => print('Tab $index selected'),
)
```

## 🧭 Navigation Menu Component

### Tính năng chính
- **4 loại style**: Default, Outlined, Filled, Minimal
- **2 orientation**: Horizontal, Vertical
- **3 kích thước**: Small, Medium, Large
- **Submenu support**: Hỗ trợ menu con
- **Active state**: Highlight item hiện tại
- **Disabled state**: Item có thể bị disable
- **Expandable**: Menu có thể mở rộng (vertical)

### Cách sử dụng

```dart
import 'uiElement/navigation_menu.dart';

final menuItems = [
  const MenuItem(
    label: 'Dashboard',
    icon: Icons.dashboard,
    isActive: true,
    onTap: () => print('Dashboard clicked'),
  ),
  const MenuItem(
    label: 'Products',
    icon: Icons.shopping_bag,
    children: [
      MenuItem(
        label: 'All Products',
        icon: Icons.list,
        onTap: () => print('All Products clicked'),
      ),
      MenuItem(
        label: 'Categories',
        icon: Icons.category,
        onTap: () => print('Categories clicked'),
      ),
    ],
  ),
  const MenuItem(
    label: 'Reports',
    icon: Icons.analytics,
    disabled: true, // Item bị disable
  ),
];

// Horizontal navigation menu
NavigationMenu(
  items: menuItems,
  onItemSelected: (index) => print('Item $index selected'),
)

// Vertical navigation menu
NavigationMenu(
  items: menuItems,
  orientation: MenuOrientation.vertical,
  onItemSelected: (index) => print('Item $index selected'),
)
```

### Tùy chỉnh

```dart
NavigationMenu(
  items: menuItems,
  size: MenuSize.large,
  style: MenuStyle.filled,
  orientation: MenuOrientation.vertical,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey,
  backgroundColor: Colors.grey[100],
  showIcons: true,
  showLabels: true,
  showSubmenu: true,
  showIndicator: true,
  indicatorColor: Colors.blue,
  indicatorHeight: 2,
  onItemSelected: (index) => print('Item $index selected'),
)
```

## 🎨 Customization Examples

### Breadcrumb với custom styling

```dart
OutlinedBreadcrumb(
  items: breadcrumbItems,
  size: BreadcrumbSize.large,
  activeColor: const Color(0xFF4CAF50),
  inactiveColor: Colors.grey[600],
  borderColor: const Color(0xFF4CAF50),
  borderRadius: 12,
  showIcons: true,
  showSeparators: true,
  separatorIcon: Icons.arrow_forward_ios,
)
```

### Tabs với custom theme

```dart
PillTabs(
  tabs: tabItems,
  size: TabSize.medium,
  activeColor: const Color(0xFF4CAF50),
  inactiveColor: Colors.grey[600],
  borderRadius: 20,
  showIcons: true,
  showLabels: true,
  onTabChanged: (index) => print('Tab $index selected'),
)
```

### Navigation Menu với submenu

```dart
FilledNavigationMenu(
  items: menuItems,
  size: MenuSize.medium,
  orientation: MenuOrientation.horizontal,
  activeColor: const Color(0xFF4CAF50),
  inactiveColor: Colors.grey[600],
  backgroundColor: Colors.grey[100],
  borderRadius: 8,
  showIcons: true,
  showLabels: true,
  showSubmenu: true,
  onItemSelected: (index) => print('Item $index selected'),
)
```

## 📱 Responsive Design

### Mobile-friendly
- Tất cả components đều responsive
- Tự động điều chỉnh kích thước
- Hỗ trợ touch gestures

### Tablet/Desktop
- Tối ưu cho màn hình lớn
- Hỗ trợ hover effects
- Keyboard navigation

## 🔧 Best Practices

### 1. Accessibility
- Sử dụng semantic labels
- Hỗ trợ screen readers
- Keyboard navigation

### 2. Performance
- Lazy loading cho content
- Efficient state management
- Minimal rebuilds

### 3. UX
- Consistent styling
- Clear visual hierarchy
- Intuitive interactions

## 🚀 Advanced Features

### 1. Dynamic Content
- Load content on demand
- Async data loading
- Real-time updates

### 2. State Management
- Integrate with state management
- Persistent state
- URL synchronization

### 3. Custom Animations
- Smooth transitions
- Custom animations
- Loading states

## 🔍 Troubleshooting

### Common Issues

1. **Breadcrumb không hiển thị**
   - Kiểm tra items không rỗng
   - Verify icon imports
   - Check widget tree

2. **Tabs không chuyển đổi**
   - Verify TabController
   - Check onTabChanged callback
   - Ensure content widgets

3. **Navigation menu không mở submenu**
   - Check showSubmenu property
   - Verify children structure
   - Ensure proper state management

### Performance Tips

1. **Use const constructors** khi có thể
2. **Minimize rebuilds** với proper state management
3. **Lazy load content** cho tabs
4. **Optimize images** cho icons

## 📚 Examples

### E-commerce Navigation
```dart
// Breadcrumb cho product page
final productBreadcrumb = [
  BreadcrumbItem(label: 'Home', icon: Icons.home),
  BreadcrumbItem(label: 'Electronics', icon: Icons.devices),
  BreadcrumbItem(label: 'Smartphones', icon: Icons.phone_android),
  BreadcrumbItem(label: 'iPhone 15', icon: Icons.phone_iphone, isActive: true),
];

// Product tabs
final productTabs = [
  TabItem(label: 'Overview', content: ProductOverview()),
  TabItem(label: 'Specifications', content: ProductSpecs()),
  TabItem(label: 'Reviews', content: ProductReviews()),
  TabItem(label: 'Related', content: RelatedProducts()),
];

// Admin navigation menu
final adminMenu = [
  MenuItem(label: 'Dashboard', icon: Icons.dashboard, isActive: true),
  MenuItem(
    label: 'Products',
    icon: Icons.shopping_bag,
    children: [
      MenuItem(label: 'All Products', icon: Icons.list),
      MenuItem(label: 'Add Product', icon: Icons.add),
      MenuItem(label: 'Categories', icon: Icons.category),
    ],
  ),
  MenuItem(
    label: 'Orders',
    icon: Icons.shopping_cart,
    children: [
      MenuItem(label: 'Pending', icon: Icons.pending),
      MenuItem(label: 'Completed', icon: Icons.check_circle),
    ],
  ),
];
```

Hoàn thành! Bạn đã có một bộ navigation components hoàn chỉnh với đầy đủ tính năng và tùy chỉnh. 🎉 
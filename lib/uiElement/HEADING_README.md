# Heading Component

Heading component cung cấp các cấp độ tiêu đề khác nhau cho Flutter app với khả năng tùy chỉnh cao.

## Các cấp độ Heading

### 1. H1 - Tiêu đề chính
Tiêu đề cấp cao nhất, thường dùng cho tiêu đề trang.

```dart
// Cơ bản
H1(text: 'Tiêu đề chính')

// Với icon
H1(
  text: 'Dashboard',
  icon: Icons.dashboard,
)

// Với trailing widget
H1(
  text: 'Thông báo',
  trailing: Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text('3', style: TextStyle(color: Colors.white)),
  ),
)
```

### 2. H2 - Tiêu đề phụ
Tiêu đề cấp hai, thường dùng cho tiêu đề phần.

```dart
// Cơ bản
H2(text: 'Tiêu đề phụ')

// Với màu sắc tùy chỉnh
H2(
  text: 'Thống kê',
  color: Colors.blue,
)

// Có thể click
H2(
  text: 'Nhấn để xem chi tiết',
  onTap: () {
    print('H2 được nhấn');
  },
)
```

### 3. H3 - Tiêu đề nhỏ
Tiêu đề cấp ba, thường dùng cho tiêu đề mục con.

```dart
// Cơ bản
H3(text: 'Tiêu đề nhỏ')

// Với icon và màu sắc
H3(
  text: 'Doanh thu',
  icon: Icons.trending_up,
  color: Colors.green,
)
```

### 4. H4, H5, H6 - Tiêu đề nhỏ hơn
Các tiêu đề cấp thấp hơn.

```dart
H4(text: 'Tiêu đề cấp 4')
H5(text: 'Tiêu đề cấp 5')
H6(text: 'Tiêu đề cấp 6')
```

## Special Heading Components

### PageTitle
Tiêu đề trang với kích thước lớn và font đậm.

```dart
PageTitle(
  text: 'Dashboard',
  icon: Icons.dashboard,
)
```

### SectionTitle
Tiêu đề phần với kích thước vừa.

```dart
SectionTitle(
  text: 'Thống kê',
  icon: Icons.analytics,
)
```

### SubsectionTitle
Tiêu đề mục con với kích thước nhỏ.

```dart
SubsectionTitle(
  text: 'Doanh thu tháng này',
  trailing: Icon(Icons.trending_up, color: Colors.green),
)
```

## Kích thước

Có 4 kích thước có sẵn:
- `HeadingSize.small`: 16px
- `HeadingSize.medium`: 20px
- `HeadingSize.large`: 24px
- `HeadingSize.xlarge`: 32px

```dart
H1(
  text: 'Heading với kích thước nhỏ',
  size: HeadingSize.small,
)

H2(
  text: 'Heading với kích thước lớn',
  size: HeadingSize.large,
)
```

## Trọng lượng font

Có 6 trọng lượng font có sẵn:
- `HeadingWeight.light`: w300
- `HeadingWeight.normal`: w400
- `HeadingWeight.medium`: w500
- `HeadingWeight.semibold`: w600
- `HeadingWeight.bold`: w700
- `HeadingWeight.extrabold`: w800

```dart
H2(
  text: 'Heading với font nhẹ',
  weight: HeadingWeight.light,
)

H2(
  text: 'Heading với font đậm',
  weight: HeadingWeight.bold,
)
```

## Tùy chỉnh

### Màu sắc tùy chỉnh
```dart
H2(
  text: 'Heading với màu tùy chỉnh',
  color: Colors.purple,
)
```

### Icon
```dart
H2(
  text: 'Heading với icon',
  icon: Icons.star,
)
```

### Trailing widget
```dart
H2(
  text: 'Heading với badge',
  trailing: Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text('NEW', style: TextStyle(color: Colors.white)),
  ),
)
```

### Có thể click
```dart
H2(
  text: 'Heading có thể click',
  onTap: () {
    print('Heading được nhấn');
  },
)
```

### Style đặc biệt
```dart
H2(
  text: 'Heading với gạch chân',
  underline: true,
)

H3(
  text: 'Heading với chữ nghiêng',
  italic: true,
)
```

### Căn chỉnh text
```dart
H2(
  text: 'Heading căn giữa',
  textAlign: TextAlign.center,
)

H2(
  text: 'Heading căn phải',
  textAlign: TextAlign.right,
)
```

### Margin và padding
```dart
H2(
  text: 'Heading với margin',
  margin: EdgeInsets.all(16),
)

H3(
  text: 'Heading với padding',
  padding: EdgeInsets.all(16),
)
```

### Giới hạn số dòng
```dart
H2(
  text: 'Heading này rất dài và sẽ bị cắt nếu vượt quá số dòng cho phép.',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

## Sử dụng Heading chung

Có thể sử dụng class `Heading` chính với enum `HeadingLevel`:

```dart
Heading(
  text: 'Custom Heading',
  level: HeadingLevel.h2,
  size: HeadingSize.large,
  weight: HeadingWeight.bold,
  color: Colors.blue,
  icon: Icons.star,
)
```

## Ví dụ thực tế

### Dashboard layout
```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(
              text: 'Dashboard',
              icon: Icons.dashboard,
            ),
            SizedBox(height: 24),
            
            SectionTitle(
              text: 'Thống kê tổng quan',
              icon: Icons.analytics,
            ),
            SizedBox(height: 16),
            
            // Stats cards
            Row(
              children: [
                Expanded(child: StatCard(title: 'Doanh thu', value: '1.2M')),
                SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Đơn hàng', value: '156')),
              ],
            ),
            SizedBox(height: 24),
            
            SubsectionTitle(
              text: 'Hoạt động gần đây',
              trailing: TextButton(
                onPressed: () {},
                child: Text('Xem tất cả'),
              ),
            ),
            SizedBox(height: 16),
            
            // Activity list
            ActivityList(),
          ],
        ),
      ),
    );
  }
}
```

### Product detail page
```dart
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product images
            ProductImageCarousel(images: product.images),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  H1(
                    text: product.name,
                    size: HeadingSize.large,
                  ),
                  SizedBox(height: 8),
                  
                  H3(
                    text: '\$${product.price}',
                    color: Colors.green,
                    weight: HeadingWeight.bold,
                  ),
                  SizedBox(height: 16),
                  
                  SectionTitle(
                    text: 'Mô tả sản phẩm',
                    icon: Icons.description,
                  ),
                  SizedBox(height: 8),
                  
                  Text(product.description),
                  SizedBox(height: 24),
                  
                  SubsectionTitle(
                    text: 'Đánh giá',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Text(' ${product.rating}'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Reviews list
                  ReviewsList(reviews: product.reviews),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Settings page
```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          PageTitle(
            text: 'Cài đặt',
            icon: Icons.settings,
          ),
          SizedBox(height: 24),
          
          SectionTitle(
            text: 'Tài khoản',
            icon: Icons.person,
          ),
          SettingsListTile(
            title: 'Thông tin cá nhân',
            icon: Icons.edit,
            onTap: () {},
          ),
          SettingsListTile(
            title: 'Đổi mật khẩu',
            icon: Icons.lock,
            onTap: () {},
          ),
          
          Divider(),
          
          SectionTitle(
            text: 'Thông báo',
            icon: Icons.notifications,
          ),
          SwitchListTile(
            title: Text('Thông báo đẩy'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('Email marketing'),
            value: false,
            onChanged: (value) {},
          ),
          
          Divider(),
          
          SubsectionTitle(
            text: 'Hỗ trợ',
            icon: Icons.help,
          ),
          SettingsListTile(
            title: 'Trung tâm trợ giúp',
            icon: Icons.help_center,
            onTap: () {},
          ),
          SettingsListTile(
            title: 'Liên hệ',
            icon: Icons.contact_support,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
```

## Demo

Để xem demo của tất cả các loại heading, hãy chạy:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => HeadingDemo()),
);
```

## Lưu ý

- Tất cả heading components đều có thiết kế responsive
- Có thể tùy chỉnh màu sắc, kích thước, trọng lượng font
- Hỗ trợ cả light và dark theme
- Có thể có icon, trailing widget và sự kiện onTap
- Hỗ trợ các style đặc biệt như underline, italic
- Có thể giới hạn số dòng và xử lý overflow
- Performance tốt với việc sử dụng StatelessWidget
- Tự động sử dụng theme colors nếu không chỉ định màu
- Có thể sử dụng trong layout, forms, cards, lists 
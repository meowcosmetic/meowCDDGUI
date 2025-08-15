# Card System Documentation

Hệ thống card hoàn chỉnh với title, mô tả ngắn, content và nhiều tùy chọn khác.

## Các loại Card

### 1. MeowCard (Default)
Card cơ bản với thiết kế mặc định.

```dart
MeowCard(
  title: 'Card Title',
  description: 'Card description',
  content: Text('Card content'),
  onTap: () => print('Card tapped'),
)
```

### 2. ElevatedMeowCard
Card có hiệu ứng đổ bóng và nổi lên.

```dart
ElevatedMeowCard(
  title: 'Elevated Card',
  description: 'Card with shadow',
  content: Text('Content with elevation'),
)
```

### 3. OutlinedMeowCard
Card có viền outline.

```dart
OutlinedMeowCard(
  title: 'Outlined Card',
  description: 'Card with border',
  content: Text('Content with outline'),
)
```

### 4. FilledMeowCard
Card có background màu.

```dart
FilledMeowCard(
  title: 'Filled Card',
  description: 'Card with background',
  content: Text('Content with background'),
)
```

## Kích thước Card

Có 3 kích thước: `small`, `medium`, `large`

```dart
MeowCard(
  title: 'Small Card',
  size: CardSize.small,
  content: Text('Small card content'),
)

MeowCard(
  title: 'Medium Card',
  size: CardSize.medium, // Mặc định
  content: Text('Medium card content'),
)

MeowCard(
  title: 'Large Card',
  size: CardSize.large,
  content: Text('Large card content'),
)
```

## Các thành phần của Card

### Title và Description
```dart
MeowCard(
  title: 'Card Title',
  description: 'This is a description of the card',
  content: Text('Content here'),
)
```

### Leading Widget
Widget hiển thị bên trái title (icon, avatar, etc.)

```dart
MeowCard(
  title: 'Card with Icon',
  leading: Icon(Icons.star, color: Colors.amber),
  content: Text('Content'),
)
```

### Trailing Widget
Widget hiển thị bên phải title

```dart
MeowCard(
  title: 'Card with Trailing',
  trailing: Icon(Icons.more_vert),
  content: Text('Content'),
)
```

### Content
Nội dung chính của card (có thể là bất kỳ widget nào)

```dart
MeowCard(
  title: 'Card with Rich Content',
  content: Column(
    children: [
      Text('Line 1'),
      Text('Line 2'),
      Image.network('https://example.com/image.jpg'),
    ],
  ),
)
```

### Actions
Các button hành động ở cuối card

```dart
MeowCard(
  title: 'Card with Actions',
  content: Text('Content'),
  actions: [
    GhostButton(
      text: 'Cancel',
      onPressed: () {},
    ),
    PrimaryButton(
      text: 'Save',
      onPressed: () {},
    ),
  ],
)
```

## Tùy chỉnh Card

### Màu sắc
```dart
MeowCard(
  title: 'Custom Colors',
  backgroundColor: Colors.blue[50],
  borderColor: Colors.blue,
  content: Text('Content'),
)
```

### Border Radius
```dart
MeowCard(
  title: 'Rounded Card',
  borderRadius: 20,
  content: Text('Content'),
)
```

### Padding và Margin
```dart
MeowCard(
  title: 'Custom Spacing',
  padding: EdgeInsets.all(24),
  margin: EdgeInsets.all(16),
  content: Text('Content'),
)
```

### Ẩn Divider
```dart
MeowCard(
  title: 'No Divider',
  content: Text('Content'),
  showDivider: false,
)
```

## Ví dụ sử dụng trong thực tế

### Product Card
```dart
MeowCard(
  title: 'Product Name',
  description: 'Premium Product',
  leading: Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: Color(0xFF4CAF50),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.shopping_bag, color: Colors.white),
  ),
  trailing: Text(
    '\$99.99',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF4CAF50),
    ),
  ),
  content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Features:'),
      Text('• Feature 1'),
      Text('• Feature 2'),
    ],
  ),
  actions: [
    OutlineButton(text: 'Details', onPressed: () {}),
    PrimaryButton(text: 'Buy Now', onPressed: () {}),
  ],
)
```

### Article Card
```dart
MeowCard(
  title: 'Article Title',
  description: 'Published on March 15, 2024',
  leading: CircleAvatar(
    backgroundColor: Color(0xFF4CAF50),
    child: Icon(Icons.article, color: Colors.white),
  ),
  trailing: Icon(Icons.bookmark_border),
  content: Text(
    'This is a sample article content that can be quite long...',
    style: TextStyle(height: 1.5),
  ),
  actions: [
    GhostButton(
      text: 'Share',
      icon: Icons.share,
      onPressed: () {},
    ),
    PrimaryButton(
      text: 'Read More',
      onPressed: () {},
    ),
  ],
)
```

## Các thuộc tính có sẵn

- `title`: Tiêu đề card (String?)
- `description`: Mô tả ngắn (String?)
- `content`: Nội dung chính (Widget?)
- `leading`: Widget bên trái title (Widget?)
- `trailing`: Widget bên phải title (Widget?)
- `actions`: Danh sách button hành động (List<Widget>?)
- `onTap`: Callback khi card được nhấn (VoidCallback?)
- `type`: Loại card (CardType.default_, elevated, outlined, filled)
- `size`: Kích thước card (CardSize.small, medium, large)
- `padding`: Padding bên trong card (EdgeInsetsGeometry?)
- `margin`: Margin bên ngoài card (EdgeInsetsGeometry?)
- `width`: Chiều rộng tùy chỉnh (double?)
- `height`: Chiều cao tùy chỉnh (double?)
- `backgroundColor`: Màu nền (Color?)
- `borderColor`: Màu viền (Color?)
- `borderRadius`: Bán kính góc (double?)
- `showDivider`: Hiển thị đường phân cách (bool)

## Tích hợp với Button System

Card system được thiết kế để hoạt động hoàn hảo với button system:

```dart
MeowCard(
  title: 'Form Card',
  content: Column(
    children: [
      TextField(decoration: InputDecoration(labelText: 'Name')),
      TextField(decoration: InputDecoration(labelText: 'Email')),
    ],
  ),
  actions: [
    SecondaryButton(
      text: 'Cancel',
      onPressed: () {},
    ),
    PrimaryButton(
      text: 'Submit',
      icon: Icons.send,
      onPressed: () {},
    ),
  ],
)
``` 
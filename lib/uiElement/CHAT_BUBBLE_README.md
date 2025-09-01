# Chat Bubble Component

Component chat bubble được thiết kế đẹp và hiện đại cho ứng dụng Flutter, hỗ trợ nhiều tính năng tùy chỉnh.

## Tính năng chính

- ✅ Thiết kế bong bóng chat đẹp mắt
- ✅ Hỗ trợ tin nhắn từ người dùng và người khác
- ✅ Hiển thị thời gian thông minh (hôm nay, hôm qua, ngày tháng)
- ✅ Hiển thị tên người gửi (tùy chọn)
- ✅ Avatar cho người gửi
- ✅ Icon đã đọc cho tin nhắn của mình
- ✅ Tùy chỉnh màu sắc
- ✅ Hỗ trợ tap vào tin nhắn
- ✅ Tự động wrap text cho tin nhắn dài
- ✅ Input chat với nút gửi
- ✅ Danh sách chat với scroll tự động

## Cách sử dụng

### 1. ChatBubble cơ bản

```dart
import 'package:your_app/uiElement/chat_bubble.dart';

ChatBubble(
  message: "Xin chào!",
  isFromMe: true,
  timestamp: DateTime.now(),
)
```

### 2. ChatBubble với tên người gửi

```dart
ChatBubble(
  message: "Tin nhắn từ chuyên gia",
  isFromMe: false,
  timestamp: DateTime.now(),
  senderName: "Chuyên gia tư vấn",
  showSenderName: true,
)
```

### 3. ChatBubble với màu tùy chỉnh

```dart
ChatBubble(
  message: "Tin nhắn với màu tùy chỉnh",
  isFromMe: true,
  timestamp: DateTime.now(),
  bubbleColor: Colors.green,
  textColor: Colors.white,
)
```

### 4. ChatBubble với onTap

```dart
ChatBubble(
  message: "Tap vào tin nhắn này",
  isFromMe: true,
  timestamp: DateTime.now(),
  onTap: () {
    print("Đã tap vào tin nhắn!");
  },
)
```

### 5. Sử dụng ChatList

```dart
final List<ChatMessage> messages = [
  ChatMessage(
    text: "Tin nhắn 1",
    isFromMe: true,
    timestamp: DateTime.now(),
  ),
  ChatMessage(
    text: "Tin nhắn 2",
    isFromMe: false,
    timestamp: DateTime.now(),
    senderName: "Người khác",
    showSenderName: true,
  ),
];

ChatList(
  messages: messages,
  scrollController: scrollController,
)
```

### 6. Sử dụng ChatInput

```dart
ChatInput(
  onSendMessage: (String text) {
    // Xử lý gửi tin nhắn
    print("Gửi tin nhắn: $text");
  },
  hintText: "Nhập tin nhắn...",
)
```

### 7. Chat hoàn chỉnh

```dart
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  void _sendMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isFromMe: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              messages: _messages,
              scrollController: _scrollController,
            ),
          ),
          ChatInput(
            onSendMessage: _sendMessage,
            controller: _textController,
          ),
        ],
      ),
    );
  }
}
```

## Tham số ChatBubble

| Tham số | Kiểu | Mặc định | Mô tả |
|---------|------|----------|-------|
| `message` | `String` | **Bắt buộc** | Nội dung tin nhắn |
| `isFromMe` | `bool` | **Bắt buộc** | `true` nếu là tin nhắn của mình, `false` nếu là của người khác |
| `timestamp` | `DateTime?` | `null` | Thời gian gửi tin nhắn |
| `senderName` | `String?` | `null` | Tên người gửi |
| `onTap` | `VoidCallback?` | `null` | Callback khi tap vào tin nhắn |
| `showTimestamp` | `bool` | `true` | Hiển thị thời gian |
| `showSenderName` | `bool` | `false` | Hiển thị tên người gửi |
| `bubbleColor` | `Color?` | `null` | Màu nền của bong bóng |
| `textColor` | `Color?` | `null` | Màu chữ |
| `maxWidth` | `double` | `280` | Chiều rộng tối đa của bong bóng |
| `padding` | `EdgeInsets` | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` | Padding xung quanh bong bóng |

## Tham số ChatList

| Tham số | Kiểu | Mặc định | Mô tả |
|---------|------|----------|-------|
| `messages` | `List<ChatMessage>` | **Bắt buộc** | Danh sách tin nhắn |
| `scrollController` | `ScrollController?` | `null` | Controller cho scroll |
| `padding` | `EdgeInsets` | `EdgeInsets.all(16)` | Padding của danh sách |
| `reverse` | `bool` | `false` | Đảo ngược thứ tự hiển thị |

## Tham số ChatInput

| Tham số | Kiểu | Mặc định | Mô tả |
|---------|------|----------|-------|
| `onSendMessage` | `Function(String)` | **Bắt buộc** | Callback khi gửi tin nhắn |
| `hintText` | `String?` | `"Nhập tin nhắn..."` | Placeholder text |
| `enabled` | `bool` | `true` | Cho phép nhập tin nhắn |
| `controller` | `TextEditingController?` | `null` | Controller cho text field |

## Model ChatMessage

```dart
class ChatMessage {
  final String text;           // Nội dung tin nhắn
  final bool isFromMe;         // Có phải tin nhắn của mình không
  final DateTime timestamp;    // Thời gian gửi
  final String? senderName;    // Tên người gửi
  final bool showSenderName;   // Hiển thị tên người gửi
}
```

## Demo

Để xem demo, sử dụng:

```dart
// Demo chat hoàn chỉnh
ChatBubbleDemo()

// Demo các loại chat bubble khác nhau
ChatBubbleVariantsDemo()
```

## Tùy chỉnh

### Thay đổi màu sắc mặc định

Component sử dụng `AppColors.primary` cho màu chính. Bạn có thể thay đổi trong file `app_colors.dart`.

### Thay đổi style

Để thay đổi style, bạn có thể:

1. Tùy chỉnh tham số `bubbleColor` và `textColor`
2. Sử dụng Theme của Flutter
3. Tạo extension hoặc wrapper component

### Thêm tính năng mới

Component được thiết kế mở rộng, bạn có thể dễ dàng thêm:

- Emoji picker
- File attachment
- Voice message
- Typing indicator
- Message status (sending, sent, delivered, read)

## Lưu ý

- Component tự động xử lý dark mode
- Tin nhắn dài sẽ được wrap tự động
- Thời gian được format thông minh (hôm nay, hôm qua, ngày tháng)
- Avatar được hiển thị cho cả tin nhắn của mình và người khác
- Icon đã đọc chỉ hiển thị cho tin nhắn của mình

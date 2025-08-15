# Loading Component

Loading component cung cấp nhiều kiểu loading khác nhau cho Flutter app với khả năng tùy chỉnh cao.

## Các loại Loading

### 1. Circular Loading
Loading dạng tròn xoay, phù hợp cho các tác vụ không xác định thời gian.

```dart
// Cơ bản
CircularLoading()

// Với text
CircularLoading(
  text: 'Loading...',
  showText: true,
)

// Tùy chỉnh màu sắc và kích thước
CircularLoading(
  size: LoadingSize.large,
  color: Colors.blue,
  text: 'Processing...',
  showText: true,
)
```

### 2. Linear Loading
Loading dạng thanh ngang, phù hợp cho các tác vụ có thể hiển thị tiến trình.

```dart
// Cơ bản
LinearLoading()

// Với text
LinearLoading(
  text: 'Uploading...',
  showText: true,
)

// Tùy chỉnh
LinearLoading(
  size: LoadingSize.large,
  color: Colors.green,
  text: 'Downloading...',
  showText: true,
)
```

### 3. Skeleton Loading
Loading dạng skeleton, phù hợp cho việc hiển thị placeholder cho content.

```dart
// Cơ bản
SkeletonLoading()

// Tùy chỉnh kích thước
SkeletonLoading(
  width: double.infinity,
  height: 20,
)

// Skeleton cho card
SkeletonLoading(
  size: LoadingSize.large,
  width: 60,
  height: 60,
)
```

### 4. Dots Loading
Loading dạng chấm nhấp nháy, phù hợp cho các tác vụ ngắn.

```dart
// Cơ bản
DotsLoading()

// Với text
DotsLoading(
  text: 'Connecting...',
  showText: true,
)

// Tùy chỉnh
DotsLoading(
  size: LoadingSize.large,
  color: Colors.red,
  text: 'Syncing...',
  showText: true,
)
```

### 5. Pulse Loading
Loading dạng xung động, phù hợp cho các tác vụ đang chờ.

```dart
// Cơ bản
PulseLoading()

// Với text
PulseLoading(
  text: 'Searching...',
  showText: true,
)

// Tùy chỉnh
PulseLoading(
  size: LoadingSize.large,
  color: Colors.purple,
  text: 'Analyzing...',
  showText: true,
)
```

## Kích thước

Có 3 kích thước có sẵn:
- `LoadingSize.small`: Nhỏ (20px)
- `LoadingSize.medium`: Vừa (32px) - Mặc định
- `LoadingSize.large`: Lớn (48px)

## Tùy chỉnh

### Màu sắc
```dart
Loading(
  type: LoadingType.circular,
  color: Colors.blue, // Tùy chỉnh màu
)
```

### Kích thước tùy chỉnh
```dart
Loading(
  type: LoadingType.circular,
  width: 40,  // Chiều rộng tùy chỉnh
  height: 40, // Chiều cao tùy chỉnh
)
```

### Text
```dart
Loading(
  type: LoadingType.circular,
  text: 'Loading data...',
  showText: true, // Hiển thị text
)
```

## Sử dụng trong Button

Loading component cũng được tích hợp sẵn trong Button component:

```dart
PrimaryButton(
  text: 'Submit',
  isLoading: true, // Hiển thị loading trong button
  onPressed: () {
    // Xử lý khi button được nhấn
  },
)
```

## Ví dụ thực tế

### Loading cho API call
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool isLoading = false;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Gọi API
      await Future.delayed(Duration(seconds: 2));
      // Xử lý dữ liệu
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading)
          CircularLoading(
            text: 'Loading data...',
            showText: true,
          )
        else
          Text('Data loaded!'),
        
        PrimaryButton(
          text: 'Load Data',
          isLoading: isLoading,
          onPressed: isLoading ? null : fetchData,
        ),
      ],
    );
  }
}
```

### Loading cho upload file
```dart
class UploadWidget extends StatefulWidget {
  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  bool isUploading = false;
  double progress = 0.0;

  Future<void> uploadFile() async {
    setState(() {
      isUploading = true;
      progress = 0.0;
    });

    // Giả lập upload với progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        progress = i / 100;
      });
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isUploading)
          LinearLoading(
            text: 'Uploading... ${(progress * 100).toInt()}%',
            showText: true,
          ),
        
        PrimaryButton(
          text: 'Upload File',
          isLoading: isUploading,
          onPressed: isUploading ? null : uploadFile,
        ),
      ],
    );
  }
}
```

### Skeleton loading cho list
```dart
class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  bool isLoading = true;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      products = generateProducts(); // Giả lập dữ liệu
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SkeletonLoading(
                    width: 60,
                    height: 60,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading(
                          width: double.infinity,
                          height: 16,
                        ),
                        SizedBox(height: 8),
                        SkeletonLoading(
                          width: 200,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
```

## Demo

Để xem demo của tất cả các loại loading, hãy chạy:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => LoadingDemo()),
);
```

## Lưu ý

- Tất cả loading components đều có animation mượt mà
- Có thể tùy chỉnh màu sắc, kích thước và text
- Tích hợp sẵn với Button component
- Hỗ trợ cả light và dark theme
- Performance tốt với việc sử dụng AnimationController hiệu quả 
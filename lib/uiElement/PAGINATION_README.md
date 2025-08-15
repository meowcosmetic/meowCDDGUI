# Pagination Component

Pagination component cung cấp các kiểu phân trang khác nhau cho Flutter app với khả năng tùy chỉnh cao.

## Các loại Pagination

### 1. NumbersPagination
Pagination với số trang và nút điều hướng, phù hợp cho danh sách dài.

```dart
// Cơ bản
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)

// Với thông tin chi tiết
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  totalItems: 100,
  itemsPerPage: 10,
  showInfo: true,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

### 2. DotsPagination
Pagination dạng chấm tròn, phù hợp cho carousel hoặc gallery.

```dart
// Cơ bản
DotsPagination(
  currentPage: 1,
  totalPages: 5,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)

// Với màu sắc tùy chỉnh
DotsPagination(
  currentPage: 1,
  totalPages: 5,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey[300],
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

### 3. ArrowsPagination
Pagination với mũi tên điều hướng, phù hợp cho mobile.

```dart
// Cơ bản
ArrowsPagination(
  currentPage: 1,
  totalPages: 10,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)

// Với màu sắc tùy chỉnh
ArrowsPagination(
  currentPage: 1,
  totalPages: 10,
  activeColor: Colors.green,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

### 4. SimplePagination
Pagination đơn giản với nút Trước/Sau, phù hợp cho danh sách ngắn.

```dart
// Cơ bản
SimplePagination(
  currentPage: 1,
  totalPages: 5,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)

// Với màu sắc tùy chỉnh
SimplePagination(
  currentPage: 1,
  totalPages: 5,
  activeColor: Colors.purple,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

## Kích thước

Có 3 kích thước có sẵn:
- `PaginationSize.small`: Nhỏ
- `PaginationSize.medium`: Vừa (Mặc định)
- `PaginationSize.large`: Lớn

```dart
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  size: PaginationSize.small,
  onPageChanged: (page) {},
)

DotsPagination(
  currentPage: 1,
  totalPages: 5,
  size: PaginationSize.large,
  onPageChanged: (page) {},
)
```

## Tùy chỉnh

### Màu sắc tùy chỉnh
```dart
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey[400],
  onPageChanged: (page) {},
)
```

### Ẩn nút Đầu/Cuối
```dart
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  showFirstLast: false,
  onPageChanged: (page) {},
)
```

### Số trang hiển thị tối đa
```dart
NumbersPagination(
  currentPage: 1,
  totalPages: 20,
  maxVisiblePages: 7,
  onPageChanged: (page) {},
)
```

### Hiển thị thông tin
```dart
NumbersPagination(
  currentPage: 1,
  totalPages: 10,
  totalItems: 100,
  itemsPerPage: 10,
  showInfo: true,
  onPageChanged: (page) {},
)
```

## Sử dụng Pagination chung

Có thể sử dụng class `Pagination` chính với enum `PaginationType`:

```dart
Pagination(
  currentPage: 1,
  totalPages: 10,
  type: PaginationType.numbers,
  size: PaginationSize.medium,
  onPageChanged: (page) {
    print('Chuyển đến trang $page');
  },
)
```

## Ví dụ thực tế

### Pagination trong danh sách sản phẩm
```dart
class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  int _currentPage = 1;
  int _totalPages = 10;
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi API để lấy sản phẩm theo trang
      final response = await ProductService.getProducts(page: _currentPage);
      setState(() {
        _products = response.products;
        _totalPages = response.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: _products[index]);
                  },
                ),
        ),
        NumbersPagination(
          currentPage: _currentPage,
          totalPages: _totalPages,
          totalItems: _totalPages * 10,
          itemsPerPage: 10,
          showInfo: true,
          onPageChanged: _onPageChanged,
        ),
      ],
    );
  }
}
```

### Pagination trong carousel
```dart
class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({required this.images});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        DotsPagination(
          currentPage: _currentIndex + 1,
          totalPages: widget.images.length,
          onPageChanged: (page) {
            _pageController.animateToPage(
              page - 1,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }
}
```

### Pagination với search
```dart
class SearchResults extends StatefulWidget {
  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  List<SearchResult> _results = [];

  Future<void> _search(String query, {int page = 1}) async {
    if (query.isEmpty) return;

    try {
      final response = await SearchService.search(
        query: query,
        page: page,
      );
      
      setState(() {
        _results = response.results;
        _totalPages = response.totalPages;
        _currentPage = page;
        _searchQuery = query;
      });
    } catch (e) {
      // Xử lý lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search input
        TextField(
          onSubmitted: (query) => _search(query),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            suffixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        
        // Results
        Expanded(
          child: _results.isEmpty
              ? Center(child: Text('Không có kết quả'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return SearchResultCard(result: _results[index]);
                  },
                ),
        ),
        
        // Pagination
        if (_totalPages > 1)
          SimplePagination(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: (page) {
              _search(_searchQuery, page: page);
            },
          ),
      ],
    );
  }
}
```

## Demo

Để xem demo của tất cả các loại pagination, hãy chạy:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => PaginationDemo()),
);
```

## Lưu ý

- Tất cả pagination components đều có thiết kế responsive
- Có thể tùy chỉnh màu sắc, kích thước và hành vi
- Hỗ trợ cả light và dark theme
- Performance tốt với việc sử dụng StatelessWidget
- Có thể sử dụng trong danh sách, carousel, search results
- Ellipsis (...) được hiển thị tự động khi có nhiều trang
- Hỗ trợ thông tin chi tiết về items và pages 
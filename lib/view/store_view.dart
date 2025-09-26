import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  String selectedCategory = 'Tất cả';
  String searchQuery = '';
  List<StoreItem> items = [];
  List<StoreItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadStoreItems();
  }

  void _loadStoreItems() {
    // Dữ liệu mẫu cho cửa hàng
    items = [
      StoreItem(
        id: '1',
        name: 'Bộ đồ chơi giao tiếp cho trẻ tự kỷ',
        description:
            'Bộ đồ chơi hỗ trợ phát triển kỹ năng giao tiếp và tương tác xã hội',
        price: 250000,
        originalPrice: 300000,
        imageUrl:
            'https://via.placeholder.com/200x200/4CAF50/FFFFFF?text=Toy+1',
        category: 'Đồ chơi giáo dục',
        rating: 4.5,
        reviewCount: 128,
        inStock: true,
        discount: 17,
      ),
      StoreItem(
        id: '2',
        name: 'Sách tương tác cảm ứng',
        description:
            'Sách có các nút cảm ứng phát âm thanh, giúp trẻ học từ vựng',
        price: 180000,
        originalPrice: 200000,
        imageUrl:
            'https://via.placeholder.com/200x200/2196F3/FFFFFF?text=Book+1',
        category: 'Sách tương tác',
        rating: 4.8,
        reviewCount: 95,
        inStock: true,
        discount: 10,
      ),
      StoreItem(
        id: '3',
        name: 'Bộ ghép hình phát triển tư duy',
        description:
            'Bộ ghép hình với nhiều mức độ khó khác nhau, phù hợp từng lứa tuổi',
        price: 120000,
        originalPrice: 150000,
        imageUrl:
            'https://via.placeholder.com/200x200/FF9800/FFFFFF?text=Puzzle+1',
        category: 'Đồ chơi giáo dục',
        rating: 4.3,
        reviewCount: 67,
        inStock: true,
        discount: 20,
      ),
      StoreItem(
        id: '4',
        name: 'Bộ dụng cụ vận động tinh',
        description: 'Bộ dụng cụ hỗ trợ phát triển vận động tinh cho trẻ',
        price: 350000,
        originalPrice: 400000,
        imageUrl:
            'https://via.placeholder.com/200x200/9C27B0/FFFFFF?text=Tools+1',
        category: 'Dụng cụ trị liệu',
        rating: 4.7,
        reviewCount: 43,
        inStock: false,
        discount: 13,
      ),
      StoreItem(
        id: '5',
        name: 'Thẻ học từ vựng bằng hình ảnh',
        description:
            'Bộ thẻ học từ vựng với hình ảnh minh họa rõ ràng, dễ hiểu',
        price: 89000,
        originalPrice: 120000,
        imageUrl:
            'https://via.placeholder.com/200x200/F44336/FFFFFF?text=Cards+1',
        category: 'Tài liệu học tập',
        rating: 4.6,
        reviewCount: 156,
        inStock: true,
        discount: 26,
      ),
      StoreItem(
        id: '6',
        name: 'Bộ đồ chơi cảm giác',
        description:
            'Bộ đồ chơi kích thích các giác quan, phù hợp cho trẻ tự kỷ',
        price: 280000,
        originalPrice: 320000,
        imageUrl:
            'https://via.placeholder.com/200x200/00BCD4/FFFFFF?text=Sensory+1',
        category: 'Đồ chơi cảm giác',
        rating: 4.4,
        reviewCount: 89,
        inStock: true,
        discount: 13,
      ),
    ];
    filteredItems = items;
  }

  void _filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        final matchesCategory =
            selectedCategory == 'Tất cả' || item.category == selectedCategory;
        final matchesSearch =
            searchQuery.isEmpty ||
            item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Cửa Hàng'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Navigate to cart
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Giỏ hàng đang được phát triển')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    searchQuery = value;
                    _filterItems();
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.grey50,
                  ),
                ),
                const SizedBox(height: 12),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                              'Tất cả',
                              'Đồ chơi giáo dục',
                              'Sách tương tác',
                              'Dụng cụ trị liệu',
                              'Tài liệu học tập',
                              'Đồ chơi cảm giác',
                            ]
                            .map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: selectedCategory == category,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedCategory = category;
                                      _filterItems();
                                    });
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Store Items
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildStoreItem(filteredItems[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(StoreItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Discount Badge
                  if (item.discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '-${item.discount}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Out of Stock Badge
                  if (!item.inStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Hết hàng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating} (${item.reviewCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        '${_formatPrice(item.price)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (item.originalPrice > item.price) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${_formatPrice(item.originalPrice)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: item.inStock ? () => _addToCart(item) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        item.inStock ? 'Thêm vào giỏ' : 'Hết hàng',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi bộ lọc hoặc tìm kiếm',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _addToCart(StoreItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${item.name}" vào giỏ hàng'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
          textColor: AppColors.white,
          onPressed: () {
            // TODO: Navigate to cart
          },
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0)}k';
  }
}

class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final int originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int discount;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.discount,
  });
}

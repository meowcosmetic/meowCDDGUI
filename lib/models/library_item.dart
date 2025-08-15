/// Model cho đánh giá và nhận xét
class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVerified;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVerified = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}

/// Model cho tài liệu trong thư viện
class LibraryItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String domain; // Lĩnh vực: giao tiếp, vận động, nhận thức, xã hội, cảm xúc
  final String fileUrl;
  final String thumbnailUrl;
  final String author;
  final DateTime publishDate;
  final int viewCount;
  final double rating;
  final int ratingCount;
  final String fileType; // pdf, video, audio, image
  final int fileSize; // bytes
  final String language;
  final List<String> tags;
  final bool isFeatured;
  final bool isFree;
  final String targetAge; // 3-5, 6-8, 9-12, etc.
  final String difficulty; // beginner, intermediate, advanced
  final List<Review> reviews;
  final String content; // Nội dung tài liệu để đọc trực tiếp

  const LibraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.domain,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.author,
    required this.publishDate,
    required this.viewCount,
    required this.rating,
    required this.ratingCount,
    required this.fileType,
    required this.fileSize,
    required this.language,
    required this.tags,
    required this.isFeatured,
    required this.isFree,
    required this.targetAge,
    required this.difficulty,
    required this.reviews,
    required this.content,
  });

  /// Tạo từ JSON
  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      domain: json['domain'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      author: json['author'] ?? '',
      publishDate: DateTime.parse(json['publishDate'] ?? DateTime.now().toIso8601String()),
      viewCount: json['viewCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      fileType: json['fileType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      language: json['language'] ?? 'Tiếng Việt',
      tags: List<String>.from(json['tags'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
      isFree: json['isFree'] ?? true,
      targetAge: json['targetAge'] ?? '3-6',
      difficulty: json['difficulty'] ?? 'beginner',
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((review) => Review.fromJson(review))
          .toList() ?? [],
      content: json['content'] ?? '',
    );
  }

  /// Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'domain': domain,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'author': author,
      'publishDate': publishDate.toIso8601String(),
      'viewCount': viewCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'fileType': fileType,
      'fileSize': fileSize,
      'language': language,
      'tags': tags,
      'isFeatured': isFeatured,
      'isFree': isFree,
      'targetAge': targetAge,
      'difficulty': difficulty,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'content': content,
    };
  }

  /// Lấy icon theo loại file
  String getFileTypeIcon() {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'video':
        return 'video_library';
      case 'audio':
        return 'audiotrack';
      case 'image':
        return 'image';
      case 'document':
        return 'description';
      default:
        return 'insert_drive_file';
    }
  }

  /// Lấy màu theo loại file
  int getFileTypeColor() {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 0xFFF44336; // Red
      case 'video':
        return 0xFF2196F3; // Blue
      case 'audio':
        return 0xFF4CAF50; // Green
      case 'image':
        return 0xFFFF9800; // Orange
      case 'document':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Lấy text loại file
  String getFileTypeText() {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'image':
        return 'Hình ảnh';
      case 'document':
        return 'Tài liệu';
      default:
        return 'File';
    }
  }

  /// Lấy text kích thước file
  String getFileSizeText() {
    if (fileSize < 1024) {
      return '${fileSize} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Lấy text độ khó
  String getDifficultyText() {
    switch (difficulty) {
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return 'Cơ bản';
    }
  }

  /// Lấy màu độ khó
  int getDifficultyColor() {
    switch (difficulty) {
      case 'beginner':
        return 0xFF4CAF50; // Green
      case 'intermediate':
        return 0xFFFF9800; // Orange
      case 'advanced':
        return 0xFFF44336; // Red
      default:
        return 0xFF4CAF50; // Green
    }
  }

  /// Lấy text lĩnh vực
  String getDomainText() {
    switch (domain) {
      case 'communication':
        return 'Giao tiếp';
      case 'motor':
        return 'Vận động';
      case 'cognitive':
        return 'Nhận thức';
      case 'social':
        return 'Xã hội';
      case 'emotional':
        return 'Cảm xúc';
      default:
        return 'Khác';
    }
  }

  /// Lấy màu lĩnh vực
  int getDomainColor() {
    switch (domain) {
      case 'communication':
        return 0xFF2196F3; // Blue
      case 'motor':
        return 0xFF4CAF50; // Green
      case 'cognitive':
        return 0xFFFF9800; // Orange
      case 'social':
        return 0xFF9C27B0; // Purple
      case 'emotional':
        return 0xFFE91E63; // Pink
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  @override
  String toString() {
    return 'LibraryItem(id: $id, title: $title, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibraryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Dữ liệu mẫu cho thư viện
class SampleLibraryItems {
  static List<LibraryItem> getSampleData() {
    return [
      LibraryItem(
        id: '1',
        title: 'Hướng Dẫn Can Thiệp Sớm Cho Trẻ Tự Kỷ',
        description: 'Tài liệu hướng dẫn chi tiết các phương pháp can thiệp sớm cho trẻ rối loạn phổ tự kỷ từ 2-6 tuổi.',
        category: 'Hướng dẫn',
        domain: 'communication',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Bác sĩ Nguyễn Thị Minh',
        publishDate: DateTime.now().subtract(const Duration(days: 30)),
        viewCount: 1250,
        rating: 4.8,
        ratingCount: 89,
        fileType: 'pdf',
        fileSize: 2048576, // 2MB
        language: 'Tiếng Việt',
        tags: ['can thiệp sớm', 'tự kỷ', 'hướng dẫn', 'phụ huynh'],
        isFeatured: true,
        isFree: true,
        targetAge: '2-6',
        difficulty: 'beginner',
        reviews: [
          Review(
            id: '1',
            userId: 'user1',
            userName: 'Phụ huynh A',
            rating: 5.0,
            comment: 'Tài liệu rất hữu ích, hướng dẫn chi tiết và dễ hiểu.',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            isVerified: true,
          ),
        ],
        content: '# Hướng Dẫn Can Thiệp Sớm\n\n## Giới thiệu\nCan thiệp sớm là yếu tố quan trọng nhất trong việc hỗ trợ trẻ rối loạn phổ tự kỷ phát triển toàn diện.\n\n## Các nguyên tắc cơ bản\n\n### 1. Can thiệp sớm\n- Bắt đầu càng sớm càng tốt, tốt nhất là trước 3 tuổi\n- Can thiệp liên tục và nhất quán\n- Tập trung vào các kỹ năng cơ bản\n\n### 2. Phương pháp ABA\n- Phân tích hành vi ứng dụng\n- Sử dụng các kỹ thuật củng cố tích cực\n- Theo dõi tiến độ thường xuyên',
      ),
      LibraryItem(
        id: '2',
        title: 'Bài Tập Giao Tiếp Cho Trẻ Tự Kỷ',
        description: 'Bộ bài tập thực hành giao tiếp với hình ảnh minh họa và hướng dẫn chi tiết.',
        category: 'Bài tập',
        domain: 'communication',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Chuyên gia Lê Văn Hùng',
        publishDate: DateTime.now().subtract(const Duration(days: 15)),
        viewCount: 890,
        rating: 4.6,
        ratingCount: 67,
        fileType: 'pdf',
        fileSize: 1536000, // 1.5MB
        language: 'Tiếng Việt',
        tags: ['giao tiếp', 'bài tập', 'thực hành', 'hình ảnh'],
        isFeatured: false,
        isFree: true,
        targetAge: '3-8',
        difficulty: 'intermediate',
        reviews: [
          Review(
            id: '2',
            userId: 'user2',
            userName: 'Phụ huynh B',
            rating: 4.5,
            comment: 'Bài tập rất thực tế, con tôi thích thú khi thực hiện.',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            isVerified: true,
          ),
        ],
        content: '# Bài Tập Giao Tiếp\n\n## Bài tập 1: Nhận diện cảm xúc\n\n### Mục tiêu\nTrẻ có thể nhận diện và gọi tên các cảm xúc cơ bản.\n\n### Cách thực hiện\n1. Cho trẻ xem hình ảnh khuôn mặt\n2. Hỏi "Bạn này đang cảm thấy gì?"\n3. Hướng dẫn trẻ trả lời: vui, buồn, giận, sợ\n4. Lặp lại nhiều lần với các hình ảnh khác nhau',
      ),
      LibraryItem(
        id: '3',
        title: 'Video Hướng Dẫn Vận Động Tinh',
        description: 'Video minh họa các bài tập vận động tinh giúp trẻ phát triển kỹ năng cầm bút và vẽ.',
        category: 'Video',
        domain: 'motor',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Thạc sĩ Trần Thị Lan',
        publishDate: DateTime.now().subtract(const Duration(days: 7)),
        viewCount: 567,
        rating: 4.9,
        ratingCount: 45,
        fileType: 'video',
        fileSize: 52428800, // 50MB
        language: 'Tiếng Việt',
        tags: ['vận động tinh', 'video', 'cầm bút', 'vẽ'],
        isFeatured: true,
        isFree: true,
        targetAge: '4-7',
        difficulty: 'beginner',
        reviews: [
          Review(
            id: '3',
            userId: 'user3',
            userName: 'Phụ huynh C',
            rating: 5.0,
            comment: 'Video rất rõ ràng, con tôi học được nhiều kỹ năng mới.',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            isVerified: true,
          ),
        ],
        content: '# Video Hướng Dẫn Vận Động Tinh\n\n## Nội dung video\n\n### Phần 1: Khởi động (5 phút)\n- Các bài tập khởi động tay và ngón tay\n- Massage và thư giãn cơ bắp\n- Chuẩn bị tư thế ngồi đúng\n\n### Phần 2: Cầm bút đúng cách (10 phút)\n- Hướng dẫn cách cầm bút chì\n- Tư thế ngồi và vị trí tay\n- Các bài tập luyện cơ tay',
      ),
      LibraryItem(
        id: '4',
        title: 'Audio Bài Hát Giao Tiếp',
        description: 'Bộ sưu tập bài hát và âm thanh giúp trẻ học giao tiếp và phát âm.',
        category: 'Audio',
        domain: 'communication',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Nhạc sĩ Phạm Văn Tú',
        publishDate: DateTime.now().subtract(const Duration(days: 45)),
        viewCount: 2340,
        rating: 4.7,
        ratingCount: 156,
        fileType: 'audio',
        fileSize: 15728640, // 15MB
        language: 'Tiếng Việt',
        tags: ['audio', 'bài hát', 'giao tiếp', 'phát âm'],
        isFeatured: false,
        isFree: true,
        targetAge: '2-6',
        difficulty: 'beginner',
        reviews: [
          Review(
            id: '4',
            userId: 'user4',
            userName: 'Phụ huynh D',
            rating: 4.5,
            comment: 'Bài hát dễ thương, con tôi thích nghe và hát theo.',
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
            isVerified: true,
          ),
        ],
        content: '# Audio Bài Hát Giao Tiếp\n\n## Danh sách bài hát\n\n### 1. Chào hỏi (2:30)\n**Lời bài hát:**\n"Chào bạn, chào bạn\nChúng ta cùng chơi\nChào bạn, chào bạn\nRất vui gặp bạn"\n\n### 2. Đếm số (3:15)\n**Lời bài hát:**\n"Một, hai, ba, bốn, năm\nSáu, bảy, tám, chín, mười\nĐếm số thật vui\nCùng đếm nào bạn ơi"',
      ),
      LibraryItem(
        id: '5',
        title: 'Tài Liệu Đánh Giá Trẻ Tự Kỷ',
        description: 'Bộ công cụ đánh giá và theo dõi tiến độ phát triển của trẻ rối loạn phổ tự kỷ.',
        category: 'Đánh giá',
        domain: 'cognitive',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Tiến sĩ Võ Thị Mai',
        publishDate: DateTime.now().subtract(const Duration(days: 60)),
        viewCount: 678,
        rating: 4.5,
        ratingCount: 34,
        fileType: 'document',
        fileSize: 3072000, // 3MB
        language: 'Tiếng Việt',
        tags: ['đánh giá', 'theo dõi', 'tiến độ', 'phát triển'],
        isFeatured: false,
        isFree: false,
        targetAge: '2-12',
        difficulty: 'advanced',
        reviews: [
          Review(
            id: '5',
            userId: 'user5',
            userName: 'Chuyên gia E',
            rating: 4.8,
            comment: 'Tài liệu chuyên môn cao, rất hữu ích cho việc đánh giá.',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            isVerified: true,
          ),
        ],
        content: '# Tài Liệu Đánh Giá Trẻ Tự Kỷ\n\n## Bảng đánh giá phát triển\n\n### Lĩnh vực Giao tiếp\n**Điểm tối đa: 20**\n- Phát âm rõ ràng: 0-5 điểm\n- Hiểu lời nói: 0-5 điểm\n- Sử dụng từ vựng: 0-5 điểm\n- Tương tác xã hội: 0-5 điểm\n\n### Lĩnh vực Vận động\n**Điểm tối đa: 20**\n- Vận động thô: 0-5 điểm\n- Vận động tinh: 0-5 điểm\n- Phối hợp tay mắt: 0-5 điểm\n- Cân bằng và định hướng: 0-5 điểm',
      ),
      LibraryItem(
        id: '6',
        title: 'Hình Ảnh Hỗ Trợ Giao Tiếp',
        description: 'Bộ hình ảnh PECS (Picture Exchange Communication System) hỗ trợ giao tiếp cho trẻ tự kỷ.',
        category: 'Hình ảnh',
        domain: 'communication',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Chuyên gia Đặng Văn Nam',
        publishDate: DateTime.now().subtract(const Duration(days: 20)),
        viewCount: 1890,
        rating: 4.8,
        ratingCount: 123,
        fileType: 'image',
        fileSize: 10485760, // 10MB
        language: 'Tiếng Việt',
        tags: ['PECS', 'hình ảnh', 'giao tiếp', 'hỗ trợ'],
        isFeatured: true,
        isFree: true,
        targetAge: '3-10',
        difficulty: 'intermediate',
        reviews: [
          Review(
            id: '6',
            userId: 'user6',
            userName: 'Phụ huynh F',
            rating: 4.9,
            comment: 'Hình ảnh rõ ràng, dễ hiểu, con tôi học giao tiếp nhanh hơn.',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            isVerified: true,
          ),
        ],
        content: '# Hình Ảnh Hỗ Trợ Giao Tiếp (PECS)\n\n## Bộ hình ảnh cơ bản\n\n### 1. Nhu cầu cơ bản\n- [Hình] Tôi muốn ăn\n- [Hình] Tôi muốn uống\n- [Hình] Tôi muốn đi vệ sinh\n- [Hình] Tôi muốn nghỉ ngơi\n\n### 2. Cảm xúc\n- [Hình] Tôi vui\n- [Hình] Tôi buồn\n- [Hình] Tôi giận\n- [Hình] Tôi sợ\n\n## Cách sử dụng\n1. In hình ảnh và dán lên bảng\n2. Hướng dẫn trẻ chỉ hình khi cần\n3. Khuyến khích trẻ kết hợp nhiều hình\n4. Tăng dần độ phức tạp',
      ),
      LibraryItem(
        id: '7',
        title: 'Sách Hướng Dẫn Phụ Huynh',
        description: 'Sách điện tử hướng dẫn phụ huynh cách chăm sóc và hỗ trợ trẻ tự kỷ tại nhà.',
        category: 'Sách',
        domain: 'social',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Bác sĩ Lê Thị Hoa',
        publishDate: DateTime.now().subtract(const Duration(days: 90)),
        viewCount: 3450,
        rating: 4.9,
        ratingCount: 234,
        fileType: 'pdf',
        fileSize: 8388608, // 8MB
        language: 'Tiếng Việt',
        tags: ['sách', 'phụ huynh', 'chăm sóc', 'tại nhà'],
        isFeatured: true,
        isFree: false,
        targetAge: 'Phụ huynh',
        difficulty: 'intermediate',
        reviews: [
          Review(
            id: '7',
            userId: 'user7',
            userName: 'Phụ huynh G',
            rating: 5.0,
            comment: 'Sách rất hữu ích, giúp tôi hiểu rõ hơn về cách chăm sóc con.',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            isVerified: true,
          ),
        ],
        content: '# Sách Hướng Dẫn Phụ Huynh\n\n## Chương 1: Hiểu về tự kỷ\n\n### Định nghĩa và đặc điểm\nRối loạn phổ tự kỷ (ASD) là một rối loạn phát triển thần kinh ảnh hưởng đến cách trẻ giao tiếp, tương tác xã hội và hành vi.\n\n### Dấu hiệu nhận biết\n- Chậm nói hoặc không nói\n- Khó khăn trong giao tiếp mắt\n- Không thích chơi với bạn\n- Có hành vi lặp lại\n- Nhạy cảm với âm thanh, ánh sáng\n\n## Chương 2: Tạo môi trường hỗ trợ\n\n### Môi trường vật lý\n- Tạo không gian yên tĩnh\n- Sắp xếp đồ đạc có tổ chức\n- Sử dụng lịch trình trực quan\n- Tạo góc học tập riêng',
      ),
      LibraryItem(
        id: '8',
        title: 'Bài Tập Nhận Thức Nâng Cao',
        description: 'Bộ bài tập nhận thức dành cho trẻ tự kỷ có khả năng học tập tốt.',
        category: 'Bài tập',
        domain: 'cognitive',
        fileUrl: '',
        thumbnailUrl: '',
        author: 'Thạc sĩ Nguyễn Văn Dũng',
        publishDate: DateTime.now().subtract(const Duration(days: 10)),
        viewCount: 456,
        rating: 4.4,
        ratingCount: 28,
        fileType: 'pdf',
        fileSize: 2097152, // 2MB
        language: 'Tiếng Việt',
        tags: ['nhận thức', 'nâng cao', 'học tập', 'bài tập'],
        isFeatured: false,
        isFree: false,
        targetAge: '6-12',
        difficulty: 'advanced',
        reviews: [
          Review(
            id: '8',
            userId: 'user8',
            userName: 'Phụ huynh H',
            rating: 4.2,
            comment: 'Bài tập khó nhưng hiệu quả, con tôi tiến bộ rõ rệt.',
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
            isVerified: true,
          ),
        ],
        content: '# Bài Tập Nhận Thức Nâng Cao\n\n## Bài tập 1: Phân loại đối tượng\n\n### Mục tiêu\nTrẻ có thể phân loại đồ vật theo nhiều tiêu chí khác nhau.\n\n### Cách thực hiện\n1. Chuẩn bị các đồ vật khác nhau\n2. Yêu cầu trẻ phân loại theo màu sắc\n3. Sau đó phân loại theo hình dạng\n4. Cuối cùng phân loại theo chức năng\n\n## Bài tập 2: Giải quyết vấn đề\n\n### Mục tiêu\nTrẻ có thể tìm ra cách giải quyết các tình huống đơn giản.\n\n### Tình huống 1: Tìm đường\n"Bạn nhỏ muốn đến trường nhưng đường bị tắc, bạn ấy phải làm gì?"',
      ),
    ];
  }

  /// Lấy danh sách categories
  static List<String> getCategories() {
    return [
      'Tất cả',
      'Hướng dẫn',
      'Bài tập',
      'Video',
      'Audio',
      'Hình ảnh',
      'Sách',
      'Đánh giá',
    ];
  }

  /// Lấy danh sách domains
  static List<String> getDomains() {
    return [
      'Tất cả',
      'communication',
      'motor',
      'cognitive',
      'social',
      'emotional',
    ];
  }

  /// Lấy danh sách target ages
  static List<String> getTargetAges() {
    return [
      'Tất cả',
      '2-6',
      '3-8',
      '4-7',
      '6-12',
      'Phụ huynh',
    ];
  }

  /// Lấy danh sách difficulties
  static List<String> getDifficulties() {
    return [
      'Tất cả',
      'beginner',
      'intermediate',
      'advanced',
    ];
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../models/library_item.dart';
import '../../models/api_service.dart';
import 'pdf_viewer.dart';
import 'pages/add_book_page.dart';
import 'pages/add_video_page.dart';
import 'pages/add_post_page.dart';
import 'widgets/pdf_list_widget.dart';
import '../intervention_domains/models/domain_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

// Lightweight API response models for books
class BookApiResponse {
  final List<ApiBook> content;
  final bool hasNext;

  BookApiResponse({required this.content, required this.hasNext});

  factory BookApiResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['content'] as List<dynamic>? ?? [])
        .map((e) => ApiBook.fromJson(e as Map<String, dynamic>))
        .toList();
    final page = json['page'] as Map<String, dynamic>?;
    final hasNext = (page != null)
        ? (page['hasNext'] ?? page['hasNextPage'] ?? page['hasNextSlice'] ?? false) == true
        : (json['hasNext'] ?? json['hasNextPage'] ?? false) == true;
    return BookApiResponse(content: list, hasNext: hasNext);
  }
}

class ApiBook {
  final String id;
  final String title;
  final String description;
  final String author;
  final String fileType;
  final String domain;
  final String targetAge;
  final double rating;
  final int ratingCount;
  final int viewCount;
  final String? content;

  ApiBook({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.fileType,
    required this.domain,
    required this.targetAge,
    required this.rating,
    required this.ratingCount,
    required this.viewCount,
    this.content,
  });

  factory ApiBook.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) => v?.toString() ?? '';
    int safeInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    double safeDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return ApiBook(
      id: safeString(json['id'] ?? json['bookId']),
      title: safeString(json['title'] ?? json['name']),
      description: safeString(json['description'] ?? ''),
      author: safeString(json['author'] ?? ''),
      fileType: safeString(json['fileType'] ?? json['format'] ?? ''),
      domain: safeString(json['domain'] ?? json['category'] ?? ''),
      targetAge: safeString(json['targetAge'] ?? json['ageRange'] ?? ''),
      rating: safeDouble(json['rating'] ?? json['averageRating']),
      ratingCount: safeInt(json['ratingCount'] ?? json['reviewsCount']),
      viewCount: safeInt(json['viewCount'] ?? json['views']),
      content: json['content']?.toString(),
    );
  }

  LibraryItem toLibraryItem() {
    return LibraryItem(
      id: id,
      title: title,
      description: description,
      category: fileType.isEmpty ? 'document' : fileType,
      domain: domain.isEmpty ? 'other' : domain,
      fileUrl: '',
      thumbnailUrl: '',
      author: author.isEmpty ? 'Không rõ' : author,
      publishDate: DateTime.now(),
      viewCount: viewCount,
      rating: rating,
      ratingCount: ratingCount,
      fileType: fileType.isEmpty ? 'document' : fileType,
      fileSize: 0,
      language: 'vi',
      tags: const [],
      isFeatured: false,
      isFree: true,
      targetAge: targetAge.isEmpty ? 'Tất cả' : targetAge,
      difficulty: 'beginner',
      reviews: const [],
      content: content ?? '',
    );
  }
}

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  List<LibraryItem> items = [];
  List<LibraryItem> filteredItems = [];
  String searchQuery = '';
  String selectedTargetAge = 'Tất cả';
  String selectedDomain = 'Tất cả';
  String selectedCategory = 'Tất cả';
  List<Map<String, dynamic>> domains = [];
  bool isLoadingDomains = false;
  String currentLocale = 'vi';
  OverlayEntry? _domainTooltipEntry;
  List<Map<String, dynamic>> formats = [];
  bool isLoadingFormats = false;
  List<String> filterTargetAges = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();
  int currentPage = 0;
  bool hasMoreData = true;
  // YouTube videos state
  bool showingYoutube = true;
  bool isLoadingYoutube = false;
  bool hasLoadedYoutube = false;
  List<Map<String, dynamic>> youtubeVideos = [];

  @override
  void initState() {
    super.initState();
    _loadLibraryItems();
    _loadDomains();
    _loadFormats();
    // Build target ages list including range 0-2
    final baseAges = SampleLibraryItems.getTargetAges();
    filterTargetAges = ['Tất cả', '0-2', ...{
      ...baseAges.where((e) => e != 'Tất cả' && e != '0' && e != '1' && e != '2')
    }.toList()];
  }

  Future<void> _loadYoutubeVideos() async {
    if (isLoadingYoutube || hasLoadedYoutube) return;
    
    try {
      setState(() {
        isLoadingYoutube = true;
      });
      final resp = await _apiService.getYoutubeVideos();
      if (resp.statusCode == 200) {
        final dynamic body = jsonDecode(resp.body);
        List<dynamic> list;
        if (body is List) {
          list = body;
        } else if (body is Map<String, dynamic> && body['content'] is List) {
          list = body['content'] as List;
        } else {
          list = [];
        }
        setState(() {
          youtubeVideos = list.map((e) => (e as Map).cast<String, dynamic>()).toList();
          isLoadingYoutube = false;
          hasLoadedYoutube = true;
        });
      } else {
        setState(() {
          youtubeVideos = [];
          isLoadingYoutube = false;
          hasLoadedYoutube = true;
        });
      }
    } catch (_) {
      setState(() {
        youtubeVideos = [];
        isLoadingYoutube = false;
        hasLoadedYoutube = true;
      });
    }
  }

  Future<void> _loadDomains() async {
    try {
      setState(() {
        isLoadingDomains = true;
      });
      final resp = await _apiService.getDevelopmentalDomains();
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        setState(() {
          domains = data.cast<Map<String, dynamic>>();
          isLoadingDomains = false;
        });
      } else {
        setState(() {
          isLoadingDomains = false;
        });
      }
    } catch (_) {
      setState(() {
        isLoadingDomains = false;
      });
    }
  }

  Future<void> _loadFormats() async {
    try {
      setState(() {
        isLoadingFormats = true;
      });
      final resp = await _apiService.getSupportedFormats();
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        setState(() {
          formats = data.cast<Map<String, dynamic>>();
          isLoadingFormats = false;
        });
      } else {
        setState(() {
          isLoadingFormats = false;
        });
      }
    } catch (_) {
      setState(() {
        isLoadingFormats = false;
      });
    }
  }

  Future<void> _loadLibraryItems() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await _apiService.getBooksPaginated(
        page: currentPage,
        size: 10,
        sortBy: 'title',
        sortDir: 'desc',
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = BookApiResponse.fromJson(jsonData);
        
        final newItems = apiResponse.content.map((book) => book.toLibraryItem()).toList();
        
        setState(() {
          if (currentPage == 0) {
            items = newItems;
          } else {
            items.addAll(newItems);
          }
          filteredItems = items;
          hasMoreData = apiResponse.hasNext;
          isLoading = false;
        });
      } else {
        setState(() {
          items = [];
          filteredItems = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        items = [];
        filteredItems = [];
        isLoading = false;
      });
    }
  }

  void _filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        final matchesSearch = searchQuery.isEmpty ||
            item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.author.toLowerCase().contains(searchQuery.toLowerCase());
        
        final matchesTargetAge = selectedTargetAge == 'Tất cả' || item.targetAge == selectedTargetAge;
        final matchesDomain = selectedDomain == 'Tất cả' || item.domain == selectedDomain || item.domain == _mapDomainIdToName(selectedDomain);
        final matchesCategory = selectedCategory == 'Tất cả' ||
            item.title.toLowerCase().endsWith(selectedCategory.toLowerCase()) ||
            item.getFileTypeText().toLowerCase().contains(selectedCategory.toLowerCase());
        
        return matchesSearch && matchesTargetAge && matchesDomain && matchesCategory;
      }).toList();
    });
  }

  String _mapDomainIdToName(String domainId) {
    final found = domains.firstWhere(
      (d) => (d['id'] ?? '') == domainId,
      orElse: () => const {},
    );
    if (found.isEmpty) return domainId;
    return (found['name'] ?? domainId).toString();
  }

  void _loadMoreData() async {
    if (!hasMoreData || isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      final nextPage = currentPage + 1;
      final response = await _apiService.getBooksPaginated(
        page: nextPage,
        size: 10,
        sortBy: 'title',
        sortDir: 'desc',
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = BookApiResponse.fromJson(jsonData);
        
        final newItems = apiResponse.content.map((book) => book.toLibraryItem()).toList();
        
        setState(() {
          items.addAll(newItems);
          filteredItems = items;
          currentPage = nextPage;
          hasMoreData = apiResponse.hasNext;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchBooks() async {
    if (searchQuery.isEmpty) {
      _loadLibraryItems();
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await _apiService.getBooksWithFilter(
        page: 0,
        size: 10,
        sortBy: 'title',
        sortDir: 'desc',
        filter: searchQuery,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = BookApiResponse.fromJson(jsonData);
        
        final newItems = apiResponse.content.map((book) => book.toLibraryItem()).toList();
        
        setState(() {
          items = newItems;
          filteredItems = newItems;
          currentPage = 0;
          hasMoreData = apiResponse.hasNext;
          isLoading = false;
        });
      } else {
        // Fallback to local filtering
        _filterItems();
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to local filtering
      _filterItems();
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDomainChip(String id, String label) {
    final isSelected = selectedDomain == id;
    return Builder(builder: (chipContext) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          final domain = domains.firstWhere(
            (d) => (d['id'] ?? '') == id,
            orElse: () => const {},
          );
          final desc = (domain['description']?[currentLocale] ?? '').toString();
          if (desc.isEmpty) return;

          // Remove existing tooltip if any
          _domainTooltipEntry?.remove();
          _domainTooltipEntry = null;

          // Calculate position right under the chip
          final box = chipContext.findRenderObject() as RenderBox?;
          if (box == null) return;
          final offset = box.localToGlobal(Offset.zero);
          final size = box.size;

          final entry = OverlayEntry(
            builder: (_) => Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 6,
              child: IgnorePointer(
                ignoring: true,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey900.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      desc,
                      style: const TextStyle(color: AppColors.white, fontSize: 12, height: 1.4),
                    ),
                  ),
                ),
              ),
            ),
          );
          Overlay.of(chipContext).insert(entry);
          _domainTooltipEntry = entry;
        },
        onExit: (_) {
          _domainTooltipEntry?.remove();
          _domainTooltipEntry = null;
        },
        child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDomain = id;
            currentPage = 0;
            hasMoreData = true;
            _filterItems();
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
    });
  }

  Widget _buildFormatChip(String idOrExt, String label) {
    final isSelected = selectedCategory == idOrExt;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = idOrExt;
          currentPage = 0;
          hasMoreData = true;
          _filterItems();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build and order tabs so that PDF comes first, then Video, then others
    List<Map<String, dynamic>> tabFormats = List<Map<String, dynamic>>.from(
      formats.isNotEmpty
          ? formats
          : [
              {'id': 1, 'formatName': 'PDF Document', 'fileExtension': '.pdf', 'mimeType': 'application/pdf', 'category': 'PDF'},
              {'id': 2, 'formatName': 'MP4 Video', 'fileExtension': '.mp4', 'mimeType': 'video/mp4', 'category': 'VIDEO'},
            ],
    );
    int _priority(Map<String, dynamic> f) {
      final id = (f['id'] as num?)?.toInt();
      final ext = (f['fileExtension'] ?? '').toString().toLowerCase();
      final mime = (f['mimeType'] ?? '').toString().toLowerCase();
      final cat = (f['category'] ?? '').toString().toUpperCase();
      final isPdf = id == 1 || ext == '.pdf' || mime == 'application/pdf' || cat == 'PDF';
      final isVideo = id == 2 || ext == '.mp4' || mime.startsWith('video/') || cat == 'VIDEO';
      if (isPdf) return 0;
      if (isVideo) return 1;
      return 2;
    }
    tabFormats.sort((a, b) => _priority(a).compareTo(_priority(b)));
    return DefaultTabController(
      length: tabFormats.length,
      initialIndex: 0,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Thư Viện'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await _loadYoutubeVideos();
            },
            icon: const Icon(Icons.play_circle_fill),
            tooltip: 'Tải lại YouTube',
          ),
          IconButton(
            onPressed: () {
              try {
                final domainModels = domains
                    .where((domain) => domain != null)
                    .map((domain) => InterventionDomainModel.fromJson(domain))
                    .toList();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPostPage(
                      domains: domainModels,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi mở trang thêm bài post: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.article),
            tooltip: 'Thêm bài post',
          ),
          IconButton(
            onPressed: () {
              try {
                final domainModels = domains
                    .where((domain) => domain != null)
                    .map((domain) => InterventionDomainModel.fromJson(domain))
                    .toList();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVideoPage(
                      domains: domainModels,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi mở trang thêm video: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.video_library),
            tooltip: 'Thêm video',
          ),
          IconButton(
            onPressed: () {
              try {
                final domainModels = domains
                    .where((domain) => domain != null)
                    .map((domain) => InterventionDomainModel.fromJson(domain))
                    .toList();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookPage(
                      domains: domainModels,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi mở trang thêm sách: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.book),
            tooltip: 'Thêm sách',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              isScrollable: true,
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
              tabs: tabFormats
                  .map((f) => Tab(text: (f['formatName'] ?? 'Unknown').toString()))
                  .toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar + Filter Button
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      searchQuery = value;
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (searchQuery == value) {
                          _searchBooks();
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tài liệu...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.grey50,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openFilterSidebar,
                  icon: const Icon(Icons.tune),
                  label: const Text('Bộ lọc'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Inline filters removed; use sidebar button instead
          
          // Tabbed content
          Expanded(
            child: TabBarView(
              children: tabFormats.map((f) {
                final id = (f['id'] as num?)?.toInt();
                final category = (f['category'] ?? '').toString().toUpperCase();
                final isVideo = id == 2 || category == 'VIDEO' || (f['mimeType']?.toString().startsWith('video/') ?? false);
                final isPdf = id == 1 || (f['fileExtension'] ?? '').toString().toLowerCase() == '.pdf' || (f['mimeType'] ?? '').toString() == 'application/pdf';
                if (isVideo) {
                  // Lazy-load videos only when the tab is opened
                  if (!isLoadingYoutube && !hasLoadedYoutube) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !hasLoadedYoutube) {
                        _loadYoutubeVideos();
                      }
                    });
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      hasLoadedYoutube = false;
                      await _loadYoutubeVideos();
                    },
                    child: isLoadingYoutube
                        ? const Center(child: CircularProgressIndicator())
                        : _buildYoutubeList(),
                  );
                } else if (isPdf) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      currentPage = 0;
                      hasMoreData = true;
                      await _loadLibraryItems();
                    },
                    child: PdfListWidget(
                      items: items,
                      filteredItems: filteredItems,
                      isLoading: isLoading,
                      hasMoreData: hasMoreData,
                      currentPage: currentPage,
                      onLoadMore: _loadMoreData,
                      onReadItem: _readItem,
                      onShowItemDetails: _showItemDetails,
                      onDeleteItem: _deleteItem,
                      emptyStateBuilder: _buildEmptyState,
                    ),
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.info_outline, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('Định dạng này sẽ được hỗ trợ sau'),
                        ],
                      ),
                    ),
                  );
                }
              }).toList(),
            ),
          ),
        ],
      ),
    ));
  }



  Widget _buildYoutubeList() {
    if (youtubeVideos.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final v = youtubeVideos[index];
        final url = (v['url'] ?? '').toString();
        print('[WEB-VIDEO] youtube video url=' + url);
        final id = (v['id'] ?? v['videoId'] ?? v['uuid'] ?? '').toString();
        final language = (v['language'] ?? 'vi').toString();
        final publishedAt = (v['publishedAt'] ?? '').toString();
        final minAge = (v['minAge'] ?? '').toString();
        final maxAge = (v['maxAge'] ?? '').toString();
        final ageGroup = (v['ageGroup'] ?? '').toString();
        final contentRating = (v['contentRating'] ?? '').toString();
        final domainNames = (v['developmentalDomainNames'] as List?)?.join(', ') ?? '';
        // Derive YouTube thumbnail from watch URL if possible
        final ytId = _extractYoutubeId(url);
        final thumb = ytId != null ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg' : null;
        // Handle nested title/description structure
        String title = 'MP4 Video';
        String desc = '';
        
        if (v['title'] is Map) {
          final titleMap = v['title'] as Map;
          title = (titleMap['vi'] ?? titleMap['en'] ?? 'MP4 Video').toString();
        } else {
          title = (v['titleVi'] ?? v['titleEn'] ?? 'MP4 Video').toString();
        }
        
        if (v['description'] is Map) {
          final descMap = v['description'] as Map;
          desc = (descMap['vi'] ?? descMap['en'] ?? '').toString();
        } else {
          desc = (v['descriptionVi'] ?? v['descriptionEn'] ?? '').toString();
        }
        final domainCount = (v['developmentalDomainIds'] is List) ? (v['developmentalDomainIds'] as List).length : 0;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            leading: thumb == null
                ? const Icon(Icons.play_circle_fill, color: AppColors.primary)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      thumb,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_fill, color: AppColors.primary),
                    ),
                  ),
            title: Text(title.isEmpty ? 'Untitled Video' : title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (desc.isNotEmpty) Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(
                  'Lang: $language • Age: $minAge-$maxAge ($ageGroup) • Rated: $contentRating\nDomains: ${domainNames.isEmpty ? domainCount : domainNames}\n$publishedAt',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _openVideo(url),
                  tooltip: 'Phát trong ứng dụng',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Xóa video',
                  onPressed: id.isEmpty ? null : () => _confirmDeleteYoutube(id, title),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: youtubeVideos.length,
    );
  }

  String? _extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      // Shorts or embed patterns
      final segs = uri.pathSegments;
      final idx = segs.indexWhere((s) => s == 'shorts' || s == 'embed' || s == 'v');
      if (idx >= 0 && idx + 1 < segs.length) return segs[idx + 1];
    }
    return null;
  }

  void _openVideo(String url) {
    if (url.isEmpty) return;
    if (kIsWeb) {
      _showInlineWebPlayer(url);
      return;
    }
    final ytId = _extractYoutubeId(url);
    if (ytId != null) {
      _showYoutubePlayerWithUrl(url);
    } else {
      _launchExternal(url);
    }
  }

  void _showInlineWebPlayer(String url) {
    final ytId = _extractYoutubeId(url);
    if (ytId == null) {
      // Render HTML5 video element for non-YouTube URLs in-app on web
      final viewType = 'html5-video-${DateTime.now().millisecondsSinceEpoch}';
      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final video = html.VideoElement()
          ..src = url
          ..autoplay = true
          ..muted = true
          ..controls = true
          ..preload = 'metadata'
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('playsinline', 'true')
          ..setAttribute('controlsList', 'nodownload')
          ..setAttribute('crossorigin', 'anonymous');

        // Best effort autoplay, user can press play if blocked
        // ignore: body_might_complete_normally_catch_error
        video.play().catchError((_) {});
        return video;
      });

      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final maxH = constraints.maxHeight;
              // Prefer 16:9, but allow flex for arbitrary videos
              double width = maxW;
              double height = width * 9 / 16;
              if (height > maxH) {
                height = maxH;
                width = height * 16 / 9;
              }
              return Center(
                child: SizedBox(
                  width: width,
                  height: height + 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4, bottom: 8),
                          child: Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: HtmlElementView(viewType: viewType),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    final viewType = 'yt-iframe-$ytId-${DateTime.now().millisecondsSinceEpoch}';
    // Register a view factory for this iframe
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$ytId?autoplay=1&modestbranding=1&rel=0'
        ..style.border = '0'
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
        ..allowFullscreen = true;
      return element;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final maxH = constraints.maxHeight;
            // Target aspect ratio 16:9
            double width = maxW;
            double height = width * 9 / 16;
            if (height > maxH) {
              height = maxH;
              width = height * 16 / 9;
            }
            return Center(
              child: SizedBox(
                width: width,
                height: height + 48, // extra space for the close button row
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button row above the video to avoid iframe overlay issues
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 8),
                        child: Material(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Video area
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: HtmlElementView(viewType: viewType),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showYoutubePlayerWithUrl(String url) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Phát Video'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Video sẽ mở trong tab mới',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchExternal(url);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Phát Video'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (kIsWeb) {
      await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
        mode: LaunchMode.platformDefault,
      );
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmDeleteYoutube(String id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa video'),
        content: Text('Bạn có chắc muốn xóa "${title.isEmpty ? id : title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final resp = await _apiService.deleteYoutubeVideo(id);
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        if (mounted) {
          setState(() {
            youtubeVideos.removeWhere((e) => (e['id']?.toString() ?? e['videoId']?.toString() ?? e['uuid']?.toString() ?? '') == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa video thành công'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa video: ${resp.statusCode} - ${resp.body}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa video: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy tài liệu nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'picture_as_pdf':
        return Icons.picture_as_pdf;
      case 'video_library':
        return Icons.video_library;
      case 'audiotrack':
        return Icons.audiotrack;
      case 'image':
        return Icons.image;
      case 'description':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _openUrl(String url) async {
    if (url.isEmpty) return;
    // For web, simply open new window. For other platforms, consider url_launcher.
    try {
      // ignore: undefined_prefixed_name
      // Use a simple workaround: open in new tab if running on web
      // Since we avoid adding new deps, we won't import url_launcher here.
      // This is a no-op on non-web.
    } catch (_) {}
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterDialog(
        selectedTargetAge: selectedTargetAge,
        selectedDomain: selectedDomain,
        selectedCategory: selectedCategory,
        onApply: (targetAge, domain, category) {
          setState(() {
            selectedTargetAge = targetAge;
            selectedDomain = domain;
            selectedCategory = category;
            currentPage = 0;
            hasMoreData = true;
            _filterItems();
          });
        },
      ),
    );
  }

  void _openFilterSidebar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Dùng biến tạm cho dialog để hiển thị chọn ngay lập tức
        String tempTargetAge = selectedTargetAge;
        String tempDomain = selectedDomain;
        String tempCategory = selectedCategory;

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Material(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setSheetState) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.border)),
                            ),
                            child: Row(
                              children: [
                                const Text('Bộ lọc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              controller: controller,
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildFilterSection('Độ Tuổi', filterTargetAges, tempTargetAge, (v) => setSheetState(() {
                                  tempTargetAge = v;
                                })),
                                const SizedBox(height: 16),
                                _buildDomainSidebarSection(current: tempDomain, onChanged: (v) => setSheetState(() {
                                  tempDomain = v;
                                })),
                                const SizedBox(height: 16),
                                _buildFormatSidebarSection(current: tempCategory, onChanged: (v) => setSheetState(() {
                                  tempCategory = v;
                                })),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setSheetState(() {
                                        tempTargetAge = 'Tất cả';
                                        tempDomain = 'Tất cả';
                                        tempCategory = 'Tất cả';
                                      });
                                    },
                                    child: const Text('Đặt lại'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedTargetAge = tempTargetAge;
                                        selectedDomain = tempDomain;
                                        selectedCategory = tempCategory;
                                        currentPage = 0;
                                        hasMoreData = true;
                                        _filterItems();
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                    ),
                                    child: const Text('Áp dụng'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDomainSidebarSection({required String current, required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lĩnh Vực', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _domainChoiceChip('Tất cả', 'Tất cả', current, onChanged),
            ...domains.map((d) {
              final label = (d['displayedName']?[currentLocale] ?? d['name'] ?? '').toString();
              final id = (d['id'] ?? '').toString();
              return _domainChoiceChip(id, label, current, onChanged);
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _domainChoiceChip(String id, String label, String current, ValueChanged<String> onChanged) {
    final isSelected = current == id;
    return Builder(builder: (chipContext) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          // Find domain description for tooltip
          final domain = domains.firstWhere(
            (d) => (d['id'] ?? '') == id,
            orElse: () => const {},
          );
          final desc = (domain['description']?[currentLocale] ?? '').toString();
          if (desc.isEmpty) return;

          // Remove existing tooltip
          _domainTooltipEntry?.remove();
          _domainTooltipEntry = null;

          // Position below chip
          final box = chipContext.findRenderObject() as RenderBox?;
          if (box == null) return;
          final offset = box.localToGlobal(Offset.zero);
          final size = box.size;

          final entry = OverlayEntry(
            builder: (_) => Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 6,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.grey900.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Text(
                    desc,
                    style: const TextStyle(color: AppColors.white, fontSize: 12, height: 1.4),
                  ),
                ),
              ),
            ),
          );
          Overlay.of(chipContext).insert(entry);
          _domainTooltipEntry = entry;
        },
        onExit: (_) {
          _domainTooltipEntry?.remove();
          _domainTooltipEntry = null;
        },
        child: ChoiceChip(
          selected: isSelected,
          label: Text(label),
          onSelected: (val) => onChanged(id),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(color: isSelected ? AppColors.white : AppColors.textSecondary),
          backgroundColor: AppColors.grey100,
          shape: StadiumBorder(side: BorderSide(color: AppColors.border)),
        ),
      );
    });
  }

  Widget _buildFormatSidebarSection({required String current, required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Định Dạng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _formatChoiceChip('Tất cả', 'Tất cả', current, onChanged),
            ...formats.map((f) {
              final ext = (f['fileExtension'] ?? '').toString();
              final label = (f['formatName'] ?? ext).toString();
              final key = ext.isNotEmpty ? ext : label;
              return _formatChoiceChip(key, label, current, onChanged);
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _formatChoiceChip(String key, String label, String current, ValueChanged<String> onChanged) {
    final isSelected = current == key;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (val) => onChanged(key),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? AppColors.white : AppColors.textSecondary),
      backgroundColor: AppColors.grey100,
      shape: StadiumBorder(side: BorderSide(color: AppColors.border)),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selected,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              selected: isSelected,
              label: Text(option),
              onSelected: (_) => onChanged(option),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
              backgroundColor: AppColors.grey100,
              shape: StadiumBorder(side: BorderSide(color: AppColors.border)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showItemDetails(LibraryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemDetailsSheet(item: item),
    );
  }

  void _deleteItem(LibraryItem item) async {
    print('Delete button clicked for item: ${item.title}');
    // Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${item.title}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Lấy ID sách từ item
      final bookId = int.tryParse(item.id);
      if (bookId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể xác định ID sách'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final apiService = ApiService();
      final response = await apiService.deleteBook(bookId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa sách thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh danh sách
          currentPage = 0;
          hasMoreData = true;
          await _loadLibraryItems();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${response.statusCode} - ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa sách: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _readItem(LibraryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ItemReaderPage(item: item),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final String selectedTargetAge;
  final String selectedDomain;
  final String selectedCategory;
  final Function(String, String, String) onApply;

  const _FilterDialog({
    required this.selectedTargetAge,
    required this.selectedDomain,
    required this.selectedCategory,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String selectedTargetAge;
  late String selectedDomain;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedTargetAge = widget.selectedTargetAge;
    selectedDomain = widget.selectedDomain;
    selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Bộ Lọc',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedTargetAge = 'Tất cả';
                      selectedDomain = 'Tất cả';
                      selectedCategory = 'Tất cả';
                    });
                  },
                  child: const Text('Đặt lại'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Độ Tuổi',
                    SampleLibraryItems.getTargetAges(),
                    selectedTargetAge,
                    (value) => setState(() => selectedTargetAge = value),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildFilterSection(
                    'Lĩnh Vực',
                    SampleLibraryItems.getDomains(),
                    selectedDomain,
                    (value) => setState(() => selectedDomain = value),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildFilterSection(
                    'Định Dạng',
                    SampleLibraryItems.getCategories(),
                    selectedCategory,
                    (value) => setState(() => selectedCategory = value),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(selectedTargetAge, selectedDomain, selectedCategory);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Áp Dụng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String selected, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) => GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected == option ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected == option ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected == option ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _ItemDetailsSheet extends StatelessWidget {
  final LibraryItem item;

  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(item.getFileTypeColor()).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(item.getFileTypeIcon()),
                          color: Color(item.getFileTypeColor()),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bởi ${item.author}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildDetailSection('Mô tả', item.description),
                  _buildDetailSection('Thông tin', 
                    'Loại: ${item.getFileTypeText()}\n'
                    'Lĩnh vực: ${item.getDomainText()}\n'
                    'Độ khó: ${item.getDifficultyText()}\n'
                    'Độ tuổi: ${item.targetAge}\n'
                    'Lượt xem: ${item.viewCount}'),
                  
                  if (item.reviews.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildReviewsSection(),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _readItem(context),
                    icon: const Icon(Icons.book),
                    label: const Text('Đọc'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addReview(context),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Đánh giá'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Đánh giá (${item.reviews.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.reviews.map((review) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          review.rating.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(review.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
           )),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'picture_as_pdf':
        return Icons.picture_as_pdf;
      case 'video_library':
        return Icons.video_library;
      case 'audiotrack':
        return Icons.audiotrack;
      case 'image':
        return Icons.image;
      case 'description':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _readItem(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ItemReaderPage(item: item),
      ),
    );
  }

  void _addReview(BuildContext context) {
    Navigator.pop(context);
    _showAddReviewDialog(context);
  }

  void _showAddReviewDialog(BuildContext context) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá tài liệu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    rating = index + 1.0;
                  },
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhận xét của bạn...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add review
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đánh giá đã được gửi'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }
}

class _ItemReaderPage extends StatefulWidget {
  final LibraryItem item;

  const _ItemReaderPage({required this.item});

  @override
  State<_ItemReaderPage> createState() => _ItemReaderPageState();
}

class _ItemReaderPageState extends State<_ItemReaderPage> {
  String? bookContent;
  bool isLoading = true;
  String? errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadBookContent();
  }

  Future<void> _loadBookContent() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Gọi API để lấy chi tiết sách
      final response = await _apiService.getBookById(int.parse(widget.item.id));
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        // Kiểm tra tất cả các field có thể chứa nội dung
        final contentFile = jsonData['contentFile'] as String?;
        final content = jsonData['content'] as String?;
        final description = jsonData['description'] as String?;

        // Ưu tiên contentFile, nếu không có thì dùng content, cuối cùng là description
        String? finalContent;
        if (contentFile != null && contentFile.isNotEmpty) {
          finalContent = await _normalizePdfSource(contentFile);
        } else if (content != null && content.isNotEmpty) {
          // Nếu đây là PDF được trả về dạng data URI/base64 thì chuẩn hóa
          if (_looksLikeDataUri(content) || _looksLikeUrl(content)) {
            finalContent = await _normalizePdfSource(content);
          } else {
            finalContent = content;
          }
        } else if (description != null && description.isNotEmpty) {
          finalContent = description;
        }
        
        if (finalContent != null && finalContent.isNotEmpty) {
          setState(() {
            bookContent = finalContent;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Không có nội dung sách';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Không thể tải nội dung sách (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải nội dung sách: $e';
        isLoading = false;
      });
    }
  }

  // Chuẩn hóa nguồn PDF về chuỗi Base64 thuần
  Future<String> _normalizePdfSource(String src) async {
    final trimmed = src.trim();
    // Nếu là URL -> tải bytes và encode base64
    if (_looksLikeUrl(trimmed)) {
      final uri = Uri.parse(trimmed);
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        return base64Encode(resp.bodyBytes);
      }
      throw Exception('Không tải được PDF từ URL (${resp.statusCode})');
    }
    // Nếu là data URI -> tách lấy phần base64 phía sau dấu phẩy
    if (_looksLikeDataUri(trimmed)) {
      final commaIdx = trimmed.indexOf(',');
      final dataPart = commaIdx >= 0 ? trimmed.substring(commaIdx + 1) : trimmed;
      return _cleanBase64(dataPart);
    }
    // Mặc định coi như base64 -> dọn dẹp whitespace và padding
    return _cleanBase64(trimmed);
  }

  bool _looksLikeUrl(String s) {
    return s.startsWith('http://') || s.startsWith('https://');
  }

  bool _looksLikeDataUri(String s) {
    return s.startsWith('data:application/pdf') || s.startsWith('data:;base64,');
  }

  String _cleanBase64(String b64) {
    // Loại bỏ mọi khoảng trắng/xuống dòng
    String cleaned = b64.replaceAll(RegExp(r'\s+'), '');
    // Bổ sung padding '=' để độ dài chia hết cho 4
    final mod = cleaned.length % 4;
    if (mod != 0) {
      cleaned = cleaned.padRight(cleaned.length + (4 - mod), '=');
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          widget.item.title,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review),
            onPressed: () => _showAddReviewDialog(context),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải nội dung sách...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookContent,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (bookContent == null || bookContent!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16),
            Text(
              'Không có nội dung sách',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Nếu nội dung là PDF -> hiển thị viewer ngay
    if (_isLikelyPdf(bookContent!, widget.item)) {
      return _buildPdfViewer();
    }

    // Hiển thị nội dung sách
    try {
      
      // Kiểm tra nếu nội dung có vẻ là base64
      if (bookContent != null && bookContent!.isNotEmpty) {
        try {
          // Thử decode base64
          final bytes = base64Decode(bookContent!);
          // Nếu bytes có chữ ký PDF thì hiển thị PDF
          if (bytes.length >= 4) {
            final sig = String.fromCharCodes(bytes.take(4));
            if (sig.startsWith('%PDF')) {
              return _buildPdfViewer();
            }
          }
          final content = utf8.decode(bytes);
          
          // Parse content as JSON if possible, otherwise treat as plain text
          try {
            final jsonData = jsonDecode(content);
            return _buildJsonContent(jsonData);
          } catch (e) {
            // If not JSON, treat as plain text
            return _buildTextContent(content);
          }
        } catch (e) {
          // Nếu không phải base64, hiển thị trực tiếp
          return _buildTextContent(bookContent!);
        }
      } else {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_outlined,
                size: 64,
                color: AppColors.grey400,
              ),
              SizedBox(height: 16),
              Text(
                'Không có nội dung sách',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể đọc nội dung sách: $e',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  // Heuristic nhận diện PDF từ nội dung/metadata
  bool _isLikelyPdf(String content, LibraryItem item) {
    final ft = item.fileType.toLowerCase();
    if (ft.contains('pdf')) return true;
    final title = item.title.toLowerCase();
    if (title.endsWith('.pdf')) return true;
    if (content.startsWith('data:application/pdf')) return true;
    if (_looksLikeUrl(content) && content.toLowerCase().contains('.pdf')) return true;
    // Try check base64 signature quickly without throwing
    try {
      final bytes = base64Decode(content);
      if (bytes.length >= 4) {
        final sig = String.fromCharCodes(bytes.take(4));
        if (sig.startsWith('%PDF')) return true;
      }
    } catch (_) {}
    return false;
  }

  Widget _buildJsonContent(Map<String, dynamic> jsonData) {
    // Hiển thị nội dung JSON
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (jsonData['title'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                jsonData['title'].toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          
          if (jsonData['content'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                jsonData['content'].toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          
          if (jsonData['chapters'] != null)
            ...(jsonData['chapters'] as List).map((chapter) => 
              _buildChapterWidget(chapter)
            ).toList(),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    // Hiển thị PDF viewer trực tiếp
    return SizedBox.expand(
      child: PdfViewerWidget(
        base64Data: bookContent!,
        title: widget.item.title,
        showAppBar: false, // Không hiển thị AppBar khi nhúng trong trang
      ),
    );
  }

  Widget _buildChapterWidget(dynamic chapter) {
    if (chapter is Map<String, dynamic>) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chapter['title'] != null)
              Text(
                chapter['title'].toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            
            if (chapter['content'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  chapter['content'].toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextContent(String content) {
    // Hiển thị nội dung text thông thường
    final lines = content.split('\n');
    final widgets = <Widget>[];
    
    for (final line in lines) {
      if (line.startsWith('# ')) {
        // H1
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // H2
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // H3
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              line.substring(4),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        // List item
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold text
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line.substring(2, line.length - 2),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.trim().isNotEmpty) {
        // Regular text
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        );
      } else {
        // Empty line
        widgets.add(const SizedBox(height: 8));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'picture_as_pdf':
        return Icons.picture_as_pdf;
      case 'video_library':
        return Icons.video_library;
      case 'audiotrack':
        return Icons.audiotrack;
      case 'image':
        return Icons.image;
      case 'description':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showAddReviewDialog(BuildContext context) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá tài liệu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    rating = index + 1.0;
                  },
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhận xét của bạn...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add review
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đánh giá đã được gửi'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }
}

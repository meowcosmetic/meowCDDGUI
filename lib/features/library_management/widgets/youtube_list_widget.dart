import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';

class YoutubeListWidget extends StatefulWidget {
  const YoutubeListWidget({super.key});

  @override
  State<YoutubeListWidget> createState() => _YoutubeListWidgetState();
}

class _YoutubeListWidgetState extends State<YoutubeListWidget> {
  final ApiService _apiService = ApiService();

  bool isLoadingYoutube = false;
  bool hasLoadedYoutube = false;
  List<Map<String, dynamic>> youtubeVideos = [];

  @override
  void initState() {
    super.initState();
    _loadYoutubeVideos();
  }

  Future<void> _loadYoutubeVideos() async {
    if (isLoadingYoutube || hasLoadedYoutube) return;
    try {
      setState(() {
        isLoadingYoutube = true;
      });
      final resp = await _apiService.getYoutubeVideos();
      if (!mounted) return;
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
          youtubeVideos = list
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();
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
      if (!mounted) return;
      setState(() {
        youtubeVideos = [];
        isLoadingYoutube = false;
        hasLoadedYoutube = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        hasLoadedYoutube = false;
        await _loadYoutubeVideos();
      },
      child: isLoadingYoutube
          ? const Center(child: CircularProgressIndicator())
          : _buildYoutubeList(),
    );
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
        final id = (v['id'] ?? v['videoId'] ?? v['uuid'] ?? '').toString();
        final titleMap = (v['title'] is Map)
            ? (v['title'] as Map).cast<String, dynamic>()
            : {};
        final descMap = (v['description'] is Map)
            ? (v['description'] as Map).cast<String, dynamic>()
            : {};
        final title = (titleMap['vi'] ?? titleMap['en'] ?? v['title'] ?? '')
            .toString();
        final description = (descMap['vi'] ?? descMap['en'] ?? '').toString();
        final language = (v['language'] ?? '').toString();
        final contentRating = (v['contentRating'] ?? '').toString();
        final ageMin = (v['minAge'] ?? '').toString();
        final ageMax = (v['maxAge'] ?? '').toString();
        final domains = (v['developmentalDomainIds'] is List)
            ? (v['developmentalDomainIds'] as List).cast<String>()
            : const <String>[];
        final publishedAt = (v['publishedAt'] ?? '').toString();

        final ytId = _extractYoutubeId(url);
        final thumbnailUrl = ytId != null
            ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg'
            : null;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: thumbnailUrl != null
                      ? Image.network(
                          thumbnailUrl,
                          width: 160,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 160,
                          height: 90,
                          color: AppColors.grey200,
                          child: const Icon(
                            Icons.play_circle_fill,
                            size: 40,
                            color: AppColors.grey500,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isEmpty ? 'Video $id' : title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (language.isNotEmpty)
                            _buildChip(Icons.language, language),
                          if (contentRating.isNotEmpty)
                            _buildChip(Icons.shield, contentRating),
                          if (ageMin.isNotEmpty || ageMax.isNotEmpty)
                            _buildChip(
                              Icons.cake,
                              '${ageMin.isEmpty ? '?' : ageMin} - ${ageMax.isEmpty ? '?' : ageMax} tháng',
                            ),
                          if (publishedAt.isNotEmpty)
                            _buildChip(
                              Icons.calendar_today,
                              publishedAt.split('T').first,
                            ),
                          if (domains.isNotEmpty)
                            _buildChip(Icons.category, domains.join(',')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _openVideo(url),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Phát'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _launchExternal(url),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Mở ngoài'),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Xóa video',
                            onPressed: () => _confirmDeleteYoutube(id, title),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
      final segs = uri.pathSegments;
      final idx = segs.indexWhere(
        (s) => s == 'shorts' || s == 'embed' || s == 'v',
      );
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final maxH = constraints.maxHeight;
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
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.IFrameElement()
        ..src =
            'https://www.youtube.com/embed/$ytId?autoplay=1&modestbranding=1&rel=0'
        ..style.border = '0'
        ..allow =
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
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
    if (ok != true) return;
    try {
      final resp = await _apiService.deleteYoutubeVideo(id);
      if (!mounted) return;
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        setState(() {
          youtubeVideos.removeWhere(
            (e) =>
                (e['id']?.toString() ??
                    e['videoId']?.toString() ??
                    e['uuid']?.toString() ??
                    '') ==
                id,
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa video thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xóa video: ${resp.statusCode} - ${resp.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.video_library, size: 64, color: AppColors.grey400),
                SizedBox(height: 16),
                Text(
                  'Chưa có video nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

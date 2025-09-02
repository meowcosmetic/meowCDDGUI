import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../constants/app_colors.dart';

class PdfViewerWidget extends StatefulWidget {
  final String base64Data;
  final String title;
  final bool showAppBar;

  const PdfViewerWidget({
    super.key,
    required this.base64Data,
    required this.title,
    this.showAppBar = true,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  Uint8List? _pdfBytes;
  String? _errorMessage;
  bool _isLoading = true;
  String _pdfVersion = 'Unknown';
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _initializePdf();
    
    // Register web PDF viewer
    if (kIsWeb) {
      _registerWebPdfViewer();
    }
  }

  // Register web PDF viewer view type
  void _registerWebPdfViewer() {}

  // Create blob URL for PDF
  String _createPdfBlobUrl() {
    if (_pdfBytes == null) return '';
    
    try {
      final blob = html.Blob([_pdfBytes!], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Clean up blob URL after a delay
      Future.delayed(const Duration(seconds: 30), () {
        html.Url.revokeObjectUrl(url);
      });
      
      return url;
    } catch (e) {
      print('DEBUG: Error creating PDF blob URL: $e');
      return '';
    }
  }

    Future<void> _initializePdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      
      
      // Validate base64 data
      if (widget.base64Data.isEmpty) {
        throw Exception('Dữ liệu Base64 trống');
      }
      
      // Additional Base64 validation
      
      
      if (!_isValidBase64(widget.base64Data)) {
        throw Exception('Dữ liệu Base64 không hợp lệ');
      }

      // Decode base64 to bytes
      final Uint8List bytes = base64Decode(widget.base64Data);
      
      
      // Additional debug: Check first and last bytes
      if (bytes.isNotEmpty) {
        
      }
      
      // Validate PDF file
      if (!_isValidPdf(bytes)) {
        throw Exception('Dữ liệu không phải file PDF hợp lệ');
      }

      // Extract PDF info
      _pdfVersion = _extractPdfVersion(bytes);
      

      // Check file size for potential issues
      if (bytes.length > 10 * 1024 * 1024) { // 10MB
        
      }

      // Try to test PDF loading first
      await _testPdfLoading(bytes);

      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      
      
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isValidPdf(Uint8List bytes) {
    if (bytes.length < 4) {
      print('DEBUG: Bytes too short to be PDF');
      return false;
    }
    
    // Check PDF signature (PDF files start with %PDF)
    final pdfSignature = String.fromCharCodes(bytes.take(4));
    
    
    if (!pdfSignature.startsWith('%PDF')) {
      print('DEBUG: Not a valid PDF file');
      return false;
    }
    
    return true;
  }

  String _extractPdfVersion(Uint8List bytes) {
    try {
      final lines = String.fromCharCodes(bytes.take(100)).split('\n');
      for (final line in lines) {
        if (line.startsWith('%PDF-')) {
          return line.trim();
        }
      }
    } catch (e) {
      
    }
    return 'Unknown';
  }

  // Test PDF loading with better error handling
  Future<bool> _testPdfLoading(Uint8List bytes) async {
    try {
      
      
      // Try to create a temporary PDF viewer to test loading
      // This is a workaround to catch errors before the main viewer
      final testViewer = SfPdfViewer.memory(
        bytes,
        onDocumentLoadFailed: (details) {
          
        },
        onDocumentLoaded: (details) {
          
        },
      );
      
      // If we reach here, the viewer was created successfully
      return true;
    } catch (e) {
      
      return false;
    }
  }

  // Try alternative PDF loading methods
  Future<void> _tryAlternativeLoading() async {
    if (_pdfBytes == null) return;
    
    print('DEBUG: Trying alternative PDF loading methods...');
    print('DEBUG: Platform: ${kIsWeb ? 'Web' : 'Mobile/Desktop'}');
    
    try {
      // Method 1: Try with minimal options
      print('DEBUG: Method 1: Minimal options');
      final minimalViewer = SfPdfViewer.memory(
        _pdfBytes!,
        enableDoubleTapZooming: false,
        enableTextSelection: false,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        onDocumentLoadFailed: (details) {
          print('DEBUG: Minimal viewer failed: ${details.error}');
        },
        onDocumentLoaded: (details) {
          print('DEBUG: Minimal viewer succeeded!');
          setState(() {
            _errorMessage = null;
          });
        },
      );
      
      // Method 2: Try with different memory approach
      if (kIsWeb) {
        print('DEBUG: Method 2: Web-specific approach');
        try {
          // On web, try to create a smaller chunk first
          final testBytes = _pdfBytes!.take(100000).toList(); // First 100KB
          final testViewer = SfPdfViewer.memory(
            Uint8List.fromList(testBytes),
            onDocumentLoadFailed: (details) {
              print('DEBUG: Test chunk viewer failed: ${details.error}');
            },
            onDocumentLoaded: (details) {
              print('DEBUG: Test chunk viewer succeeded!');
            },
          );
        } catch (e) {
          print('DEBUG: Test chunk approach failed: $e');
        }
      }
      
      // Method 3: Try with different PDF viewer options
      print('DEBUG: Method 3: Different viewer options');
      final optionViewer = SfPdfViewer.memory(
        _pdfBytes!,
        enableDoubleTapZooming: true,
        enableTextSelection: false, // Disable text selection
        canShowScrollHead: false,
        canShowScrollStatus: false,
        onDocumentLoadFailed: (details) {
          print('DEBUG: Option viewer failed: ${details.error}');
        },
        onDocumentLoaded: (details) {
          print('DEBUG: Option viewer succeeded!');
          setState(() {
            _errorMessage = null;
          });
        },
      );
      
      // Method 4: Try with delay (sometimes helps on web)
      if (kIsWeb) {
        print('DEBUG: Method 4: Delayed loading');
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final delayedViewer = SfPdfViewer.memory(
            _pdfBytes!,
            onDocumentLoadFailed: (details) {
              print('DEBUG: Delayed viewer failed: ${details.error}');
            },
            onDocumentLoaded: (details) {
              print('DEBUG: Delayed viewer succeeded!');
              setState(() {
                _errorMessage = null;
              });
            },
          );
        } catch (e) {
          print('DEBUG: Delayed approach failed: $e');
        }
      }
      
      // Method 5: Try to bypass Syncfusion completely on web
      if (kIsWeb) {
        print('DEBUG: Method 5: Bypass Syncfusion, use native viewer');
        _tryNativePdfViewer();
      }
      
    } catch (e) {
      print('DEBUG: Alternative loading methods failed: $e');
    }
  }

  // Validate Base64 string
  bool _isValidBase64(String str) {
    if (str.isEmpty) return false;
    
    // Check if string contains only valid Base64 characters
    final validChars = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!validChars.hasMatch(str)) {
      print('DEBUG: Base64 contains invalid characters');
      return false;
    }
    
    // Check padding
    final paddingCount = '='.allMatches(str).length;
    if (paddingCount > 2) {
      print('DEBUG: Base64 has invalid padding');
      return false;
    }
    
    // Check length (should be multiple of 4)
    if (str.length % 4 != 0) {
      print('DEBUG: Base64 length is not multiple of 4');
      return false;
    }
    
    return true;
  }

  // Download PDF as file
  void _downloadPdf() {
    if (_pdfBytes == null) return;
    
    try {
      // Create blob URL for download
      final blob = html.Blob([_pdfBytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create download link
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${widget.title}.pdf')
        ..click();
      
      // Clean up
      html.Url.revokeObjectUrl(url);
      
      print('DEBUG: PDF download initiated');
    } catch (e) {
      print('DEBUG: Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải PDF: $e')),
      );
    }
  }

  // Open PDF in new tab
  void _openPdfInNewTab() {
    if (_pdfBytes == null) return;
    
    try {
      // Create blob URL with proper MIME type for PDF
      final blob = html.Blob([_pdfBytes!], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Open in new tab - browser should use built-in PDF viewer
      html.window.open(url, '_blank');
      
      print('DEBUG: PDF opened in new tab with proper MIME type');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF đã được mở trong tab mới'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clean up blob URL after a delay
      Future.delayed(const Duration(seconds: 5), () {
        html.Url.revokeObjectUrl(url);
      });
      
    } catch (e) {
      print('DEBUG: Error opening PDF in new tab: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi mở PDF: $e')),
      );
    }
  }

  // Try to use browser's native PDF viewer
  void _tryNativePdfViewer() {
    if (_pdfBytes == null) return;
    
    try {
      print('DEBUG: Trying native PDF viewer...');
      
      // Create blob URL with proper MIME type
      final blob = html.Blob([_pdfBytes!], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Method 1: Try to open in new tab with PDF viewer
      print('DEBUG: Method 1: Opening in new tab with PDF viewer');
      html.window.open(url, '_blank');
      
      // Method 2: Try to embed with object tag (better PDF support)
      print('DEBUG: Method 2: Trying object tag embedding');
      try {
        final object = html.ObjectElement()
          ..data = url
          ..type = 'application/pdf'
          ..style.width = '100%'
          ..style.height = '600px';
        
                 // Add fallback content using textContent instead of innerHTML
         object.text = 'PDF không thể hiển thị. Nhấn vào đây để mở PDF';
        
        // Try to find a container to embed
        final container = html.document.getElementById('pdf-container');
        if (container != null) {
          container.children.clear();
          container.children.add(object);
          print('DEBUG: Object tag PDF viewer loaded successfully');
        } else {
          print('DEBUG: PDF container not found, using new tab fallback');
        }
      } catch (e) {
        print('DEBUG: Object tag failed: $e, using new tab');
      }
      
      // Clean up blob URL after a delay
      Future.delayed(const Duration(seconds: 10), () {
        html.Url.revokeObjectUrl(url);
      });
      
    } catch (e) {
      print('DEBUG: Native PDF viewer failed: $e');
      // Fallback to new tab
      _openPdfInNewTab();
    }
  }

  // Try to use browser's built-in PDF viewer with embed tag
  void _tryEmbedPdfViewer() {
    if (_pdfBytes == null) return;
    
    try {
      print('DEBUG: Trying embed PDF viewer...');
      
      // Force rebuild with embedded viewer to show PDF directly
      setState(() {
        _errorMessage = null;
      });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Đang tải lại PDF viewer...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Force a rebuild after a short delay to ensure the PDF viewer is recreated
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            // This will trigger a rebuild of the PDF viewer
          });
        }
      });
      
    } catch (e) {
      print('DEBUG: Embed PDF viewer failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải PDF viewer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Check package compatibility
  void _checkPackageCompatibility() {
    print('DEBUG: === PACKAGE COMPATIBILITY CHECK ===');
    print('DEBUG: Platform: ${kIsWeb ? 'Web' : 'Mobile/Desktop'}');
    print('DEBUG: Flutter version: ${html.window.navigator.userAgent}');
    print('DEBUG: PDF file size: ${(_pdfBytes?.length ?? 0) / 1024} KB');
    print('DEBUG: PDF signature: ${_pdfBytes != null ? String.fromCharCodes(_pdfBytes!.take(8)) : 'N/A'}');
    print('DEBUG: === END COMPATIBILITY CHECK ===');
    
    // Additional web-specific checks
    if (kIsWeb) {
      print('DEBUG: === WEB-SPECIFIC CHECKS ===');
      print('DEBUG: Browser: ${html.window.navigator.userAgent}');
      print('DEBUG: Screen size: ${html.window.screen?.width}x${html.window.screen?.height}');
      print('DEBUG: Available memory: ${html.window.navigator.deviceMemory ?? 'Unknown'} GB');
      print('DEBUG: Hardware concurrency: ${html.window.navigator.hardwareConcurrency ?? 'Unknown'}');
      print('DEBUG: === END WEB CHECKS ===');
      
      // Show recommendations
      print('DEBUG: === RECOMMENDATIONS ===');
      print('DEBUG: 1. Try Native Viewer (bypasses Syncfusion)');
      print('DEBUG: 2. Download PDF and open locally');
      print('DEBUG: 3. Consider downgrading Syncfusion to v24.x');
      print('DEBUG: 4. Use alternative PDF viewer package');
      print('DEBUG: === END RECOMMENDATIONS ===');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: _initializePdf,
              tooltip: 'Tải lại PDF',
            ),
          ],
        ),
        body: _buildBody(),
      );
    } else {
      return _buildBody();
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải tài liệu PDF...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_pdfBytes == null) {
      return _buildErrorWidget('Không có dữ liệu PDF');
    }

    return _buildPdfViewer(_pdfBytes!);
  }

    Widget _buildPdfViewer(Uint8List bytes) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // PDF Viewer - Use Embed Viewer on Web, Syncfusion on Mobile/Desktop
            Expanded(
              child: kIsWeb 
                ? Column(
                    children: [
                      // Web notice
            Container(
              width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border(
                            bottom: BorderSide(color: Colors.blue.shade200),
              ),
                        ),
                        child: Row(
                children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'PDF đang được hiển thị trực tiếp trong ứng dụng',
                    style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // PDF Viewer
                      Expanded(
                        child: _buildWebPdfViewer(bytes),
                      ),
                    ],
                  )
                : _buildMobilePdfViewer(bytes),
            ),
          ],
        ),
      ),
    );
  }

  // Web-specific PDF viewer using embed tag
  Widget _buildWebPdfViewer(Uint8List bytes) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _buildWebPdfEmbed(bytes),
    );
  }

  // Build web PDF embed viewer
  Widget _buildWebPdfEmbed(Uint8List bytes) {
    try {
      // Prefer iframe with sandbox first to limit downloads
      try {
        return _buildSimpleWebPdfViewer(bytes);
      } catch (e) {
        print('Iframe approach failed: $e, trying object approach');
        
        // Try object tag as second option
        try {
          return _buildObjectTagPdfViewer(bytes);
        } catch (e) {
          print('Object tag approach failed: $e, using direct DOM approach');
          
          // Last resort: Create PDF viewer directly in DOM
          return _buildDirectWebPdfViewer(bytes);
        }
      }
      
    } catch (e) {
      print('Error creating web PDF embed: $e');
      // Fallback to simple display
      return _buildWebPdfFallback(bytes);
    }
  }

  // Alternative web PDF viewer that creates elements directly
  Widget _buildDirectWebPdfViewer(Uint8List bytes) {
    try {
      // Create blob URL for PDF
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create a container div for the PDF viewer
      final containerId = 'pdf-container-${DateTime.now().millisecondsSinceEpoch}';
      
      // Schedule the DOM manipulation for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          // Find or create the container
          html.Element? container = html.document.getElementById(containerId);
          if (container == null) {
            container = html.DivElement()
              ..id = containerId
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.backgroundColor = '#f5f5f5'
              ..style.border = 'none'
              ..style.overflow = 'hidden';
            
            // Add to body temporarily
            html.document.body?.children.add(container);
          }
          
          // Clear existing content
          container.children.clear();
          
          // Create iframe for PDF viewing
          final iframe = html.IFrameElement()
            ..src = url
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.border = 'none'
            ..style.overflow = 'hidden'
            ..allowFullscreen = true;
          
          // Add iframe to container
          container.children.add(iframe);
          
          // Clean up blob URL after a delay
          Future.delayed(const Duration(seconds: 30), () {
            html.Url.revokeObjectUrl(url);
            // Remove container from DOM
            container?.remove();
          });
          
        } catch (e) {
          print('Error in direct DOM manipulation: $e');
          html.Url.revokeObjectUrl(url);
        }
      });
      
      // Return a container that will contain the PDF iframe
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // This container will be replaced by the iframe
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            // Overlay with PDF info
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                  Text(
                      'PDF đang được tải...',
                    style: TextStyle(
                      fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      
    } catch (e) {
      print('Error in direct web PDF viewer: $e');
      return _buildWebPdfFallback(bytes);
    }
  }

  // Simple web PDF viewer using iframe directly
  Widget _buildSimpleWebPdfViewer(Uint8List bytes) {
    try {
      // Create blob URL for PDF
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Clean up blob URL after a delay
      Future.delayed(const Duration(seconds: 30), () {
        html.Url.revokeObjectUrl(url);
      });
      
      // Use a simple approach: create a container with iframe
      // This approach works better with newer Flutter versions
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildIframeWidget(url),
        ),
      );
      
    } catch (e) {
      print('Error in simple web PDF viewer: $e');
      return _buildWebPdfFallback(bytes);
    }
  }

  // Build iframe widget using HtmlElementView with ui_web registry
  Widget _buildIframeWidget(String url) {
    try {
      final iframeId = 'iframe-${DateTime.now().millisecondsSinceEpoch}';

      ui_web.platformViewRegistry.registerViewFactory(
        iframeId,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = url
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.border = 'none'
            ..style.overflow = 'hidden'
            ..allowFullscreen = true;
          return iframe;
        },
      );

      return HtmlElementView(viewType: iframeId);
    } catch (e) {
      print('Error building iframe widget: $e');
      return _buildWebPdfFallback(Uint8List(0)); // Empty bytes for fallback
    }
  }

  // Direct iframe widget using DOM manipulation
  Widget _buildDirectIframeWidget(String url) {
    // Schedule the DOM manipulation for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Create iframe directly in DOM
        final iframe = html.IFrameElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..style.overflow = 'hidden'
          ..allowFullscreen = true;
        
        // Try to find a container to embed
        final container = html.document.getElementById('pdf-iframe-container');
        if (container != null) {
          container.children.clear();
          container.children.add(iframe);
        } else {
          // Create container if it doesn't exist
          final newContainer = html.DivElement()
            ..id = 'pdf-iframe-container'
            ..style.width = '100%'
            ..style.height = '100%';
          
          newContainer.children.add(iframe);
          html.document.body?.children.add(newContainer);
        }
      } catch (e) {
        print('Error in direct iframe manipulation: $e');
      }
    });
    
    // Return a container that will contain the PDF iframe
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // This container will be replaced by the iframe
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          // Overlay with PDF info
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PDF đang được tải...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
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

  // Simple object tag PDF viewer (most compatible)
  Widget _buildObjectTagPdfViewer(Uint8List bytes) {
    try {
      // Create blob URL for PDF
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Clean up blob URL after a delay
      Future.delayed(const Duration(seconds: 30), () {
        html.Url.revokeObjectUrl(url);
      });
      
      // Use object tag which is more compatible with PDFs
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildObjectWidget(url),
        ),
      );
      
    } catch (e) {
      print('Error in object tag PDF viewer: $e');
      return _buildWebPdfFallback(bytes);
    }
  }

  // Build object widget using HtmlElementView with ui_web registry
  Widget _buildObjectWidget(String url) {
    try {
      final objectId = 'object-${DateTime.now().millisecondsSinceEpoch}';

      ui_web.platformViewRegistry.registerViewFactory(
        objectId,
        (int viewId) {
          final object = html.ObjectElement()
            ..data = url
            ..type = 'application/pdf'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.border = 'none';
          object.text = 'PDF không thể hiển thị. Nhấn vào đây để mở PDF';
          return object;
        },
      );

      return HtmlElementView(viewType: objectId);
    } catch (e) {
      print('Error building object widget: $e');
      return _buildWebPdfFallback(Uint8List(0));
    }
  }

  // Direct object widget using DOM manipulation
  Widget _buildDirectObjectWidget(String url) {
    // Schedule the DOM manipulation for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Create object element directly in DOM
        final object = html.ObjectElement()
          ..data = url
          ..type = 'application/pdf'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none';
        
        // Add fallback content
        object.text = 'PDF không thể hiển thị. Nhấn vào đây để mở PDF';
        
        // Try to find a container to embed
        final container = html.document.getElementById('pdf-object-container');
        if (container != null) {
          container.children.clear();
          container.children.add(object);
        } else {
          // Create container if it doesn't exist
          final newContainer = html.DivElement()
            ..id = 'pdf-object-container'
            ..style.width = '100%'
            ..style.height = '100%';
          
          newContainer.children.add(object);
          html.document.body?.children.add(newContainer);
        }
      } catch (e) {
        print('Error in direct object manipulation: $e');
      }
    });
    
    // Return a container that will contain the PDF object
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // This container will be replaced by the object element
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          // Overlay with PDF info
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 6),
                    Text(
                    'PDF đang được tải...',
                      style: TextStyle(
                        fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
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

  // Fallback web PDF display
  Widget _buildWebPdfFallback(Uint8List bytes) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'PDF Viewer (Web)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _tryEmbedPdfViewer(),
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Thử Embed Viewer'),
              ),
              ElevatedButton.icon(
                onPressed: () => _openPdfInNewTab(),
                icon: Icon(Icons.open_in_new),
                label: Text('Mở tab mới'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'PDF sẽ được hiển thị trực tiếp hoặc mở trong tab mới',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Mobile/Desktop PDF viewer using Syncfusion
  Widget _buildMobilePdfViewer(Uint8List bytes) {
    return SfPdfViewer.memory(
      bytes,
      enableDoubleTapZooming: true,
      enableTextSelection: true,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        print('=== PDF LOAD FAILED DEBUG ===');
        print('Error: ${details.error}');
        print('Error Type: ${details.error.runtimeType}');
        print('Details: $details');
         
        // Try to get more specific error information
        String errorMessage = 'Không thể tải PDF';
         
        if (details.error is String) {
          errorMessage = 'Lỗi PDF: ${details.error}';
        } else if (details.error != null) {
          errorMessage = 'Lỗi PDF: ${details.error.toString()}';
        }
         
        // Check if it's a common PDF error
        if (details.error.toString().contains('corrupt') || 
            details.error.toString().contains('invalid') ||
            details.error.toString().contains('format')) {
          errorMessage = 'File PDF bị hỏng hoặc không đúng định dạng';
        } else if (details.error.toString().contains('memory') ||
                 details.error.toString().contains('size')) {
          errorMessage = 'File PDF quá lớn hoặc không đủ bộ nhớ';
        }
         
        print('Final Error Message: $errorMessage');
        print('=== END DEBUG ===');
         
        setState(() {
          _errorMessage = errorMessage;
        });
      },
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        print('PDF Loaded Successfully: ${details.document.pages.count} pages');
        setState(() {
          _pageCount = details.document.pages.count;
        });
      },
      onPageChanged: (PdfPageChangedDetails details) {
        print('Page changed to: ${details.newPageNumber}');
      },
      onZoomLevelChanged: (PdfZoomDetails details) {
        print('Zoom level changed');
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
              'Không thể hiển thị tài liệu PDF',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lỗi: $error',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Debug information
            if (_pdfBytes != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin Debug:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kích thước: ${(_pdfBytes!.length / 1024 / 1024).toStringAsFixed(2)} MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Bytes count: ${_pdfBytes!.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_pdfVersion != 'Unknown')
                      Text(
                        'PDF Version: $_pdfVersion',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
                                            // Web-specific fallback options
            if (_pdfBytes != null && kIsWeb) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tùy chọn thay thế cho Web:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nếu PDF viewer không hoạt động, bạn có thể:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                                         Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         ElevatedButton.icon(
                           onPressed: () => _tryEmbedPdfViewer(),
                           icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Thử Embed Viewer'),
                         ),
                       ],
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _initializePdf,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}





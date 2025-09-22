import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class WebFileInput {
  static void openFileDialog({
    required Function(String fileName, html.File file) onFileSelected,
    String? accept,
  }) {
    if (!kIsWeb) return;
    
    // Tạo input element
    final input = html.FileUploadInputElement();
    input.accept = accept ?? '*/*';
    
    // Xử lý khi file được chọn
    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        onFileSelected(file.name, file);
      }
    });
    
    // Trigger click để mở dialog
    input.click();
  }
}

import 'package:flutter/material.dart';
import '../constants/app_config.dart';

/// Widget helper để hiển thị text có thể chọn hoặc không tùy theo config
class SelectableTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? enableSelection; // Override config nếu cần

  const SelectableTextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.enableSelection,
  });

  @override
  Widget build(BuildContext context) {
    final shouldEnableSelection =
        enableSelection ?? AppConfig.enableTextSelection;

    if (shouldEnableSelection) {
      return SelectableText(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        onSelectionChanged: (selection, cause) {
          // Có thể thêm logic xử lý khi text được chọn
        },
      );
    } else {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
  }
}

/// Extension để dễ dàng sử dụng với Text widget
extension TextSelectionExtension on Text {
  /// Chuyển đổi Text thành SelectableText nếu config được bật
  Widget toSelectable() {
    return SelectableTextWidget(
      text: data ?? '',
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

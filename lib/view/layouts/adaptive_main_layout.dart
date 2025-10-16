import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';
import 'web_main_layout.dart';
import 'mobile_main_layout.dart';

class AdaptiveMainLayout extends StatelessWidget {
  const AdaptiveMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layoutType) {
        // Desktop và Large Desktop sử dụng Web Layout
        if (layoutType == ResponsiveLayoutType.desktop || 
            layoutType == ResponsiveLayoutType.largeDesktop) {
          return const WebMainLayout();
        }
        
        // Mobile và Tablet sử dụng Mobile Layout
        return const MobileMainLayout();
      },
    );
  }
}

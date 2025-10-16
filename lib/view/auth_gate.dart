import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/responsive_utils.dart';
import 'auth/auth_web_view.dart';
import 'auth/auth_mobile_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layoutType) {
        if (layoutType == ResponsiveLayoutType.desktop ||
            layoutType == ResponsiveLayoutType.largeDesktop) {
          return const AuthWebView();
        } else {
          return const AuthMobileView();
        }
      },
    );
  }
}


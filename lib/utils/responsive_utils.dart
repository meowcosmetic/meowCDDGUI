import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Screen size helpers
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Responsive width helpers
  static double getResponsiveWidth(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? 1.0;
    } else if (isTablet(context)) {
      return tablet ?? 0.8;
    } else if (isDesktop(context)) {
      return desktop ?? 0.7;
    } else {
      return largeDesktop ?? 0.6;
    }
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else {
      return const EdgeInsets.all(40);
    }
  }

  // Responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
    double? mobileMultiplier,
    double? tabletMultiplier,
    double? desktopMultiplier,
    double? largeDesktopMultiplier,
  }) {
    if (isMobile(context)) {
      return baseFontSize * (mobileMultiplier ?? 1.0);
    } else if (isTablet(context)) {
      return baseFontSize * (tabletMultiplier ?? 1.1);
    } else if (isDesktop(context)) {
      return baseFontSize * (desktopMultiplier ?? 1.2);
    } else {
      return baseFontSize * (largeDesktopMultiplier ?? 1.3);
    }
  }

  // Responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    required double baseSpacing,
    double? mobileMultiplier,
    double? tabletMultiplier,
    double? desktopMultiplier,
    double? largeDesktopMultiplier,
  }) {
    if (isMobile(context)) {
      return baseSpacing * (mobileMultiplier ?? 1.0);
    } else if (isTablet(context)) {
      return baseSpacing * (tabletMultiplier ?? 1.2);
    } else if (isDesktop(context)) {
      return baseSpacing * (desktopMultiplier ?? 1.4);
    } else {
      return baseSpacing * (largeDesktopMultiplier ?? 1.6);
    }
  }

  // Responsive columns for grid layouts
  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else if (isDesktop(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  // Responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return BoxConstraints(maxWidth: screenWidth, minWidth: 300);
    } else if (isTablet(context)) {
      return BoxConstraints(maxWidth: 600, minWidth: 400);
    } else if (isDesktop(context)) {
      return BoxConstraints(maxWidth: 800, minWidth: 500);
    } else {
      return BoxConstraints(maxWidth: 1000, minWidth: 600);
    }
  }

  // Responsive button size
  static Size getResponsiveButtonSize(BuildContext context) {
    if (isMobile(context)) {
      return const Size(double.infinity, 48);
    } else if (isTablet(context)) {
      return const Size(double.infinity, 52);
    } else if (isDesktop(context)) {
      return const Size(double.infinity, 56);
    } else {
      return const Size(double.infinity, 60);
    }
  }

  // Responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    required double baseSize,
  }) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else if (isDesktop(context)) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.3;
    }
  }

  // Responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else if (isDesktop(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(28);
    }
  }

  // Responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context, {
    required double baseRadius,
  }) {
    if (isMobile(context)) {
      return baseRadius;
    } else if (isTablet(context)) {
      return baseRadius * 1.1;
    } else if (isDesktop(context)) {
      return baseRadius * 1.2;
    } else {
      return baseRadius * 1.3;
    }
  }

  // Get responsive layout type
  static ResponsiveLayoutType getLayoutType(BuildContext context) {
    if (isMobile(context)) {
      return ResponsiveLayoutType.mobile;
    } else if (isTablet(context)) {
      return ResponsiveLayoutType.tablet;
    } else if (isDesktop(context)) {
      return ResponsiveLayoutType.desktop;
    } else {
      return ResponsiveLayoutType.largeDesktop;
    }
  }
}

enum ResponsiveLayoutType { mobile, tablet, desktop, largeDesktop }

// Responsive Widget Builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveLayoutType layoutType)
  builder;

  const ResponsiveBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveUtils.getLayoutType(context));
  }
}

// Responsive Container Widget
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: ResponsiveUtils.getResponsiveConstraints(context),
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          borderRadius ??
              ResponsiveUtils.getResponsiveBorderRadius(
                context,
                baseRadius: 12,
              ),
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

// Responsive Text Widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = fontSize != null
        ? ResponsiveUtils.getResponsiveFontSize(
            context,
            baseFontSize: fontSize!,
          )
        : null;

    return Text(
      text,
      style:
          style?.copyWith(
            fontSize: responsiveFontSize,
            fontWeight: fontWeight,
            color: color,
          ) ??
          TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: fontWeight,
            color: color,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

// Responsive Button Widget
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool isOutlined;

  const ResponsiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonSize = ResponsiveUtils.getResponsiveButtonSize(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(
      context,
      baseRadius: 12,
    );

    if (isOutlined) {
      return SizedBox(
        width: buttonSize.width,
        height: buttonSize.height,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: BorderSide(
              color: foregroundColor ?? Theme.of(context).primaryColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(text),
        ),
      );
    } else {
      return SizedBox(
        width: buttonSize.width,
        height: buttonSize.height,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(text),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


enum HeadingLevel {
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
}

enum HeadingSize {
  small,
  medium,
  large,
  xlarge,
}

enum HeadingWeight {
  light,
  normal,
  medium,
  semibold,
  bold,
  extrabold,
}

class Heading extends StatelessWidget {
  final String text;
  final HeadingLevel level;
  final HeadingSize size;
  final HeadingWeight weight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool underline;
  final bool italic;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const Heading({
    super.key,
    required this.text,
    this.level = HeadingLevel.h1,
    this.size = HeadingSize.large,
    this.weight = HeadingWeight.bold,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.underline = false,
    this.italic = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = color ?? _getDefaultColor(theme);
    final textStyle = _getTextStyle(defaultColor);

    Widget headingWidget = Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    if (onTap != null) {
      headingWidget = GestureDetector(
        onTap: onTap,
        child: headingWidget,
      );
    }

    if (icon != null || trailing != null) {
      headingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: defaultColor,
            ),
            SizedBox(width: _getIconSpacing()),
          ],
          Flexible(child: headingWidget),
          if (trailing != null) ...[
            SizedBox(width: _getIconSpacing()),
            trailing!,
          ],
        ],
      );
    }

    if (margin != null || padding != null) {
      headingWidget = Container(
        margin: margin,
        padding: padding,
        child: headingWidget,
      );
    }

    return headingWidget;
  }

  TextStyle _getTextStyle(Color color) {
    return TextStyle(
      fontSize: _getFontSize(),
      fontWeight: _getFontWeight(),
      color: color,
      decoration: underline ? TextDecoration.underline : null,
      decorationColor: underline ? AppColors.cardBorder : null,
      decorationThickness: underline ? 2.0 : null,
      fontStyle: italic ? FontStyle.italic : null,
      height: _getLineHeight(),
    );
  }

  Color _getDefaultColor(ThemeData theme) {
    switch (level) {
      case HeadingLevel.h1:
        return theme.textTheme.headlineLarge?.color ?? AppColors.textPrimary;
      case HeadingLevel.h2:
        return theme.textTheme.headlineMedium?.color ?? AppColors.textPrimary;
      case HeadingLevel.h3:
        return theme.textTheme.headlineSmall?.color ?? AppColors.textPrimary;
      case HeadingLevel.h4:
        return theme.textTheme.titleLarge?.color ?? AppColors.textPrimary;
      case HeadingLevel.h5:
        return theme.textTheme.titleMedium?.color ?? AppColors.textPrimary;
      case HeadingLevel.h6:
        return theme.textTheme.titleSmall?.color ?? AppColors.textPrimary;
    }
  }

  double _getFontSize() {
    switch (size) {
      case HeadingSize.small:
        return 16;
      case HeadingSize.medium:
        return 20;
      case HeadingSize.large:
        return 24;
      case HeadingSize.xlarge:
        return 32;
    }
  }

  FontWeight _getFontWeight() {
    switch (weight) {
      case HeadingWeight.light:
        return FontWeight.w300;
      case HeadingWeight.normal:
        return FontWeight.w400;
      case HeadingWeight.medium:
        return FontWeight.w500;
      case HeadingWeight.semibold:
        return FontWeight.w600;
      case HeadingWeight.bold:
        return FontWeight.w700;
      case HeadingWeight.extrabold:
        return FontWeight.w800;
    }
  }

  double _getLineHeight() {
    switch (size) {
      case HeadingSize.small:
        return 1.4;
      case HeadingSize.medium:
        return 1.3;
      case HeadingSize.large:
        return 1.2;
      case HeadingSize.xlarge:
        return 1.1;
    }
  }

  double _getIconSize() {
    switch (size) {
      case HeadingSize.small:
        return 16;
      case HeadingSize.medium:
        return 20;
      case HeadingSize.large:
        return 24;
      case HeadingSize.xlarge:
        return 28;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case HeadingSize.small:
        return 8;
      case HeadingSize.medium:
        return 10;
      case HeadingSize.large:
        return 12;
      case HeadingSize.xlarge:
        return 16;
    }
  }
}

// Convenience constructors for different heading levels
class H1 extends StatelessWidget {
  final String text;
  final HeadingSize size;
  final HeadingWeight weight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool underline;
  final bool italic;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const H1({
    super.key,
    required this.text,
    this.size = HeadingSize.xlarge,
    this.weight = HeadingWeight.bold,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.underline = false,
    this.italic = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Heading(
      text: text,
      level: HeadingLevel.h1,
      size: size,
      weight: weight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      underline: underline,
      italic: italic,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

class H2 extends StatelessWidget {
  final String text;
  final HeadingSize size;
  final HeadingWeight weight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool underline;
  final bool italic;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const H2({
    super.key,
    required this.text,
    this.size = HeadingSize.large,
    this.weight = HeadingWeight.bold,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.underline = false,
    this.italic = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Heading(
      text: text,
      level: HeadingLevel.h2,
      size: size,
      weight: weight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      underline: underline,
      italic: italic,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

class H3 extends StatelessWidget {
  final String text;
  final HeadingSize size;
  final HeadingWeight weight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool underline;
  final bool italic;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const H3({
    super.key,
    required this.text,
    this.size = HeadingSize.medium,
    this.weight = HeadingWeight.semibold,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.underline = false,
    this.italic = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Heading(
      text: text,
      level: HeadingLevel.h3,
      size: size,
      weight: weight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      underline: underline,
      italic: italic,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

class H4 extends StatelessWidget {
  final String text;
  final HeadingSize size;
  final HeadingWeight weight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool underline;
  final bool italic;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const H4({
    super.key,
    required this.text,
    this.size = HeadingSize.medium,
    this.weight = HeadingWeight.medium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.underline = false,
    this.italic = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Heading(
      text: text,
      level: HeadingLevel.h4,
      size: size,
      weight: weight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      underline: underline,
      italic: italic,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

class H5 extends StatelessWidget {
  final String text;
  final HeadingSize size;
  final HeadingWeight weight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool underline;
  final bool italic;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const H5({
    super.key,
    required this.text,
    this.size = HeadingSize.small,
    this.weight = HeadingWeight.medium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.underline = false,
    this.italic = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Heading(
      text: text,
      level: HeadingLevel.h5,
      size: size,
      weight: weight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      underline: underline,
      italic: italic,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

class H6 extends StatelessWidget {
  final String text;
  final HeadingSize size;
  final HeadingWeight weight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool underline;
  final bool italic;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const H6({
    super.key,
    required this.text,
    this.size = HeadingSize.small,
    this.weight = HeadingWeight.normal,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.underline = false,
    this.italic = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Heading(
      text: text,
      level: HeadingLevel.h6,
      size: size,
      weight: weight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      underline: underline,
      italic: italic,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

// Special heading components
class PageTitle extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const PageTitle({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return H1(
      text: text,
      size: HeadingSize.xlarge,
      weight: HeadingWeight.extrabold,
      color: color,
      textAlign: textAlign,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SectionTitle({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return H2(
      text: text,
      size: HeadingSize.large,
      weight: HeadingWeight.bold,
      color: color,
      textAlign: textAlign,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
}

class SubsectionTitle extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SubsectionTitle({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.icon,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return H3(
      text: text,
      size: HeadingSize.medium,
      weight: HeadingWeight.semibold,
      color: color,
      textAlign: textAlign,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
      margin: margin,
      padding: padding,
    );
  }
} 

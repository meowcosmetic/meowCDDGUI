import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CardType { default_, elevated, outlined, filled }

enum CardSize { small, medium, large }

class MeowCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final CardType type;
  final CardSize size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showDivider;

  const MeowCard({
    super.key,
    this.title,
    this.description,
    this.content,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.type = CardType.default_,
    this.size = CardSize.medium,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: _buildCard(context));
  }

  Widget _buildCard(BuildContext context) {
    switch (type) {
      case CardType.default_:
        return _buildDefaultCard(context);
      case CardType.elevated:
        return _buildElevatedCard(context);
      case CardType.outlined:
        return _buildOutlinedCard(context);
      case CardType.filled:
        return _buildFilledCard(context);
    }
  }

  Widget _buildDefaultCard(BuildContext context) {
    return Card(
      margin: margin ?? _getMargin(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? _getBorderRadius()),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      color: backgroundColor,
      child: _buildCardContent(context),
    );
  }

  Widget _buildElevatedCard(BuildContext context) {
    return Card(
      margin: margin ?? _getMargin(),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? _getBorderRadius()),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      color: backgroundColor,
      child: _buildCardContent(context),
    );
  }

  Widget _buildOutlinedCard(BuildContext context) {
    return Card(
      margin: margin ?? _getMargin(),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? _getBorderRadius()),
        side: BorderSide(color: borderColor ?? AppColors.cardBorder, width: 1),
      ),
      color: backgroundColor,
      child: _buildCardContent(context),
    );
  }

  Widget _buildFilledCard(BuildContext context) {
    return Card(
      margin: margin ?? _getMargin(),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? _getBorderRadius()),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      color: backgroundColor ?? AppColors.grey50,
      child: _buildCardContent(context),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius ?? _getBorderRadius()),
      child: Padding(
        padding: padding ?? _getPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section with leading, title, description, and trailing
            if (leading != null ||
                title != null ||
                description != null ||
                trailing != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(title!, style: _getTitleStyle()),
                        if (description != null) ...[
                          if (title != null) const SizedBox(height: 4),
                          Text(description!, style: _getDescriptionStyle()),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),

            // Divider
            if (showDivider &&
                (title != null || description != null) &&
                content != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.grey300, height: 1),
              ),

            // Content
            if (content != null) content!,

            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              if (content != null) const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: action,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case CardSize.small:
        return const EdgeInsets.all(12);
      case CardSize.medium:
        return const EdgeInsets.all(16);
      case CardSize.large:
        return const EdgeInsets.all(20);
    }
  }

  EdgeInsets _getMargin() {
    switch (size) {
      case CardSize.small:
        return const EdgeInsets.all(4);
      case CardSize.medium:
        return const EdgeInsets.all(8);
      case CardSize.large:
        return const EdgeInsets.all(12);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case CardSize.small:
        return 6;
      case CardSize.medium:
        return 8;
      case CardSize.large:
        return 12;
    }
  }

  TextStyle _getTitleStyle() {
    switch (size) {
      case CardSize.small:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
      case CardSize.medium:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
      case CardSize.large:
        return const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
    }
  }

  TextStyle _getDescriptionStyle() {
    switch (size) {
      case CardSize.small:
        return TextStyle(fontSize: 12, color: AppColors.grey600);
      case CardSize.medium:
        return TextStyle(fontSize: 14, color: AppColors.grey600);
      case CardSize.large:
        return TextStyle(fontSize: 16, color: AppColors.grey600);
    }
  }
}

// Convenience constructors for different card types
class ElevatedMeowCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final CardSize size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showDivider;

  const ElevatedMeowCard({
    super.key,
    this.title,
    this.description,
    this.content,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.size = CardSize.medium,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return MeowCard(
      title: title,
      description: description,
      content: content,
      leading: leading,
      trailing: trailing,
      actions: actions,
      onTap: onTap,
      type: CardType.elevated,
      size: size,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      showDivider: showDivider,
    );
  }
}

class OutlinedMeowCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final CardSize size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showDivider;

  const OutlinedMeowCard({
    super.key,
    this.title,
    this.description,
    this.content,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.size = CardSize.medium,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return MeowCard(
      title: title,
      description: description,
      content: content,
      leading: leading,
      trailing: trailing,
      actions: actions,
      onTap: onTap,
      type: CardType.outlined,
      size: size,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      showDivider: showDivider,
    );
  }
}

class FilledMeowCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final CardSize size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showDivider;

  const FilledMeowCard({
    super.key,
    this.title,
    this.description,
    this.content,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.size = CardSize.medium,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return MeowCard(
      title: title,
      description: description,
      content: content,
      leading: leading,
      trailing: trailing,
      actions: actions,
      onTap: onTap,
      type: CardType.filled,
      size: size,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      showDivider: showDivider,
    );
  }
}

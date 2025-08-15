import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum AlertType {
  success,
  error,
  warning,
  info,
}

enum AlertSize {
  small,
  medium,
  large,
}

class Alert extends StatelessWidget {
  final String title;
  final String? message;
  final AlertType type;
  final AlertSize size;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final bool showIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const Alert({
    super.key,
    required this.title,
    this.message,
    this.type = AlertType.info,
    this.size = AlertSize.medium,
    this.icon,
    this.actions,
    this.onDismiss,
    this.dismissible = true,
    this.showIcon = true,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    
    return Container(
      width: width,
      padding: padding ?? _getPadding(),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors['background'],
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: borderColor ?? colors['border']!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors['shadow']!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? _getDefaultIcon(),
              color: colors['icon'],
              size: _getIconSize(),
            ),
            SizedBox(width: _getIconSpacing()),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: _getTitleSize(),
                          fontWeight: FontWeight.w600,
                          color: colors['text'],
                        ),
                      ),
                    ),
                    if (dismissible && onDismiss != null)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: _getIconSize() * 0.8,
                          color: colors['icon'],
                        ),
                        onPressed: onDismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                if (message != null) ...[
                  SizedBox(height: _getMessageSpacing()),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: _getMessageSize(),
                      color: colors['text']?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                if (actions != null && actions!.isNotEmpty) ...[
                  SizedBox(height: _getActionsSpacing()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!
                        .map((action) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: action,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColors(ThemeData theme) {
    switch (type) {
      case AlertType.success:
        return {
          'background': AppColors.alertSuccessBackground,
          'border': AppColors.alertSuccessBorder,
          'icon': AppColors.alertSuccessIcon,
          'text': AppColors.alertSuccessText,
          'shadow': AppColors.alertSuccessShadow,
        };
      case AlertType.error:
        return {
          'background': AppColors.alertErrorBackground,
          'border': AppColors.alertErrorBorder,
          'icon': AppColors.alertErrorIcon,
          'text': AppColors.alertErrorText,
          'shadow': AppColors.alertErrorShadow,
        };
      case AlertType.warning:
        return {
          'background': AppColors.alertWarningBackground,
          'border': AppColors.alertWarningBorder,
          'icon': AppColors.alertWarningIcon,
          'text': AppColors.alertWarningText,
          'shadow': AppColors.alertWarningShadow,
        };
      case AlertType.info:
        return {
          'background': AppColors.alertInfoBackground,
          'border': AppColors.alertInfoBorder,
          'icon': AppColors.alertInfoIcon,
          'text': AppColors.alertInfoText,
          'shadow': AppColors.alertInfoShadow,
        };
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.warning:
        return Icons.warning_amber_outlined;
      case AlertType.info:
        return Icons.info_outline;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AlertSize.small:
        return 4;
      case AlertSize.medium:
        return 8;
      case AlertSize.large:
        return 12;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AlertSize.small:
        return const EdgeInsets.all(12);
      case AlertSize.medium:
        return const EdgeInsets.all(16);
      case AlertSize.large:
        return const EdgeInsets.all(20);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AlertSize.small:
        return 16;
      case AlertSize.medium:
        return 20;
      case AlertSize.large:
        return 24;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AlertSize.small:
        return 8;
      case AlertSize.medium:
        return 12;
      case AlertSize.large:
        return 16;
    }
  }

  double _getTitleSize() {
    switch (size) {
      case AlertSize.small:
        return 14;
      case AlertSize.medium:
        return 16;
      case AlertSize.large:
        return 18;
    }
  }

  double _getMessageSize() {
    switch (size) {
      case AlertSize.small:
        return 12;
      case AlertSize.medium:
        return 14;
      case AlertSize.large:
        return 16;
    }
  }

  double _getMessageSpacing() {
    switch (size) {
      case AlertSize.small:
        return 4;
      case AlertSize.medium:
        return 6;
      case AlertSize.large:
        return 8;
    }
  }

  double _getActionsSpacing() {
    switch (size) {
      case AlertSize.small:
        return 8;
      case AlertSize.medium:
        return 12;
      case AlertSize.large:
        return 16;
    }
  }
}

// Convenience constructors
class SuccessAlert extends StatelessWidget {
  final String title;
  final String? message;
  final AlertSize size;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final bool showIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const SuccessAlert({
    super.key,
    required this.title,
    this.message,
    this.size = AlertSize.medium,
    this.icon,
    this.actions,
    this.onDismiss,
    this.dismissible = true,
    this.showIcon = true,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      message: message,
      type: AlertType.success,
      size: size,
      icon: icon,
      actions: actions,
      onDismiss: onDismiss,
      dismissible: dismissible,
      showIcon: showIcon,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      width: width,
      padding: padding,
    );
  }
}

class ErrorAlert extends StatelessWidget {
  final String title;
  final String? message;
  final AlertSize size;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final bool showIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const ErrorAlert({
    super.key,
    required this.title,
    this.message,
    this.size = AlertSize.medium,
    this.icon,
    this.actions,
    this.onDismiss,
    this.dismissible = true,
    this.showIcon = true,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      message: message,
      type: AlertType.error,
      size: size,
      icon: icon,
      actions: actions,
      onDismiss: onDismiss,
      dismissible: dismissible,
      showIcon: showIcon,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      width: width,
      padding: padding,
    );
  }
}

class WarningAlert extends StatelessWidget {
  final String title;
  final String? message;
  final AlertSize size;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final bool showIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const WarningAlert({
    super.key,
    required this.title,
    this.message,
    this.size = AlertSize.medium,
    this.icon,
    this.actions,
    this.onDismiss,
    this.dismissible = true,
    this.showIcon = true,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      message: message,
      type: AlertType.warning,
      size: size,
      icon: icon,
      actions: actions,
      onDismiss: onDismiss,
      dismissible: dismissible,
      showIcon: showIcon,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      width: width,
      padding: padding,
    );
  }
}

class InfoAlert extends StatelessWidget {
  final String title;
  final String? message;
  final AlertSize size;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final bool showIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const InfoAlert({
    super.key,
    required this.title,
    this.message,
    this.size = AlertSize.medium,
    this.icon,
    this.actions,
    this.onDismiss,
    this.dismissible = true,
    this.showIcon = true,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      message: message,
      type: AlertType.info,
      size: size,
      icon: icon,
      actions: actions,
      onDismiss: onDismiss,
      dismissible: dismissible,
      showIcon: showIcon,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      width: width,
      padding: padding,
    );
  }
} 

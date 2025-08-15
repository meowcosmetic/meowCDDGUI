import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double? height;

  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || isLoading;
    
    return SizedBox(
      width: width,
      height: height ?? _getHeight(),
      child: _buildButton(context, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(context, isDisabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(context, isDisabled);
      case ButtonType.outline:
        return _buildOutlineButton(context, isDisabled);
      case ButtonType.ghost:
        return _buildGhostButton(context, isDisabled);
      case ButtonType.destructive:
        return _buildDestructiveButton(context, isDisabled);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey300 : AppColors.primary,
        foregroundColor: isDisabled ? AppColors.grey600 : AppColors.white,
        textStyle: _getTextStyle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: _getPadding(),
        elevation: 0,
        shadowColor: AppColors.transparent,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey100 : AppColors.grey200,
        foregroundColor: isDisabled ? AppColors.grey600 : AppColors.textPrimary,
        textStyle: _getTextStyle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: _getPadding(),
        elevation: 0,
        shadowColor: AppColors.transparent,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDisabled ? AppColors.grey600 : AppColors.cardBorder,
        side: BorderSide(
          color: isDisabled ? AppColors.grey400 : AppColors.cardBorder,
          width: 1.5,
        ),
        textStyle: _getTextStyle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: _getPadding(),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildGhostButton(BuildContext context, bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDisabled ? AppColors.grey600 : AppColors.cardBorder,
        textStyle: _getTextStyle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: _getPadding(),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildDestructiveButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey300 : AppColors.error,
        foregroundColor: isDisabled ? AppColors.grey600 : AppColors.white,
        textStyle: _getTextStyle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: _getPadding(),
        elevation: 0,
        shadowColor: AppColors.transparent,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline || type == ButtonType.ghost
                ? AppColors.cardBorder
                : AppColors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
          ),
          SizedBox(width: _getIconSpacing()),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      case ButtonSize.medium:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.large:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case ButtonSize.small:
        return 4;
      case ButtonSize.medium:
        return 6;
      case ButtonSize.large:
        return 8;
    }
  }
}

// Convenience constructors for different button types
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      text: text,
      onPressed: onPressed,
      type: ButtonType.secondary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double? height;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      text: text,
      onPressed: onPressed,
      type: ButtonType.outline,
      size: size,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double? height;

  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      text: text,
      onPressed: onPressed,
      type: ButtonType.ghost,
      size: size,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
    );
  }
}

class DestructiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double? height;

  const DestructiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      text: text,
      onPressed: onPressed,
      type: ButtonType.destructive,
      size: size,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
    );
  }
}

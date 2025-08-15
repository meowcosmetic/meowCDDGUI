import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


enum LoadingType {
  circular,
  linear,
  skeleton,
  dots,
  pulse,
}

enum LoadingSize {
  small,
  medium,
  large,
}

class Loading extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final Color? color;
  final String? text;
  final double? width;
  final double? height;
  final bool showText;

  const Loading({
    super.key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.color,
    this.text,
    this.width,
    this.height,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = color ?? theme.primaryColor;

    switch (type) {
      case LoadingType.circular:
        return _buildCircularLoading(defaultColor);
      case LoadingType.linear:
        return _buildLinearLoading(defaultColor);
      case LoadingType.skeleton:
        return _buildSkeletonLoading(defaultColor);
      case LoadingType.dots:
        return _buildDotsLoading(defaultColor);
      case LoadingType.pulse:
        return _buildPulseLoading(defaultColor);
    }
  }

  Widget _buildCircularLoading(Color color) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _getSize(),
            height: _getSize(),
            child: CircularProgressIndicator(
              strokeWidth: _getStrokeWidth(),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (showText && text != null) ...[
            SizedBox(height: _getTextSpacing()),
            Text(
              text!,
              style: TextStyle(
                fontSize: _getTextSize(),
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinearLoading(Color color) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? _getSize(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: _getStrokeWidth(),
          ),
          if (showText && text != null) ...[
            SizedBox(height: _getTextSpacing()),
            Text(
              text!,
              style: TextStyle(
                fontSize: _getTextSize(),
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(Color color) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? _getSize(),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: _SkeletonAnimation(color: color),
      ),
    );
  }

  Widget _buildDotsLoading(Color color) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DotsAnimation(
            color: color,
            size: _getDotSize(),
          ),
          if (showText && text != null) ...[
            SizedBox(height: _getTextSpacing()),
            Text(
              text!,
              style: TextStyle(
                fontSize: _getTextSize(),
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPulseLoading(Color color) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseAnimation(
            color: color,
            size: _getSize(),
          ),
          if (showText && text != null) ...[
            SizedBox(height: _getTextSpacing()),
            Text(
              text!,
              style: TextStyle(
                fontSize: _getTextSize(),
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 32;
      case LoadingSize.large:
        return 48;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }

  double _getDotSize() {
    switch (size) {
      case LoadingSize.small:
        return 6;
      case LoadingSize.medium:
        return 8;
      case LoadingSize.large:
        return 12;
    }
  }

  double _getTextSize() {
    switch (size) {
      case LoadingSize.small:
        return 12;
      case LoadingSize.medium:
        return 14;
      case LoadingSize.large:
        return 16;
    }
  }

  double _getTextSpacing() {
    switch (size) {
      case LoadingSize.small:
        return 8;
      case LoadingSize.medium:
        return 12;
      case LoadingSize.large:
        return 16;
    }
  }
}

// Skeleton Animation
class _SkeletonAnimation extends StatefulWidget {
  final Color color;

  const _SkeletonAnimation({required this.color});

  @override
  State<_SkeletonAnimation> createState() => _SkeletonAnimationState();
}

class _SkeletonAnimationState extends State<_SkeletonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.transparent,
                widget.color.withValues(alpha: 0.3),
                AppColors.transparent,
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Dots Animation
class _DotsAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsAnimation({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsAnimation> createState() => _DotsAnimationState();
}

class _DotsAnimationState extends State<_DotsAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 200)),
        vsync: this,
      ),
    );
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.3 + (_animations[index].value * 0.7)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

// Pulse Animation
class _PulseAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseAnimation({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Convenience constructors
class CircularLoading extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final String? text;
  final double? width;
  final double? height;
  final bool showText;

  const CircularLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.text,
    this.width,
    this.height,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Loading(
      type: LoadingType.circular,
      size: size,
      color: color,
      text: text,
      width: width,
      height: height,
      showText: showText,
    );
  }
}

class LinearLoading extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final String? text;
  final double? width;
  final double? height;
  final bool showText;

  const LinearLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.text,
    this.width,
    this.height,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Loading(
      type: LoadingType.linear,
      size: size,
      color: color,
      text: text,
      width: width,
      height: height,
      showText: showText,
    );
  }
}

class SkeletonLoading extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final double? width;
  final double? height;

  const SkeletonLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Loading(
      type: LoadingType.skeleton,
      size: size,
      color: color,
      width: width,
      height: height,
    );
  }
}

class DotsLoading extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final String? text;
  final double? width;
  final double? height;
  final bool showText;

  const DotsLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.text,
    this.width,
    this.height,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Loading(
      type: LoadingType.dots,
      size: size,
      color: color,
      text: text,
      width: width,
      height: height,
      showText: showText,
    );
  }
}

class PulseLoading extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final String? text;
  final double? width;
  final double? height;
  final bool showText;

  const PulseLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.text,
    this.width,
    this.height,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Loading(
      type: LoadingType.pulse,
      size: size,
      color: color,
      text: text,
      width: width,
      height: height,
      showText: showText,
    );
  }
} 

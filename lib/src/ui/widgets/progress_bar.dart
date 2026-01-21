import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 100.0);
    final effectiveProgressColor = progressColor ?? _getProgressColor(clampedProgress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.grey.shade200,
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: clampedProgress / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: effectiveProgressColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${clampedProgress.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: effectiveProgressColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppTheme.successColor;
    if (progress >= 60) return AppTheme.primaryColor;
    if (progress >= 30) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}

class CircularProgressIndicatorWithLabel extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;

  const CircularProgressIndicatorWithLabel({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 100.0);
    final effectiveProgressColor = progressColor ?? _getProgressColor(clampedProgress);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedProgress / 100,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
            ),
          ),
          Text(
            '${clampedProgress.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: size / 4,
              fontWeight: FontWeight.bold,
              color: effectiveProgressColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppTheme.successColor;
    if (progress >= 60) return AppTheme.primaryColor;
    if (progress >= 30) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: config.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String rawStatus) {
    final s = rawStatus.toLowerCase().trim();

    // Success states
    if (s == 'active' || s == 'approved' || s == 'converted' || s == 'present') {
      return _StatusConfig(
        textColor: AppColors.success,
        backgroundColor: AppColors.successLight,
        borderColor: AppColors.success.withOpacity(0.3),
      );
    }

    // Warning / Pending states
    if (s == 'pending' || s == 'contacted' || s == 'interested') {
      return _StatusConfig(
        textColor: AppColors.warning,
        backgroundColor: AppColors.warningLight,
        borderColor: AppColors.warning.withOpacity(0.3),
      );
    }

    // Error / Rejected / Absent states
    if (s == 'rejected' || s == 'absent' || s == 'inactive') {
      return _StatusConfig(
        textColor: AppColors.error,
        backgroundColor: AppColors.errorLight,
        borderColor: AppColors.error.withOpacity(0.3),
      );
    }

    // Info / New / Default states
    return _StatusConfig(
      textColor: AppColors.info,
      backgroundColor: AppColors.infoLight,
      borderColor: AppColors.info.withOpacity(0.3),
    );
  }
}

class _StatusConfig {
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const _StatusConfig({
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

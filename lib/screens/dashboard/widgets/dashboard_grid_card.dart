import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class DashboardGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final Color backgroundColor;
  final Color accentCircleColor;
  final Color arrowColor;
  final VoidCallback onTap;

  const DashboardGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.backgroundColor,
    required this.accentCircleColor,
    this.arrowColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentCircleColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Top-Right Accent Circle with Arrow (Centered inside the circle)
                Positioned(
                  bottom: -5,
                  left: -5,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: accentCircleColor.withAlpha(100),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: arrowColor,
                      size: 16,
                    ),
                  ),
                ),

                // Big 3D Asset Illustration placed at right bottom corner and clipped
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Hero(
                      tag: 'grid_card_$title',
                      child: Image.asset(
                        assetPath,
                        height: 120,
                        width: 120,
                        fit: BoxFit.contain,
                        opacity: const AlwaysStoppedAnimation(0.5),
                      ),
                    ),
                  ),
                ),

                // Card Content (Title & Subtitle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 52, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withOpacity(0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

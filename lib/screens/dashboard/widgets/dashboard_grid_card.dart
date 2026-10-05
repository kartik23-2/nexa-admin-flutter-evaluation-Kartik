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
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
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
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: accentCircleColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: arrowColor,
                      size: 22,
                    ),
                  ),
                ),

                // Big 3D Asset Illustration placed at right bottom corner and clipped
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Hero(
                    tag: 'grid_card_$title',
                    child: Image.asset(
                      assetPath,
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
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

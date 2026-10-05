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
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        // Proportional sizing based on available card dimensions
        final hPadding = (cardWidth * 0.085).clamp(12.0, 16.0);
        final topPadding = (cardHeight * 0.10).clamp(12.0, 16.0);
        final titleFontSize = (cardWidth * 0.11).clamp(15.0, 18.0);
        final subtitleFontSize = (cardWidth * 0.07).clamp(11.0, 12.5);
        final imgSize = (cardWidth * 0.68).clamp(88.0, 125.0);
        final imgOffset = -(imgSize * 0.12);
        final circleSize = (cardWidth * 0.25).clamp(36.0, 44.0);
        final iconSize = (circleSize * 0.38).clamp(14.0, 17.0);

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(28),
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
              borderRadius: BorderRadius.circular(28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Bottom-Left Accent Circle with Arrow
                    Positioned(
                      bottom: -4,
                      left: -4,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: accentCircleColor.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          color: arrowColor,
                          size: iconSize,
                        ),
                      ),
                    ),

                    // 3D Asset Illustration responsive to card size and clipped
                    Positioned(
                      right: imgOffset,
                      bottom: imgOffset,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Hero(
                          tag: 'grid_card_$title',
                          child: Image.asset(
                            assetPath,
                            height: imgSize,
                            width: imgSize,
                            fit: BoxFit.contain,
                            opacity: const AlwaysStoppedAnimation(0.25),
                          ),
                        ),
                      ),
                    ),

                    // Card Content (Title & Subtitle) - auto-scales cleanly without "..." truncation
                    Padding(
                      padding: EdgeInsets.fromLTRB(hPadding, topPadding, hPadding, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title with auto-scaling to prevent truncation on any device
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Subtitle with auto-scaling
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary.withOpacity(0.85),
                              ),
                            ),
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
      },
    );
  }
}

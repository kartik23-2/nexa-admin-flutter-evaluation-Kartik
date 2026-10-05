import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'shimmer_loading.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  final bool isGrid;
  final int count;

  const LoadingView({
    super.key,
    this.message,
    this.isGrid = false,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const ShimmerBox(width: 8, height: 8, shape: BoxShape.circle, color: AppColors.limeAccent),
                  const SizedBox(width: 8),
                  Text(
                    message!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (isGrid)
            ShimmerGrid(itemCount: count)
          else
            ShimmerCardList(itemCount: count),
        ],
      ),
    );
  }
}

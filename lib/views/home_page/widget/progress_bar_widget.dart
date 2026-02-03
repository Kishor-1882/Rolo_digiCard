import 'package:flutter/material.dart';
import 'package:rolo_digi_card/utils/color.dart';

class ProgressBarWidget extends StatelessWidget {
  final String title;
  final String percentage;
  final double progress;

  const ProgressBarWidget({
    Key? key,
    required this.title,
    required this.percentage,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                percentage,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textPrimary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.progressPink,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
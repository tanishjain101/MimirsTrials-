import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../utils/colors.dart';

class CourseNode extends StatelessWidget {
  final LessonNode node;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback onTap;

  const CourseNode({
    super.key,
    required this.node,
    required this.isCompleted,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color nodeColor;

    if (isLocked) {
      nodeColor = AppColors.nodeLocked;
    } else if (isCompleted) {
      nodeColor = AppColors.nodeCompleted;
    } else if (node.isCurrent) {
      nodeColor = AppColors.nodeCurrent;
    } else {
      nodeColor = AppColors.secondary;
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 350),
            scale: node.isCurrent ? 1.08 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: nodeColor,
                  width: node.isCurrent ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: nodeColor.withValues(alpha: isLocked ? 0.2 : 0.6),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _getTypeIcon(node.type),
                    color: nodeColor,
                    size: 28,
                  ),
                  if (isCompleted)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 18,
                      ),
                    ),
                  if (isLocked)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.lock,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 90,
            child: Text(
              node.title,
              style: TextStyle(
                color: isLocked ? AppColors.textMuted : AppColors.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.lesson:
        return Icons.menu_book;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.story:
        return Icons.auto_stories;
      case LessonType.practice:
        return Icons.edit;
    }
  }
}

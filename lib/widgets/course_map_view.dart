import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../utils/colors.dart';
import 'course_node.dart';

class CourseMapView extends StatelessWidget {
  final Course course;
  final List<String> completedLessons;
  final double height;
  final double nodeSize;
  final ValueChanged<LessonNode> onNodeTap;

  const CourseMapView({
    super.key,
    required this.course,
    required this.completedLessons,
    required this.onNodeTap,
    this.height = 620,
    this.nodeSize = 84,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - nodeSize;
          final availableHeight = height - nodeSize;
          return Stack(
            children: [
              CustomPaint(
                painter: CoursePathPainter(
                  nodes: course.nodes,
                  width: constraints.maxWidth,
                  nodeSize: nodeSize,
                ),
                size: Size(constraints.maxWidth, height),
              ),
              ...course.nodes.map((node) {
                final isCompleted = completedLessons.contains(node.id);
                final isLocked = node.prerequisites.isNotEmpty &&
                    !node.prerequisites.every(completedLessons.contains);
                final nodeX = node.position.x * availableWidth;
                final nodeY = node.position.y * availableHeight;
                final clampedX = nodeX.clamp(0.0, availableWidth);
                final clampedY = nodeY.clamp(0.0, availableHeight);

                return Positioned(
                  left: clampedX,
                  top: clampedY,
                  child: CourseNode(
                    node: node,
                    isCompleted: isCompleted,
                    isLocked: isLocked,
                    onTap: () => onNodeTap(node),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class CoursePathPainter extends CustomPainter {
  final List<LessonNode> nodes;
  final double width;
  final double nodeSize;

  CoursePathPainter({
    required this.nodes,
    required this.width,
    required this.nodeSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;

    final pathPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.pathLocked,
          AppColors.pathCurrent,
          AppColors.pathCompleted,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < nodes.length - 1; i++) {
      final start = Offset(
        nodes[i].position.x * (width - nodeSize) + nodeSize / 2,
        nodes[i].position.y * (size.height - nodeSize) + nodeSize / 2,
      );
      final end = Offset(
        nodes[i + 1].position.x * (width - nodeSize) + nodeSize / 2,
        nodes[i + 1].position.y * (size.height - nodeSize) + nodeSize / 2,
      );

      final controlPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2 - 56,
      );

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          end.dx,
          end.dy,
        );
      canvas.drawPath(path, pathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

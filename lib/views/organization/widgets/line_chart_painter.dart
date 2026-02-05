import 'dart:math';
import 'package:flutter/material.dart';

class LineChartPainter extends CustomPainter {
  final List<dynamic> chartData;
  LineChartPainter(this.chartData);

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.isEmpty) return;

    final List<double> scanPoints = chartData.map((e) => ((e['scans'] ?? e['hits'] ?? 0) as num).toDouble()).toList().cast<double>();
    final List<double> viewPoints = chartData.map((e) => ((e['views'] ?? 0) as num).toDouble()).toList().cast<double>();
    final List<double> savePoints = chartData.map((e) => ((e['saves'] ?? 0) as num).toDouble()).toList().cast<double>();
    final List<double> sharePoints = chartData.map((e) => ((e['shares'] ?? 0) as num).toDouble()).toList().cast<double>();

    if (scanPoints.isEmpty) return;

    final maxVal = [...scanPoints, ...viewPoints, ...savePoints, ...sharePoints].reduce(max);
    final normalization = maxVal == 0 ? 1.0 : maxVal;

    final numPoints = scanPoints.length;
    final dx = numPoints > 1 ? size.width / (numPoints - 1) : 0.0;

    _drawMetric(canvas, size, scanPoints, normalization, dx, Colors.orange, "Scans");
    _drawMetric(canvas, size, viewPoints, normalization, dx, Colors.purpleAccent, "Views");
    _drawMetric(canvas, size, savePoints, normalization, dx, const Color(0xFF00C950), "Saves");
    _drawMetric(canvas, size, sharePoints, normalization, dx, Colors.blueAccent, "Shares");

    // Draw bottom labels
    final textStyle = const TextStyle(color: Colors.white38, fontSize: 8);
    for (int i = 0; i < chartData.length; i += max(1, chartData.length ~/ 5)) {
      final dateStr = (chartData[i]['_id'] ?? chartData[i]['date'])?.toString().split('-').last ?? '';
      final textSpan = TextSpan(text: dateStr, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      final xPos = numPoints > 1 ? dx * i : size.width / 2;
      textPainter.paint(canvas, Offset(xPos - textPainter.width/2, size.height + 10));
    }
  }

  void _drawMetric(Canvas canvas, Size size, List<double> points, double normalization, double dx, Color color, String label) {
    if (points.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final startY = size.height * (1 - points[0] / normalization);
    path.moveTo(0, startY);

    if (points.length > 1) {
      for (int i = 1; i < points.length; i++) {
        path.lineTo(dx * i, size.height * (1 - points[i] / normalization));
      }
    } else {
      // Single point case
      canvas.drawCircle(Offset(size.width / 2, startY), 4, paint..style = PaintingStyle.fill);
      return;
    }

    final fillPath = Path.from(path)
      ..lineTo(dx * (points.length - 1), size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

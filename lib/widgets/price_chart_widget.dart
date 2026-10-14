import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class PriceChartWidget extends StatefulWidget {
  final List<double> prices;
  final bool isPositive;

  const PriceChartWidget({
    super.key,
    required this.prices,
    required this.isPositive,
  });

  @override
  State<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  String _selectedTimeframe = '7D';
  final List<String> _timeframes = ['1H', '24H', '7D', '1M', '1Y', 'ALL'];
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final chartColor = widget.isPositive ? ColorResource.success : ColorResource.danger;
    
    // Generate simulated points if list is short
    List<double> dataPoints = List.from(widget.prices);
    if (dataPoints.length < 5) {
      dataPoints = [100, 105, 103, 110, 108, 115, 120];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorResource.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: ColorResource.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeframe Selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _timeframes.map((tf) {
              final isSelected = _selectedTimeframe == tf;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeframe = tf;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorResource.appThemeColor1 : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    tf,
                    style: AppStyles.medium.copyWith(
                      fontSize: 12,
                      color: isSelected ? Colors.white : ColorResource.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Chart Painter
          SizedBox(
            height: 200,
            width: double.infinity,
            child: GestureDetector(
              onPanUpdate: (details) {
                // Handle touch scrubbing if desired
              },
              child: CustomPaint(
                painter: LineChartPainter(
                  prices: dataPoints,
                  lineColor: chartColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low: \$${dataPoints.reduce(math.min).toStringAsFixed(2)}',
                style: AppStyles.regular.copyWith(fontSize: 12, color: ColorResource.textSecondary),
              ),
              Text(
                'High: \$${dataPoints.reduce(math.max).toStringAsFixed(2)}',
                style: AppStyles.regular.copyWith(fontSize: 12, color: ColorResource.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> prices;
  final Color lineColor;

  LineChartPainter({required this.prices, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.25), lineColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    final priceRange = maxPrice == minPrice ? 1.0 : (maxPrice - minPrice);

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (prices.length - 1 > 0 ? prices.length - 1 : 1);

    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final normalizedY = (prices[i] - minPrice) / priceRange;
      final y = size.height - (normalizedY * (size.height - 20) + 10);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BarChartWrapper extends StatelessWidget {
  final Map<String, double> dailyIncome;

  const BarChartWrapper({super.key, required this.dailyIncome});

  @override
  Widget build(BuildContext context) {
    if (dailyIncome.isEmpty) {
      return const Center(child: Text('Belum ada data grafik.'));
    }

    final sortedKeys = dailyIncome.keys.toList()..sort();
    final barData = List.generate(sortedKeys.length, (index) {
      final key = sortedKeys[index];
      final value = dailyIncome[key] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.brown,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final dateLabels = sortedKeys.map((k) => k.substring(0, 5)).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (dailyIncome.values.reduce(max) * 1.2).clamp(10000, 999999),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                return Text(
                  i < dateLabels.length ? dateLabels[i] : '',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) =>
                  Text('Rp${value.toInt()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barData,
      ),
    );
  }
}

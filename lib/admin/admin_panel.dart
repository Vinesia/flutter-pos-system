import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  double totalIncome = 0;
  double totalMinuman = 0;
  double totalMakanan = 0;
  double totalLainnya = 0;

  List<Map<String, dynamic>> todayOrders = [];
  Map<String, double> dailyIncome = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  String getTodayKey() {
    final now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(now.day)}-${twoDigits(now.month)}-${now.year}';
  }

  Future<void> _fetchData() async {
    final todayKey = getTodayKey();

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(todayKey)
        .collection('daily_orders')
        .get();

    double income = 0;
    double minuman = 0;
    double makanan = 0;
    double lainnya = 0;

    List<Map<String, dynamic>> orders = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'paid') {
        final total = (data['total'] ?? 0);
        final double amount = total is int ? total.toDouble() : total;
        final String kategori = (data['category'] ?? '').toLowerCase();

        income += amount;
        orders.add(data);

        if (kategori == 'minuman') {
          minuman += amount;
        } else if (kategori == 'makanan') {
          makanan += amount;
        } else {
          lainnya += amount;
        }
      }
    }

    final ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
    Map<String, double> tempIncome = {};

    for (var doc in ordersSnapshot.docs) {
      final dateKey = doc.id;
      final dailySnapshot = await doc.reference.collection('daily_orders').get();
      double sum = 0;

      for (var orderDoc in dailySnapshot.docs) {
        final data = orderDoc.data();
        if (data['status'] == 'paid') {
          final total = (data['total'] ?? 0);
          final double amount = total is int ? total.toDouble() : total;
          sum += amount;
        }
      }

      tempIncome[dateKey] = sum;
    }

    setState(() {
      totalIncome = income;
      totalMinuman = minuman;
      totalMakanan = makanan;
      totalLainnya = lainnya;
      todayOrders = orders;
      dailyIncome = tempIncome;
    });
  }

  List<BarChartGroupData> _buildBarChartData() {
    final sortedKeys = dailyIncome.keys.toList()..sort();

    return List.generate(sortedKeys.length, (index) {
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
  }

  List<String> _buildDateLabels() {
    final keys = dailyIncome.keys.toList()..sort();
    return keys.map((k) => k.substring(0, 5)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIncomeCard(),
              const SizedBox(height: 24),
              const Text(
                'Grafik Pendapatan Harian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 220, child: _BarChartWrapper()),
              const SizedBox(height: 24),
              const Text(
                'Pesanan Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              todayOrders.isEmpty
                  ? const Text('Belum ada pesanan hari ini.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayOrders.length,
                      itemBuilder: (context, index) {
                        final order = todayOrders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            tileColor: Colors.brown[50],
                            leading: const Icon(Icons.coffee),
                            title: Text(order['name'] ?? 'Tanpa Nama'),
                            subtitle: Text(
                                'Total: Rp ${order['total'] ?? 0} - Kategori: ${order['category'] ?? '-'}'),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeCard() {
    final List<_StatItem> stats = [
      _StatItem('Total Income', totalIncome, Icons.attach_money, Colors.green),
      _StatItem('Minuman', totalMinuman, Icons.local_cafe, Colors.brown),
      _StatItem('Makanan', totalMakanan, Icons.fastfood, Colors.orange),
      _StatItem('Lainnya', totalLainnya, Icons.category, Colors.grey),
    ];

    return GridView.builder(
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatTile(stat.title, stat.amount, stat.icon, stat.color);
      },
    );
  }

  Widget _buildStatTile(String title, double amount, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Rp ${amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  _StatItem(this.title, this.amount, this.icon, this.color);
}

class _BarChartWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_AdminPanelState>();
    if (state == null || state.dailyIncome.isEmpty) {
      return const Center(child: Text('Belum ada data grafik.'));
    }

    final barData = state._buildBarChartData();
    final dateLabels = state._buildDateLabels();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (state.dailyIncome.values.reduce(max) * 1.2).clamp(10000, 999999),
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
              getTitlesWidget: (value, _) => Text('Rp${value.toInt()}'),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barData,
      ),
    );
  }
}

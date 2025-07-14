import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/stat_tile.dart';
import '../widgets/bar_chart_wrapper.dart';
import '../widgets/order_card.dart';

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
    return DateFormat('dd-MM-yyyy').format(now);
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
      if ((data['status'] ?? '') == 'paid') {
        final double amount = _toDouble(data['total']);
        final String kategori = (data['category'] ?? '').toString().toLowerCase();

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
        if ((data['status'] ?? '') == 'paid') {
          final double amount = _toDouble(data['total']);
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

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatItem('Total Income', totalIncome, Icons.attach_money, Colors.green),
      StatItem('Minuman', totalMinuman, Icons.local_cafe, Colors.brown),
      StatItem('Makanan', totalMakanan, Icons.fastfood, Colors.orange),
      StatItem('Lainnya', totalLainnya, Icons.category, Colors.grey),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.brown[400],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  return StatTile(stat: stat);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Grafik Pendapatan Harian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 220, child: BarChartWrapper(dailyIncome: dailyIncome)),
              const SizedBox(height: 24),
              const Text('Pesanan Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              todayOrders.isEmpty
                  ? const Text('Belum ada pesanan hari ini.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayOrders.length,
                      itemBuilder: (context, index) {
                        return OrderCard(order: todayOrders[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'receipt_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class OrderFormPage extends StatefulWidget {
  final Map<MenuItem, int> selectedItems;

  const OrderFormPage({super.key, required this.selectedItems});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _nameController = TextEditingController();
  String _selectedMilk = 'Full Cream';
  String _selectedSugar = 'Normal';
  String _selectedIce = 'Normal';
  bool _isSubmitting = false;

  final List<String> milkOptions = ['Full Cream', 'Oatside', 'Almond', 'Tidak Ada'];
  final List<String> sugarOptions = ['Normal', 'Less Sugar', 'No Sugar'];
  final List<String> iceOptions = ['Normal', 'Less Ice', 'No Ice', 'Hot'];

  Future<void> _submitOrder() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama wajib diisi')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final uuid = const Uuid().v4();
    final now = DateTime.now();
    final dateKey = DateFormat('dd-MM-yyyy').format(now);
    final orderId = 'order_$uuid';

    final total = widget.selectedItems.entries
        .map((e) => e.key.price * e.value)
        .fold(0, (a, b) => a + b);

    Map<String, double> categoryTotals = {};
    for (var entry in widget.selectedItems.entries) {
      final category = entry.key.category.toLowerCase().trim();
      final subtotal = entry.key.price * entry.value;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + subtotal;
    }

    String dominantCategory = 'lainnya';
    double maxTotal = 0;
    categoryTotals.forEach((cat, catTotal) {
      if (catTotal > maxTotal) {
        maxTotal = catTotal;
        dominantCategory = cat;
      }
    });

    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(dateKey)
        .collection('daily_orders')
        .doc(orderId);

    bool hasDrink = widget.selectedItems.keys.any(
      (item) => item.category.toLowerCase().contains('minuman'),
    );

    await orderRef.set({
      'name': _nameController.text.trim(),
      'milk': hasDrink ? _selectedMilk : null,
      'sugar': hasDrink ? _selectedSugar : null,
      'ice': hasDrink ? _selectedIce : null,
      'items': widget.selectedItems.map((item, qty) => MapEntry(item.name, qty)),
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      'total': total,
      'category': dominantCategory,
    });

    setState(() {
      _isSubmitting = false;
    });

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPage(
            orderId: orderId,
            dateKey: dateKey,
            customerName: _nameController.text.trim(),
            items: widget.selectedItems.map((item, qty) => MapEntry(item.name, qty)),
            total: total,
            milk: hasDrink ? _selectedMilk : null,
            sugar: hasDrink ? _selectedSugar : null,
            ice: hasDrink ? _selectedIce : null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.selectedItems.entries
        .map((e) => e.key.price * e.value)
        .fold(0, (a, b) => a + b);

    bool hasDrink = widget.selectedItems.keys.any(
      (item) => item.category.toLowerCase().contains('minuman'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.brown[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pesanan Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.selectedItems.entries.map((entry) {
              return ListTile(
                leading: Image.asset(entry.key.imageUrl, width: 40),
                title: Text(entry.key.name),
                subtitle: Text('x${entry.value}'),
                trailing: Text('Rp${entry.key.price * entry.value}'),
              );
            }).toList(),
            const Divider(height: 32),
            const Text('Nama Pelanggan', style: TextStyle(fontWeight: FontWeight.w600)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Masukkan nama Anda'),
            ),
            const SizedBox(height: 16),

            if (hasDrink) ...[
              const Text('Pilih Susu', style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 10,
                children: milkOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: _selectedMilk == option,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMilk = option;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Pilih Gula', style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 10,
                children: sugarOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: _selectedSugar == option,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSugar = option;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Pilih Es', style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 10,
                children: iceOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: _selectedIce == option,
                    onSelected: (selected) {
                      setState(() {
                        _selectedIce = option;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            const Divider(height: 32),
            Text('Total: Rp$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitOrder,
                icon: const Icon(Icons.check),
                label: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Konfirmasi Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'confirmation_page.dart';
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
  List<String> _extras = [];
  bool _isSubmitting = false;

  final List<String> milkOptions = ['Full Cream', 'Almond', 'Soy'];
  final List<String> extrasOptions = ['Extra Shot', 'Less Sugar', 'Ice'];

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

    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(dateKey)
        .collection('daily_orders')
        .doc(orderId);

    await orderRef.set({
      'name': _nameController.text.trim(),
      'milk': _selectedMilk,
      'extras': _extras,
      'items': widget.selectedItems.map((item, qty) => MapEntry(item.name, qty)),
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isSubmitting = false;
    });

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationPage(
            orderId: orderId,
            dateKey: dateKey,
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
            const Text('Pilih Susu', style: TextStyle(fontWeight: FontWeight.w600)),
            DropdownButton<String>(
              value: _selectedMilk,
              items: milkOptions.map((milk) {
                return DropdownMenuItem(value: milk, child: Text(milk));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMilk = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Tambahan', style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 10,
              children: extrasOptions.map((extra) {
                final isSelected = _extras.contains(extra);
                return FilterChip(
                  label: Text(extra),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _extras.add(extra);
                      } else {
                        _extras.remove(extra);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
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

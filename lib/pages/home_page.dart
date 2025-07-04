import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../data/dummy_menu.dart';
import 'order_form_page.dart';
import '../admin/admin_panel.dart'; // pastikan file ini ada di folder lib/admin

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<MenuItem, int> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _resetSelections();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetSelections(); // reset saat kembali ke halaman ini
  }

  void _resetSelections() {
    _selectedItems.clear();
    setState(() {}); // update tampilan
  }

  void _updateQuantity(MenuItem item, int change) {
    setState(() {
      _selectedItems[item] = (_selectedItems[item] ?? 0) + change;
      if (_selectedItems[item]! <= 0) {
        _selectedItems.remove(item);
      }
    });
  }

  void _goToOrderForm() {
    if (_selectedItems.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderFormPage(selectedItems: Map.from(_selectedItems)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu item.')),
      );
    }
  }

  void _goToAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminPanel()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('roaStory'),
        backgroundColor: Colors.brown[400],
        actions: [
          IconButton(
            onPressed: _goToAdminPanel,
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Panel',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: menuItems.map((item) {
                final qty = _selectedItems[item] ?? 0;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(item.imageUrl, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Rp${item.price}'),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => _updateQuantity(item, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('$qty'),
                            IconButton(
                              onPressed: () => _updateQuantity(item, 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _goToOrderForm,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Order Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          )
        ],
      ),
    );
  }
}

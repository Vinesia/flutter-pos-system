import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../data/dummy_menu.dart';
import 'order_form_page.dart';
import '../admin/admin_panel.dart';

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

  void _resetSelections() {
    _selectedItems.clear();
    setState(() {});
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
          builder: (_) => OrderFormPage(
            selectedItems: Map.from(_selectedItems),
          ),
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
    final categories = menuItems.map((item) => item.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        title: Row(
          children: [
            Image.asset('assets/logo-roastory.png', height: 56, width: 56),
            const SizedBox(width: 12),
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text(
                'roaStory',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _goToAdminPanel,
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Panel',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          const SizedBox(height: 16),
          ...categories.map((category) {
            final itemsInCategory = menuItems
                .where((item) => item.category == category)
                .toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsInCategory.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final item = itemsInCategory[index];
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
                                child: Image.asset(
                                  item.imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Rp${item.price}'),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _updateQuantity(item, -1),
                                    icon: const Icon(
                                        Icons.remove_circle_outline),
                                  ),
                                  Text('$qty'),
                                  IconButton(
                                    onPressed: () =>
                                        _updateQuantity(item, 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
      bottomNavigationBar: Padding(
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptPage extends StatelessWidget {
  final String orderId;
  final String dateKey;
  final String customerName;
  final Map<String, int> items;
  final int total;
  final String? milk;
  final String? sugar;
  final String? ice;

  const ReceiptPage({
    super.key,
    required this.orderId,
    required this.dateKey,
    required this.customerName,
    required this.items,
    required this.total,
    this.milk,
    this.sugar,
    this.ice,
  });

  Future<void> _printReceipt(BuildContext context) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Struk Pesanan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Order ID: $orderId'),
              pw.Text('Tanggal: $dateKey'),
              pw.Text('Nama: $customerName'),
              pw.SizedBox(height: 10),
              pw.Text('Detail Pesanan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...items.entries.map((e) => pw.Text('${e.key} x${e.value}')),
              if (milk != null) pw.Text('Susu: $milk'),
              if (sugar != null) pw.Text('Gula: $sugar'),
              if (ice != null) pw.Text('Es: $ice'),
              pw.SizedBox(height: 10),
              pw.Text('Total: Rp$total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pesanan'),
        backgroundColor: Colors.brown[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Struk Pesanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Order ID: $orderId'),
            Text('Tanggal: $dateKey'),
            Text('Nama: $customerName'),
            const Divider(height: 32),
            const Text('Pesanan:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.entries.map((e) => Text('${e.key} x${e.value}')),
            if (milk != null) Text('Susu: $milk'),
            if (sugar != null) Text('Gula: $sugar'),
            if (ice != null) Text('Es: $ice'),
            const Divider(height: 32),
            Text('Total: Rp$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('Cetak Struk'),
                onPressed: () => _printReceipt(context),
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

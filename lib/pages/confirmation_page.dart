import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

import 'home_page.dart';

class ConfirmationPage extends StatefulWidget {
  final String orderId;
  final String dateKey;

  const ConfirmationPage({
    super.key,
    required this.orderId,
    required this.dateKey,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> with SingleTickerProviderStateMixin {
  bool isPaid = false;
  late AnimationController _controller;
  late StreamSubscription<DocumentSnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listenToPayment(); // optional if using realtime listener
  }

  void _listenToPayment() {
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.dateKey)
        .collection('daily_orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((doc) async {
      if (doc.exists && doc.data()?['status'] == 'paid' && !isPaid) {
        await _handlePaidFlow();
      }
    });
  }

  Future<void> _handlePaidFlow() async {
    setState(() {
      isPaid = true;
    });

    await _controller.forward(); // play animation
    await Future.delayed(const Duration(seconds: 5));

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }

    // reset if needed after going home
    setState(() {
      isPaid = false;
    });
  }

  Future<void> _simulatePayment() async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.dateKey)
        .collection('daily_orders')
        .doc(widget.orderId)
        .update({'status': 'paid'});

    await _handlePaidFlow(); // langsung jalankan alur setelah simulasi
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pembayaran'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isPaid
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _controller,
                        curve: Curves.elasticOut,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 120),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pembayaran Diterima!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: widget.orderId,
                      size: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text('Silakan scan QR untuk membayar'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _simulatePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simulasikan Pembayaran'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

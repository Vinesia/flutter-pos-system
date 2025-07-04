import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RoaStoryApp());
}

class RoaStoryApp extends StatelessWidget {
  const RoaStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'roaStory',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

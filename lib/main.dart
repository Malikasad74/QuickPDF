import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  // Change `super.key` to `Key? key`

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickPDF',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const HomePage(),  // Adding const if possible for optimization
    );
  }
}

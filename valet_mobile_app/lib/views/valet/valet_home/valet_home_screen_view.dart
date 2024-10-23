import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: const Text('Valet App', style: TextStyle(color: Color(0xFFFDFDFD), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[900],
      ),
      body: const Center(child: Text('')),
    );
  }
}

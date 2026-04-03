// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'responsive_kalkan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("SİVİL TERMİNAL", style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.w900, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              onPressed: () => FirebaseAuth.instance.signOut(),
            )
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF00FFC2), size: 100),
              SizedBox(height: 24),
              Text("SİSTEME HOŞ GELDİNİZ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
              SizedBox(height: 12),
              Text("Durum: Kuantum Ağı Güvende ✅", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
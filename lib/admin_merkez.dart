// lib/admin_merkez.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 🚨 İŞTE TEK EKSİK OLAN DOĞRU ROTA BURASI:
import 'package:otodna/core/responsive_kalkan.dart';

class AdminMerkezScreen extends StatelessWidget {
  const AdminMerkezScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("SİBER KARARGAH (ADMİN)", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () => FirebaseAuth.instance.signOut(),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.redAccent, size: 100),
              const SizedBox(height: 24),
              const Text("BÜTÜN YETKİLER SİZDE KOMUTANIM", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("AĞDAN ÇIKIŞ YAP"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
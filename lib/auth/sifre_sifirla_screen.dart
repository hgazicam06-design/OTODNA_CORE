import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SifreSifirlaScreen extends StatelessWidget {
  const SifreSifirlaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF0C1014),
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("ŞİFRE KURTARMA")),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            const Text("Yetkili e-posta adresinizi girin, sıfırlama protokolünü başlatalım.", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            TextField(controller: emailCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "E-Posta", hintStyle: TextStyle(color: Colors.white24))),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: emailCtrl.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("BAĞLANTIYI GÖNDER"),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM QR VE KRİPTOGRAFİ MOTORU
class QREngineService {
  // ── 🔐 1. SİBER ŞİFRELEME (STRING OLUŞTURUCU) ──
  static String generateVehicleDNAString({required String plateNumber, required String dealerId}) {
    try {
      String siberPlate = plateNumber.trim().toUpperCase().replaceAll(' ', '');
      String siberDealer = dealerId.trim().toUpperCase();

      if (siberPlate.isEmpty || siberDealer.isEmpty) {
        throw Exception("SİBER İHLAL: Eksik DNA veya Bayi İstihbaratı!");
      }

      // Kuantum Şifreleme Formatı: Web URL tabanlı
      // 🚀 Vatandaşlar normal kamera ile okuttuğunda web sitesi açılacak
      String qrSinyali = 'https://www.otodna.com/qr/$siberPlate?dealer=$siberDealer&ts=${DateTime.now().millisecondsSinceEpoch}';
      developer.log("SİBER KRİPTOGRAFİ: Kuantum QR Mührü Şifrelendi -> $qrSinyali");

      return qrSinyali;
    } catch (e) {
      developer.log("KRİPTOGRAFİ ÇÖKTÜ: Şifreleme başarısız!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: Sahte string dönmek yerine Kırmızı Alarm fırlatılır!
      throw Exception("SİBER HATA: QR Kodu oluşturulamadı. Lütfen araç ve bayi verilerini kontrol edin!");
    }
  }

  // ── 📲 2. SİBER QR EKRAN ÇİZİCİ ──
  static Widget buildSiberQRCode(String dnaData, {double size = 200.0}) {
    // Eğer dışarıdan gelen bir hatayla boş data gelirse arayüzü çökertmek yerine İhlal Ekranı basar
    if (dnaData.isEmpty) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(16)),
        child: const Center(
            child: Text("SİBER İHLAL\nEKSİK VERİ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FFC2), width: 3), // Kuantum Turkuazı
        boxShadow: [
          BoxShadow(color: const Color(0xFF00FFC2).withValues(alpha: 0.5), blurRadius: 25, spreadRadius: 3)
        ],
      ),
      child: QrImageView(
        data: dnaData,
        version: QrVersions.auto,
        size: size,
        errorCorrectionLevel: QrErrorCorrectLevel.H, // Siber Hasar Kalkanı %30
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
      ),
    );
  }
}

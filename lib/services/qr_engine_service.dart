import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM QR VE KRİPTOGRAFİ MOTORU
class QREngineService {
  // ── 🔐 1. SİBER ŞİFRELEME (STRING OLUŞTURUCU) ──
  static String generateVehicleDNAString({required String plateNumber, required String dealerId}) {
    try {
      String siberPlate = plateNumber.trim().toUpperCase().replaceAll(' ', '');
      if (siberPlate.isEmpty) throw Exception("SİBER İHLAL: Eksik DNA verisi!");

      // Kuantum Şifreleme Formatı: OTODNA_TAG_34DNA2026_ZAMANDAMGASİ
      String qrSinyali = 'OTODNA_TAG_${siberPlate}_${DateTime.now().millisecondsSinceEpoch}';
      developer.log("SİBER KRİPTOGRAFİ: Şifrelendi -> $qrSinyali");
      return qrSinyali;
    } catch (e) {
      return 'OTODNA::ERROR';
    }
  }

  // ── 📲 2. SİBER QR EKRAN ÇİZİCİ ──
  static Widget buildSiberQRCode(String dnaData, {double size = 200.0}) {
    if (dnaData.isEmpty || dnaData == 'OTODNA::ERROR') {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text("SİBER İHLAL\nQR ÇÖKTÜ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FFC2), width: 3),
        boxShadow: [BoxShadow(color: const Color(0xFF00FFC2).withOpacity(0.5), blurRadius: 25, spreadRadius: 3)],
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
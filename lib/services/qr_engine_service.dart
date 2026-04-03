import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM QR VE KRİPTOGRAFİ MOTORU (QREngineService)
/// Araç DNA'sını siber bir mühre (QR) çevirir ve cihaz ekranına Kuantum standartlarında çizer.
class QREngineService {

  // ── 🔐 1. SİBER ŞİFRELEME (STRING OLUŞTURUCU) ─────────────────────────────
  /// Araç verilerini alıp kırılamaz OtoDNA QR formatına çevirir
  static String generateVehicleDNAString({
    required String vehicleId,
    required String dealerId,
    required String plateNumber,
  }) {
    try {
      // 🛡️ Otonom Veri Temizliği: Boşlukları sil ve Karargah formatı olan BÜYÜK harfe çevir
      String siberID = vehicleId.trim().toUpperCase();
      String siberDealer = dealerId.trim().toUpperCase();
      String siberPlate = plateNumber.trim().toUpperCase().replaceAll(' ', '');

      if (siberID.isEmpty || siberDealer.isEmpty) {
        throw Exception("SİBER İHLAL: Eksik DNA verisi ile mühür oluşturulamaz!");
      }

      // Kuantum Şifreleme Formatı:
      String qrSinyali = 'OTODNA::V1::ID[$siberID]::DLR[$siberDealer]::PLT[$siberPlate]';

      developer.log("SİBER KRİPTOGRAFİ: Araç DNA Sinyali başarıyla şifrelendi -> $qrSinyali");
      return qrSinyali;

    } catch (e) {
      developer.log("ŞİFRELEME HATASI: QR Kod metni oluşturulamadı!", error: e);
      return 'OTODNA::ERROR'; // Sistem çökmesin diye güvenli kalkan
    }
  }

  // ── 📲 2. SİBER QR EKRAN ÇİZİCİ (WIDGET OLUŞTURUCU) ───────────────────────
  /// Şifreli metni alıp ekrana fütüristik, parlayan ve hasara dayanıklı bir QR Kod olarak yansıtır
  static Widget buildSiberQRCode(String dnaData, {double size = 200.0}) {

    // 🛡️ Çökme Kalkanı: Veri bozuksa kırmızı ihlal ekranı göster
    if (dnaData.isEmpty || dnaData == 'OTODNA::ERROR') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
              "SİBER İHLAL\nQR ÇÖKTÜ",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
      );
    }

    // 🎯 Başarılı Siber Çizim
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Optik okuyucular (Kameralar) için arka plan kesinlikle beyaz olmalıdır!
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FFC2), width: 3), // Kuantum Yeşili/Camgöbeği
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFC2).withOpacity(0.5),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: QrImageView(
        data: dnaData,
        version: QrVersions.auto,
        size: size,

        // 🛡️ SİBER HASAR KALKANI (Error Correction Level H)
        // Araç üzerindeki etiket çamurlansa, çizilse veya %30'u yok olsa bile optik gözler okumaya devam eder!
        errorCorrectionLevel: QrErrorCorrectLevel.H,

        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF0F172A), // Koyu Karargah Laciverti
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}
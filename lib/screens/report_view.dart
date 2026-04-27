import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart'; // 🚀 SİBER UYARI: pubspec.yaml'da qr_flutter ekli olmalı!



class SiberQrOnayAlani extends StatelessWidget {

  final String raporId;



  const SiberQrOnayAlani({super.key, required this.raporId});



// 🌑 TESLA MİMARİSİ: OLED SİYAH PALET

  static const Color surfaceColor = Color(0xFF111111);

  static const Color primaryCyan = Color(0xFF00FFC2);



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(32),

      decoration: BoxDecoration(

        color: surfaceColor,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),

        boxShadow: [

          BoxShadow(

            color: primaryCyan.withOpacity(0.1),

            blurRadius: 30,

            spreadRadius: 5,

          )

        ],

      ),

      child: Column(

        mainAxisSize: MainAxisSize.min, // Ekranı gereksiz kaplamasını engeller

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

// 🚀 GERÇEK KUANTUM KAREKOD (Dinamik Üretici)

          Container(

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(

                color: Colors.white, // SİBER NOT: Kameralar okuyabilsin diye arka plan SAF BEYAZ olmalıdır!

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: primaryCyan, width: 3),

                boxShadow: [

                  BoxShadow(color: primaryCyan.withOpacity(0.4), blurRadius: 15)

                ]

            ),

            child: QrImageView(

              data: raporId, // Dışarıdan gelen gerçek Firebase Rapor ID'si

              version: QrVersions.auto,

              size: 160.0,

              backgroundColor: Colors.white,

              foregroundColor: Colors.white, // Siyah QR pikselleri

            ),

          ),

          const SizedBox(height: 32),



// 🛡️ BİLGİLENDİRME PANELİ

          const Text(

            "SİBER MÜHÜR DOĞRULAMA",

            textAlign: TextAlign.center,

            style: TextStyle(

              color: primaryCyan,

              fontSize: 13,

              fontWeight: FontWeight.w900,

              letterSpacing: 2,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            "RAPOR ID: ${raporId.toUpperCase()}",

            textAlign: TextAlign.center,

            style: const TextStyle(

              color: SiberTema.textMuted,

              fontSize: 11,

              fontWeight: FontWeight.bold,

              letterSpacing: 1.5,

            ),

          ),

          const SizedBox(height: 24),



// 🔒 GÜVENLİK ROZETİ

          Row(

            mainAxisSize: MainAxisSize.min,

            children: [

              Icon(Icons.verified_user, color: primaryCyan.withOpacity(0.8), size: 16),

              const SizedBox(width: 8),

              Text(

                "OtoDNA Kripto Ağı Tarafından Onaylanmıştır",

                style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),

              ),

            ],

          )

        ],

      ),

    );

  }

}
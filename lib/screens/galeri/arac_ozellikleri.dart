import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/siber_rehber_dialog.dart';

/// 🦅 KUANTUM ARAÇ KÜNYESİ (OtoDNA Siber Sicil Kartı)
/// Aracın canlı verilerini, DNA skorunu ve trafikteki risk durumunu gösterir.
class KuantumAracKunyesi extends StatefulWidget {
  final String plakaID;

  const KuantumAracKunyesi({super.key, required this.plakaID});

  @override
  State<KuantumAracKunyesi> createState() => _KuantumAracKunyesiState();
}

class _KuantumAracKunyesiState extends State<KuantumAracKunyesi> {
  // 🎨 Siber Tasarım Standartları
  static const Color _primaryCyan = Color(0xFF00FFC2);
  static const Color _cyberBlack = Color(0xFF0A0A0B);
  static const Color _cardNavy = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    const String baslik = "KUANTUM ARAÇ KÜNYESİ";
    const String icerik = "OtoDNA Siber Sicil Kartına hoş geldiniz.\n\n"
        "Bu panel, baktığınız aracın tüm geçmişini, kilometresini ve en önemlisi DNA Skorunu gösterir. Eğer araçta usta tarafından atılmış bir 'KIRMIZI X' varsa, sistem bunu hemen tespit eder ve sizi uyarır.\n\n"
        "Tüm DNA geçmişini görmek veya bayi ile iletişime geçmek için panelin altındaki butonu kullanabilirsiniz.";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'arac_kunyesi_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'arac_kunyesi_rehber', baslik: baslik, icerik: icerik);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. FİREBASE'DEN ARACIN CANLI DNA'SINI ÇEK (Real-time Stream kullanılabilir, burada Future tercih edildi)
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('araclar').doc(widget.plakaID).get(),
      builder: (context, snapshot) {

        // 📡 AĞ BEKLENİYOR
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _primaryCyan));
        }

        // 🚨 ARAÇ BULUNAMADI (Siber Ağda Kaydı Yok)
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gavel_rounded, color: Colors.redAccent, size: 48),
                SizedBox(height: 16),
                Text("SİBER HATA: Araç Kuantum Ağında Bulunamadı!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        // 2. VERİLERİ PARÇALA VE ANALİZ ET
        var arac = snapshot.data!.data() as Map<String, dynamic>;

        String markaModel = "${arac['marka'] ?? 'Bilinmeyen'} ${arac['model'] ?? ''}";
        String yil = arac['yil']?.toString() ?? '-';
        String km = arac['km']?.toString() ?? '0';
        String fiyat = arac['fiyat']?.toString() ?? '0';
        int dnaSkoru = arac['dna_skoru'] ?? 0;
        bool kirmiziX = arac['kritik_hata_var_mi'] ?? false;
        String referansNotu = arac['muayene_durumu'] ?? 'Değerlendirme Bekliyor';

        // 3. KUANTUM GÖRSELLEŞTİRME (ARAYÜZ)
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cyberBlack,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BAŞLIK VE SKOR RADARI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(markaModel, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                  ),
                  _buildDNABadge(dnaSkoru),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.help_outline_rounded, color: _primaryCyan, size: 24),
                    onPressed: () => _rehberiGoster(otomatik: false),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // 📊 TEKNİK VERİ TABLOSU
              Container(
                decoration: BoxDecoration(
                  color: _cardNavy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetaySatiri("Üretim Yılı", yil, Icons.calendar_today),
                    const Divider(color: Colors.white10),
                    _buildDetaySatiri("Kilometre", "$km KM", Icons.speed),
                    const Divider(color: Colors.white10),
                    _buildDetaySatiri("Satış Fiyatı", "₺$fiyat", Icons.payments_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🛡️ OTODNA REFERANS MÜHRÜ (GÜVENLİK PROTOKOLÜ)
              _buildSecurityStatus(kirmiziX, referansNotu),

              const SizedBox(height: 20),

              // AKSİYON BUTONU (Siber Satın Alma / İletişim)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: İlan sahibi bayi ile iletişimi başlat
                  },
                  child: const Text("TÜM DNA GEÇMİŞİNİ GÖR", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // DNA Skor Rozeti
  Widget _buildDNABadge(int skor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryCyan.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryCyan),
      ),
      child: Text("DNA: $skor", style: const TextStyle(color: _primaryCyan, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  // Güvenlik Durumu (Kırmızı X Kontrolü)
  Widget _buildSecurityStatus(bool kirmiziX, String not) {
    final Color statusColor = kirmiziX ? Colors.redAccent : _primaryCyan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: statusColor.withOpacity(0.05),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: statusColor.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)
          ]
      ),
      child: Row(
        children: [
          Icon(
              kirmiziX ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
              color: statusColor,
              size: 40
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kirmiziX ? "KRİTİK GÜVENLİK RİSKİ!" : "OTODNA ONAYLI",
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  kirmiziX ? "Bu araçta Usta tarafından atılmış KIRMIZI X var! Trafiğe çıkış risklidir." : not,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Detay Satırı Widget'ı
  Widget _buildDetaySatiri(String baslik, String deger, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(ikon, color: _primaryCyan.withOpacity(0.7), size: 18),
          const SizedBox(width: 12),
          Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const Spacer(),
          Text(deger, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
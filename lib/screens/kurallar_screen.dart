import 'package:flutter/material.dart';

/// 🦅 OTODNA SİBER PROTOKOL MERKEZİ
/// [2026-03-28] GÜNCELLEME: Finansal %12 Kuralı ve Karaliste Yasakları İşlendi.
class KurallarScreen extends StatelessWidget {
  const KurallarScreen({super.key});

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SİBER SÖZLEŞME VE PROTOKOLLER",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 2,
            fontFamily: 'Avenir',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // 🖥️ Web / Geniş Ekran Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🛡️ SİBER LOGO VE BAŞLIK
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: surfaceColor,
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: primaryCyan.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 10
                          )
                        ],
                      ),
                      child: const Icon(Icons.gavel, color: primaryCyan, size: 64),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'OTODNA DİJİTAL REFERANS PROTOKOLÜ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontFamily: 'Avenir'
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kuantum Ağına bağlanan tüm Sürücüler ve Bayiler için bağlayıcıdır. Sistemi kullanan herkes bu mühürlü şartları kabul etmiş sayılır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        height: 1.6,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir'
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 🚀 BÖLÜM 1: SİSTEMİN ÇALIŞMA PRENSİBİ
                  _buildRuleCard(
                    icon: Icons.memory,
                    title: '1. SİSTEMİN İŞLEYİŞİ VE DNA SKORU',
                    color: primaryCyan,
                    content: 'OtoDNA, araç seceresini manipüle edilemez şekilde dijital zırha alır. Her araca atanan "DNA Skoru (0-100)", usta onaylı fotoğraflar ve videolarla desteklenen gerçek verilerle güncellenir.',
                  ),

                  // 💰 BÖLÜM 2: FİNANS VE TİCARİ KURALLAR
                  _buildRuleCard(
                    icon: Icons.account_balance,
                    title: '2. FİNANS VE %12 KOMİSYON ZIRHI',
                    color: Colors.amber,
                    content: '• Servis İşlemleri: Ustaların işçilik bedelinden komisyon alınmaz.\n'
                        '• Siber Pazar: Satılan her ürün ve parçadan %10 Karargah Payı + %2 Vergi olmak üzere toplam %12 komisyon kesilir.\n'
                        '• İlan Limitleri: Standart bayiler 10 ilanla sınırlıdır. VIP Bayiler (Murat Plaza vb.) sınırsız mühürleme hakkına sahiptir.',
                  ),

                  // 🚨 BÖLÜM 3: KESİN YASAKLAR VE KARALİSTE
                  _buildRuleCard(
                    icon: Icons.block,
                    title: '3. KARALİSTE (BLACKLIST) KRİTERLERİ',
                    color: dangerColor,
                    content: 'Aşağıdaki ihlallerde hesap anında süresiz olarak kapatılır:\n'
                        '1. Kilometre (Odometer) manipülasyonu veya sahte rapor.\n'
                        '2. SOS Mega Protokolünü asılsız yere meşgul etmek.\n'
                        '3. Bayilerin 30 dakikalık acil müdahale süresini mazeretsiz aşması.\n'
                        '4. Ağ dışından gizli ticaret teşebbüsü.',
                  ),

                  // ⚖️ BÖLÜM 4: HUKUKİ YÜKÜMLÜLÜK
                  _buildRuleCard(
                    icon: Icons.policy,
                    title: '4. ULUSAL ÇAPRAZ GARANTİ',
                    color: Colors.blueAccent,
                    content: 'Sisteme dahil olan her Bayi, OtoDNA üzerinden yapılan işlemlerde müşteriye "Ulusal Çapraz Garanti" vermek zorundadır. Yapılan her işlemin altında ustanın dijital imzası bulunur.',
                  ),

                  const SizedBox(height: 32),

                  // 🔘 ONAY BUTONU
                  SizedBox(
                    height: 64,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.verified_user, size: 24),
                      label: const Text(
                        'PROTOKOLÜ ANLADIM VE MÜHÜRLÜYORUM',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir'),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧠 YARDIMCI SİBER KART MOTORU
  Widget _buildRuleCard({required IconData icon, required String title, required Color color, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.5))
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir'),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12, thickness: 1),
          ),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.6, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
          ),
        ],
      ),
    );
  }
}
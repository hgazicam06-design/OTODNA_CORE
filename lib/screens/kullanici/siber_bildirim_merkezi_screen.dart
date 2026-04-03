import 'package:flutter/material.dart';

class SiberBildirimMerkeziScreen extends StatefulWidget {
  const SiberBildirimMerkeziScreen({super.key});

  @override
  State<SiberBildirimMerkeziScreen> createState() => _SiberBildirimMerkeziScreenState();
}

class _SiberBildirimMerkeziScreenState extends State<SiberBildirimMerkeziScreen> {
  // SİBER BİLDİRİM VERİTABANI (Simülasyon)
  final List<Map<String, dynamic>> _bildirimler = [
    {
      "id": "b1",
      "baslik": "TÜVTÜRK Muayene Yaklaşıyor!",
      "mesaj": "34 DNA 2026 plakalı aracınızın muayenesine 45 gün kaldı. Ceza yememek için Siber Asistan üzerinden hemen randevu alın.",
      "zaman": "10 dk önce",
      "okunduMu": false,
      "ikon": Icons.warning_amber_rounded,
      "renk": Colors.orangeAccent
    },
    {
      "id": "b2",
      "baslik": "Ekspertiz Randevusu Onaylandı",
      "mesaj": "Murat Plaza (Merkez Bayi) için yarın saat 10:30'a oluşturduğunuz randevu Kuantum Ağına işlendi.",
      "zaman": "1 saat önce",
      "okunduMu": false,
      "ikon": Icons.event_available_outlined,
      "renk": const Color(0xFF00FFC2)
    },
    {
      "id": "b3",
      "baslik": "DNA Skoru Güncellendi",
      "mesaj": "Aracınızın periyodik bakım verileri sisteme girildi. Güncel genetik sağlık skoru %92 olarak hesaplandı.",
      "zaman": "3 saat önce",
      "okunduMu": true,
      "ikon": Icons.science_outlined,
      "renk": Colors.purpleAccent
    },
    {
      "id": "b4",
      "baslik": "Market Radarı Uyarısı",
      "mesaj": "Takip ettiğiniz 'BMW M Performance Fren Disk Takımı' için yeni bir sıfır ilan eklendi.",
      "zaman": "Dün",
      "okunduMu": true,
      "ikon": Icons.shopping_bag_outlined,
      "renk": Colors.blueAccent
    },
    {
      "id": "b5",
      "baslik": "Siber Cüzdan Hareketi",
      "mesaj": "Trafik Mağdurları Derneği'ne yapılan %1'lik bağışınız başarıyla ulaştı. Teşekkür ederiz!",
      "zaman": "2 gün önce",
      "okunduMu": true,
      "ikon": Icons.volunteer_activism_outlined,
      "renk": Colors.greenAccent
    }
  ];

  // 💎 GERÇEKÇİ SİLME ANİMASYONU VE MANTIĞI
  void _bildirimiSil(String id) {
    setState(() {
      _bildirimler.removeWhere((element) => element['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sinyal ağdan kalıcı olarak silindi.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 1),
        )
    );
  }

  void _tumunuOkunduIsaretle() {
    setState(() {
      for (var bildirim in _bildirimler) {
        bildirim['okunduMu'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tüm Kuantum Sinyalleri Okundu Olarak İşaretlendi! 🦅", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Color(0xFF00FFC2)
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const bgColor = Color(0xFF000000); // Saf Siyah
    const surfaceColor = Color(0xFF111111); // Mat Gri
    const primaryCyan = Color(0xFF00FFC2);

    int okunmamisSayisi = _bildirimler.where((b) => b['okunduMu'] == false).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("S İ N Y A L   M E R K E Z İ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          if (okunmamisSayisi > 0)
            IconButton(
              icon: const Icon(Icons.done_all, color: primaryCyan),
              tooltip: "Tümünü Okundu İşaretle",
              onPressed: _tumunuOkunduIsaretle,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ÜST BİLGİ PANELİ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Siber Ağ Akışı", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                if (okunmamisSayisi > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: primaryCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryCyan.withOpacity(0.5))
                    ),
                    child: Text("$okunmamisSayisi Yeni Sinyal", style: const TextStyle(color: primaryCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  )
              ],
            ),
          ),

          // 2. BİLDİRİM LİSTESİ VEYA BOŞ DURUM
          Expanded(
            child: _bildirimler.isEmpty
                ? _buildEmptyState() // Eğer liste boşsa şık bir HUD ekranı çıkar
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _bildirimler.length,
              itemBuilder: (context, index) {
                var bildirim = _bildirimler[index];
                bool isUnread = !bildirim['okunduMu'];

                // 💎 SWIPE-TO-DELETE (Kaydırarak Silme Modülü)
                return Dismissible(
                  key: Key(bildirim['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _bildirimiSil(bildirim['id']),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.only(right: 24),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5))
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (isUnread) setState(() => bildirim['okunduMu'] = true);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isUnread ? primaryCyan.withOpacity(0.03) : surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isUnread ? primaryCyan.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
                        boxShadow: isUnread ? [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)] : [],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sol İkon Kutusu
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUnread ? bildirim['renk'].withOpacity(0.1) : Colors.white.withOpacity(0.02),
                              shape: BoxShape.circle,
                              border: Border.all(color: isUnread ? bildirim['renk'].withOpacity(0.5) : Colors.white12),
                            ),
                            child: Icon(bildirim['ikon'], color: isUnread ? bildirim['renk'] : Colors.white38, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // Orta Metin Alanı
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bildirim['baslik'], style: TextStyle(color: isUnread ? Colors.white : Colors.white54, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                                const SizedBox(height: 6),
                                Text(bildirim['mesaj'], style: TextStyle(color: isUnread ? Colors.white70 : Colors.white38, fontSize: 12, height: 1.4)),
                                const SizedBox(height: 12),
                                Text(bildirim['zaman'].toUpperCase(), style: TextStyle(color: isUnread ? primaryCyan : Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ],
                            ),
                          ),

                          // Sağ Kuantum Nabzı (Sadece Okunmamışlarda)
                          if (isUnread)
                            Container(
                              width: 10, height: 10,
                              margin: const EdgeInsets.only(top: 6, left: 8),
                              decoration: BoxDecoration(
                                  color: primaryCyan,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)]
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: BOŞ EKRAN DURUMU (HUD EMPTY STATE)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: const Color(0xFF111111),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: const Color(0xFF00FFC2).withOpacity(0.02), blurRadius: 50, spreadRadius: 20)]
            ),
            child: const Icon(Icons.satellite_alt_outlined, color: Colors.white24, size: 64),
          ),
          const SizedBox(height: 32),
          const Text("SİNYAL AĞI TEMİZ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text("Kuantum radarında okunmamış veya\nbekleyen bir bildirim bulunmuyor.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
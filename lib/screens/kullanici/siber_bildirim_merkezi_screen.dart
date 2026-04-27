import 'package:flutter/material.dart';

class SiberBildirimMerkeziScreen extends StatefulWidget {
  const SiberBildirimMerkeziScreen({super.key});

  @override
  State<SiberBildirimMerkeziScreen> createState() => _SiberBildirimMerkeziScreenState();
}

class _SiberBildirimMerkeziScreenState extends State<SiberBildirimMerkeziScreen> {
  // BİLDİRİM VERİTABANI (Simülasyon)
  final List<Map<String, dynamic>> _bildirimler = [
    {
      "id": "b1",
      "baslik": "TÜVTÜRK Muayene Yaklaşıyor!",
      "mesaj": "34 DNA 2026 plakalı aracınızın muayenesine 45 gün kaldı. Ceza yememek için akıllı asistan üzerinden hemen randevu alın.",
      "zaman": "10 dk önce",
      "okunduMu": false,
      "ikon": Icons.warning_amber_rounded,
      "renk": Colors.orange
    },
    {
      "id": "b2",
      "baslik": "Ekspertiz Randevusu Onaylandı",
      "mesaj": "Murat Plaza (Merkez Bayi) için yarın saat 10:30'a oluşturduğunuz randevu sisteme işlendi.",
      "zaman": "1 saat önce",
      "okunduMu": false,
      "ikon": Icons.event_available_outlined,
      "renk": Colors.teal.shade700
    },
    {
      "id": "b3",
      "baslik": "DNA Skoru Güncellendi",
      "mesaj": "Aracınızın periyodik bakım verileri sisteme girildi. Güncel sağlık skoru %92 olarak hesaplandı.",
      "zaman": "3 saat önce",
      "okunduMu": true,
      "ikon": Icons.science_outlined,
      "renk": Colors.purple
    },
    {
      "id": "b4",
      "baslik": "Market Uyarısı",
      "mesaj": "Takip ettiğiniz 'BMW M Performance Fren Disk Takımı' için yeni bir sıfır ilan eklendi.",
      "zaman": "Dün",
      "okunduMu": true,
      "ikon": Icons.shopping_bag_outlined,
      "renk": Colors.blue
    },
    {
      "id": "b5",
      "baslik": "Bağış Hareketi",
      "mesaj": "Trafik Mağdurları Derneği'ne yapılan %1'lik bağışınız başarıyla ulaştı. Teşekkür ederiz!",
      "zaman": "2 gün önce",
      "okunduMu": true,
      "ikon": Icons.volunteer_activism_outlined,
      "renk": Colors.green
    }
  ];

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

  // 💎 GERÇEKÇİ SİLME ANİMASYONU VE MANTIĞI
  void _bildirimiSil(String id) {
    setState(() {
      _bildirimler.removeWhere((element) => element['id'] == id);
    });
    _plazaUyariGoster("BİLDİRİM SİLİNDİ", "Bildirim kayıtlardan kalıcı olarak silindi.", Colors.black87);
  }

  void _tumunuOkunduIsaretle() {
    setState(() {
      for (var bildirim in _bildirimler) {
        bildirim['okunduMu'] = true;
      }
    });
    _plazaUyariGoster("İŞLEM BAŞARILI", "Tüm bildirimler okundu olarak işaretlendi.", primaryTeal);
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        duration: const Duration(seconds: 2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int okunmamisSayisi = _bildirimler.where((b) => b['okunduMu'] == false).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text("B İ L D İ R İ M   M E R K E Z İ", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
        actions: [
          if (okunmamisSayisi > 0)
            IconButton(
              icon: Icon(Icons.done_all, color: primaryTeal),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Akış", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                if (okunmamisSayisi > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("$okunmamisSayisi Yeni Bildirim", style: TextStyle(color: primaryTeal, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
                  )
              ],
            ),
          ),

          // 2. BİLDİRİM LİSTESİ VEYA BOŞ DURUM
          Expanded(
            child: _bildirimler.isEmpty
                ? _buildEmptyState() 
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
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))
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
                        color: isUnread ? primaryTeal.withValues(alpha: 0.05) : surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isUnread ? primaryTeal.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05)),
                        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sol İkon Kutusu
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUnread ? bildirim['renk'].withValues(alpha: 0.1) : bgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: isUnread ? bildirim['renk'].withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05)),
                            ),
                            child: Icon(bildirim['ikon'], color: isUnread ? bildirim['renk'] : Colors.black38, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // Orta Metin Alanı
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bildirim['baslik'], style: TextStyle(color: isUnread ? textColor : Colors.black87, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                                const SizedBox(height: 6),
                                Text(bildirim['mesaj'], style: TextStyle(color: isUnread ? Colors.black87 : Colors.black54, fontSize: 12, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                const SizedBox(height: 12),
                                Text(bildirim['zaman'].toUpperCase(), style: TextStyle(color: isUnread ? primaryTeal : Colors.black38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),

                          // Sağ Nabız (Sadece Okunmamışlarda)
                          if (isUnread)
                            Container(
                              width: 10, height: 10,
                              margin: const EdgeInsets.only(top: 6, left: 8),
                              decoration: BoxDecoration(
                                  color: primaryTeal,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
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

  // 💎 BOŞ EKRAN DURUMU (EMPTY STATE)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Icon(Icons.notifications_off_outlined, color: Colors.white26, size: 64),
          ),
          const SizedBox(height: 32),
          Text("BİLDİRİM YOK", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          const Text("Şu an için okunmamış veya\nbekleyen bir bildirim bulunmuyor.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Teklif satırlarını yöneten model
class OfferItem {
  String description;
  int quantity;
  double unitPrice;
  OfferItem({required this.description, this.quantity = 1, required this.unitPrice});
}

class ServiceDetailScreen extends StatefulWidget {
  final String raporId; // Firebase'deki rapor dökümanı ID'si

  const ServiceDetailScreen({super.key, required this.raporId});

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String brandName = "OTODNA SİBER AĞI";

  // Kontrol listesini Firebase'den alacağız
  List<Map<String, dynamic>> _checkItems = [];
  List<OfferItem> _currentOffer = [];

  // Rapor verileri
  Map<String, dynamic>? _raporData;
  String _dealerName = "Bayi Yükleniyor...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _raporVerileriniCek();
  }

  // 🚀 FİREBASE'DEN GERÇEK RAPOR VE BAYİ VERİSİNİ ÇEKME MOTORU
  Future<void> _raporVerileriniCek() async {
    try {
      // 1. Raporu çek
      DocumentSnapshot raporDoc = await _db.collection('raporlar').doc(widget.raporId).get();
      if (!raporDoc.exists) {
        throw Exception("Rapor bulunamadı.");
      }

      _raporData = raporDoc.data() as Map<String, dynamic>;

      // 2. Bayi adını usta_id'den çek
      String ustaId = _raporData!['usta_id'] ?? '';
      if (ustaId.isNotEmpty) {
        DocumentSnapshot bayiDoc = await _db.collection('kullanicilar').doc(ustaId).get();
        if (bayiDoc.exists) {
          _dealerName = (bayiDoc.data() as Map<String, dynamic>)['ad'] ?? "Bilinmeyen Bayi";
        }
      }

      // 3. Kontrol listesini Firebase verisinden dinamik oluştur
      // Biz daha önce verileri "Parça Adı: 0 (Bekliyor), 1 (Onaylı), 2 (Riskli)" diye tutmuştuk.
      Map<String, dynamic>? dbListe = _raporData!['kontrol_listesi'];
      if (dbListe != null) {
        dbListe.forEach((key, value) {
          _checkItems.add({
            "title": key,
            "checked": value == 1 || value == 2, // İşlem yapıldıysa işaretli
            "changed": value == 1, // Onaylıysa değişti/sağlam, Riskliyse (2) değişmedi
            "isRisk": value == 2 // 2 ise kırmızı alarm
          });
        });
      }

      setState(() => _isLoading = false);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ağ Hatası: $e'), backgroundColor: Colors.redAccent));
        setState(() => _isLoading = false);
      }
    }
  }

  // Hızlı Paket: Periyodik Bakım (Örnek teklif faturası)
  void _addPeriodicPackage() {
    setState(() {
      _currentOffer = [
        OfferItem(description: "Motor Yağı (5W-30)", unitPrice: 1250),
        OfferItem(description: "Yağ Filtresi", unitPrice: 280),
        OfferItem(description: "Hava Filtresi", unitPrice: 320),
        OfferItem(description: "Polen Filtresi", unitPrice: 450),
        OfferItem(description: "OtoDNA İşlem & Hizmet Bedeli", unitPrice: 1500),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(_dealerName.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.share, color: primaryCyan), onPressed: () {})],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : _raporData == null
          ? const Center(child: Text("Siber Rapor Okunamadı!", style: TextStyle(color: Colors.redAccent)))
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST BAŞLIK (FORM TİPİ)
            _buildHeaderSection(cardColor, primaryCyan),
            const SizedBox(height: 30),

            const Row(
              children: [
                Icon(Icons.handyman, color: primaryCyan, size: 20),
                SizedBox(width: 8),
                Text("ARAÇ KONTROL ŞEMASI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 12),

            // ÇİFT TİKLİ LİSTE (Firebase Verisi)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _checkItems.length,
              itemBuilder: (context, index) => _buildDoubleCheckRow(index, cardColor, primaryCyan),
            ),

            const SizedBox(height: 30),
            const Row(
              children: [
                Icon(Icons.request_quote, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text("FİYAT TEKLİFİ (TASLAK)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 12),

            // HIZLI PAKET BUTONU
            GestureDetector(
              onTap: _addPeriodicPackage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.amber), SizedBox(width: 8),
                    Text("Hızlı Periyodik Bakım Paketi Yükle", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TEKLİF TABLOSU
            _buildOfferTable(cardColor, primaryCyan),

            const SizedBox(height: 40),

            // YAZDIRMA BUTONLARI
            _buildActionButtons(primaryCyan),

            const SizedBox(height: 24),
            Center(
              child: Text(
                "Bu döküman $brandName sisteminden üretilmiştir. Geçerliliği OtoDNA Mührü ile sabittir.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.white38, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color cardColor, Color primaryCyan) {
    String plaka = _raporData!['plaka'] ?? 'BİLİNMİYOR';
    String tarih = "Tarih Yok";
    if (_raporData!['tarih'] != null) {
      tarih = DateFormat('dd.MM.yyyy - HH:mm').format((_raporData!['tarih'] as Timestamp).toDate());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryCyan.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.verified, color: Color(0xFF00FFC2), size: 40),
          const SizedBox(height: 12),
          Text(_dealerName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text("YETKİLİ SERVİS DİJİTAL BİLGİ FORMU", style: TextStyle(color: primaryCyan, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(Icons.directions_car, color: Colors.white54, size: 16), const SizedBox(width: 8), Text("Plaka: $plaka", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
              Row(children: [const Icon(Icons.calendar_month, color: Colors.white54, size: 16), const SizedBox(width: 8), Text(tarih, style: const TextStyle(color: Colors.white70, fontSize: 12))]),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDoubleCheckRow(int index, Color cardColor, Color primaryCyan) {
    bool isRisk = _checkItems[index]["isRisk"] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isRisk ? Colors.redAccent.withOpacity(0.5) : Colors.white12)
      ),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text(
                  _checkItems[index]["title"],
                  style: TextStyle(color: isRisk ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
              )
          ),
          _checkColumn("Kontrol", _checkItems[index]["checked"], (v) => setState(() => _checkItems[index]["checked"] = v), primaryCyan),
          _checkColumn("Durum İyi", _checkItems[index]["changed"], (v) => setState(() => _checkItems[index]["changed"] = v), Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _checkColumn(String label, bool val, Function(bool) onSub, Color checkColor) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Checkbox(
                value: val,
                activeColor: checkColor,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white54),
                onChanged: (v) => onSub(v!)
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOfferTable(Color cardColor, Color primaryCyan) {
    if (_currentOffer.isEmpty) {
      return Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
        child: const Text("Henüz teklif faturası oluşturulmadı.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
      );
    }

    double totalAmount = _currentOffer.fold(0, (sum, item) => sum + item.unitPrice);

    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.white12),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(primaryCyan.withOpacity(0.1)),
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text("İşlem / Parça", style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Fiyat", style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold))),
              ],
              rows: _currentOffer.map((item) => DataRow(cells: [
                DataCell(Text(item.description, style: const TextStyle(color: Colors.white, fontSize: 12))),
                DataCell(Text("₺${item.unitPrice}", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
              ])).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TOPLAM TUTAR:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("₺$totalAmount", style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color primaryCyan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.print, color: Color(0xFF0F172A)),
            label: const Text("Yazdır", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Siber Yazıcıya Gönderiliyor... 🖨️')));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text("PDF Teklif", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklif Faturası (PDF) Müşteriye SMS İle İletildi! 📲')));
            },
          ),
        ),
      ],
    );
  }
}
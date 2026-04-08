import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dukkan_model.dart'; // Esnaf modelimizi içeri alıyoruz
import '../../core/siber_tema.dart';

class IlanVerScreen extends StatefulWidget {
  final Dukkan aktifDukkan; // Giriş yapan firmanın tüm bilgileri (Rozet, VIP durumu vb.)

  const IlanVerScreen({super.key, required this.aktifDukkan});

  @override
  State<IlanVerScreen> createState() => _IlanVerScreenState();
}

class _IlanVerScreenState extends State<IlanVerScreen> {
  // Siber Renk Paleti (SiberTema entegrasyonu)
  static const _neonGreen = SiberTema.kuantumCyan;
  static const _cyberBlack = SiberTema.oledBlack;
  static const _cyberCard = Color(0xFF1E1E2E);

  // Form Kontrolcüleri
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  @override
  void dispose() {
    _adController.dispose();
    _fiyatController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🧠 KUANTUM LİMİT KONTROLÜ (dukkan_model.dart'tan geliyor)
    bool limitDolduMu = !widget.aktifDukkan.yeniIlanEklenebilirMi;
    bool vipMi = widget.aktifDukkan.isVip;

    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.add_shopping_cart, color: _neonGreen),
            SizedBox(width: 10),
            Text('Siber Oto Market - İlan Ver',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 KULLANICI / FİRMA BİLGİ BANDI
            _buildFirmaBilgiBandi(),
            const SizedBox(height: 20),

            // 🌟 VIP TOPLU YÜKLEME BUTONU
            if (vipMi) ...[
              _buildVipTopluYuklemeAlani(),
              const SizedBox(height: 20),
              const Center(child: Text("--- VEYA TEK TEK EKLE ---",
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
              const SizedBox(height: 20),
            ],

            // 🚨 LİMİT KONTROLÜ VE FORM
            if (limitDolduMu)
              _buildLimitDoluUyarisi()
            else
              _buildStandartIlanFormu(),
          ],
        ),
      ),
    );
  }

  // ─── 👤 FİRMA ROZET VE LİMİT GÖSTERGESİ ───
  Widget _buildFirmaBilgiBandi() {
    int maxLimit = widget.aktifDukkan.maxIlanSiniri;
    String limitMetni = maxLimit == -1 ? "Sınırsız (VIP)" : "${widget.aktifDukkan.kullanilanIlanSayisi} / $maxLimit";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cyberCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.aktifDukkan.isVip ? Colors.amber : Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.aktifDukkan.ad,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(widget.aktifDukkan.isVip ? Icons.stars : Icons.storefront,
                      color: widget.aktifDukkan.isVip ? Colors.amber : Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text("Rozet: ${widget.aktifDukkan.rozet}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Avenir')),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Kullanım", style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Avenir')),
              Text(limitMetni,
                  style: const TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
            ],
          )
        ],
      ),
    );
  }

  // ─── 🌟 VIP TOPLU YÜKLEME MOTORU ───
  Widget _buildVipTopluYuklemeAlani() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.1), Colors.black]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
          const SizedBox(height: 10),
          const Text("VIP TOPLU İLAN YÜKLEME",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
          const SizedBox(height: 5),
          const Text("PDF veya Excel listenizi seçin, Kuantum AI saniyeler içinde binlerce ilanınızı vitrine dizsin.",
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir')),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 45),
            ),
            icon: const Icon(Icons.file_upload),
            label: const Text("Katalog Dosyası Seç (.pdf / .xlsx)", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("VIP Kuantum Tarayıcı Başlatılıyor..."), backgroundColor: Colors.amber));
            },
          )
        ],
      ),
    );
  }

  // ─── 🚨 LİMİT DOLU UYARISI ───
  Widget _buildLimitDoluUyarisi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.block, color: Colors.redAccent, size: 40),
          const SizedBox(height: 10),
          const Text("İLAN LİMİTİNİZ DOLDU!",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Avenir')),
          const SizedBox(height: 10),
          Text(
            "Mevcut paketiniz ile en fazla ${widget.aktifDukkan.maxIlanSiniri} ürün sergileyebilirsiniz. Kuantum Ağı'nın devasa müşteri kitlesine daha fazla ürün sunmak için rozetinizi yükseltin.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Avenir'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _neonGreen,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.rocket_launch),
            label: const Text("PAKETİ YÜKSELT (GOLD / VIP)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Siber Kasaya Yönlendiriliyor..."), backgroundColor: _neonGreen));
            },
          )
        ],
      ),
    );
  }

  // ─── 📝 STANDART TEKLİ İLAN FORMU ───
  Widget _buildStandartIlanFormu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Yeni İlan Bilgileri",
            style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
        const SizedBox(height: 16),
        _buildTextField("Parça / Araç Adı", Icons.title, _adController),
        const SizedBox(height: 12),
        _buildTextField("Fiyat (TL)", Icons.attach_money, _fiyatController, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField("Açıklama", Icons.description, _aciklamaController, maxLines: 3),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _neonGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _ilanYayinla,
            child: const Text("KUANTUM AĞINDA YAYINLA",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontFamily: 'Avenir'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: _neonGreen),
        filled: true,
        fillColor: _cyberCard,
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: _neonGreen), borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 🚀 GERÇEK FİREBASE KAYIT MOTORU
  Future<void> _ilanYayinla() async {
    if (_adController.text.isEmpty || _fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eksik veri girişi!")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('ilanlar').add({
        'dukkan_id': widget.aktifDukkan.id,
        'ilan_ad': _adController.text,
        'fiyat': double.tryParse(_fiyatController.text) ?? 0,
        'aciklama': _aciklamaController.text,
        'kayit_tarihi': FieldValue.serverTimestamp(),
        'vitrin_etiketi': "Murat Plaza", // Global kural
      });

      // Dükkanın kullanılan ilan sayısını artır (Yerelde ve veritabanında senkronize olmalı)
      // Bu işlem dukkan_model veya bir servis üzerinden yapılmalıdır.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("İlan Kuantum Ağına Eklendi!"), backgroundColor: _neonGreen));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Kayıt Hatası: $e");
    }
  }
}
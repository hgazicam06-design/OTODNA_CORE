import 'package:flutter/material.dart';
import '../models/dukkan_model.dart'; // Esnaf modelimizi içeri alıyoruz

class IlanVerScreen extends StatefulWidget {
  final Dukkan aktifDukkan; // Giriş yapan firmanın tüm bilgileri (Rozet, VIP durumu vb.)

  const IlanVerScreen({super.key, required this.aktifDukkan});

  @override
  State<IlanVerScreen> createState() => _IlanVerScreenState();
}

class _IlanVerScreenState extends State<IlanVerScreen> {
  // Siber Renk Paleti
  static const _neonGreen = Color(0xFF00FFCC);
  static const _cyberBlack = Color(0xFF0D0D0D);
  static const _cyberCard = Color(0xFF1E1E2E);

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
            Text('Siber Oto Market - İlan Ver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

            // 🌟 SADECE VIP'LERE ÖZEL TOPLU YÜKLEME BUTONU
            if (vipMi) ...[
              _buildVipTopluYuklemeAlani(),
              const SizedBox(height: 20),
              const Center(child: Text("--- VEYA TEK TEK EKLE ---", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
            ],

            // 🚨 LİMİT DOLDUYSA ÇIKACAK ÖDEME DUVARI (PAYWALL)
            if (limitDolduMu)
              _buildLimitDoluUyarisi()
            else
              _buildStandartIlanFormu(), // Limit dolmadıysa standart form çıkar
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
              Text(widget.aktifDukkan.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(widget.aktifDukkan.isVip ? Icons.stars : Icons.storefront, color: widget.aktifDukkan.isVip ? Colors.amber : Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text("Rozet: ${widget.aktifDukkan.rozet}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Kullanım", style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text(limitMetni, style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 16)),
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
          const Text("VIP TOPLU İLAN YÜKLEME", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          const Text("PDF veya Excel listenizi seçin, Kuantum AI saniyeler içinde binlerce ilanınızı vitrine dizsin.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 45),
            ),
            icon: const Icon(Icons.file_upload),
            label: const Text("Katalog Dosyası Seç (.pdf / .xlsx)", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              // TODO: İleride FilePicker ile dosya seçtirip Firebase Cloud Functions'a göndereceğiz
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("VIP Kuantum Tarayıcı Başlatılıyor..."), backgroundColor: Colors.amber));
            },
          )
        ],
      ),
    );
  }

  // ─── 🚨 LİMİT DOLU UYARISI (PARA BASMA MAKİNESİ) ───
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
          const Text("İLAN LİMİTİNİZ DOLDU!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Text(
            "Mevcut paketiniz ile en fazla ${widget.aktifDukkan.maxIlanSiniri} ürün sergileyebilirsiniz. Kuantum Ağı'nın devasa müşteri kitlesine daha fazla ürün sunmak için rozetinizi yükseltin.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _neonGreen,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.rocket_launch),
            label: const Text("PAKETİ YÜKSELT (GOLD / VIP)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () {
              // TODO: İleride Abonelik/Ödeme Ekranına yönlendireceğiz
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber Kasaya Yönlendiriliyor..."), backgroundColor: _neonGreen));
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
        const Text("Yeni İlan Bilgileri", style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        _buildTextField("Parça / Araç Adı", Icons.title),
        const SizedBox(height: 12),
        _buildTextField("Fiyat (TL)", Icons.attach_money, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField("Açıklama", Icons.description, maxLines: 3),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _neonGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // TODO: Firebase'e ilanı ekle ve dukkan_model içindeki kullanilanIlanSayisi'nı 1 artır!
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İlan Kuantum Ağına Eklendi!"), backgroundColor: _neonGreen));
            },
            child: const Text("KUANTUM AĞINDA YAYINLA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: _neonGreen),
        filled: true,
        fillColor: _cyberCard,
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: _neonGreen), borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
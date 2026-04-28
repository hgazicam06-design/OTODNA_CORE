import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTODNA BİLDİRİM TERMİNALİ - V3 (ZIRHLI)
/// Vatandaşların veya Adminlerin ağ üzerinden sinyal fırlattığı merkez üssü.
class OtoDNABildirimEkrani extends StatefulWidget {
  OtoDNABildirimEkrani({super.key});

  @override
  State<OtoDNABildirimEkrani> createState() => _OtoDNABildirimEkraniState();
}

class _OtoDNABildirimEkraniState extends State<OtoDNABildirimEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _qrController = TextEditingController();

  bool _isProcessing = false;
  bool _isGlobalProcessing = false;
  bool _isAdmin = false; // Siber Yetki Kontrolü

  @override
  void initState() {
    super.initState();
    _yetkiKontrolEt();
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  // --- 🔐 YETKİ KONTROL MOTORU ---
  Future<void> _yetkiKontrolEt() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('kullanicilar').doc(user.uid).get();
      if (doc.exists && doc.data()?['rol'] == 'ADMIN') {
        setState(() => _isAdmin = true);
      }
    }
  }

  // --- 🛰️ SİBER BİLDİRİM MOTORU (GERÇEK VERİ YAZIMI) ---
  Future<void> bildirimGonder() async {
    final String qrID = _qrController.text.trim().toUpperCase();

    if (qrID.isEmpty) {
      _uyariGoster("SİBER HATA: HEDEF QR KODU BOŞ BIRAKILAMAZ!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. ADIM: KARA LİSTE KONTROLÜ (GÜVENLİK DUVARI)
      String gonderenUID = _auth.currentUser?.uid ?? "ANONIM_SIBER_YOLCU";

      final blacklistRef = await _db.collection('kara_liste').doc(gonderenUID).get();
      if (blacklistRef.exists) {
        if (!mounted) return;
        _uyariGoster("İHLAL TESPİTİ: SİBER YETKİLERİNİZ ASKIYA ALINDI!", isError: true);
        return;
      }

      // 2. ADIM: HEDEF ARAÇ ANALİZİ
      final qrSorgu = await _db.collection('araclar').where('qr_id', isEqualTo: qrID).limit(1).get();

      if (qrSorgu.docs.isEmpty) {
        if (!mounted) return;
        _uyariGoster("HEDEF BULUNAMADI: $qrID SİSTEME KAYITLI DEĞİL.", isError: true);
        return;
      }

      var aracData = qrSorgu.docs.first.data();
      String aracSahibiID = aracData['sahibi_id'] ?? 'Bilinmiyor';

      // 3. ADIM: ATOMİK BİLDİRİM MÜHRÜ (WriteBatch)
      WriteBatch batch = _db.batch();
      DocumentReference bildirimRef = _db.collection('bildirimler').doc();

      batch.set(bildirimRef, {
        "alici_id": aracSahibiID,
        "gonderen_id": gonderenUID,
        "baslik": "🚨 SİBER ACİL DURUM SİNYALİ",
        "mesaj": "Aracınızın ($qrID) QR kodu taratıldı. Acil bir durum veya park ihlali olabilir.",
        "qr_kodu": qrID,
        "plaka": aracData['plaka'],
        "durum": "BEKLEMEDE",
        "okundu_mu": false,
        "tip": "VATANDAS_IHBARI",
        "tarih": FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      _qrController.clear();
      _uyariGoster("SİNYAL FIRLATILDI! ARAÇ SAHİBİNE ULAŞILDI. 🦅");

    } catch (e) {
      if (!mounted) return;
      _uyariGoster("AĞ BAĞLANTISI KOPUK: SİNYAL İLETİLEMEDİ.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- ⚔️ GAZİ YETKİSİ: GLOBAL SİNYAL (ADMIN ONLY) ---
  Future<void> _globalBildirimAtesle() async {
    if (!_isAdmin) {
      _uyariGoster("YETKİSİZ ERİŞİM: SADECE KOMUTAN GAZİ BU EMRİ VEREBİLİR!", isError: true);
      return;
    }

    setState(() => _isGlobalProcessing = true);

    try {
      await _db.collection('sistem_mesajlari').add({
        "baslik": "🔴 OTODNA GENEL KARARGAH EMRİ",
        "mesaj": "Tüm birimlerin dikkatine: Sistem genelinde kuantum güncellemesi başlamıştır. Bağlantınızı koparmayın.",
        "gonderen": "Siber Komutan Gazi",
        "tarih": FieldValue.serverTimestamp(),
        "hedef": "TUM_AG",
      });

      if (!mounted) return;
      _uyariGoster("GAZİ EMRİ ONAYLANDI: TÜM AĞA SİNYAL FIRLATILDI! 🚀");
    } catch (e) {
      _uyariGoster("KRİTİK HATA: GLOBAL SİNYAL BAŞARISIZ.", isError: true);
    } finally {
      if (mounted) setState(() => _isGlobalProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12, letterSpacing: 1)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return _buildDesktopLayout();
                  } else {
                    return _buildMobileLayout();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, color: SiberTema.kuantumCyan, size: 18),
          SizedBox(width: 12),
          Text(
            'SİBER İLETİŞİM KULESİ',
            style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildQrGirisKarti(),
              SizedBox(height: 24),
              _buildKayitDavetiKarti(),
            ],
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: _buildGaziYetkisiKarti(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildQrGirisKarti(),
        SizedBox(height: 24),
        _buildGaziYetkisiKarti(),
        SizedBox(height: 24),
        _buildKayitDavetiKarti(),
      ],
    );
  }

  Widget _buildQrGirisKarti() {
    return SiberTema.siberCamKalkan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 30),
              SizedBox(width: 16),
              Text("HIZLI SİNYAL RADARI", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          SizedBox(height: 24),
          Text(
            "Hedef aracın siber kimliğini (QR Kodu) girerek araç sahibine anonim bir 'Müdahale Çağrısı' bırakın.",
            style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5),
          ),
          SizedBox(height: 24),
          _buildSiberTextField(
            controller: _qrController,
            hint: "QR KODUNU BURAYA MÜHÜRLE (Örn: ARAC-123)",
            icon: Icons.qr_code_scanner,
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : bildirimGonder,
              style: SiberTema.kuantumButonStili(renk: SiberTema.kuantumCyan),
              icon: _isProcessing
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(Icons.send_rounded, color: Colors.white),
              label: Text(_isProcessing ? "İŞLENİYOR..." : "SİNYALİ ATEŞLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: SiberTema.textMuted),
          hintText: hint,
          hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildKayitDavetiKarti() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        children: [
          Icon(Icons.fingerprint, color: SiberTema.textMuted, size: 40),
          SizedBox(height: 16),
          Text("ARACINI AĞA KAYDET", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          SizedBox(height: 8),
          Text(
            "Siz de aracınızı koruma altına almak ve QR bildirimleri almak için Profil > Araçlarım sekmesinden DNA kaydı yapabilirsiniz.",
            textAlign: TextAlign.center,
            style: TextStyle(color: SiberTema.textMuted, fontSize: 9, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildGaziYetkisiKarti() {
    // Eğer admin değilse bu kartı siber bir gizlilikle saklıyoruz veya sadece kilitli gösteriyoruz
    return Opacity(
      opacity: _isAdmin ? 1.0 : 0.4,
      child: SiberTema.siberCamKalkan(
        child: Column(
          children: [
            Icon(Icons.admin_panel_settings, color: _isAdmin ? SiberTema.kanKirmizi : Colors.white24, size: 50),
            SizedBox(height: 20),
            Text(
                "KOMUTA MERKEZİ",
                style: TextStyle(color: _isAdmin ? SiberTema.kanKirmizi : Colors.white38, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)
            ),
            SizedBox(height: 12),
            Text(
              "BU ALAN SADECE SİBER KOMUTAN YETKİSİYLE ERİŞİLEBİLİR. TÜM TÜRKİYE GENELİNE ANLIK PUSH NOTIFICATION GÖNDERİLİR.",
              textAlign: TextAlign.center,
              style: TextStyle(color: SiberTema.textMuted, fontSize: 10, height: 1.5, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton.icon(
                onPressed: (_isAdmin && !_isGlobalProcessing) ? _globalBildirimAtesle : null,
                style: SiberTema.kuantumButonStili(renk: _isAdmin ? SiberTema.kanKirmizi : Colors.grey.shade900),
                icon: Icon(_isAdmin ? Icons.rocket_launch : Icons.lock, color: Colors.white),
                label: Text(
                    _isGlobalProcessing ? "ATEŞLENİYOR..." : (_isAdmin ? "TÜM AĞA DUYURU YAP" : "ERİŞİM ENGELLENDİ"),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
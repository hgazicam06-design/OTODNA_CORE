// lib/bayi/b2b_imece_agi_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE TEMALARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ B2B İMECE AĞI (Bayiler Arası Kuantum Ticaret Merkezi)
/// Bayilerin parça paslaştığı ve %12 Karargah kesintisiyle çalışan otonom terminal.
class B2bImeceAgiScreen extends StatefulWidget {
  const B2bImeceAgiScreen({super.key});

  @override
  State<B2bImeceAgiScreen> createState() => _B2bImeceAgiScreenState();
}

class _B2bImeceAgiScreenState extends State<B2bImeceAgiScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _parcaAdiController = TextEditingController();
  final TextEditingController _aracModeliController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  bool _islemSuruyor = false;
  String _aciliyetDurumu = "NORMAL";

  @override
  void dispose() {
    _parcaAdiController.dispose();
    _aracModeliController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  // ── 🚀 SİBER YARDIM SİNYALİ FIRLATMA (YENİ TALEP) ──
  Future<void> _yeniTalepFirlat() async {
    if (_parcaAdiController.text.trim().isEmpty || _aracModeliController.text.trim().isEmpty) {
      _siberUyariGoster("İHLAL", "Parça Adı ve Araç Modeli zorunludur!", SiberTema.kanKirmizi);
      return;
    }

    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    try {
      // Kendi bayi bilgilerimizi çekelim ki ilanda görünsün
      DocumentSnapshot bayiDoc = await _db.collection('kullanicilar').doc(_currentUser!.uid).get();
      String bayiAdi = bayiDoc.exists ? (bayiDoc.data() as Map<String, dynamic>)['firma_adi'] ?? "Bilinmeyen Bayi" : "Gizli Karargah";

      WriteBatch batch = _db.batch();

      DocumentReference talepRef = _db.collection('b2b_talepler').doc();
      batch.set(talepRef, {
        'talep_eden_id': _currentUser!.uid,
        'talep_eden_firma': bayiAdi,
        'parca_adi': _parcaAdiController.text.trim().toUpperCase(),
        'arac_modeli': _aracModeliController.text.trim().toUpperCase(),
        'aciklama': _aciklamaController.text.trim(),
        'aciliyet': _aciliyetDurumu,
        'durum': 'AKTIF',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      // 📡 SİBER İSTİHBARAT: YENİ TALEP MÜHRÜ
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'İMECE_DİVANI',
        'seviye': _aciliyetDurumu == 'ACIL' ? 'KRİTİK' : 'BİLGİ',
        'islem_detayi': 'B2B SİNYAL: $bayiAdi, ${_aracModeliController.text.trim().toUpperCase()} aracı için ${_parcaAdiController.text.trim().toUpperCase()} arıyor.',
        'kullanici_id': _currentUser!.uid,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _parcaAdiController.clear();
      _aracModeliController.clear();
      _aciklamaController.clear();

      _siberUyariGoster("SİNYAL FIRLATILDI", "Parça talebiniz B2B İmece Ağına düştü.", SiberTema.kuantumCyan);
      if (mounted) Navigator.pop(context); // BottomSheet'i kapat

    } catch (e) {
      developer.log("AĞ HATASI", error: e);
      _siberUyariGoster("HATA", "Sinyal Karargaha ulaşmadı.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 💰 TEDARİK ET VE %12 KESİNTİ MOTORU (WRITEBATCH) ──
  void _tedarikSagla(String talepId, String talepEdenFirma, String parcaAdi) {
    TextEditingController fiyatController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: SiberTema.kuantumCyan)),
        title: const Text("TEDARİK PROTOKOLÜ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hedef: $talepEdenFirma", style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text("Parça: $parcaAdi", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Satış Fiyatı (TL):", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: fiyatController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: SiberTema.oledBlack,
                prefixIcon: const Icon(Icons.currency_lira, color: SiberTema.kuantumCyan),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            const Text("DİKKAT: Karargah bu işlemden otonom olarak %12 hizmet ve vergi kesintisi yapacaktır.", style: TextStyle(color: SiberTema.altinSari, fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: SiberTema.kuantumButonStili(),
            onPressed: () async {
              double girilenFiyat = double.tryParse(fiyatController.text.trim()) ?? 0;
              if (girilenFiyat <= 0) {
                _siberUyariGoster("İHLAL", "Geçerli bir fiyat girmelisiniz.", SiberTema.kanKirmizi);
                return;
              }

              Navigator.pop(context);
              await _tedarikIsleminiMuhurle(talepId, girilenFiyat);
            },
            child: const Text("SATIŞI MÜHÜRLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Future<void> _tedarikIsleminiMuhurle(String talepId, double fiyat) async {
    setState(() => _islemSuruyor = true);
    HapticFeedback.vibrate();

    try {
      // %12 Karargah Kesintisi Hesaplaması (Sarsılmaz Kural)
      double karargahPayi = fiyat * 0.12;
      double saticiHakedisi = fiyat - karargahPayi;

      WriteBatch batch = _db.batch();

      // 1. Talebi Kapat
      DocumentReference talepRef = _db.collection('b2b_talepler').doc(talepId);
      batch.update(talepRef, {
        'durum': 'TAMAMLANDI',
        'tedarik_eden_id': _currentUser!.uid,
        'satis_fiyati': fiyat,
        'tamamlanma_zamani': FieldValue.serverTimestamp(),
      });

      // 2. Kuantum Finansal İşlemler Havuzuna %12'yi İşle
      DocumentReference finansRef = _db.collection('finansal_islemler').doc();
      batch.set(finansRef, {
        'islem_tipi': 'B2B_TEDARIK',
        'brut_tutar': fiyat,
        'gazi_payi_12': karargahPayi,
        'talep_id': talepId,
        'satici_id': _currentUser!.uid,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 3. Siber İstihbarata Mühürle
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'İMECE_DİVANI',
        'seviye': 'BİLGİ',
        'islem_detayi': 'B2B TEDARİK: Bir bayi ₺${fiyat.toStringAsFixed(2)} değerindeki parçayı sağladı.',
        'vaka_id': talepId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _siberUyariGoster("TİCARET BAŞARILI", "Karargah payı kesildi. Net hakedişiniz: ₺${saticiHakedisi.toStringAsFixed(2)}", SiberTema.kuantumCyan);

    } catch (e) {
      developer.log("MÜHÜRLEME HATASI", error: e);
      _siberUyariGoster("SİBER HATA", "Ticaret işlemi ağa yazılamadı.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 📝 TALEP FORMU (BOTTOM SHEET) ──
  void _talepFormuAc() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: SiberTema.matGrey,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SİBER YARDIM SİNYALİ", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 20),
                    _buildSiberTextField("Aranan Parça (Örn: G20 KARBON TAMPON)", Icons.settings, _parcaAdiController),
                    const SizedBox(height: 12),
                    _buildSiberTextField("Araç Marka/Model", Icons.directions_car, _aracModeliController),
                    const SizedBox(height: 12),
                    _buildSiberTextField("Ekstra Detay (İsteğe Bağlı)", Icons.notes, _aciklamaController),
                    const SizedBox(height: 16),
                    const Text("SİNYAL ACİLİYETİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("NORMAL", style: TextStyle(color: Colors.white, fontSize: 12)),
                            activeColor: SiberTema.kuantumCyan,
                            value: "NORMAL",
                            groupValue: _aciliyetDurumu,
                            onChanged: (val) => setModalState(() => _aciliyetDurumu = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("KIRMIZI KOD (ACİL)", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 12, fontWeight: FontWeight.bold)),
                            activeColor: SiberTema.kanKirmizi,
                            value: "ACIL",
                            groupValue: _aciliyetDurumu,
                            onChanged: (val) => setModalState(() => _aciliyetDurumu = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: SiberTema.kuantumButonStili(),
                        icon: const Icon(Icons.radar, color: SiberTema.oledBlack),
                        label: const Text("AĞA SİNYAL FIRLAT", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        onPressed: _islemSuruyor ? null : _yeniTalepFirlat,
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  Widget _buildSiberTextField(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
        prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
        filled: true,
        fillColor: SiberTema.oledBlack,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırh OLED Siyah verir
        appBar: AppBar(
          title: const Text("B2B İMECE AĞI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: SiberTema.kuantumCyan, size: 28),
              tooltip: "Yeni Sinyal Fırlat",
              onPressed: _talepFormuAc,
            )
          ],
        ),
        body: Column(
          children: [
            // 📡 RADAR BİLGİLENDİRMESİ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: SiberTema.kuantumCyan.withOpacity(0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 16),
                  SizedBox(width: 8),
                  Text("MATRİX CANLI DİNLENİYOR...", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),

            // 📦 CANLI TALEPLER (FİREBASE STREAM)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('b2b_talepler')
                    .where('durum', isEqualTo: 'AKTIF')
                    .orderBy('zaman_damgasi', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Şu an ağda aktif bir parça talebi bulunmuyor.", style: TextStyle(color: Colors.white30)),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var talep = snapshot.data!.docs[index];
                      var data = talep.data() as Map<String, dynamic>;
                      bool isAcil = data['aciliyet'] == 'ACIL';
                      bool isBenimTalebim = data['talep_eden_id'] == _currentUser?.uid;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: SiberTema.matGrey,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isAcil ? SiberTema.kanKirmizi : Colors.white12, width: isAcil ? 2 : 1),
                          boxShadow: isAcil ? [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.2), blurRadius: 10)] : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isAcil ? SiberTema.kanKirmizi.withOpacity(0.2) : SiberTema.kuantumCyan.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: isAcil ? SiberTema.kanKirmizi : SiberTema.kuantumCyan),
                                    ),
                                    child: Text(
                                      isAcil ? "🔴 KIRMIZI KOD (ACİL)" : "🟢 NORMAL TALEP",
                                      style: TextStyle(color: isAcil ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  Text("Talep Eden: ${data['talep_eden_firma']}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(data['parca_adi'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text("Uyumlu Araç: ${data['arac_modeli']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              if (data['aciklama'] != null && data['aciklama'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text("Not: ${data['aciklama']}", style: const TextStyle(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: 16),

                              // Aksiyon Butonu
                              SizedBox(
                                width: double.infinity,
                                child: isBenimTalebim
                                    ? OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), foregroundColor: Colors.white54),
                                  icon: const Icon(Icons.hourglass_empty, size: 16),
                                  label: const Text("KENDİ TALEBİNİZ - BEKLENİYOR"),
                                  onPressed: null,
                                )
                                    : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAcil ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
                                    foregroundColor: SiberTema.oledBlack,
                                  ),
                                  icon: const Icon(Icons.handshake),
                                  label: const Text("TEDARİK SAĞLA & SAT", style: TextStyle(fontWeight: FontWeight.w900)),
                                  onPressed: () => _tedarikSagla(talep.id, data['talep_eden_firma'], data['parca_adi']),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
// ── DOSYA SONU MÜHRÜ ──
import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/torpido_servisi.dart';
import '../../models/parca_garanti_model.dart';

/// 🛡️ SİBER PARÇA DEĞİŞİM VE GARANTİ MÜHRÜ EKRANI
/// Yetkili ustaların parça değişimini "Dijital Garanti" ile taçlandırdığı arayüz.
class SiberParcaDegisimScreen extends StatefulWidget {
  final String ustaUid;
  final String firmaUnvani;

  SiberParcaDegisimScreen({
    super.key,
    required this.ustaUid,
    required this.firmaUnvani,
  });

  @override
  State<SiberParcaDegisimScreen> createState() => _SiberParcaDegisimScreenState();
}

class _SiberParcaDegisimScreenState extends State<SiberParcaDegisimScreen> {
  final TorpidoServisi _torpidoServisi = TorpidoServisi();
  final ImagePicker _picker = ImagePicker();

  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = Color(0xFF1E293B);
  final Color textMuted = Color(0xFF64748B);
  final Color dangerColor = SiberTema.kanKirmizi;

  final TextEditingController _aracIdCtrl = TextEditingController();
  final TextEditingController _parcaAdiCtrl = TextEditingController();
  final TextEditingController _garantiSuresiCtrl = TextEditingController(text: "12");

  // AI Tarama Sonuçları (Kilitli Veriler)
  String? _oemKodu;
  String? _benzersizSeriNo;
  String? _irsaliyeFaturaNo;
  int? _aiGuvenSkoru;

  File? _eskiParcaFoto;
  File? _yeniParcaFoto;
  File? _kutuFaturaFoto; // AI'ın tarayacağı fotoğraf
  
  bool _islemSuruyor = false;
  bool _muhurBasildi = false;

  // 🤝 İKİ TARAFLI MÜHÜR DEĞİŞKENLERİ
  bool _musteriOncedenTaradiMi = false; // Test amaçlı Toggle
  bool _adliProtokolOnaylandi = false; // Yasal sözleşme onayı

  @override
  void initState() {
    super.initState();
    // Test Senaryosu: Gelen işlem müşteri tarafından taranmış mı?
    // Gerçekte bu parametre olarak gelir.
  }

  Future<void> _fotoSec(String tur) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      setState(() {
        if (tur == "eski") _eskiParcaFoto = File(image.path);
        if (tur == "yeni") _yeniParcaFoto = File(image.path);
      });
    }
  }

  // 🤖 YENİ: YAPAY ZEKA GÖRSEL TARAMA TETİKLEYİCİSİ
  Future<void> _aiTaramaBaslat() async {
    if (!_adliProtokolOnaylandi) {
      _siberUyari("YASAL ONAY GEREKLİ", "Devam etmek için Adli Protokolü kabul etmeniz zorunludur.", Colors.orange.shade700);
      return;
    }

    HapticFeedback.heavyImpact();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    
    if (image != null) {
      setState(() {
        _kutuFaturaFoto = File(image.path);
        _islemSuruyor = true;
      });

      try {
        // 1. Optik Tarama (Vision API)
        Map<String, dynamic> taramaSonucu = await _torpidoServisi.aiOptikTarama(_kutuFaturaFoto!);
        
        // 2. Çıkma Parça / Sahtecilik Kontrolü (Tek Kullanımlık Seri No)
        bool seriNoKullanilmisMi = await _torpidoServisi.seriNoKullanilmisMi(taramaSonucu['benzersizSeriNo']);

        if (seriNoKullanilmisMi) {
          _siberUyari("🚨 SİBER İHLAL (ÇIKMA PARÇA)", "Bu seri numarası daha önce başka bir araçta kullanılmış! İşlem kilitlendi.", dangerColor);
          setState(() {
            _oemKodu = null;
            _benzersizSeriNo = null;
            _islemSuruyor = false;
          });
          return;
        }

        // 3. Geçerliyse Verileri Kilitle
        setState(() {
          _oemKodu = taramaSonucu['oemKodu'];
          _benzersizSeriNo = taramaSonucu['benzersizSeriNo'];
          _irsaliyeFaturaNo = taramaSonucu['irsaliyeFaturaNo'];
          _aiGuvenSkoru = taramaSonucu['aiGuvenSkoru'];
          _islemSuruyor = false;
        });

        HapticFeedback.vibrate();
        _siberUyari("AI TARAMA BAŞARILI", "Orijinal kutu ve irsaliye doğrulandı. Güven Skoru: %$_aiGuvenSkoru", primaryTeal);

      } catch (e) {
        setState(() => _islemSuruyor = false);
        _siberUyari("TARAMA HATASI", e.toString().replaceAll("Exception: ", ""), dangerColor);
      }
    }
  }

  void _siberUyari(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: surfaceColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk.withOpacity(0.3), width: 1.5)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textMain, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _garantiMuhruBas() async {
    if (!_adliProtokolOnaylandi) {
      _siberUyari("YASAL ONAY GEREKLİ", "Devam etmek için Adli Protokolü kabul etmeniz zorunludur.", Colors.orange.shade700);
      return;
    }

    HapticFeedback.heavyImpact();

    if (_aracIdCtrl.text.isEmpty || _parcaAdiCtrl.text.isEmpty) {
      _siberUyari("EKSİK VERİ", "Araç ID ve Parça Adı boş bırakılamaz.", Colors.orange.shade700);
      return;
    }

    if (_oemKodu == null || _benzersizSeriNo == null) {
      _siberUyari("SİBER İHLAL", "AI Taraması yapılmadan Mühür basılamaz!", dangerColor);
      return;
    }

    if (_eskiParcaFoto == null || _yeniParcaFoto == null) {
      _siberUyari("EKSİK KANIT", "Çıkan eski parça ve takılan yeni parçanın fotoğrafları ZORUNLUDUR.", dangerColor);
      return;
    }

    setState(() => _islemSuruyor = true);

    try {
      // 1. AI OEM Doğrulaması (Katalogda Var mı?)
      bool oemGecerliMi = await _torpidoServisi.oemKoduDogrula(_oemKodu!);
      
      if (!oemGecerliMi) {
        _siberUyari("SAHTE PARÇA TESPİTİ", "Okunan OEM kodu global katalogda bulunamadı. OtoDNA Mührü BASILAMAZ!", dangerColor);
        setState(() => _islemSuruyor = false);
        return;
      }

      // 2. Modeli Oluştur
      int garantiAy = int.tryParse(_garantiSuresiCtrl.text) ?? 12;
      DateTime bitis = DateTime.now().add(Duration(days: 30 * garantiAy));

      ParcaGarantiModel belge = ParcaGarantiModel(
        aracId: _aracIdCtrl.text.trim(),
        ustaUid: widget.ustaUid,
        firmaUnvani: widget.firmaUnvani,
        // Kuantum İstihbarat Ağı Adli Konum (Şimdilik Ustanın Profilinden Gelecek Varsayılan Değerler)
        countryId: "TR",
        regionId: "MARMARA",
        cityId: "İSTANBUL",
        districtId: "MASLAK",
        parcaAdi: _parcaAdiCtrl.text.trim(),
        oemKodu: _oemKodu!,
        benzersizSeriNo: _benzersizSeriNo!,
        irsaliyeFaturaNo: _irsaliyeFaturaNo!,
        aiGuvenSkoru: _aiGuvenSkoru ?? 0,
        adliProtokolKabulEdildi: _adliProtokolOnaylandi,
        degisimOncesiFoto: "eski_parca_url_mock.png",
        degisimSonrasiFoto: "yeni_parca_url_mock.png",
        garantiSuresiAy: garantiAy,
        gecerlilikBitisTarihi: bitis,
        otodnaMuhruBasildiMi: true,
        musteriOnayladiMi: _musteriOncedenTaradiMi,
        gorseliKimCekti: _musteriOncedenTaradiMi ? 'musteri' : 'usta',
        islemTarihi: DateTime.now(),
      );

      // 3. İki Taraflı Mühür Olarak Torpidoya Fırlat
      await _torpidoServisi.ikiTarafliMuhurFirlat(belge);

      setState(() {
        _muhurBasildi = true;
      });
      HapticFeedback.vibrate();
      _siberUyari("MÜHÜRLENDİ", "OtoDNA Garanti Mührü basıldı ve müşteri torpidosuna iletildi.", primaryTeal);

    } catch (e) {
      _siberUyari("AĞ ÇÖKTÜ", "Mühürleme işlemi sırasında hata oluştu.", dangerColor);
    } finally {
      setState(() => _islemSuruyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("🛡️ GARANTİ MÜHRÜ", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => context.pop()),
        ),
        body: _muhurBasildi ? _buildMuhurEkrani() : _buildKriminalForm(),
      ),
    );
  }

  Widget _buildKriminalForm() {
    return ListView(
      padding: EdgeInsets.all(24),
      physics: BouncingScrollPhysics(),
      children: [
        // Siber Garanti Uyarı Kalkanı
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryTeal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryTeal.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.handshake, color: primaryTeal, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _musteriOncedenTaradiMi 
                    ? "MÜŞTERİ ONAYLI İŞLEM: Müşteri takılacak parçayı önceden taradı. İşlemi onaylayarak Çift Taraflı Mührü tamamlayın."
                    : "MÜŞTERİ YOK: Tarama sorumluluğu sizde. İşlem sonrası müşteriye uzaktan onay bildirimi gidecek.",
                  style: TextStyle(color: textMain, fontSize: 11, height: 1.5, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: _musteriOncedenTaradiMi,
                onChanged: (val) {
                  setState(() {
                    _musteriOncedenTaradiMi = val;
                    if (val) {
                      // Test amaçlı müşteri taramış gibi verileri doldur
                      _oemKodu = "ORG-MUSTERI-101";
                      _benzersizSeriNo = "SN-MUSTERI-999";
                      _irsaliyeFaturaNo = "FTR-MUSTERI-01";
                      _aiGuvenSkoru = 99;
                    } else {
                      _oemKodu = null;
                    }
                  });
                },
                activeColor: primaryTeal,
                inactiveTrackColor: Colors.black12,
              )
            ],
          ),
        ),
        SizedBox(height: 24),

        // Veri Girişi
        _buildSiberTextField("Aracın Plakası / ID'si", Icons.directions_car, _aracIdCtrl),
        SizedBox(height: 16),
        _buildSiberTextField("Değişen Parça Adı (Örn: Triger Seti)", Icons.build, _parcaAdiCtrl),
        SizedBox(height: 16),
        
        // 🚨 OTONOM AI TARAMA KONSOLU
        Text("KUTU VE FATURA TARAMASI (YAPAY ZEKA)", style: TextStyle(color: textMuted, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        SizedBox(height: 12),
        
        if (_oemKodu == null) ...[
          // Tarama Yapılmamışsa Kamera Butonu
          InkWell(
            onTap: _adliProtokolOnaylandi ? _aiTaramaBaslat : () {
              _siberUyari("ONAY BEKLENİYOR", "Lütfen önce aşağıdaki hukuki metni okuyup onaylayın.", Colors.orange.shade700);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: _adliProtokolOnaylandi ? primaryTeal.withOpacity(0.05) : surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _adliProtokolOnaylandi ? primaryTeal.withOpacity(0.5) : Colors.black.withOpacity(0.05), width: 2),
                boxShadow: _adliProtokolOnaylandi ? [BoxShadow(color: primaryTeal.withOpacity(0.1), blurRadius: 15)] : [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.center_focus_strong, color: _adliProtokolOnaylandi ? primaryTeal : textMuted.withOpacity(0.5), size: 36),
                  SizedBox(height: 8),
                  Text("🤖 YAPAY ZEKA İLE KUTUYU VE FATURAYI TARA", style: TextStyle(color: _adliProtokolOnaylandi ? primaryTeal : textMuted, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                ],
              ),
            ),
          )
        ] else ...[
          // Tarama Yapılmışsa Kilitli Veriler
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryTeal.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock, color: primaryTeal, size: 16),
                    SizedBox(width: 8),
                    Text("AI TARAFINDAN KİLİTLENDİ", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
                Divider(color: Colors.white.withOpacity(0.05), height: 24),
                _buildKilitliVeriSatiri("OEM Kodu:", _oemKodu!),
                SizedBox(height: 8),
                _buildKilitliVeriSatiri("Tek Kullanımlık Seri No:", _benzersizSeriNo!),
                SizedBox(height: 8),
                _buildKilitliVeriSatiri("Fatura/İrsaliye No:", _irsaliyeFaturaNo!),
                SizedBox(height: 8),
                _buildKilitliVeriSatiri("Güven Skoru:", "%$_aiGuvenSkoru (Orijinal)"),
              ],
            ),
          )
        ],
        
        SizedBox(height: 24),
        _buildSiberTextField("Garanti Süresi (Ay)", Icons.date_range, _garantiSuresiCtrl, type: TextInputType.number),
        SizedBox(height: 32),

        // 📸 GÖRSEL KANIT ZORUNLULUĞU
        Text("DİJİTAL GÖRSEL KANITLAR (ZORUNLU)", style: TextStyle(color: textMuted, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildResimSeciciBox("Çıkan Eski Parça", _eskiParcaFoto, "eski")),
            SizedBox(width: 12),
            Expanded(child: _buildResimSeciciBox("Takılan Yeni Parça", _yeniParcaFoto, "yeni")),
          ],
        ),
        SizedBox(height: 40),

        // ⚖️ ADLİ PROTOKOL BEYANI
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dangerColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dangerColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Theme(
                data: Theme.of(context).copyWith(unselectedWidgetColor: textMuted.withOpacity(0.5)),
                child: Checkbox(
                  value: _adliProtokolOnaylandi,
                  activeColor: dangerColor,
                  checkColor: Colors.white,
                  onChanged: (val) {
                    setState(() => _adliProtokolOnaylandi = val ?? false);
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "DİKKAT: Bu sistemdeki veriler Adli Delil niteliğindedir. Olası kaza incelemelerinde hukuki sorumluluk işlemi onaylayan taraflara aittir. OtoDNA donanım ve görsel zafiyetlerinden sorumlu tutulamaz.",
                    style: TextStyle(color: dangerColor, fontSize: 10, height: 1.5, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 32),

        // Mühürleme Butonu
        SizedBox(
          height: 60,
          child: _islemSuruyor
              ? Center(child: CircularProgressIndicator(color: primaryTeal))
              : ElevatedButton.icon(
                  onPressed: _adliProtokolOnaylandi ? _garantiMuhruBas : () {
                    _siberUyari("ONAY BEKLENİYOR", "Lütfen önce yukarıdaki hukuki metni okuyup onaylayın.", Colors.orange.shade700);
                  },
                  icon: Icon(Icons.fingerprint, color: SiberTema.kuantumCyan, size: 28),
                  label: Text("OTODNA MÜHRÜNÜ BAS VE FIRLAT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _adliProtokolOnaylandi ? primaryTeal : Colors.black12,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0
                  ),
                ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSiberTextField(String hint, IconData icon, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        keyboardType: type,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(color: textMuted, fontSize: 12),
          prefixIcon: Icon(icon, color: primaryTeal, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
        ),
      ),
    );
  }

  Widget _buildResimSeciciBox(String baslik, File? resimFile, String tur) {
    return GestureDetector(
      onTap: () => _fotoSec(tur),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: resimFile != null ? primaryTeal : Colors.black.withOpacity(0.05), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)],
          image: resimFile != null ? DecorationImage(image: FileImage(resimFile), fit: BoxFit.cover) : null,
        ),
        child: resimFile == null 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: textMuted.withOpacity(0.5), size: 30),
                  SizedBox(height: 8),
                  Text(baslik, style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ],
              )
            : Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Icon(Icons.check_circle, color: primaryTeal, size: 40)),
              ),
      ),
    );
  }

  // ── KİLİTLİ VERİ GÖSTERİMİ ──
  Widget _buildKilitliVeriSatiri(String baslik, String deger) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(deger, style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      ],
    );
  }

  // ── 🎉 MÜHÜR BAŞARI EKRANI ──
  Widget _buildMuhurEkrani() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.shield, color: primaryTeal, size: 80),
          ),
          SizedBox(height: 32),
          Text("MÜHÜRLENDİ!", style: TextStyle(color: primaryTeal, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text("Parça garantisi dijital olarak mühürlendi ve müşterinin Dijital Torpidosuna ışınlandı. Ustanın onuru korunmuştur.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
          ),
          SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _aracIdCtrl.clear();
                _parcaAdiCtrl.clear();
                _oemKodu = null;
                _benzersizSeriNo = null;
                _irsaliyeFaturaNo = null;
                _eskiParcaFoto = null;
                _yeniParcaFoto = null;
                _adliProtokolOnaylandi = false;
                _musteriOncedenTaradiMi = false;
                _muhurBasildi = false;
              });
            },
            icon: Icon(Icons.refresh, color: primaryTeal),
            label: Text("YENİ İŞLEM BAŞLAT", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryTeal.withOpacity(0.5), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
          )
        ],
      ),
    );
  }
}

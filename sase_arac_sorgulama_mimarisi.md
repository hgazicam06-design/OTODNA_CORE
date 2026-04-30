# 🛡️ SİBER ŞASE VE ARAÇ SORGULAMA MİMARİSİ (FREEMIUM / PREMIUM UYGULAMA PLANI)

OtoDNA Karargahı'ndaki "Ortak Şase" üzerinden global araç sorgulama ve mühürleme modülünün mevcut dosyalarla (API ve eklentilerle birlikte) nasıl entegre edileceğinin detaylı teknik rehberidir.

---

## 1. MEVCUT EKLENTİ DURUMU (pubspec.yaml Analizi)
Sisteminizi incelediğimde, şase sorgulama işlemleri için gerekli olan **tüm ana eklentilerin zaten projeye kurulu olduğunu** tespit ettim. Dışarıdan ekstra bir paket eklememize gerek kalmadan mevcut mimariyi ateşleyebiliriz:
*   `http: ^1.2.2` (Global API bağlantıları için)
*   `google_mlkit_text_recognition: ^0.13.1` (Ruhsat veya camdaki şaseyi OCR ile okumak için)
*   `image_picker` ve `camera` (Kamerayı açmak için)

---

## 2. DOSYA DOSYA ENTEGRASYON HARİTASI

Mevcut dosya yapısına göre entegrasyon 3 ana koldan gerçekleştirilecektir:

### A. Dış Veri İstihbaratı: `lib/services/dis_ekspertiz_entegrasyon.dart`
*   `http` paketi import edilecek. Maket fonksiyon kaldırılarak tamamen ücretsiz ve resmi olan **NHTSA vPIC API**'sine bağlanacak.
*   Ayrıca dışarıdan gelen (ileride eklenecek) Tramer / Hasar durumu özet verileri de buradan geçecek.

### B. Otonom Pasaport Mührü: `lib/services/services/sase_sorgu_servisi.dart`
*   Yeni kayıt açılırken aracın markası ve modeli doğrudan API verileriyle kaydedilecek.

### C. Arayüz ve Siber Göz (OCR): `lib/screens/kullanici/sase_sorgu_merkezi.dart`
*   Ekrana **"SİBER GÖZ AKTİF ET (Kamera/Ruhsat Oku)"** butonu eklenecek ve ML Kit ile şase numarası taranacak.
*   Arayüz, aracın OtoDNA'da olup olmamasına göre 2'ye ayrılacak (Aşağıda detaylandırılmıştır).

---

## 3. OTODNA SİCİL RAPORU VE ÖDEME GEÇİDİ (FREEMIUM MODEL)

Sisteme şase girildiğinde kesinlikle boş sayfa gösterilmeyecektir. Strateji iki farklı duruma (Freemium/Premium) göre işleyecektir:

### DURUM 1: Araç OtoDNA Kayıtlarında YOKSA (Ücretsiz Temel Görünüm)
Eğer şase sorgulandıktan sonra aracın OtoDNA Kuantum Garaj geçmişi olmadığı tespit edilirse:
1.  **Dış API Künyesi:** (NHTSA'dan çekilen) Marka, Model, Yıl bilgileri net şekilde gösterilir.
2.  **Dış Kaynak Hasar Özeti:** Tramer/Ortak Havuz verilerinden temsili olarak "3 Adet Hasar Dosyası, 2 Kaza, Toplam Hasar: 14.500 TL" gibi bir özet basılır.
3.  **Uyarı:** Ekranda "Bu araç henüz OtoDNA güvencesine (Ekspertiz/Bakım) girmemiştir." uyarısı verilir. Bu ekran vatandaşa tamamen **ÜCRETSİZ** sunulur. Çıktı verilmez.

### DURUM 2: Araç OtoDNA Kayıtlarında VARSA (Premium Kilitli Rapor Ekranı)
Eğer araç OtoDNA ağına daha önce girdiyse (Ekspertiz, usta işlemi, DNA skoru oluştuysa):
1.  Ücretsiz ekranın altında **"OtoDNA Premium İstihbarat Radarı"** belirir.
2.  Ekranda aracın "DNA Skoru: 92/100", "Fotoğraf Sayısı: 14", "Karne Kaydı: Var", "Ekspertiz Onayı: Var" şeklinde kışkırtıcı başlıklar görülür ancak detaylar (değişen parça isimleri, fotoğraflar vs.) bulanık (blur) veya kilitli olarak gizlenir.
3.  **Ödeme Duvarı (Paywall):** Ekranda devasa bir buton belirir: `Detaylı OtoDNA Ekspertiz ve Sicil Raporunu İndir - 500 TL`.
4.  Kullanıcı ödeme yapar. Uygulama başarılı onayı alır almaz kilidi açar ve sistemdeki tüm verileri (ekspertiz raporu formatında) bir araya getirerek PDF oluşturur.

---

# 🛠️ 4. UYGULAMA DÜZENLEME ADIMLARI (KODLANACAK YAPI)

Bu yeni "Freemium / Premium" mimarinin kodlanması için yapılması gereken düzenlemeler:

### ADIM 1: Dış İstihbarat (`dis_ekspertiz_entegrasyon.dart`)
Sınıfa NHTSA bağlantısı ve dış veri mocklaması (şimdilik) eklenecek.
```dart
Future<Map<String, dynamic>> nhtsaVeDisVeriCek(String saseNo) async {
  // 1. Gerçek NHTSA İstihbaratı
  final url = Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValuesExtended/$saseNo?format=json');
  final response = await http.get(url);
  final decoded = jsonDecode(response.body);
  final sonuclar = decoded['Results'][0];

  return {
    'marka': sonuclar['Make'],
    'model': sonuclar['Model'],
    'yil': sonuclar['ModelYear'],
    // 2. Dış Hasar Özeti (Şimdilik temsili, ileride gerçek TRAMER'e bağlanacak)
    'dis_hasar_dosyasi': 2,
    'dis_kaza_sayisi': 1,
    'otodna_kayitli': false, // Varsayılan olarak OtoDNA'da yok
  };
}
```

### ADIM 2: Arayüz Ayrımı (`sase_sorgu_merkezi.dart`)
Ekranda aracın `otodna_kayitli` boolean değerine göre arayüz çatallanacak.
```dart
// Ekranda gösterilecek widget kurgusu
if (_bulunanVeri['otodna_kayitli'] == false) {
   // DURUM 1: Ücretsiz Dış Veri Ekranı
   return Column(
     children: [
       Text("Marka/Model: ${_bulunanVeri['marka']} ${_bulunanVeri['model']}"),
       Text("Dış Kaynak Hasar Dosyası: ${_bulunanVeri['dis_hasar_dosyasi']}"),
       Container(
         color: Colors.orangeAccent,
         child: Text("⚠️ Bu araç OtoDNA Kuantum Karargahına hiç girmemiştir. Detaylı OtoDNA Raporu mevcut değil."),
       )
     ]
   );
} else {
   // DURUM 2: OtoDNA Premium Ekranı
   return Column(
     children: [
       Text("DNA Skoru: ${_bulunanVeri['dna_skoru']}/100"),
       Text("Sistemdeki Fotoğraf Sayısı: ${_bulunanVeri['fotograf_sayisi']}"),
       // Kilitli İçerik ve Ödeme Butonu
       ElevatedButton.icon(
          icon: Icon(Icons.lock_open),
          label: Text("TÜM SİCİLİ VE EKSPERTİZ RAPORUNU İNDİR (500 ₺)"),
          onPressed: () => _odemeVeIndirmeBaslat(saseNo),
       )
     ]
   );
}
```

### ADIM 3: Ödeme ve PDF Çıktısı (Yeni Modül İşlevi)
Ödeme butonuna basıldığında tetiklenecek akış.
```dart
Future<void> _odemeVeIndirmeBaslat(String saseNo) async {
  // 1. Ödeme Geçidine Yönlendir (PayTR, iyzico veya Wallet)
  bool odemeBasarili = await PayoutService.odemeAl(miktar: 500.0, aciklama: "OtoDNA Sicil Raporu: $saseNo");
  
  if (odemeBasarili) {
     _plazaUyari("SİBER ONAY: Ödeme alındı. Rapor hazırlanıyor...");
     
     // 2. Ekspertiz benzeri tüm veriyi çek
     var detayliVeri = await FirebaseFirestore.instance.collection('araclar').doc(saseNo).get();
     
     // 3. PdfGeneratorService ile raporu oluştur ve paylaş
     await PdfGeneratorService.aracSicilRaporuOlustur(detayliVeri.data());
  } else {
     _plazaUyari("ÖDEME REDDEDİLDİ!", isError: true);
  }
}
```

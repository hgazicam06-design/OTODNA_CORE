# Ünal Bey İçin Geliştirme Rehberi: Siber Favori Motoru

Sayın Ünal Bey, OtoDNA Market ve OtoDNA Galeri içindeki "Favorileme" (Ürün, Firma, Araç, Galeri) işlemlerini merkezi bir yapıda yönetmek için **Siber Favori Motoru** mimarisini kuruyoruz. Bu sayede tüm favorileme işlemleri tek bir servisten yönetilecek ve kullanıcı profillerinde kolayca listelenecektir.

## 1. Firestore Veritabanı Mimarisi
Kullanıcıların favorilerini kendi dokümanları altında bir alt koleksiyon (sub-collection) olarak tutacağız.
**Yol:** `kullanicilar/{userId}/favoriler/{hedefId}`

Bir favori dokümanının (JSON) yapısı şu şekilde olacaktır:
```json
{
  "hedefId": "URUN_VEYA_FIRMA_ID",
  "tur": "urun",  // Alabileceği değerler: 'urun', 'firma', 'arac', 'galeri'
  "baslik": "Bosch Fren Balatası", // Gösterim kolaylığı için önbellek
  "gorsel": "https://...",
  "eklenmeTarihi": "2026-05-06T..."
}
```

---

## 2. Favori Servisinin Oluşturulması
Lütfen `lib/services/` klasörü altına **`favori_servisi.dart`** adında yeni bir dosya oluşturun ve aşağıdaki kodları yapıştırın.

**Dosya Yolu:** `lib/services/favori_servisi.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

/// ⭐️ SİBER FAVORİ MOTORU
/// OtoMarket (Ürün, Firma) ve OtoDNA Galeri (Araç, Galeri) içindeki 
/// tüm favorileme işlemlerini merkezi olarak yönetir.
class FavoriServisi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Favori Türleri (Sabitler)
  static const String TUR_URUN = 'urun';
  static const String TUR_FIRMA = 'firma';
  static const String TUR_ARAC = 'arac';
  static const String TUR_GALERI = 'galeri';

  /// Kullanıcının bir öğeyi favorilere eklemesi veya çıkarması (Toggle)
  static Future<bool> favoriToggle({
    required String hedefId,
    required String tur,
    required String baslik,
    String? gorsel,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      developer.log("🚨 SİBER HATA: Favoriye eklemek için giriş yapılmalı.");
      return false;
    }

    final docRef = _db.collection('kullanicilar').doc(user.uid).collection('favoriler').doc(hedefId);

    try {
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        // Zaten favorilerde var, o zaman ÇIKAR
        await docRef.delete();
        developer.log("⭐️ FAVORİDEN ÇIKARILDI: \$baslik (\$tur)");
        return false; // Artık favori değil
      } else {
        // Favorilerde yok, o zaman EKLE
        await docRef.set({
          'hedefId': hedefId,
          'tur': tur,
          'baslik': baslik,
          'gorsel': gorsel ?? '',
          'eklenmeTarihi': FieldValue.serverTimestamp(),
        });
        developer.log("⭐️ FAVORİYE EKLENDİ: \$baslik (\$tur)");
        return true; // Favoriye eklendi
      }
    } catch (e) {
      developer.log("💥 FAVORİ İŞLEMİ ÇÖKTÜ: \$e");
      return false;
    }
  }

  /// Bir öğenin kullanıcının favorilerinde olup olmadığını kontrol eder (Kalp ikonunu dolu/boş yapmak için)
  static Future<bool> favoriMi(String hedefId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final docSnap = await _db
          .collection('kullanicilar')
          .doc(user.uid)
          .collection('favoriler')
          .doc(hedefId)
          .get();
      return docSnap.exists;
    } catch (e) {
      return false;
    }
  }

  /// Kullanıcının tüm favorilerini getirir (Profil sayfasında listelemek için)
  static Stream<QuerySnapshot> favorileriGetir({String? filtreTur}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Giriş yapılmamış");

    Query query = _db.collection('kullanicilar').doc(user.uid).collection('favoriler');

    // Eğer sadece "arac" veya sadece "firma" favorilerini çekmek istersek:
    if (filtreTur != null) {
      query = query.where('tur', isEqualTo: filtreTur);
    }

    return query.orderBy('eklenmeTarihi', descending: true).snapshots();
  }
}
```

---

## 3. Arayüzlere (UI) Entegre Edilmesi
Ünal Bey, bu servisi UI tarafında şu şekilde kullanabilirsiniz:

### Örnek 1: İlan Detay Sayfasında (Kalp İkonuna Tıklayınca)
```dart
IconButton(
  icon: Icon(Icons.favorite), // Duruma göre Icons.favorite_border olabilir
  onPressed: () async {
    bool yeniDurum = await FavoriServisi.favoriToggle(
      hedefId: ilan.id,
      tur: FavoriServisi.TUR_ARAC, // Araç ilanı olduğu için
      baslik: ilan.arabaMarkaModel,
      gorsel: ilan.anaGorselUrl,
    );
    // State'i güncelle (setState ile kalbin rengini değiştir)
  },
)
```

### Örnek 2: Firma/Galeri Detay Sayfasında
```dart
ElevatedButton(
  child: Text("Firmayı Favoriye Al"),
  onPressed: () {
    FavoriServisi.favoriToggle(
      hedefId: firma.id,
      tur: FavoriServisi.TUR_FIRMA, // Market firması olduğu için
      baslik: firma.sirketAdi,
    );
  },
)
```

Bu merkezi yapı sayesinde, ileride kullanıcının "Siber Profil" ekranında favorilerini ayrı sekmelerde (Araçlarım, Ürünlerim, Takip Ettiğim Firmalar) rahatça listeleyebileceksiniz. Kolay gelsin!

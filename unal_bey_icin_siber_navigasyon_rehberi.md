# Ünal Bey İçin Geliştirme Rehberi: Google Destekli Özelleştirilmiş OtoDNA Siber Navigasyonu

Sayın Ünal Bey, navigasyon altyapımızı küresel çapta (Türkiye ve Yurt Dışı) en yüksek stabiliteyle çalıştırmak ve radarları/istasyonları canlı çekmek için **Google Maps SDK** altyapısına geçiş yapıyoruz. 

Ancak bu standart bir Google Haritalar görünümü OLMAYACAK. Uygulama içi (In-App) haritamız, **OtoDNA'nın kendine has HUD (Head-Up Display)** tasarımına sahip olacak.

---

## 1. Siber Harita Katmanları ve Özel Semboller (Custom Markers)
Google veritabanındaki standart mekanlar (benzinlikler, sıradan tamirciler, hastaneler vb.) Google'ın kendi ikonlarıyla görünürken, **OtoDNA Sistemine Kayıtlı Bayiler ve Aktif Revizyon Garajları** haritada devasa ve özel sembollerle parlayacak.

### A. İşaretçi (Marker) Hiyerarşisi
*   **Sıradan İstasyonlar (Google Places):** Standart harita ikonlarıyla (küçük ve sönük) görünür.
*   **OtoDNA Yetkili Bayileri:** Harita üzerinde 3D tasarımlı, etrafında hale (glow) yanan **"OtoDNA Altın Kalkan"** ikonuyla görünür. Kullanıcı haritayı kaydırdıkça bu bayiler diğer mekanların arasından "VIP" olarak sıyrılır.
*   **Elektrikli Şarj & Radar Noktaları:** Harita üzerinde Karargahın belirlediği özel Siber Radar pingleri ile işaretlenir.

---

## 2. Kurulum ve Google Maps SDK Entegrasyonu
Lütfen `pubspec.yaml` dosyanıza aşağıdaki paketleri ekleyin:
```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  flutter_polyline_points: ^2.0.0
  geolocator: ^11.0.0
```

*(Not: AndroidManifest.xml ve AppDelegate.swift içine Google Cloud Console'dan alacağımız Google Maps API anahtarını eklememiz gerekmektedir.)*

---

## 3. OtoDNA Karanlık Tema (Siber HUD Map Style)
Google haritasının standart açık renkli görünümünü kapatıp, harita zeminine tamamen OtoDNA'ya has "Siber Karanlık Tema" (Dark Mode Overlay) giydireceğiz.

```dart
// Harita yüklendiğinde Google Maps Controller'a bu JSON stili basılacak:
const String otoDnaMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1A1A1D"}] // Siyah/Kurşuni Zemin
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#C5A059"}] // OtoDNA Gold Rengi Sokak İsimleri
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#333333"}] // Asfalt Rengi
  }
]
''';
```

---

## 4. Özel OtoDNA Bayi Sembolü Çizimi
Google Maps üzerinde standart kırmızı pin yerine, kendi tasarımımız olan `otodna_kalkan_marker.png` ikonunu haritaya basacağız. Bu sayede OtoDNA bayileri haritada mücevher gibi parlayacak.

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getOtoDnaMarker() async {
  return await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(64, 64)), // Normalden daha büyük
    'assets/images/otodna_kalkan_marker.png', // Özel bayi ikonumuz
  );
}

// Marker oluştururken:
Marker(
  markerId: MarkerId('bayi_1'),
  position: LatLng(41.1126, 29.0213),
  icon: customOtoDnaMarker, // Farklı ve OtoDNA'ya has sembol!
  infoWindow: InfoWindow(title: "OtoDNA Yetkili Siber Garaj"),
)
```

---

## 5. Küresel (Yurt Dışı) Radar ve Uyarı Sistemi
Google Directions API sayesinde rota çizildiğinde, yol üzerindeki hız kameraları, EDS noktaları ve dinlenme tesisleri Karargah algoritmasından geçirilir. 
* Eğer kullanıcı hız limitini aşıyorsa veya ileride bir tuzak radar varsa, Google'dan bağımsız olarak ekranın üstünde **"OtoDNA Siber Uyarı: 1KM Sonra Radar"** HUD bildirimi (Kırmızı Flaş) çakar.
* Bu otonom sistem, dünyanın neresinde olursanız olun (Türkiye veya Yurt Dışı) kendi özel navigasyonumuz gibi çalışarak sizi korur.

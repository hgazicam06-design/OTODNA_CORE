# Ünal Bey İçin Geliştirme Rehberi: Ücretsiz Siber Navigasyon Motoru

Sayın Ünal Bey, Google Maps API anahtarı (ve kredi kartı zorunluluğu) süreçlerini atlamak ve platformu tamamen bağımsız hale getirmek için **Sıfır Maliyetli Siber Navigasyon** (OpenStreetMap + OSRM) stratejisine geçiş yapıyoruz. 

Aşağıdaki adımları uygulayarak projeye hiçbir API anahtarı gerekmeden harita ve rota çizme özelliğini entegre edebilirsiniz.

## 1. Gerekli Kütüphanelerin Eklenmesi
Lütfen `pubspec.yaml` dosyanıza aşağıdaki paketleri ekleyin ve `flutter pub get` çalıştırın:
```yaml
dependencies:
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  http: ^1.2.2
```

*(Not: AndroidManifest veya AppDelegate içinde herhangi bir key ayarı yapmanıza GEREK YOKTUR. Doğrudan çalışır.)*

---

## 2. Siber Harita ve Rota Servisi
Bu servis, ücretsiz OSRM (Open Source Routing Machine) altyapısını kullanarak A noktasından B noktasına çizilecek rotanın koordinatlarını hesaplar.

**Dosya Yolu:** `lib/services/siber_navigasyon_servisi.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;

class SiberNavigasyonServisi {
  /// OSRM Public API (Tamamen Ücretsiz)
  static const String _osrmBaseUrl = "http://router.project-osrm.org/route/v1/driving";

  /// İki nokta arasındaki rotayı (çizgi koordinatlarını) getirir.
  static Future<List<LatLng>> rotaCiz(LatLng baslangic, LatLng hedef) async {
    developer.log("🗺️ SİBER NAVİGASYON: Rota hesaplanıyor...");
    
    // OSRM formatı: lon,lat;lon,lat
    final String url = "\$_osrmBaseUrl/\${baslangic.longitude},\${baslangic.latitude};\${hedef.longitude},\${hedef.latitude}?geometries=geojson";

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry']['coordinates'] as List;
          
          // OSRM [lon, lat] döner, biz [lat, lon] (LatLng) formatına çeviriyoruz
          List<LatLng> polylinePoints = geometry.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
          
          developer.log("✅ SİBER NAVİGASYON: Rota başarıyla çizildi.");
          return polylinePoints;
        }
      }
      return [];
    } catch (e) {
      developer.log("💥 SİBER NAVİGASYON ÇÖKTÜ: \$e");
      return [];
    }
  }
}
```

---

## 3. Harita Arayüzü (Siber Radar Ekranı)
Aşağıdaki kod parçacığını, kullanıcıların veya bayilerin haritayı göreceği ekrana (örneğin `SiberRadarScreen`) doğrudan yapıştırabilirsiniz.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SiberRadarScreen extends StatefulWidget {
  @override
  _SiberRadarScreenState createState() => _SiberRadarScreenState();
}

class _SiberRadarScreenState extends State<SiberRadarScreen> {
  // Örnek: Başlangıç (Maslak) - Hedef (Kadıköy)
  final LatLng baslangicKonumu = LatLng(41.1126, 29.0213);
  final LatLng hedefKonumu = LatLng(40.9904, 29.0292);
  
  List<LatLng> _cizilecekRota = [];

  @override
  void initState() {
    super.initState();
    _rotayiHazirla();
  }

  void _rotayiHazirla() async {
    // Yukarıda oluşturduğumuz servisten rotayı çek
    // final rota = await SiberNavigasyonServisi.rotaCiz(baslangicKonumu, hedefKonumu);
    // setState(() { _cizilecekRota = rota; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Siber Radar (Ağ Bağlantısı Aktif)"),
        backgroundColor: Colors.black,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: baslangicKonumu,
          initialZoom: 11.0,
        ),
        children: [
          // 1. Zemin (Karanlık Tema OpenStreetMap)
          TileLayer(
            urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
            subdomains: const ['a', 'b', 'c', 'd'],
          ),
          
          // 2. Rota Çizgisi (Polyline)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _cizilecekRota,
                strokeWidth: 4.0,
                color: Colors.amberAccent, // Siber Altın Rengi
              ),
            ],
          ),
          
          // 3. İşaretçiler (Bayi ve Araç Konumu)
          MarkerLayer(
            markers: [
              Marker(
                point: baslangicKonumu,
                width: 40,
                height: 40,
                child: Icon(Icons.my_location, color: Colors.blueAccent, size: 30),
              ),
              Marker(
                point: hedefKonumu,
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, color: Colors.redAccent, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

> **Not:** Ünal Bey, bu kodda kullanılan harita zemini (TileLayer) **CartoDB Dark Matter** temasıdır. Google Maps kullanmadan uygulamaya o aradığımız "Siber/Hacker" karanlık estetiğini ve altın sarısı rota çizimini bedavaya verecektir.

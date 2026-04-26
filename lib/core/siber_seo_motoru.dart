import 'package:seo/seo.dart';
import 'package:flutter/material.dart';

// 🚀 SİBER SEO MOTORU
// Bu motor Google ve diğer arama motorları için Kuantum etiketleme algoritmasıdır.
// Flutter Web tarafında HTML meta tag'lerini basar ve Firestore için etiket üretir.

class SiberSeoMotoru {
  
  // 1. OTONOM ETİKET JENERATÖRÜ (Firestore Aramaları İçin)
  // İlan başlığı ve açıklamasından "bmw", "f30", "far", "çıkma" gibi etiketler üretir.
  static List<String> uretEtiketler(String baslik, String aciklama, String kategori) {
    List<String> etiketler = [];
    
    // Kelimeleri parçala, küçük harfe çevir
    String hamMetin = "$baslik $aciklama $kategori".toLowerCase();
    
    // Gereksiz noktalama işaretlerini temizle
    hamMetin = hamMetin.replaceAll(RegExp(r'[^\w\sğüşıöç]'), ' ');
    
    // Boşluklardan böl
    List<String> kelimeler = hamMetin.split(' ');
    
    // Siber Filtre: 2 harften büyük anlamlı kelimeleri al
    for (String kelime in kelimeler) {
      if (kelime.trim().length > 2) {
        etiketler.add(kelime.trim());
      }
    }
    
    // Kuantum Çarpanı: Tam başlığı da ekle ki direkt aramalarda çıksın
    etiketler.add(baslik.toLowerCase());
    
    // Tekrarlayan kelimeleri sil
    return etiketler.toSet().toList();
  }

  // 2. WEB SEO ETİKETLEYİCİ (Seo.Head için)
  // Ürün detay sayfasını sarmalayarak Google botlarına sinyal gönderir
  static Widget seoKalkaniIleSar({
    required Widget child,
    required String baslik,
    required String aciklama,
    required String resimUrl,
  }) {
    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: '$baslik - OtoDNA Kuantum Ağı'),
        MetaTag(name: 'description', content: aciklama),
        MetaTag(name: 'image', content: resimUrl),
        MetaTag(name: 'keywords', content: uretEtiketler(baslik, aciklama, "Oto Yedek Parça").join(', ')),
        MetaTag(name: 'og:title', content: baslik),
        MetaTag(name: 'og:description', content: aciklama),
        MetaTag(name: 'og:image', content: resimUrl),
      ],
      child: child,
    );
  }
}

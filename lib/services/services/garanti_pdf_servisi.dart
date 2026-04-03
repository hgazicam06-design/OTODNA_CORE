class GarantiKalemi {
  final String parcaAdi;
  final String garantiSuresi; // Örn: "10.000 KM / 6 Ay" veya "Yok"
  final bool kapsamDahilinde;

  GarantiKalemi(this.parcaAdi, this.garantiSuresi, this.kapsamDahilinde);
}

class GarantiBelgesiHazirlayici {
  
  // Servis dökümanlarından gelen liste (Örnek Veritabanı)
  List<GarantiKalemi> kalemleriOlustur(List<String> secilenParcalar) {
    return secilenParcalar.map((parca) {
      if (parca.contains("Balata")) {
        return GarantiKalemi(parca, "10.000 KM", true);
      } else if (parca.contains("Ampul") || parca.contains("Silecek")) {
        return GarantiKalemi(parca, "Garanti Yok (Sarf Malzeme)", false);
      } else if (parca.contains("Amortisör")) {
        return GarantiKalemi(parca, "20.000 KM / 1 Yıl", true);
      }
      return GarantiKalemi(parca, "Standart 6 Ay", true);
    }).toList();
  }

  void pdfCiktiAl(List<GarantiKalemi> liste) {
    print("------------------------------------------");
    print("🛡️ OTODNA RESMİ GARANTİ BELGESİ (MÜHÜRLÜ)");
    print("------------------------------------------");
    for (var kalem in liste) {
      String durum = kalem.kapsamDahilinde ? "[✅ GARANTİLİ]" : "[❌ KAPSAM DIŞI]";
      print("${kalem.parcaAdi} : ${kalem.garantiSuresi} $durum");
    }
    print("\n📜 GARANTİ ŞARTLARI:");
    print("1. Hatalı kullanım ve ağır arazi şartları garantiyi geçersiz kılar.");
    print("2. OtoDNA mühürü olmayan belgeler geçersizdir.");
    print("------------------------------------------");
    print("QR KOD: [MÜHÜRLÜ_DOKUMAN_VERIFY]");
  }
}
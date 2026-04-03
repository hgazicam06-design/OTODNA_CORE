import 'package:flutter/material.dart';

class AracSecimMotoru {
  // SİBER HUB SİMÜLASYONU (İleride Firebase veya CarQuery API'den çekilecek)
  static final Map<String, dynamic> _hubVeritabani = {
    "Audi": {
      "A4": {
        "2016 - 2020 (B9 Kasa)": ["2.0 TDI 190hp", "1.4 TFSI 150hp"],
        "2008 - 2015 (B8 Kasa)": ["2.0 TDI 143hp", "1.8 TFSI 160hp"]
      },
      "A6": {
        "2018 - 2024 (C8 Kasa)": ["2.0 TDI 204hp", "3.0 TDI 286hp Quattro"]
      }
    },
    "Volkswagen": {
      "Golf": {
        "2012 - 2020 (Mk7 Kasa)": ["1.6 TDI 110hp DSG", "1.4 TSI 125hp", "1.2 TSI 110hp"],
        "2020 - 2024 (Mk8 Kasa)": ["1.0 eTSI 110hp", "1.5 eTSI 150hp"]
      },
      "Passat": {
        "2015 - 2023 (B8 Kasa)": ["1.6 TDI 120hp", "1.5 TSI 150hp", "2.0 TDI 190hp"]
      }
    },
    "BMW": {
      "3 Serisi": {
        "2012 - 2019 (F30 Kasa)": ["320i ED 170hp", "316i 136hp", "320d 190hp"],
        "2019 - 2024 (G20 Kasa)": ["320i 170hp", "330i 258hp xDrive"]
      },
      "5 Serisi": {
        "2017 - 2023 (G30 Kasa)": ["520i 170hp", "520d 190hp xDrive"]
      }
    },
    "Renault": {
      "Megane": {
        "2016 - 2022 (Megane 4)": ["1.5 dCi 110hp EDC", "1.3 TCe 140hp"]
      },
      "Clio": {
        "2019 - 2024 (Clio 5)": ["1.0 TCe 100hp X-Tronic", "1.5 Blue dCi 85hp"]
      }
    }
  };

  // 🚀 STATİK ÇAĞIRICI (Her yerden tek satırla çağrılır)
  static Future<Map<String, String>?> secimiBaslat(BuildContext context) async {
    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const _KuantumSecimEkrani();
      },
    );
  }
}

// 🧠 BOTTOM SHEET İÇİNDEKİ CANLI MOTOR
class _KuantumSecimEkrani extends StatefulWidget {
  const _KuantumSecimEkrani();

  @override
  State<_KuantumSecimEkrani> createState() => _KuantumSecimEkraniState();
}

class _KuantumSecimEkraniState extends State<_KuantumSecimEkrani> {
  int _secimAdimi = 0; // 0: Marka, 1: Model, 2: Kasa/Yıl, 3: Motor

  String _secilenMarka = "";
  String _secilenModel = "";
  String _secilenKasa = "";
  String _secilenMotor = "";

  List<String> _guncelListe = [];
  String _baslik = "Marka Seçiniz";

  @override
  void initState() {
    super.initState();
    _guncelListe = AracSecimMotoru._hubVeritabani.keys.toList();
    _guncelListe.sort(); // Alfabetik diz
  }

  void _adimIleri(String secim) {
    setState(() {
      if (_secimAdimi == 0) {
        _secilenMarka = secim;
        _guncelListe = (AracSecimMotoru._hubVeritabani[_secilenMarka] as Map).keys.toList();
        _baslik = "$_secilenMarka - Model Seçiniz";
        _secimAdimi++;
      }
      else if (_secimAdimi == 1) {
        _secilenModel = secim;
        _guncelListe = (AracSecimMotoru._hubVeritabani[_secilenMarka][_secilenModel] as Map).keys.toList();
        _baslik = "$_secilenModel - Kasa/Yıl Seçiniz";
        _secimAdimi++;
      }
      else if (_secimAdimi == 2) {
        _secilenKasa = secim;
        _guncelListe = List<String>.from(AracSecimMotoru._hubVeritabani[_secilenMarka][_secilenModel][_secilenKasa]);
        _baslik = "Motor ve Donanım Seçiniz";
        _secimAdimi++;
      }
      else if (_secimAdimi == 3) {
        _secilenMotor = secim;
        // İŞLEM TAMAM! Veriyi paketle ve ekranı kapatarak geri gönder.
        Navigator.pop(context, {
          "marka": _secilenMarka,
          "model": _secilenModel,
          "kasa_yil": _secilenKasa,
          "motor": _secilenMotor,
          "tam_isim": "$_secilenMarka $_secilenModel $_secilenKasa - $_secilenMotor"
        });
      }
      _guncelListe.sort();
    });
  }

  void _adimGeri() {
    setState(() {
      if (_secimAdimi == 3) {
        _secimAdimi = 2;
        _guncelListe = (AracSecimMotoru._hubVeritabani[_secilenMarka][_secilenModel] as Map).keys.toList();
        _baslik = "$_secilenModel - Kasa/Yıl Seçiniz";
      } else if (_secimAdimi == 2) {
        _secimAdimi = 1;
        _guncelListe = (AracSecimMotoru._hubVeritabani[_secilenMarka] as Map).keys.toList();
        _baslik = "$_secilenMarka - Model Seçiniz";
      } else if (_secimAdimi == 1) {
        _secimAdimi = 0;
        _guncelListe = AracSecimMotoru._hubVeritabani.keys.toList();
        _baslik = "Marka Seçiniz";
      }
      _guncelListe.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF00FFC2), width: 2))
      ),
      child: Column(
        children: [
          // Üst Başlık ve Geri Butonu
          Row(
            children: [
              if (_secimAdimi > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00FFC2)),
                  onPressed: _adimGeri,
                ),
              Expanded(
                  child: Text(
                      _baslik,
                      textAlign: _secimAdimi == 0 ? TextAlign.center : TextAlign.left,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  )
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const Divider(color: Colors.white24, height: 24),

          // Arama Çubuğu (Hızlı Filtreleme İçin)
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Listede Ara...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00FFC2)),
              filled: true, fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              // TODO: İleride filtreleme eklenebilir
            },
          ),
          const SizedBox(height: 16),

          // Seçim Listesi (Şelale Akışı)
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _guncelListe.length,
              itemBuilder: (context, index) {
                String eleman = _guncelListe[index];
                return InkWell(
                  onTap: () => _adimIleri(eleman),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(eleman, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                        Icon(
                            _secimAdimi == 3 ? Icons.check_circle : Icons.chevron_right,
                            color: _secimAdimi == 3 ? const Color(0xFF00FFC2) : Colors.white38
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
# -*- coding: utf-8 -*-
"""
OtoDNA Randevu ve Cayma Bedeli Güvenlik Sistemi
Prensip: Boş Randevu Yok, Emeğin Karşılığı Var.
"""

class RandevuSistemi:
    def __init__(self):
        self.kapora_tutari = 200.00  # Standart Randevu Sabitleme Bedeli
        self.otodna_kesinti = 100.00 # Müşteri gelmezse bizim işletim bedelimiz
        self.usta_tazminat = 100.00  # Müşteri gelmezse ustaya ödenen "bekleme" bedeli

    def randevu_olustur(self, musteri_id, usta_id, tarih):
        # Para önce OtoDNA Havuzuna düşer
        return {
            "durum": "HAVUZDA",
            "mesaj": f"{self.kapora_tutari} TL kapora alındı. Randevu rezerve edildi.",
            "onay_kodu": "DNA-789" # Müşteri dükkana gidince ustaya verecek
        }

    def randevu_sonuclandir(self, durum):
        if durum == "GELDI":
            # 200 TL, toplam işçilik ücretinden düşülür.
            return "İşlem başarılı. Kapora işçilikten düşüldü."
        
        elif durum == "GELMEDI":
            # Para iade edilmez, bölüştürülür.
            print(f"CEZA KESİLDİ: {self.otodna_kesinti} TL OtoDNA'ya, {self.usta_tazminat} TL Ustaya aktarıldı.")
            return "Müşteri gelmediği için kapora yakıldı."

# TEST: Müşteri randevuya gelmediğinde ne oluyor?
sistem = RandevuSistemi()
print(sistem.randevu_sonuclandir("GELMEDI"))
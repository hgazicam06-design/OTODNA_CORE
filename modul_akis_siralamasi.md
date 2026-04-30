# 🦅 OTODNA SİBER KARARGAH: MODÜL ÇALIŞMA SIRALAMASI VE YAŞAM DÖNGÜSÜ

Bu belge, OtoDNA ekosistemine giren bir kullanıcının ve aracın Karargah içindeki yolculuğunu (işlem sırasını) adım adım ve geniş bir perspektifle açıklar. Modüller arası geçişler "Kuantum Zinciri" kuralına göre sıralanmıştır.

<br><br><br>

---

## 🛡️ 1. AŞAMA: SİBER ZIRH VE GÜVENLİK KAPISI (Auth Modülü)
**Bir kullanıcının Karargaha adım attığı ilk ve zorunlu aşamadır.**

*   **KVKK ve Hukuki Onay:** Kullanıcı sisteme girerken E-Devlet ciddiyetinde KVKK ve Kullanım Sözleşmesi onay ekranıyla karşılaşır (`otodna_auth_gate.dart`). Onay vermeyen kişi içeri giremez.
*   **Rol Ataması:** Sistem giren kişinin "Sivil Müşteri" mi yoksa "VIP Bayi" mi olduğunu tarar.
*   **Karaliste (Blacklist) Tarayıcısı:** Firebase üzerinden anlık olarak kişinin sicili taranır. Puanı düşükse veya kara listedeyse kapılar kilitlenir.

<br><br><br>

---

## 🚙 2. AŞAMA: ARAÇ KAYIT VE KİMLİK OLUŞTURMA (Araç Kayıt Terminali)
**Sisteme giren kullanıcının, aracını Karargah veri tabanına mühürlediği aşamadır.**

*   **Şelale Seçim Motoru:** Kullanıcı Marka > Model > Yıl > Kasa > Motor bilgilerini seçer. Asla elle giriş yapılmaz.
*   **Siber Göz (OCR Ruhsat Tarayıcı):** Şasi veya plaka bilgisi kamerayla okunur. I, O, Q harf karmaşaları otonom düzeltilir.
*   **DNA Puanı Başlangıcı:** Araç Karargaha girdiği an "100/100 DNA Skoru" ile doğar. Artık araç OtoDNA güvencesindedir.

<br><br><br>

---

## 🛠️ 3. AŞAMA: KUANTUM GARAJ VE ÇİFT YÖNLÜ MÜHÜRLEME (Servis/Ekspertiz Modülü)
**Araca işlem (bakım, parça değişimi veya ekspertiz) yapıldığı aşamadır.**

*   **Zaman Damgalı Kanıt:** Usta, değişen parçanın fotoğrafını galeriden veya kameradan yükler.
*   **İki Taraflı Onay:** İşlem bayinin ekranına düşer. Bayi "Siber Onay" verince işlem rapora işlenir.
*   **2 Saatlik Çelik Mühür:** Onaydan sonra 2 saatlik geri sayım (Grace Period) başlar. 2 saat dolduğunda Firebase kuralları (`firestore.rules`) devreye girer; rapor kilitlenir, bir daha asla silinemez veya değiştirilemez.
*   **Kripto QR Çıktısı:** İşlem bitiminde PDF belgesine "OtoDNA Garantisi" adı altında okutulabilir QR mühür basılır.

<br><br><br>

---

## 🛒 4. AŞAMA: OTOMARKET VE E-TİCARET (Yedek Parça Modülü)
**Ustanın veya Müşterinin aracı için parça sipariş ettiği, Trendyol mimarisine sahip aşamadır.**

*   **Görsel İskelet (Platinum Plaza):** Fildişi Sedef arka plan ve Metal Gold fontlarla süslü lüks vitrin ekranı. Üstte arama çubuğu ve bayi Hikayeleri (Stories) bulunur.
*   **Buy Box Rekabeti:** Aynı fren balatasını satanlar arasında en uygun fiyatlı olan, "Sepete Ekle" butonunun sahibi olur.
*   **12% Finans Motoru:** Parça satıldığı an Karargah otonom olarak %10 Kâr + %2 Vergi (%12) komisyon keser.
*   **Stok Kalkanı:** İşlem mühürlendiği an (3. Aşama) parça pazar yerinden anında `-1` olarak düşülür.

<br><br><br>

---

## 🚘 5. AŞAMA: OTOGALERİ VE ARAÇ SATIŞ VİTRİNİ (Araç Market Modülü)
**Bakımları yapılmış, DNA skoru oluşmuş aracın güvenle satışa çıktığı, Sahibinden.com mimarisine sahip aşamadır.**

*   **Zorunlu Veri Kalkanı:** Şasi/Plaka, KM ve Hasar bilgisi girilmeden ilan AÇILAMAZ. Temsili (1 TL) sahte fiyatlar yapay zeka tarafından reddedilir.
*   **DNA Filigranı:** Vitrindeki aracın kapak fotoğrafının tam üstüne devasa bir "DNA Skoru (Örn: 92/100)" rozeti basılır.
*   **Şeffaflık:** Her bayi vitrine kendi adıyla çıkar, iade ve garanti sorumluluğu tamamen işlemi/satışı yapan bayiye aittir. OtoDNA sorumluluk almaz.

<br><br><br>

---

## 🚨 6. AŞAMA: S.O.S VE GÜVENLİK RADARI (Günlük Yaşam Modülü)
**Satışı yapılmış aracın trafikteki güvenliğini sağlayan sivil iletişim aşamasıdır.**

*   **Siber Göz (Sivil Tarama):** Vatandaş, hatalı park etmiş aracın camındaki Kripto QR kodunu okutur.
*   **Anonim Bildirim:** Karşı tarafın ismi (G*** A***) maskelenerek araç sahibine "Hatalı Park" veya "Cam Açık" şeklinde anında FCM (Push) S.O.S sinyali fırlatılır.

<br><br><br>

---
*Bu sıralama, OtoDNA sisteminin siber anayasasına ve operasyon mantığına göre Kuantum Motoru tarafından otonom olarak hizalanmıştır.*

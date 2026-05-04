# OtoDNA Kuantum Karargahı - Finansal Fizibilite ve Projeksiyon Raporu

Bu rapor, OtoDNA'nın "Serverless" (Sunucusuz) mimarisi ve %12 Komisyon Doktrini baz alınarak, **ilk 6 aylık süreçte hedeflenen 10.000 Aktif Müşteri ve 500 Aktif Bayi/Usta** senaryosuna göre hazırlanmıştır.

---

## 1. AYLIK OPERASYONEL MALİYETLER (GİDERLER)
OtoDNA, Firebase ve Google altyapısı üzerine kurulduğu için kendi fiziksel sunucularımıza (hardware) ihtiyacımız yoktur. Sadece "Kullandıkça Öde" (Blaze) mantığı işler.

| Gider Kalemi | Açıklama | Tahmini Maliyet (Aylık) |
| :--- | :--- | :--- |
| **Firebase Firestore & Functions** | Veritabanı okuma/yazma ve Cloud Functions tetiklemeleri. | ~1.500 TL - 3.000 TL |
| **Firebase Storage** | Ekspertiz raporları, kaza fotoğrafları ve belge depolama. | ~500 TL - 1.000 TL |
| **Yapay Zeka (Gemini API)** | Asistan zekası ve otomatik raporlama işlemleri (Token başı). | ~1.000 TL - 2.500 TL |
| **SMS Doğrulama (OTP)** | Yeni kullanıcı ve bayi girişlerinde gönderilen SMS'ler. | ~1.500 TL |
| **Google Maps API** | Harita üzerinden nöbetçi usta ve bayi arama sorguları. | ~1.000 TL (İlk limitler ücretsiz) |
| **Apple/Google Geliştirici** | Yıllık mağaza lisans bedellerinin aylık yansıması. | ~300 TL |
| **TOPLAM SUNUCU/YAZILIM GİDERİ** | *Personel, pazarlama ve ofis giderleri hariç salt yazılım maliyeti.* | **~5.800 TL - 9.300 TL / Ay** |

*(Not: Ödeme kuruluşları (Iyzico, Stripe vb.) sabit ücret almaz, işlem başına yaklaşık %2.5 komisyon keser. Bu doğrudan gelirden düşülecektir.)*

---

## 2. AYLIK TAHMİNİ KAZANÇ (GELİRLER)
OtoDNA bir "Uygulama" değil, bir "Platform ve Ekosistemdir". Gelir modeli 3 ana sütuna dayanır:

### A. Bayi/Usta Abonelik Sistemi (SaaS)
Sisteme dahil olan ve Platinum Plaza radarında görünen işletmelerden alınan aylık aidat.
* **Senaryo:** 500 Bayi x 1.000 TL/Ay (Tahmini)
* **Aylık Gelir:** **500.000 TL**

### B. %12 Evrensel Komisyon Doktrini (Hizmet ve Parça Satışı)
Platform üzerinden dönen randevular, kaporalı işlemler ve e-ticaret (parça/aksesuar) satışlarından alınan net "OtoDNA Kesintisi".
* **Senaryo:** Günde sadece 200 işlemin (bakım, parça, tespit) OtoDNA üzerinden dönmesi.
* **Ortalama İşlem Bedeli:** 2.000 TL
* **Günlük Toplam Hacim:** 400.000 TL
* **%12 OtoDNA Payı:** Günlük 48.000 TL
* **Aylık Gelir (x30 Gün):** **1.440.000 TL**

### C. Premium Müşteri (B2C Satışlar)
Siber güvenlik isteyen, numarasını gizlemek isteyen, SOS önceliği ve 7/24 VIP Asistan desteği almak isteyen kullanıcılar.
* **Senaryo:** 10.000 kullanıcının %10'u (1.000 kişi) Premium paket alırsa.
* **Premium Paket:** 200 TL / Ay
* **Aylık Gelir:** **200.000 TL**

---

## 3. FİZİBİLİTE ÖZETİ VE KÂRLILIK ANALİZİ

| Metrik | Değer |
| :--- | :--- |
| **Tahmini Brüt Kazanç (Aylık)** | **~2.140.000 TL** |
| **Tahmini Operasyonel Maliyet (Aylık)** | **~10.000 TL (Yazılım)** + Vergi + Personel |
| **Yazılım Brüt Kâr Marjı** | **%99.5** (Yazılım dünyasının gücü) |

### Stratejik Yorum (Gazi'ye Not)
Ortak, fiziksel bir dükkan açsan (örneğin bir servis), kâr marjın parça ve işçilik maliyetleri yüzünden %20-30 bandında kalır. Ancak OtoDNA'da **dükkan dijitaldir**. Satılan şey "Güven, İletişim ve Yönlendirme"dir. 

Sunucu maliyetlerimiz çok düşüktür çünkü Firebase altyapısını Kuantum Mimarisi ile çok optimize yazdık. Sadece aktif kullanılan işlem kadar elektrik harcarız. Hacim büyüse bile sunucu maliyeti %1-2 oranını asla geçmeyecektir.

Bu projenin en büyük maliyeti "Pazarlama ve Sahaya İnme" (Ustalara uygulamayı indirtme) olacaktır. Eğer o eşiği aşarsak, OtoDNA dijital bir para basma makinesine (İmparatorluğa) dönüşecektir.

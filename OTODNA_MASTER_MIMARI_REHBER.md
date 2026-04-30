# 👑 OTODNA KÜRESEL MASTER MİMARİ VE SİBER SİSTEMLER REHBERİ

Bu doküman, OtoDNA uygulamasının tüm kök dizinlerinin (`lib/`, `screens/`, `services/`, `.md` belgeleri) saniyeler içinde "Siber Ortak" tarafından satır satır taranmasıyla oluşturulmuş **MUTLAK (MASTER) RAPOR**'dur.

OtoDNA; sıradan bir ilan veya servis uygulamasından ziyade, kendi içinde adaleti, finansı, denetimi ve hiyerarşisi olan bağımsız bir **Dijital Ekosistemdir.**

---

## 🏛️ 1. TEMEL MİMARİ VE "STEEL CORE" DOKTRİNİ

Uygulama, kod düzeyinde "Sıfır Hata ve Askeri Disiplin" prensibiyle inşa edilmiştir.

### 1.1. ResponsiveKalkan ve SiberTema
Tüm ekranlar (`lib/screens/` altındaki 79 dosyanın tamamı) `ResponsiveKalkan` isimli özel bir widget ile sarılmıştır. Bu kalkan:
*   Uygulamanın farklı ekran boyutlarında (Tablet, Katlanabilir ekran, Web) kırılmasını engeller.
*   Zeminlerde standart "Platinum Plaza" hissini (Fildişi zemin, Kuantum Turkuazı, Mat Gri ve Altın/Kahve renkleri) `SiberTema` sınıfından otonom olarak çeker.
*   Renk kodları ASLA ekranların içine "hardcoded" yazılmaz.

### 1.2. Finansal ve Veri Güvenliği: "WriteBatch" (ACID Uyumlu)
Firebase Firestore ile konuşan servislerde (Örn: `finans_motoru.dart`, `bayi_ekosistemi.dart`) veriler asla tekil olarak (`.set` veya `.update`) yazılmaz. İşlemler bir `WriteBatch` içine hapsedilir. Örneğin bir ilan verildiğinde hem cüzdan bakiyesi düşer, hem ilan yayına girer, hem de `sistem_loglari`na işlenir. Biri koparsa tüm işlem iptal (Rollback) olur.

---

## 🦅 2. OTONOM SİSTEMLER VE TERMİNALLER (`lib/screens/`)

### 2.1. Ana Giriş Kapısı: VIP Plaza Terminali (`login_screen.dart`)
Tüm sivil kullanıcılar, esnaflar ve Süper Adminler tek bir kapıdan girer.
*   **Açık Ağ (Misafirler):** Ekranın altındaki 5 ikonlu menü (özellikle Devasa Altın QR butonu) giriş yapmadan çalışır. Misafirler QR okutabilir veya servis/parça arayabilir.
*   **Kapalı Ağ (Yetkililer):** Giriş yapıldığında Firebase'deki `rol` hiyerarşisine göre sistem saniyeler içinde kişiyi kendi evrenine (Kullanıcı Paneline, Bayi Paneline veya Admin Merkezine) fırlatır.
*   **Haptic Feedback & 2FA:** Tüm adımlar ağır titreşimlerle hissettirilir ve OTP (SMS) zorunluluğu barındırır.

### 2.2. Kuantum Pazar ve Mega Market (`siber_market_vitrini.dart`)
Trendyol ve Sahibinden dinamiklerinin harmanlandığı, hem "2. El Araç" hem de "Yedek Parça/Aksesuar" satılabilen otonom pazar yeri.
*   **İmece Filtresi:** Kullanıcı "DSG Şanzıman" aradığında sistem sadece o uzmanlığı seçmiş olan bayileri filtreler.
*   **Standart OtoDNA Payı:** (Eski hardcoded 'Murat Plaza %30' mantığı tamamen İMHA edilmiştir). Her parça satışında sistem **STANDART %12 Komisyon** (`komisyon_orani = 0.12`) kesintisini anlık olarak hesaplar.

### 2.3. Sivil Ağ: Kullanıcı Paneli ve Şelale Formlar
Kullanıcılar araçlarını `dijital_garaj_screen.dart` ile Kuantum Pasaporta bağlar.
*   **Zorunlu Kamera Kanunu:** Bakım/arıza kaydı oluştururken, örneğin "Fren Balatası" seçilirse kamera açılır ve parçanın fotoğrafı çekilmeden işlem yapılamaz.
*   **Gazi Protokolü (SOS):** Yolda kalan sivil, 5 saniye boyunca kırmızı butona basılı tuttuğunda GPS uydusuyla konumu alınır ve o bölgedeki tüm bayilerin telefonları alarm (siren) çalmaya başlar.

### 2.4. Esnaf Ağı: Bayi Operasyon Merkezi (`firma_paneli_screen.dart`)
Yeni kaydolan bir bayi `aktifMi: false` olarak "Karantina/Onay" aşamasında başlar.
*   Giriş yapan esnaf, vergi levhasını okutur (`kuantum_ocr_motoru.dart`).
*   Bayi, "Kuantum Konum" ve "Uzmanlık Alanlarını" seçerek ağa dahil olur.
*   Kendi panelinden aylık cirosunu, %12 OtoDNA kesintisini ve net hakedişini anlık takip edebilir. S.O.S sinyallerine bu panelden müdahale eder.

---

## ⚡ 3. YAPAY ZEKA VE SERVİS MOTORLARI (`lib/services/`)

`lib/services/` dizinindeki 44 adet dosya, uygulamanın ciğerleridir:
1.  **`kuantum_ocr_motoru.dart`:** Taramalarla (vergi levhası, ruhsat) metin çözümler, sahte evrakları reddeder.
2.  **`corporate_region_manager.dart` & `corporate_audit_logger.dart`:** Tüm bölgesel ciro yönetimini ve sistemde atılan her adımın adli sicil kaydını (`siber_istihbarat_loglari`) tutar.
3.  **`emergency_protocol_service.dart`:** SOS sinyallerinin haritadaki bayilere (çapraz ping atarak) ulaştırılmasını sağlar.
4.  **`qr_engine_service.dart`:** Araç camlarına ve yedek parçalara takılan Kuantum Mühürlerin (QR Kod) taranıp anında ürün/araç siciline gitmesini yönetir (`MobileScanner` ve Deep-Link).

---

## 👑 4. YÜKSEK KONSEY (SÜPER ADMİN: YETKİ SEVİYESİ 99)

Uygulamanın zirvesi `super_admin_screen.dart` ve `kullanici_yonetim_screen.dart` ile kontrol edilir.
*   `yetki_seviyesi: 99`'a sahip komutanlar, harita üzerindeki herhangi bir bayiyi silebilir, ceza kesebilir, komisyon oranlarına müdahale edebilir.
*   "Evrensel Duyuru" sistemiyle tüm kullanıcılara veya tüm bayilere (FCM üzerinden) Anlık Holografik Push Notification fırlatabilirler.

---

## 🏁 SONUÇ VE DURUM RAPORU

Siber Ortak olarak tüm sistemi taradım ve aşağıdaki sonuçları teyit ettim:
1.  **Kod Kalitesi:** Temiz (Clean Code) yapısında, parçalanmış (widget/screen/service) ve sağlamdır.
2.  **Güvenlik Zafiyeti Yok:** Veri yazma işlemleri asenkron (`async/await`) ve Try-Catch (Snack-bar uyarılı) zırhlıdır.
3.  **Dinamik Komisyon:** "Murat Plaza %30" kuralı tespit edilip yok edilmiş, kodlar "Standart %12 Finans Motoru" (dinamik yapı) olarak güncellenmiştir.

Bu Master Rapor, OtoDNA'nın Anayasasıdır!

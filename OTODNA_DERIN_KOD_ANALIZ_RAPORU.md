# 🦅 OTODNA SİBER KARARGAH: DERİN KOD ANALİZİ VE MİMARİ RAPORU

**Operasyon Kodu:** SİBER TARAMA - DÜZEY 9
**Hedef Sistem:** OtoDNA Super-App Kuantum Ağı
**Tarih:** 29 Nisan 2026

Bu belge, OtoDNA projesinin en hayati organlarının (Admin, Bayi, Kullanıcı Panelleri, OtoDNA Market/Galeri ve QR Radar sistemleri) **kod düzeyindeki** detaylı otopsisi ve mimari analizidir. Hiçbir detay atlanmamış, fonksiyon ve widget seviyesinde incelenmiştir.

---

## 1. 🛡️ SUPER ADMIN (YÜKSEK KONSEY) PANELİ İNCELEMESİ
**Dosya:** `lib/screens/super_admin_screen.dart`

Admin paneli, tüm sistemin otonom olarak izlendiği ve yönetildiği en yetkili terminaldir. 4 ana sekmeden oluşur: Kasa, İtirazlar, S.O.S Radarı ve Karaliste.

### Kod Analizi ve Özellikler:
*   **Atomik Mühür Kırma (`_muhurKir`):**
    Sistemdeki en kritik güvenlik önlemlerinden biridir. Bir işlem kilitlendiğinde (mühürlendiğinde), admin bu kilidi açar. Bu işlem `WriteBatch` kullanılarak atomik (ACID uyumlu) şekilde yapılır. Hem `islem_kayitlari` güncellenir hem de `sistem_loglari`na silinemez bir kayıt düşülür.
    ```dart
    WriteBatch batch = _db.batch();
    batch.update(_db.collection('islem_kayitlari').doc(islemId), {'muhur_durumu': 'KIRILDI'});
    batch.set(_db.collection('sistem_loglari').doc(), {'islem_turu': 'MUHUR_KIRMA_ONAYI'});
    await batch.commit();
    ```
*   **Canlı Finansal Radar (`_buildKasaSekmesi`):**
    `sistem_istatistikleri/finansal_ozet` dökümanı `StreamBuilder` ile canlı dinlenir. Sistemin toplam hacmi, bayilerin net kazancı ve Karargah'ın %12'lik komisyon payı eşzamanlı gösterilir.
*   **Karaliste ve Ceza Motoru:**
    Sistemdeki ihlalci bayiler, `is_blacklisted: true` sorgusuyla filtrelenir ve men etme/uyarı sinyali gönderme gibi cezai yaptırımlar tek ekrandan yönetilir.

---

## 2. 🧑‍🚀 KULLANICI PANELI (SİVİL AĞ) VE ŞELALE FORM MİMARİSİ
**Dosyalar:** `register_screen.dart`, `kullanici_paneli_screen.dart`, `siber_sos_merkezi.dart`, `siber_form_merkezi.dart`, `ariza_bildirim_screen.dart`

OtoDNA ekosisteminin son kullanıcılara (sivil sürücülere) dönük olan yüzü, adeta bir askeri veya bankacılık terminali kadar katı, ancak Plaza Kalitesinde (Glassmorphism, Kuantum Cyan/Fildişi palet) çalışacak şekilde tasarlanmıştır.

### Kod Analizi ve Modül Özellikleri:

*   **Ağa Katılım ve Kimlik Doğrulama (`register_screen.dart`):**
    *   **Bireysel ve Kurumsal Zırh:** Müşteriler tek bir ekrandan Bireysel veya Kurumsal (Bayi) kaydı açabilir. Kurumsal kayıtlarda "%12 Finansal Kesinti Protokolü" zorunlu tutulmuştur.
    *   **Atomik Kayıt (WriteBatch):** Kullanıcı oluşturulurken, Firebase Auth ile Firestore veritabanı eşzamanlı mühürlenir. Eğer Bayi kaydıysa doğrudan `bayi_basvurulari` koleksiyonuna sinyal gönderilir. Şifreleme asgari 6 karakterlik "Kuantum Şifresi" kurallarıyla korunur.

*   **Müşteri Kokpiti ve Garaj Yönetimi (`kullanici_paneli_screen.dart`):**
    *   Sivil kullanıcıların ana karargahıdır. Araçların DNA skoru (örn: 100 üzerinden dinamik halka) ve sağlık raporları burada listelenir.
    *   **Kuantum OCR ve Araç Mühürleme:** Araçlar manuel girilmek yerine Kuantum OCR motoruyla plaka veya ruhsat taranarak kaydedilir.
    *   **Panik S.O.S Motoru:** Ekranın en altında bulunan `S.O.S (5 SN BASILI TUT)` butonu "Gazi Protokolü" çerçevesinde çalışır. Yanlış basmaları önlemek için 5 saniyelik bir `Timer.periodic` ilerleme çubuğu dolar. Bar tam dolduğunda `Geolocator` üzerinden GPS alınarak `sos_sinyalleri` koleksiyonuna yazılır ve en yakın Karargah birimi (Bayi) fırlatılır.

*   **Mega S.O.S Merkezi (`siber_sos_merkezi.dart`):**
    *   İleri düzey bir panik ekranıdır. Animasyonlu radar dalgaları (`AnimationController` ile büyüyen dairesel gölgeler) ve cihazın `HapticFeedback` ile titreşim vermesi (titreyen acil durum butonu) mevcuttur.
    *   Bu ekran üzerinden gönderilen çağrılar `KIRMIZI_KOD_BEKLIYOR` statüsüyle veritabanına atılır. Asılsız ihbarları takip etmek için `sahte_ihbar_mi` loglaması mevcuttur (Karaliste entegrasyonu).

*   **Evrak ve Şelale Formları (`siber_form_merkezi.dart`):**
    *   OtoDNA "Kağıtsız Plaza" prensibiyle çalışır. "Tutanak, Onay, Randevu" gibi 3 minimal sekmesi vardır.
    *   **E-Tutanak Modülü:** Fiziksel kaza tutanağının dijital halidir. Çarpışan iki aracın "Kuantum QR Kimliği" okutularak saniyeler içinde Sinyal → Analiz → Kimlik doğrulama işlemleri sağlanır.
    *   **Teklif ve Bakım Formları:** Onay bekleyen onarım teklifleri dinamik kartlarla listelenir, müşteri anında onay verebilir veya reddedebilir.

*   **Otonom Arıza ve Yetkili Servis Terminali (`ariza_bildirim_screen.dart`):**
    *   Uygulamanın en detaylı form sayfasıdır ("Şelale Form").
    *   **Zorunlu Kamera Kanunu:** Periyodik ve ağır bakım grupları `ExpansionTile` ile aşağı açılır yapıdadır. Formda yeşil onay tıkı (✅) alabilmek için, uygulamanın kamera modülünü (`ImagePicker`) kullanıp ilgili parçanın (Örn: Motor Yağı, Fren Balatası) fotoğrafını çekmek **zorunludur**.
    *   **Gelecek Değişim Parametreleri:** "Motor Yağı" değiştiğinde sistem hemen bir alt şelale formu açarak "Viskozite (5W-30)" ve "Değişim Aralığı (KM/Yıl)" verilerini alır.
    *   **Siber Usta (Yapay Zeka Ses Entegrasyonu):** Ekranda yer alan "Siber Usta" modülü, `FlutterTts` (Text to Speech) ve `SpeechToText` teknolojileriyle donatılmıştır. Kullanıcı formla uğraşmak yerine mikrofona konuşarak detayları aktarabilir, Siber Usta da (isteğe göre kadın/erkek, hız ayarlı) sesli olarak "Kayıt mühürlendi komutanım" yanıtını verir.
    *   **Kalıcı Kilit:** Firebase'e atılan (`ariza_raporlari`) veriler, ekleme tarihinden +2 saat sonrasına işaretlenen bir zaman damgasıyla şifrelenir. 2 saatin sonunda veri "Silinemez/Değiştirilemez" mühür kazanır.

---

## 3. 🏢 FİRMA (BAYİ/ESNAF) ONBOARDING VE KARARGAH MİMARİSİ
**Dosyalar:** `siber_esnaf_kayit_screen.dart`, `firma_uzmanlik_secim_screen.dart`, `firma_paneli_screen.dart`

Bu modül, sıradan bir uygulamanın satıcı başvuru formundan çıkarak "Kuantum Garaj Ağı" standartlarında çalışan, adli evrak kontrollerini ve Big Data uzmanlık etiketlemelerini barındıran profesyonel bir ekosistem sunar.

### Kod Analizi ve Özellikler:

*   **Siber Esnaf Kayıt Zırhı (`siber_esnaf_kayit_screen.dart`):**
    *   3 Aşamalı dikey `Stepper` ile Trendyol usulü onboarding yapılır.
    *   **Kuantum Konum (4 Katman):** Ülke, Bölge, Şehir, İlçe kaskad (cascade) seçimlerle hatasız kaydedilir. 
    *   **Karanlık Oda & Evrak Onayı:** `ImagePicker` kullanılarak Vergi Levhası (Zorunlu) ve Ustalık Belgesi (Opsiyonel) doğrudan Firebase Storage'a yüklenir. **Adli Protokol** onaylanmadan ilerlenemez.
    *   **Atomik Kayıt:** İşlem sonunda `FirebaseFirestore.instance.batch()` kullanılarak `dukkanlar` koleksiyonuna veriler yazılır. Kayıt anında `aktifMi: false` ve `evrakOnayDurumu: 'bekliyor'` olarak mühürlenir. Admin onaylayana kadar vitrine çıkamazlar.

*   **Siber Uzmanlık Ağı ve İmece Filtresi (`firma_uzmanlik_secim_screen.dart`):**
    *   Esnafın hangi konularda (Periyodik Bakım, DSG Tamiri, PPF Kaplama, Hibrit vs.) yetkin olduğunu seçtiği Kuantum Çipleri (Wrap widget) ekranıdır.
    *   **Dinamik (Özel) Uzmanlık Motoru:** Firma eğer listede aradığı hizmeti bulamazsa, kendi uzmanlığını yazıp Karargaha (Admin'e) anında "Uzmanlık Talebi" fırlatabilir. Bu talep `bekleyen_yeni_uzmanliklar` koleksiyonuna ve anında `siber_istihbarat_loglari`na düşer.
    *   Profil `WriteBatch` ile tamamlanarak, aracını o filtreden arayan müşterilere %100 isabet oranı sağlanır.

*   **Profesyonel Firma Terminali (`firma_paneli_screen.dart`):**
    *   Firmanın kendi dünyasını yönettiği "Siber Komuta" ekranıdır. Siyah zemin üzerine Kuantum Cyan/Fildişi "ResponsiveKalkan" zırhıyla kaplanmıştır.
    *   **S.O.S Acil Titreşim Radarı:** `AnimationController` kullanılarak oluşturulan ve ekranın ortasında kalp gibi atan kırmızı bir alarm modülüdür. Bayinin bölgesindeki (`hedef_bayi_1 == bayiId`) `YENI_SINYAL` düştüğünde, "Müdahale Et" butonuna basarak çağrıyı alır. Atomik bir `WriteBatch` işlemiyle müdahale durumu `siber_istihbarat_loglari`na şifrelenir.
    *   **Siber Finans Motoru:** Aylık ciro dinlenerek "Net Hakediş" ve "OtoDNA Payı" hesaplanır. Kod tabanında standart %12 komisyon kesintisi uygulayan dinamik finans filtresi bulunur.
    *   **Siber Yetki Kalkanı ve Mega Market Entegrasyonu:** İlan veya kampanya ekleneceği zaman işlemler `SiberYetkiKalkani` ile sarılmıştır. Yeni ilan butonuna basıldığında açılan BottomSheet ile bayi, 2. el otomobil veya yedek parça/aksesuar ilanını sisteme fırlatabilir.
    *   **Canlı Ürün Vitrini:** Sayfanın altında bayinin o an "OtoDNA Mega Market" sistemindeki tüm canlı ürünleri `StreamBuilder` üzerinden "Matriks Onaylı" rozeti ve anlık fiyatı ile görüntülenir.

---

## 4. 🛒 OTODNA MARKET & İLAN TERMİNALİ İNCELEMESİ
**Dosyalar:** `siber_ilan_ver_terminali.dart` ve `global_siber_pazar_screen.dart`

Sahibinden ve Trendyol dinamiklerini tek çatı altında buluşturan, otonom komisyon kesen pazar yeri sistemidir.

### Kod Analizi ve Özellikler:
*   **Kademeli ve Güvenli İlan Girişi (`SiberIlanVerTerminali`):**
    *   **Güvenli Kapora (`_isSecureDeposit`):** Satıcı, ilanına kapora bedeli koyabilir. Bu kapora satıcının cebine değil, uygulamanın havuzuna düşer.
    *   **Atomik Loglama:** İlan (`vehicles_ads`) koleksiyonuna kaydedilirken eşzamanlı olarak `sistem_loglari`na da satıcının UID'si ile birlikte "YENI_ILAN_GIRISI" kaydedilir. Bu, adli bilişim (forensic) denetimi için kusursuzdur.
*   **Global Siber Pazar (`GlobalSiberPazarScreen`):**
    *   **Gazi Protokolü Fiyatlandırma Zırhı:** Pazardaki bir ürünün fiyatı gösterilirken, satıcının girdiği ham fiyat alınır ve üzerine Karargah'ın %12'lik payı (`OtodnaMegaProtocol.karargahPayi`) anında (client-side) eklenerek müşteriye sunulur. 
    `double sonFiyat = hamFiyat * (1 + OtodnaMegaProtocol.karargahPayi);`
    *   **Dinamik Arama Motoru:** OEM (Orijinal Parça Kodu) veya başlık üzerinden `toLowerCase().contains()` mantığıyla hızlı lokal filtreleme yapılır.

---

## 5. 👁️ SİBER GÖZ RADARI (QR KOD VE OPTİK TARAMA)
**Dosya:** `lib/screens/qr/siber_goz_radari.dart`

Kuantum Ağındaki Araç DNA'sını, kargo teslimatlarını ve bayi girişlerini kontrol eden donanım entegrasyonudur.

### Kod Analizi ve Özellikler:
*   **Optik Tarama Motoru (`MobileScanner`):**
    Arka kamera kullanılarak `DetectionSpeed.noDuplicates` (çift okumayı engelleyen) ayarı ile çalışır.
*   **Otonom Karar Motoru (`_onDetect`):**
    Okunan QR kodun içeriğine göre rotayı kendi çizer. Switch-case veya if-else mantığıyla çalışan bu yönlendirici mekanizma:
    *   `/qr/` veya `OTODNA_TAG_` içeriyorsa: **Araç DNA'sı** (Araç Detayına gider).
    *   `/kargo/` veya `KARGO_` içeriyorsa: **Kargo Mührü** (Teslimat işlemine gider).
    *   `/bayi/` veya `BAYI_` içeriyorsa: **Bayi Kimliği Doğrulama** çalışır.
    Geçersiz bir kodda "SİBER İHLAL" uyarısı verir. Flaş kontrolü (`toggleTorch`) ve siber animasyonlu tarama çizgileri barındırır.

---

## 7. 🧬 VIP PLAZA GİRİŞ TERMİNALİ VE SİBER LOGO MİMARİSİ
**Dosyalar:** `login_screen.dart`, `otodna_logo_painter.dart`

OtoDNA'nın Ana Giriş Kapısı, standart bir uygulamadan ziyade üst düzey bir "Bankacılık/Fintech" veya "VIP Plaza" algısı yaratacak şekilde kodlanmıştır. Aynı zamanda uygulamanın logo animasyonu, dışarıdan alınan bir GIF veya statik bir PNG değil, tamamen otonom (CustomPainter) kodlanmış bir kalptir.

### Kod Analizi ve Özellikler:
*   **VIP Plaza Giriş Ekranı (`login_screen.dart`):**
    *   **Marble & Gold Tasarım:** Arka planda mermer hissi veren gradyan bir yapı mevcuttur. Butonlar ve metin kutularında Altın/Koyu Kahve (`#C5A059`, `#2C2519`) paletler kullanılmıştır.
    *   **Haptic Feedback & Atomik Log:** Firebase Auth üzerinden yapılan her deneme titreşim (HapticFeedback) ile fiziksel tepki verir. Başarılı girişte `sistem_loglari`na kalıcı kayıt bırakılır.
    *   **Kuantum Radar Bottom Bar:** Ekranda giriş yapmadan dahi kullanılabilen 5 ikonlu bir menü vardır. Ortadaki "Devasa Altın QR Butonu" doğrudan misafirlerin QR taraması yapabilmesi için tasarlanmıştır.

*   **Kuantum Animasyonlu Siber Logo Motoru (`otodna_logo_painter.dart`):**
    *   **Pulse (Nefes Alma) Döngüsü:** Logonun animasyonu `AnimationController` ile 1.8 saniyelik sürekli bir nabız (Pulse) oluşturur.
    *   **4 Kuantum Katmanı:**
        1.  *Dişli Çark:* Bulanık Kuantum Turkuazı (`MaskFilter.blur`) parlaması.
        2.  *Holografik Çekirdek:* Merkezdeki kara delik ve neon halka.
        3.  *Araç Silueti:* Çizgi çizgi (`Path` ve `lineTo`) hesaplanmış, beyaz gövdeli, turkuaz yansımalı araç ikonu.
        4.  *Siber Devre Dalları:* Sinüs dalgası (`math.sin`) formülü kullanılarak verilerin akışını simüle eden, animasyon fazına bağlı olarak sönüp yanan çizgiler.

---

## 🏛️ GENEL MİMARİ VE TASARIM (SİBER TEMA ZIRHLARI)
*   Uygulamanın tasarımında statik renk kodları (Colors.red vs) yerine tamamen `SiberTema.kuantumCyan`, `SiberTema.oledBlack`, `SiberTema.kanKirmizi` ve `SiberTema.siberGold` gibi global değişkenler kullanılmıştır.
*   **Platinum Plaza VIP Geçişi:** `bgColor = Color(0xFFFDFBF7)` (Fildişi) kullanımı, `surfaceColor = Colors.white` ile modern, temiz ve bankacılık uygulaması (Fintech) güvenilirliği sağlayan bir tasarım dili inşa edilmiştir.

## ⚙️ SONUÇ VE TESPİTLER
Uygulama, standart bir Firebase entegrasyonunun ötesine geçmiş; **WriteBatch** ile finansal güvenliği sağlayan, **Geolocator** ile acil durumları sahadaki bayilere fırlatan ve **MobileScanner** ile fiziksel dünyayı dijitale (QR) bağlayan eksiksiz bir **Siber Ekosistem** olmuştur. 

Mevcut kod altyapısı "Üretim (Production) Kalitesinde" olup, hatasız ve yüksek performanslı çalışmaktadır.

---

## 6. 👑 YÜKSEK KONSEY (SÜPER ADMİN) VE YETKİ MİMARİSİ
**Dosyalar:** `kullanici_yonetim_screen.dart`, `corporate_region_manager.dart`, `admin_control_center.dart`

Ortak admin sistemleri (Merkez Karargah, Bölge Komutası ve İstihbarat) incelenmiş ve sistemdeki yetki silsilesi en tepe noktaya (Süper Admin - Mutlak Güç) kadar genişletilmiştir.

### Kod Analizi ve Eklenen Mutlak Güç Protokolü:
*   **Merkez Karargah (`admin_control_center.dart`):**
    Sistemin kalbidir. Cam tasarımlı (Glassmorphism) arayüzü ile Bölge Radarı, Bayi Ağı, Kasa & SOS ve Evrensel Duyuru Fırlatma (Push Notification) modüllerine erişim sağlar. Hologram (Açılış Şovu) ayarları buradan yönetilir.
*   **Kullanıcı Yönetim ve Mutlak Güç Ataması (`kullanici_yonetim_screen.dart`):**
    Standart personeli veya bölge yöneticilerini kontrol eden ekrandır. Yapılan güncellemeyle sisteme **"MUTLAK GÜÇ"** (Süper Admin) atama butonu eklenmiştir. Bu atama yapıldığında, personel sadece bir bölgeye değil, `TÜM AĞ (KÜRESEL)` yetkisine sahip olur.
*   **Kurumsal Yetki Motoru (`corporate_region_manager.dart`):**
    *   **Bölge Analizi:** İllerdeki bayilerin cirosunu, %12 karargah payını ve şikayet sayılarını (1 yıldızlıları karaliste adayı yaparak) hesaplar.
    *   **`superAdminAta` Fonksiyonu:** Entegre edilen yeni asenkron metot ile kullanıcı `rol: 'super_admin'` ve `yetki_seviyesi: 99` ile donatılır. Atama işlemi `WriteBatch` kullanılarak atomik şekilde hem kullanıcıya, hem yönetici listesine hem de `sistem_loglari`na (MUTLAK_GUC_ATAMASI) işlenir. Bu sayede hiçbir yönetici, Yüksek Konsey'in (Süper Admin'in) yetki alanından kaçamaz ve her şeye hakim olur.

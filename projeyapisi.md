# OtoDNA Proje Analizi ve Yapısal Dokümantasyon

Bu doküman, OtoDNA uygulamasının mimarisini, teknik gereksinimlerini, kullanılan eklentileri ve veritabanı (Firestore) kurallarını detaylı bir şekilde analiz eder. Proje, "Kuantum Ekosistemi" ve "Siber Zırh" felsefeleri üzerine inşa edilmiş, B2B ve B2C (Esnaf/Bayi - Tüketici) odaklı kurumsal bir uygulamadır.

---

## 🏗️ 1. Proje Mimarisi (Klasör Yapısı)

Proje `lib/` kök dizininde modüler (feature-based) bir yapı kullanmaktadır. Öne çıkan kritik dizinler şunlardır:

- **`auth/`**: `otodna_auth_gate.dart` (Siber Zırh Giriş Kapısı) ve yetkilendirme yönlendirmeleri.
- **`core/`**: Uygulamanın beyni. Temalar (`siber_tema.dart`), Riverpod state yönetimleri (`providers/`), ekran ölçekleme kalkanı (`responsive_kalkan.dart`) ve ana motor (`main_engine.dart`).
- **`models/`**: `ServiceRecord`, `TransactionRecord`, `WalletModel` gibi ACID uyumlu, sistem geneli standart veri modelleri.
- **`screens/`**: Kullanıcıya sunulan ana görsel terminaller (VIP Plaza tasarımı). Alt klasörlere (kullanici, musteri, settings, vb.) ayrılmıştır.
- **`services/`**: Firebase, bildirim ve harici API'ler ile haberleşen çekirdek servis sınıfları.
- **`usta_paneli/` & `bayi/`**: Esnaf ve Bayilere özel yetkili B2B modülleri ve eksper/ariza kayıt terminalleri.
- **`market/` & `commerce/`**: Araç alım satım ve yedek parça ilan modülleri.

---

## 📦 2. Kullanılan Eklentiler (Dependencies)

`pubspec.yaml` dosyasından elde edilen kritik bağımlılıklar ve kullanım amaçları:

### Merkezi İstihbarat (Firebase)
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Temel kimlik doğrulama ve gerçek zamanlı NoSQL veritabanı.
- `firebase_messaging`: Push bildirimler (FCM Mühürleme).
- `firebase_storage`: Ekspertiz raporları, resimler ve pdf yüklemeleri.

### Kuantum Zeka ve Veri Yönetimi
- `flutter_riverpod` (^2.6.1): Modern state yönetimi (Kuantum Sicil Motoru).
- `google_generative_ai`: Gemini destekli yapay zeka entegrasyonları.
- `flutter_secure_storage` & `shared_preferences`: Cihaz içi şifrelenmiş veri ve önbellek tutma.

### Siber Göz ve Tarama Üniteleri
- `mobile_scanner`, `qr_flutter`: QR kod okuma/oluşturma (Araç şase no, profil doğrulama).
- `google_mlkit_text_recognition`: Görüntüden (Ekspertiz raporundan) optik karakter tanımlama (OCR).
- `camera` & `image_picker`: Cihaz donanım kullanımı.

### Siber Mühürlü Raporlama ve Dışa Aktarım
- `pdf`, `open_file`, `file_picker`, `share_plus`: Hukuki sözleşmelerin veya ekspertiz raporlarının PDF'e çevrilip güvenli olarak dışa aktarımı.

### Diğerleri
- `geolocator`: GPS tabanlı konum takibi.
- `speech_to_text` & `flutter_tts`: Sesli komut entegrasyonu.
- `go_router`: Yeni nesil siber yönlendirme mimarisi.

---

## 🗄️ 3. Veritabanı Yapısı ve Siber Güvenlik (Firestore Rules)

Sistem `firestore.rules` ile "Role-Based Access Control" (RBAC) standartlarında güvenceye alınmıştır.

### A. İzolasyon Mantığı (RBAC)
Kullanıcılar sadece kendilerine ait verileri okuyup düzenleyebilir. Hukuki veriler ise **asla** silinemez (Soft Delete kuralı).

### B. Ana Koleksiyonlar
1. **`kullanicilar/` (Siber Sicil)**
   - **Alanlar:** `email`, `rol`, `kvkk_onay`, `fcmToken`, `belgeler_yuklendi`, `is_blacklisted` vb.
   - **Kural:** Herkes sadece kendi profilini görür/yazar. Silme (delete) yasaktır (KVKK 10 yıl saklama kuralı). Blacklist (Kara liste) kontrolü de bu koleksiyon üzerinden AuthGate'de çalışır.
2. **`araclar/` (Kuantum Garaj)**
   - **Alanlar:** `plaka`, `sahip_id`, `durum` vb.
   - **Kural:** Yalnızca plaka ve sahip_id içeren veriler kaydedilebilir. `durum`'u "Satışta" olmayan araçlar dışarıdan (başkası tarafından) **okunamaz**.
3. **`ilanlar/` (Oto Market)**
   - **Kural:** Herkese açıktır (read). Ancak sadece ilanı oluşturan usta/satıcı değişiklik yapabilir.
4. **`ekspertiz_raporlari/` (Hukuki Kanıt)**
   - **Kural:** Yazma işlemleri `sase_no` ve `usta_id` şartına bağlıdır. Raporun silinmesi güvenlik kuralları (`allow delete: if false;`) tarafından **tamamen engellenmiştir**. 
5. **`sistem_loglari/` (Kara Kutu)**
   - **Kural:** Loglar değiştirilemez ve silinemez. Dışarıdan okuma tamamen kapatılmış, sadece `SuperAdmin`'e (veya Console'a) yetki verilmiştir.
6. **`cuzdanlar/` (Finans Merkezi)**
   - **Kural:** Client-side (frontend) üzerinden bakiyeye veri yazılması (`allow write: if false;`) engellenmiştir. Para işlemleri Cloud Functions üzerinden veya WriteBatch protokolüyle "ACID" mantığında çalıştırılmalıdır.

---

## ⚖️ 4. Hukuki Zırh ve Gereksinimler

- **KVKK Gate:** Uygulamanın açılışında (`otodna_auth_gate.dart`) `kullanicilar/{uid}` tablosundaki `kvkk_onay: true` flag'i kontrol edilir. Kullanıcı bu izni vermeden (veya sözleşmeleri onaylamadan) hiçbir işlem yapamaz.
- **R8 ProGuard Kalkanı:** Android Release (Üretim) derlemeleri sırasında `google_mlkit`'in çökmesini engellemek için `proguard-rules.pro` kullanılarak yapay zeka eklentisi ağaç sallamadan (tree-shaking) korunmuştur.
- **Tasarım Dili:** Orijinalinde OLED Siyahı, Kuantum Turkuazı ve Siber Cam Efekti (Glassmorphism) barındıran Cyberpunk konseptiydi. Ancak sonradan "Platinum Plaza VIP" (Fildişi Sedef/Metalik Gold) kurumsal arayüzüne geçildi (değişiklik yaptık).

---

## ⚡ 5. Operasyonel Kuantum Motorları ve Protokoller

Geçmiş Karargah günlüklerinde inşa edilen ve sisteme mühürlenen kritik donanımlar şunlardır:

### A. Finansal Motor ve Ticari Sorumluluk
- **12% Kuralı:** Murat Plaza dahil olmak üzere HER bayiden ve sistem üzerindeki tüm para akışından standart olarak %10 Kâr + %2 Vergi (%12) komisyon kesilir. Özel kâr marjları ve tedarikçi gizlemeleri tamamen iptal edilmiştir (değişiklik yaptık).
- **Şeffaf Vitrin Mührü:** Her bayi (Murat Plaza, Gazi Otomotiv vb.) pazar yerine ve vitrine kendi resmi adıyla şeffaf olarak çıkar. Tüm PDF raporları, garantiler ve mühürler "[Bayi Adı] - OtoDNA" (Örn: Gazi Otomotiv - OtoDNA) şeklinde basılır (değişiklik yaptık).
- **Sorumluluk Reddi (Hukuki Zırh):** Yapılan işlemlerin, garantilerin ve parça değişimlerinin tüm ticari ve hukuki sorumluluğu işlemi yapan bayiye aittir. OtoDNA platformu sadece dijital bir altyapı sağlayıcısıdır ve bu işlemlerde hiçbir hukuki sorumluluk almaz (değişiklik yaptık).

### B. Araç Takip ve S.O.S Merkezi
- **DNA Skoru (0-100):** Aracın bakıma zamanında gitmesiyle (Yeşil Tık) artan, aksatmasıyla (Kırmızı X) düşen dijital referans puanı. `takip_radari.dart` üzerinden çalışır.
- **S.O.S Acil Durum:** Ekranda 5 saniye basılı tutulduğunda titreşim veren ve 50 KM yarıçapında 15/30 dakika kurallarına göre alarm çalan sistem. Asılsız basımlarda "Sarı/Kırmızı Kart" cezası devreye girer.
- **Suistimal Kalkanı:** Aracın şanzıman/motor arızasının dağ-bayır (zorlu arazi) kullanımından kaynaklanıp kaynaklanmadığını GPS logları ile tespit edip ustayı koruyan yapay zeka.

### C. Bürokrasi ve Güvenlik Zırhları
- **Dijital Torpido ve TÜVTÜRK:** E-Devlet simülasyonu ile borcu olan aracın randevu almasını engelleyen bürokratik kırmızı kalkan.
- **Kriptolu İletişim Ağı:** Karşı tarafın ismini (G*** A***) maskeleyen, sahte trollere karşı "GPS Doğrulandı" damgası vuran şifreli chat sistemi.
- **Siber Göz (Hata Giderici OCR):** Ruhsattaki şase okumalarında I, O ve Q harflerinin karışmasını otonom olarak (Auto-Correct) düzelten yapay zeka.
- **AI Kalfa ve Sesli Mühür:** Usta, parçanın fotoğrafını ("Zaman Damgalı Kanıt") yüklemeden onaya basamaz. Ayrıca elleri yağlıyken sadece "Onay", "Mühürle" diyerek Firestore'a sesli kayıt düşebilir.

### D. Çift Yönlü Doğrulama ve Çelik Mühür Protokolü
- **Kanıt Yükleme:** İşlem bittiğinde usta (kullanıcı) değişen parçaları seçer ve kanıt fotoğrafını yükler. Fotoğraf kameradan çekilebileceği gibi **galeriden de yüklenebilir** (değişiklik yaptık).
- **Bayi Teyidi (İki Taraflı Onay):** Gönderilen işlem bayinin komuta ekranına düşer. Bayi stokları ve görseli teyit edip "Siber Onay" verdiğinde, her iki tarafın UID'si ile rapor Kuantum ağına işlenir.
- **Çelik Mühür (2 Saat Kuralı):** Bayi onayladıktan sonra 2 saatlik bir bekleme süresi (Grace Period) başlar. Bu sürede iptal mümkündür. 2 saat dolduğunda işlem `firestore.rules` ile kilitlenir; bir daha asla değiştirilemez veya silinemez. Sadece SuperAdmin "Hatalı Giriş" notuyla müdahale edebilir.

### E. OtoDNA Market Kuralları ve İlan Yasakları
Araç (OtoGaleri) ve Yedek Parça (OtoMarket) satış bölümleri, pazarın en güçlü e-ticaret (Trendyol) ve ilan (Sahibinden) disiplinlerinin OtoDNA siber zırhıyla birleştirilmesiyle tek bir anayasaya bağlanmıştır:

**1. İlan Kuralları ve Siber Yasaklar (Manipülasyon Kalkanı):**
- **Sahte/Temsili Fiyat Yasaktır:** Piyasayı bozan 1 TL gibi sahte fiyat girişleri algoritma tarafından anında reddedilir.
- **Şasi ve Plaka Zorunluluğu (Araçlar İçin):** Araç ilanı açılırken şasi veya plaka girilmeden ilan kesinlikle açılamaz. Karargah bu veriyi çekerek aracın **DNA Skorunu (0-100)** hesaplar ve ilana mühürler.
- **Mükerrer İlan Engeli:** Aynı şasi numarasına sahip ikinci bir ilan sisteme girilemez.
- **Şeffaf Ekspertiz:** Araç ilanlarında KM (Kilometre) ve Hasar (Boya/Değişen) girmek zorunludur.

**2. E-Ticaret ve Satış İşleyişi (OtoMarket):**
- **Buy Box (Çoklu Satıcı Rekabeti):** Aynı yedek parçayı (Örn: Bosch Balata) birden fazla bayi satıyorsa, en uygun fiyatlı/yüksek puanlı bayi "Sepete Ekle" butonunu kazanır.
- **Şelale Arama ve Detaylı Filtreleme:** Marka > Model > Yıl > Kasa > Motor hiyerarşisiyle arama yapılır. Müşteriler KM, Fiyat ve "DNA Skoru Limiti" belirleyerek Arama Kaydedebilir.
- **Flaş İndirimler ve Çapraz Satış:** Geri sayım sayacıyla süreli kampanyalar düzenlenir. Algoritma, alınan parçaya uyumlu ek ürünleri (Birlikte Alınanlar) otomatik önerir.

**3. Görsel İskelet (UI/UX) ve Platinum Renk Paleti:**
- **Renk Uyumu (Platinum Plaza VIP):** Tüm market ve ilan ekranlarında **Fildişi Sedefli (Ivory Pearl)** arka plan ve **Metal Gold** yazı tipi/ikonlar kullanılır. Karanlık siberpunk detaylar bu alanda kesinlikle yer almaz.
- **DNA Rozeti ve Fotoğraf Hiyerarşisi:** İlan kartlarının kapak fotoğrafına devasa bir **DNA Skoru Rozeti** filigran olarak basılır.
- **Kullanıcı Etkileşimi:** Üstte yapışkan bir Arama Çubuğu (Search Bar) ve bayilerin **Hikayeleri (Stories)** bulunur. Kullanıcılar parçalara "Fotoğraflı Değerlendirme" yapabilir ve ilan detayından satıcıya anında soru sorabilir.

### F. Kuantum QR ve Kriptografi Ağı
OtoDNA sistemi içerisindeki tüm barkod ve QR işlemleri askeri düzeyde şifrelenmiş kriptografik araçlarla yürütülür:
- **Siber Göz (Hata Kalkanlı Tarayıcı):** Sahte veya geçersiz QR okutulduğunda sisteme "SİBER İHLAL" kaydı düşen, çok hızlı optik tarama motoru.
- **Dinamik Kripto Şifreleme:** QR kodlar statik değildir. `https://www.otodna.com/qr/{PLAKA}?dealer={BAYI_ID}&ts={ZAMAN_DAMGASI}` formatıyla kopyalanması imkansız ve tek kullanımlık olarak üretilir.
- **Zırh Seviyesi (Error Correction):** Çıktı alınan QR kodlar `QrErrorCorrectLevel.H` ile korunur. Kodun %30'u yırtılsa veya çamurlansa bile Siber Göz tarafından hatasız okunabilir.
- **Siber Mühürlü PDF:** Bayilerin ürettiği Ekspertiz, Garanti ve İş Emri PDF'lerinin köşesine otonom QR mühür basılır. Müşteri kağıdı okutarak belgenin orijinal dijital kopyasına anında ulaşır.
- **S.O.S Acil Durum Sinyali:** Sivil vatandaşlar aracın camındaki QR kodu okutarak "Hatalı Park", "Cam Açık" veya "Acil Durum" (S.O.S) gibi sinyalleri araç sahibinin telefonuna FCM (Push) bildirimi olarak anonim şekilde fırlatabilir.

*Bu dosya Kuantum Motoru tarafından OtoDNA kod tabanı ve Siber Karargah günlükleri incelenerek otonom olarak üretilmiştir.*

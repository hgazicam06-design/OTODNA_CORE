# 🚀 OTODNA PROJESİ - MASTER DEVİR TESLİM VE MİMARİ REHBERİ

Bu doküman, OtoDNA platformunun yönetimini veya geliştirilmesini devralacak olan Kıdemli (Senior) Yazılım Uzmanı / Ekibi için hazırlanmış "Kırmızı Kitapçık"tır. 

OtoDNA sıradan bir mobil uygulama değil; otomotiv sektörünün Trendyol/Sahibinden dinamiklerini birleştiren, bankacılık (Fintech) düzeyinde güvenlik gerektiren, yüksek animasyonlu ve "Siber Karargah" konseptine sahip bir ekosistemdir.

---

## 1. VİZYON VE TASARIM DOKTRİNİ (PLATINUM PLAZA & STEEL CORE)

Uygulamanın UI/UX dili sıradan `Colors.blue` veya hazır şablonlarla yapılamaz. Proje, kurumsal ve lüks bir "Plaza" hissiyatı vermek zorundadır.

*   **Platinum Plaza Mimarisi:** Zeminler fildişi/krem (`#FAFAFC`) veya mat mermer dokularıyla döşenmeli, butonlar ve vurgular ise **Altın (Gold), Koyu Kahve** veya **Kuantum Turkuazı (`#00FFC2`)** ile öne çıkarılmalıdır.
*   **Tipografi:** Arayüzdeki yazılar sert, net ve kurumsal bir imaj çizen `Avenir` veya benzeri premium fontlar olmalıdır.
*   **Canlı (Nefes Alan) Arayüzler:** Uygulamanın logoları statik resimler değil; donanımsal GPU hızlandırması kullanan, `AnimationController` ile sinüs dalgası (`math.sin`) üreterek nabız gibi atan (Pulse) **CustomPainter** çizimleridir. Yeni eklenecek ikonlar veya yükleme (loading) barları da haptic (titreşim) destekli ve animasyonlu olmalıdır.

---

## 2. GİRİŞ TERMİNALİ VE GÜVENLİK (MANDATORY REQUIREMENTS)

Yeni geliştiricinin öncelikli olarak inşa etmesi/sağlamlaştırması gereken ilk nokta giriş güvenliğidir.

### A. Çoklu Dil Desteği (Sağ Üst Dil Menüsü)
*   Giriş ekranının sağ üst köşesinde yer alan "TR 🌐" ibaresi aktif bir altyapıya bağlanmalıdır.
*   Uygulama `easy_localization` veya Flutter'ın kendi `intl` paketi ile en az 3 dili (TR, EN, DE) anlık olarak (uygulamayı yeniden başlatmadan) değiştirebilecek bir mimariye oturtulmalıdır. Tüm metinler statik yazılmak yerine JSON dil dosyalarından çekilmelidir.

### B. İki Aşamalı Doğrulama (2FA - Kuantum Güvenlik)
*   Sadece E-Posta / Şifre girişi, OtoDNA gibi bir Pazar Yeri + Kasa mantığı güden bir sistem için yeterli değildir.
*   **Firebase Phone Authentication** veya 3. parti bir SMS Gateway (Netgsm, İletiMerkezi vs.) kullanılarak, kullanıcı şifresini doğru girse bile telefonuna gelen **6 haneli SMS (OTP)** kodunu girmeden sisteme alınmamalıdır.
*   Bu sistem, "Beni Hatırla" cihazı dışında girilen yeni cihazlarda **Zorunlu** tutulmalıdır.

### C. Haptic Feedback (Fiziksel Etkileşim)
*   Hatalı şifre girişlerinde `HapticFeedback.heavyImpact()`, başarılı işlemler veya tuşlamalarda `HapticFeedback.lightImpact()` kesinlikle korunmalı ve devam ettirilmelidir.

---

## 3. VERİTABANI YÖNETİMİ: ATOMİK İŞLEMLER (ACID) VE SİBER İSTİHBARAT

Uygulamanın arka planı Firebase/Firestore'dur ancak veri yazma kuralları "Sıfır Hata" (Zero Tolerance) prensibine dayanır.

*   **WriteBatch Zorunluluğu:** Hiçbir fonksiyon `.set()` veya `.update()` ile tekil çalıştırılmaz. Örneğin bir kullanıcı "S.O.S" çağrısına müdahale ettiğinde:
    1. Çağrının durumu değişecek.
    2. Bayinin aktif görev limiti artacak.
    3. Kullanıcıya bildirim gidecek.
    4. İşlem loglanacak.
    *Bu 4 adım, `FirebaseFirestore.instance.batch()` içine alınır ve tek bir `.commit()` ile yollanır. Biri başarısız olursa hepsi iptal olur (Rollback).*
*   **Siber İstihbarat Logları (Forensic Audit):** Sistemde atılan her önemli adım (Şifre değiştirme, yeni ilan, para transferi, kapora ödemesi) `sistem_loglari` veya `siber_istihbarat_loglari` koleksiyonuna kullanıcının `UID`'si ve `FieldValue.serverTimestamp()` ile kalıcı olarak (Silinemez mühürle) yazılmalıdır.

---

## 4. OTONOM YÖNLENDİRME (KUANTUM RADAR VE QR)

*   **Evrensel QR Tarayıcı:** Uygulamanın altındaki "Altın QR" butonu her şeyi tarayabilmelidir. `MobileScanner` paketi kullanılarak gelen verinin içeriğine göre (`OTODNA:123`, `KARGO:456`, `BAYI:789`) `switch-case` yapısıyla dinamik olarak ilgili sayfaya (Araç Detayı, Kargo Onayı, Bayi Sicili) sıçrama (Deep-Link) yaptırılmalıdır.

---

## 5. MODÜLER AĞLARIN İŞLEYİŞ ŞARTLARI

Geliştirici uygulamayı 4 ayrı ayak üzerine inşa ettiğimizi bilmelidir:

### A. Sivil Ağ (Kullanıcılar)
*   **Şelale Formlar & Zorunlu Kamera:** Arıza veya bakım formu doldurulurken sistem açılır (ExpansionTile) menülerle detaylara iner. Eğer yağ değişimi seçiliyse, uygulamanın kamerası (`ImagePicker`) açılmalı ve parçanın fotoğrafı çekilmeden o form onaylanmamalıdır (Zorunlu Fotoğraf Kanunu).
*   **Gazi Protokolü (S.O.S):** Kullanıcı yolda kaldığında 5 saniye boyunca S.O.S butonuna basılı tutar (Yanlış basmayı önlemek için sayaçlıdır). Sistem `Geolocator` ile GPS'i çeker ve bölgedeki bayinin ekranına titreşimli alarm düşürür.

### B. Bayi ve Esnaf Ağı
*   **Kayıt ve Adli Mühür:** Bayiler (Trendyol satıcısı gibi) kaydedilir. Vergi levhalarını sisteme yüklerler. Kayıt tamamlandığında `aktifMi: false` olurlar. Sadece "Yüksek Konsey" (Admin) evrakları onayladığında ilan verebilirler.
*   **İmece Uzmanlık Filtresi:** Bayiler sadece anladıkları alanları (Örn: DSG Şanzıman) seçerler, böylece müşteri "DSG Tamiri" aradığında nokta atışı eşleşme sağlanır.

### C. Mega Market & Kapora Havuzu
*   Sistem, ikinci el otomobil ve sıfır/çıkma yedek parça satışı (Trendyol + Sahibinden Hibrit) üzerine kuruludur.
*   **OtoDNA Payı (Komisyon Motoru):** Parça satışlarında ve kaporalarda sistem otomatik olarak Ciro üzerinden standart %12 kesinti hesaplar. Bu `finans_servisi` içerisinde kuruşu kuruşuna hatasız ve Batch işlemiyle yapılmalıdır.

### D. Merkez Karargah (Süper Admin)
*   `yetki_seviyesi: 99` (Mutlak Güç) atanan kullanıcılar uygulamanın her noktasında silme, değiştirme ve bölge atama hakkına sahiptir. Hiçbir bayi veya kullanıcı Admin müdahalesinden gizlenemez.

---

## 6. YENİ GELİŞTİRİCİYE SON TALİMATLAR
1.  **Güvenlik:** Yeni eklenecek her ekran `ResponsiveKalkan` ile sarılmalı, izinsiz erişimlere karşı `SiberYetkiKalkani` widget'ı ile yetki kontrolünden geçirilmelidir.
2.  **Temiz Kod (Clean Code):** `lib/` kök dizini temiz tutulmalı, kodlar `core/`, `screens/`, `services/`, `models/` ve `widgets/` klasörlerine nizami olarak dağıtılmalıdır.
3.  **Hata Yönetimi (Error Handling):** `try-catch` blokları içinde fırlatılan hatalar kırmızı renkli, şık tasarımlı "Snack-Bar" uyarılarıyla (Örn: `_uyariGoster`) kullanıcıya bildirilmeli, ekranda çirkin kırmızılıklar bırakılmamalıdır.

**OtoDNA; salt bir kod yığını değil, sektörü domine edecek kurumsal bir operasyon zırhıdır. Geliştirmeler bu ciddiyetle yapılmalıdır.**

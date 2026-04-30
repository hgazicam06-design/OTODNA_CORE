# 🧬 OTODNA VİTRİN ANATOMİSİ: İLK AÇILIŞ EKRANI KOKPİTİ

Bu doküman, OtoDNA uygulamasının ikonu tıklandıktan sonra (`_AuthGate` denetiminden geçerek) açılan **"VIP Plaza Giriş Terminali"**nin santim santim dizilimini, yerleşim planını ve her bir bileşenin otonom görevini yeni geliştiriciye dikte etmek için hazırlanmıştır.

Ekranda sıradan veya rasgele yerleştirilmiş hiçbir obje yoktur; her pikselin Karargah standartlarında bir konumu ve görevi vardır.

---

## 1. 🌌 ZEMİN VE ATMOSFER (BACKGROUND)

Uygulama açıldığı an kullanıcıyı boğan koyu/siyah temalar yerine, **Platinum Plaza** vizyonu gereği aydınlık ve lüks bir karşılama yapılır.

*   **Marble (Mermer) Zemin:** Ekranın en alt katmanı (`Positioned.fill`), Sol Üstten Sağ Alta (topLeft to bottomRight) doğru akan bir `LinearGradient` ile boyanmıştır.
*   **Renk Kodları:** Saf Beyaz (`#FFFFFF`), Fildişi (`#F0F0F5`) ve Açık Gri/Platin (`#E8E8EE`).
*   **Amaç:** Kullanıcıya bir sanayi uygulamasında değil, üst düzey bir finans/galeri ekosisteminde olduğunu hissettirmektir.

---

## 2. 🦅 ÜST KONSOL (HEADER ALANI)

Ekranın en üst kısmında, çerçevelere çarpmayan ve nefes alan bir boşlukla (Padding) yerleştirilmiş Karargah kimlik alanı bulunur.

### Sol Üst Köşe: Kimlik Mührü
*   **Ana Başlık:** `OtoDNA` (Boyut: 22, Font: Avenir, Kalınlık: w900). Rengi sert koyu kahvedir (`#2C2519`). Harfler arası boşluk (letterSpacing: 2.0) bırakılarak geniş ve ağır bir duruş sergiler.
*   **Alt Başlık:** Hemen altında `Siber Karargah` (Boyut: 12, Orta Kahve `#8B7355`). Daha ince ve şık bir fontla hiyerarşiyi korur.

### Sağ Üst Köşe: Küresel İletişim (Dil Seçimi)
*   Yan yana duran `TR` yazısı ve minimal bir `Dünya (Language)` ikonu.
*   **Mekanizma:** Geliştiricinin buraya basıldığında bir Dropdown veya BottomSheet açarak (TR, EN, DE) `easy_localization` ile sistem dilini "Anında" değiştireceği köprü buradadır.

---

## 3. 🏦 MERKEZİ KUVVET: VIP GİRİŞ KARTI (CENTER CARD)

Ekranın tam ortasında, mermer zeminin üzerinde havada süzülüyormuş gibi duran (DropShadow uygulanmış) bembeyaz bir Zırhlı Kart bulunur. Tüm güvenlik doğrulamaları bu kartın içindedir.

### A. Karşılama Metni
*   Kartın en üstünde ortalanmış (TextAlign.center) şekilde: *"İyi Günler, Siber Komutan \n Gazi Çam"* yazar.
*   Bu metin statik değildir; ileride cihazın Local Storage (Hive) hafızasından son giren kişinin adını çekerek otonom olarak selamlama yapacak şekilde geliştirilmelidir.

### B. Altın Çerçeveli Girdiler (TextFields)
İki adet veri giriş kutusu alt alta yer alır. Sınırları (Border) `Color(0xFFDCC8A9)` kodlu Altın/Kahve rengindedir.
1.  **Üst Kutu:** E-Posta / Sicil No. Solunda `person_outline` ikonu bulunur.
2.  **Alt Kutu:** Kuantum Şifre. Solunda kilit (`lock_outline`), sağında ise şifreyi göster/gizle eylemini yapan Göz (`visibility`) ikonu yer alır.

### C. Hafıza ve Kurtarma Modülleri (Sol ve Sağ Alt Çapraz)
Girdi kutularının hemen altında iki tarafa yaslanmış butonlar:
*   **Sol Taraf (Şifremi Unuttum):** Altı çizili ve tıklanabilir. İleride Firebase Password Reset modülüne fırlatılacak kablodur.
*   **Sağ Taraf (Beni Hatırla Checkbox):** Standart yuvarlak değil, köşeli ve altın rengi çerçeveli kare bir kutudur. Seçildiğinde içi Gold (`#8B7355`) ile dolar ve bembeyaz bir Tık (✅) ikonu çıkar. (Local Storage veya Secure Storage tetikleyicisi).

### D. Ateşleme: Altın Giriş Butonu
*   Kartın en altında boydan boya uzanan (width: double.infinity), gradient Altın rengine (`#E2C485` > `#C5A059` > `#A57D36`) sahip devasa buton.
*   **Otonomi:** Butona basıldığında şifre kontrolü başlar, butonun içindeki "Giriş Yap" yazısı kaybolur ve yerine beyaz bir `CircularProgressIndicator` (Yükleme Tekerleği) döner. Sonuç haptic titreşimle (titreme) cihaza vurulur.

---

## 4. 🧭 MİSAFİR TERMİNALİ VE AÇIK AĞ RADARI (BOTTOM BAR)

Kullanıcı **sisteme giriş yapmasa dahi**, bir vatandaş olarak (Misafir) OtoDNA ekosistemine dışarıdan bağlanabilmesi için ekranın en dibine kilitlenmiş, üst köşeleri yuvarlatılmış (Radius 32) ve yukarı doğru gölge (Shadow) veren bembeyaz bir panel inşa edilmiştir.

Bu panel, sıradan bir navigasyon menüsü değil, giriş yetkisi olmayan sivil halkın **Otonom Sorgulama ve Satın Alma Önizlemesi** yapabildiği bir Açık Terminaldir.

### A. Sol Kanat (Tedarik ve Tamir)
1.  **⚙️ Parça Tedarik (Mega Market Köprüsü):** 
    *   **İkon:** `settings_outlined`
    *   **Görev:** Misafirlerin şifresiz şekilde OtoDNA Mega Market'e sızıp çıkma/sıfır yedek parça arayabileceği vitrine bağlanır. Misafirler parçaları inceleyebilir ancak satın almak veya kapora yatırmak istediklerinde sistem onları "Kayıt Olmaya" zorlar (Dönüşüm/Conversion Hunisi).
2.  **🔧 Siber Servis (Usta ve Bayi Radarı):** 
    *   **İkon:** `build_outlined`
    *   **Görev:** Yolda kalmış veya tamirci arayan bir vatandaşın, giriş yapmadan etrafındaki tüm "OtoDNA Yetkili Bayilerini" (ve puanlarını) liste üzerinde görebilmesini sağlayan yoldur. Tıklandığında `UstaAramaScreen` (Küresel Usta Radarı) tetiklenir.

### B. Merkez Güç: Devasa Kuantum QR (Araç Pasaport Tarayıcı)
*   **Tasarım:** Menünün tam ortasında, diğer ikonlardan dışarı/yukarı taşan, altın renkli (`#DCC8A9` > `#F9EDD6`) gradyana sahip devasa yuvarlak bir buton.
*   **Haptic Titreşim:** Tıklandığı an cihazın donanım motorunu tetikleyerek ağır bir titreşim (`HapticFeedback.heavyImpact`) verir.
*   **Otonomi ve Görev:** Butona basıldığında cihazın kamerası açılır ve `QrPublicScreen` sayfasına fırlar. Amacı; galerideki veya sokaktaki arabanın camında bulunan **"OtoDNA Kuantum Pasaportu"nu (QR Kod)** taratmaktır.
*   **Güvenlik:** Kod tarandığında, sistem veritabanından aracın "Şeffaf Sicilini" (Değişen parçalar, son bakım tarihi, ekspertiz durumu) çeker ve misafire gösterir. Bu sayede OtoDNA, herkesin kullanabildiği bir "Açık Araç Sicil Merkezi" görevi görür.

### C. Sağ Kanat (Analiz ve Adli Sicil)
3.  **📊 Kuantum Analizler (Rayiç Bedel Motoru):** 
    *   **İkon:** `pie_chart_outline`
    *   **Görev:** Pazar yeri fiyat analizleri ve araç rayiç bedel sorgulama motorudur. Vatandaş araç almadan önce piyasa ortalamasını buradan şifresiz inceleyebilir.
4.  **📋 Operasyon Kontrol (Ekspertiz Doğrulama):** 
    *   **İkon:** `checklist_rtl_outlined`
    *   **Görev:** Satıcının verdiği ekspertiz raporunun gerçek (OtoDNA sistemine kayıtlı) olup olmadığını barkod/şase no ile sorgulamaya yarayan adli doğrulama servisidir.

### Misafir Ağının Felsefesi (Conversion Stratejisi)
Bu Açık Ağ (Misafir Paneli), vatandaşlara OtoDNA'nın gücünü göstermek için tasarlanmış bir **Cazibe Merkezi**dir. Misafirler ücretsiz sicil sorgulamalarını ve usta aramalarını yapıp platforma güvendiklerinde, asıl işlemi (Parça satın alma, randevu alma, kendi aracına pasaport çıkarma) yapmak için mecburen ortadaki "VIP Zırhlı Karta" yönelip sisteme üye olacaktır.

---

## ÖZET TALİMAT (Geliştiriciye)
Bu ekran, uygulamanın **Şeref Kürsüsü**'dür. Ekranda var olan hiçbir padding (boşluk), hiçbir gölge (shadow) veya Altın/Mermer renk tonu keyfi olarak değiştirilemez. 
Uygulamayı çalıştırdığında ekrandaki milimetrik nizam, yukarıdaki hiyerarşiyle birebir eşleşmelidir. Yeni modül eklenecekse bu estetik zırha uyumlu şekilde inşa edilmelidir!

# 🧠 OTODNA AR-GE VE STRATEJİK GELİŞTİRME NOTLARI

Bu belge, OtoDNA platformunun "Kodlama" aşamasından ziyade **"Strateji, Mimari Eksiklikler ve Gelecek Vizyonu"** üzerine Karargah (Yapay Zeka) ve Komutan arasında yapılan beyin fırtınalarını kayıt altına almak için oluşturulmuştur. 

Uygulamanın kodlanması ve inşası yetkili mühendis (Ünal Bey) tarafından yapılacaktır. Bu belgedeki maddeler, mühendise verilecek **"Geliştirme Emirleri / Ar-Ge Vizyonu"** niteliği taşır.

---

## [YAPILACAK] 1. FİNANSAL GÜVENLİK VE ÖDEME GEÇİDİ (Kritik Eksik)
*(Not: Bu madde geliştirme aşamasında en son işlem olarak devreye alınacaktır).*
Şu an uygulamamızda %12'lik komisyon kesintileri ve "Güvenli Kapora Havuzu" mantığı kodlanmış/kurgulanmış durumda. Ancak gerçek paranın döndüğü bir sistemde şu entegrasyonlar eksiktir:
*   **Sanal POS Entegrasyonu:** iyzico, PayTR veya Param gibi lisanslı bir ödeme kuruluşunun API'sinin sisteme gömülmesi gerekiyor.
*   **Cüzdan (Wallet) Mantığı:** Kapora yatırıldığında para doğrudan satıcıya gitmemeli, BDDK onaylı bir "Emanet Havuzunda" (Escrow) beklemelidir. Satış noterden geçtikten sonra komisyon kesilip para satıcıya aktarılmalıdır.

## [YAPILACAK] 2. LOJİSTİK VE KARGO AĞI ENTEGRASYONU (Mega Market İçin)
Oto Market (Yedek Parça) bölümünde Trendyol mantığı kurduk ancak ürün satıldığında ne olacak?
*   **Kargo API Bağlantısı:** Yurtiçi Kargo, Aras veya MNG Kargo API'leri sisteme entegre edilmelidir.
*   **Otonom Kargo Kodu:** Bir parça satıldığında sistem otonom olarak barkod üretmeli ve "Kargo Gönderi Kodu" satıcının ekranına düşmelidir. Alıcı ise uygulamasından kargonun nerede olduğunu anlık (haritadan) takip edebilmelidir.

## [YAPILACAK] 3. WEB TABANLI "SÜPER ADMİN" KARARGAHI (Yönetim Eksikliği)
Şu an sistem yöneticisi (Super Admin) paneli mobil uygulama içerisinde yer alıyor.
*   **Zorluk:** On binlerce ilanı, bayiyi, itirazı ve S.O.S sinyalini küçük bir cep telefonu ekranından yönetmek profesyonel bir şirket için zordur.
*   **Çözüm:** Flutter Web kullanılarak, sadece yöneticilerin girebildiği geniş ekranlı (Dashboard) bir **OtoDNA Masaüstü Web Karargahı** yazılmalıdır. Finans grafikleri ve harita üzerinden bayi takibi dev ekranlarda yapılmalıdır.

## [YAPILACAK] 4. HUKUKİ ZIRH: DİJİTAL ZAMAN DAMGASI (Blockchain / Hash)
OtoDNA ekspertiz ve bakım raporları mahkemelerde delil sayılmalıdır.
*   **Eksiklik:** Firebase'de tutulan veriler teorik olarak (admin tarafından) değiştirilebilir. Bu durum raporun hukuki gücünü sarsar.
*   **Çözüm:** Oluşturulan her OtoDNA Kuantum Sicil Raporu PDF'ine, Devlet onaylı bir e-imza veya "SHA-256 Dijital Zaman Damgası" vurulmalıdır. Böylece rapor "Düzenlendiği saniyeden itibaren tek bir virgülü bile değiştirilmemiştir" şeklinde yasal garanti altına alınır.

## [YAPILACAK] 5. BÜYÜME VE PAZARLAMA: OYUNLAŞTIRMA (Gamification)
Sistemin kendi kendini (viral olarak) büyütmesi için bir mekanizma eksiktir.
*   **Davet Et, Kazan (Referral):** Uygulamayı kullanan bir sivil, arkadaşını sisteme davet eder ve arkadaşı aracına "Kuantum Pasaport (QR)" alırsa; her iki tarafa da "200 TL OtoDNA Bakım İndirimi" tanımlanacak bir promosyon motoru yazılmalıdır.

## [YAPILACAK] 6. CLOUD FUNCTIONS (BULUT) ZORUNLULUĞU
*   Uygulamanın içindeki hesaplama kodları (Örn: `fiyat * 0.12`) kötü niyetli kişilerce manipüle edilebilir (Tersine mühendislik ile). 
*   **Talimat:** "Tüm para kesintileri, cüzdan güncellemeleri ve kara liste banlamaları uygulamanın içinde değil, Firebase Cloud Functions (Arka Uç - Node.js) tarafında çalışacak şekilde taşınmalıdır."

---

## 🚀 İLERİ DÜZEY AR-GE VİZYONU (GELECEK SÜRÜMLER İÇİN)

### [YAPILACAK] 7. Kuantum Otonom Ekspertiz (Görsel Yapay Zeka ve Kapalı İhale)
Kullanıcı kazalı parçasının fotoğrafını çeker, Gemini AI (Vision) saniyeler içinde değişmesi gereken parçaları ve tahmini masrafı detaylı şekilde (OtoDNA Rayiç Bedeline göre) çıkarır. 
*   **Kapalı İhale Süreci:** Bu talep rastgele en yakın bayiye değil, doğrudan "Kaporta ve Boya" uzmanlığına sahip bayilerin ekranına düşer. Süreç bir **"Kapalı İhale"** usulüyle işler. Sadece ilgili bayiler teklif verir ve bu teklifleri pazar yeri gibi herkes göremez. Yalnızca işlemi başlatan araç sahibi kendisine gelen teklifleri ve bayi puanlarını görüp aralarından seçim yapar.
*   **Siber Mahkeme (Çift Taraflı Adalet) ve Öncesi/Sonrası Onayı:** Kullanıcı, onarım işlemi bittiğinde aracın "Öncesi ve Sonrası" (Before & After) görsellerini sisteme yükler ve memnuniyet oranını yayınlar. Eğer onarım memnun edici değilse süreç hemen "kötü yorum" olarak işlenmez; sistem **Siber Mahkeme**'yi kurar. Mahkeme sadece firmayı değil, **kullanıcıyı da** denetler:
    *   **Firma Kusuru:** Kötü işçilik veya eksik işlem kanıtlanırsa, firma savunması alınır ve yetersizse Karargah erişimi kısıtlanır.
    *   **Kullanıcı Kusuru:** Kullanıcının, ihale anlaşması dışında ekstra (bedava) iş çıkarmaya çalıştığı veya firmayı karalamak amacıyla haksız yere kötü yorum/puan verdiği tespit edilirse, bu kez **kullanıcının savunması alınır**. Haksız karalama yapan sivil kullanıcıların da platformdaki işlem yapma yetkileri acımadan **kısıtlanır/banlanır**. Adalet Kuantum ağının temelidir.

### [YAPILACAK] 8. IoT ve Araç Telemetri (OBD2) Entegrasyonu
Yazılıma ek olarak Bluetooth özellikli (Örn: ELM327 veya muadili donanımsal çiplerle) **OtoDNA OBD2 Dongle** üretilmeli/tedarik edilmelidir.
Kullanıcı bu çipi aracına taktığında sistem şu Kuantum operasyonlarını gerçekleştirir:
*   **Geniş Çaplı Arıza Tespiti:** Sadece motor değil; Airbag, ABS, Mekanik ve Elektronik tüm arıza kodlarını (DTC) okur.
*   **Arıza Kodu Silme (Reset):** Kullanıcı basit hata kodlarını veya geçici ikazları uygulama üzerinden tek tuşla silebilir.
*   **Canlı İkaz ve Risk Radarı:** Araç motorunda hararet (su sıcaklığı) yükseldiğinde, şarj (voltaj) düştüğünde veya kritik bir sistem hatasında uygulama anında siren çalarak sürücüyü uyarır.

### [YAPILACAK] 9. Sadakat Puanı ve Dijital Cüzdan (DNA Token)
Müşterilerin uygulamaya bağlılığını artırmak için kapalı devre bir puan/kripto sistemi. Kullanıcı kaza yapmadan geçirdiği her ay, yetkili servislerden aldığı her hizmet veya sisteme davet ettiği her yeni araç için "DNA Token" kazanır. Bu tokenlar Mega Market'te motor yağı alırken indirim olarak kullanılır.

### [KESİN YAPILACAK] 10. Artırılmış Gerçeklik (AR) Parça Uyumluluk Radarı
Kullanıcı Mega Market'te bir çelik jant, rüzgarlık veya multimedya ekranı beğendiğinde, telefonunun kamerasını kendi aracına tutar. Artırılmış Gerçeklik (ARCore/ARKit) sayesinde o parçanın kendi aracının üzerinde fiziksel olarak nasıl duracağını satın almadan önce otonom olarak (3D) görür.

### [KESİN YAPILACAK] 11. Siber Konum Hafızası (Açık ve Kapalı Alan Araç Bulucu)
Kullanıcının ister sokakta, ister ormanda, ister yer altı otoparkında olsun "Aracım tam olarak nerede?" sorununu OBD2 çipi olmadan (yazılımla) net bir şekilde çözmek için Kuantum Ağı aşağıdaki 5 aşamalı kalkanı devreye sokar:
*   **Çözüm 1: Otonom GPS Sabitleme (Açık Alanlar İçin):** Kullanıcı araca binip Bluetooth ile teybe/multimedyaya bağlandığında sistem bunu bilir. Motor durdurulup kullanıcı araçtan uzaklaştığında **Bluetooth bağlantısı kopar**. Uygulama bu kopma anını bir tetikleyici (Trigger) olarak kullanır ve o saniyelik net GPS koordinatlarını (açık havadaysa) arka planda otonom olarak kaydeder. Kullanıcı döndüğünde uygulama ona yaya navigasyonu ile araca kadar metre metre yol tarifi verir.
*   **Çözüm 2: Akıllı Fotoğraf (Görsel Bilet):** GPS'in koptuğu kapalı otoparklarda kullanıcı park anında kolonun (Örn: B-4) fotoğrafını çeker. Uygulama bu fotoğrafı saat, tarih ve kat bilgisiyle birlikte "Otopark Biletiniz" olarak ana ekrana sabitler.
*   **Çözüm 3: Zemin İçi Haritalama (Indoor Mapping):** Büyük AVM ve hastanelerin otopark planları (A Blok, B Blok vb.) uygulamanın harita sistemine gömülür. Kullanıcı park anında, sistemin sunduğu bu kapalı alan haritasına manuel olarak "Buraya Park Ettim" pini bırakır.
*   **Çözüm 4: Barometrik Kat Hafızası:** Akıllı telefonlardaki barometre (basınç sensörü) kullanılarak, araç park edildiği andaki rakım/basınç kaydedilir. Dönüşte sistem hava basıncı farkına bakarak *"Aracınız -3. Katta"* şeklinde nokta atışı kat tespiti yapar.
*   **Çözüm 5: Wi-Fi ve Hücresel Ağ Üçgenlemesi:** Kapalı alanda içerideki Wi-Fi ağlarının veya baz istasyonlarının sinyal güçleri analiz edilerek aracın tahmini bölgesi haritada daraltılır.

*(Not: Madde 8'deki OBD2 Çipi ilerleyen aşamalarda bu sisteme entegre edilerek zifiri karanlıkta bile "Sıcak/Soğuk" sinyal radarı olarak eklenecektir).*

### [YAPILACAK] 12. e-Devlet ve Finansal Araç Zırhı (HGS, Ceza, Haciz ve Men Entegrasyonu)
OtoDNA, aracın sadece mekanik değil, "Resmi ve Finansal" sağlığını da takip eden bir siber kalkan görevi görür:
*   **Otonom HGS/OGS Radarı (VIP/Ücretli Abonelere Özel):** Araç GPS üzerinden ücretli bir yola veya köprüye yaklaştığında sistem sürücüyü otoyolun tam ücretini belirterek uyarır. Eğer girilen otoyolun içinde ekstra ücretli başka bir yol (Örn: özel tünel veya köprü) varsa onu da önceden hesaplayıp söyler. Kullanıcı gişeden geçerken cüzdandaki kayıtlı kredi kartı ile tek tuşla geçiş ücreti anında Karargah üzerinden ödenir. Bu özellik, API ve altyapı maliyetlerinden dolayı ücretsiz (Standart) kullanıcılara kapalı olup, sadece Premium/Ücretli abonelerin erişebileceği elit bir donanımdır.
*   **Ceza ve Araç İşlemleri Siber Rehberi:** Uygulama, araca kesilen cezayı veya borcu sadece bir uyarı olarak göstermez; sürecin detaylı bir otopsisini sunar. "Ceza tam olarak nerede yenildi, hangi kamera/radar tespit etti, net ücret ne kadar ve %25 erken ödeme indiriminden faydalanmak için son tarih ne zaman?" gibi tüm verileri listeler. Ayrıca "Aracınız otoparka çekildi" veya "Plaka düştü/çalındı" gibi acil resmi durumlarda; *"Aracınız hangi yediemin otoparkına çekildi, çekici/otopark ücreti ne kadar, nereye başvurulacak, hangi evraklar gerekli?"* şeklinde vatandaşa adım adım bir **"Nasıl Çözülür?"** navigasyonu (Siber Rehber) sunar.
*   **Haciz, Rehin ve Trafikten Men Asistanı:** Aracın üzerinde haciz, rehin veya "Trafikten Men" (Çekme Belgeli) durumu varsa uygulama bunu tespit eder ve kullanıcıyı uyarır.
    *   *Meni Kaldırma Operasyonu:* Eğer men sebebi "Muayene Eksikliği" ise uygulama otonom olarak **TÜVTÜRK randevusu** alır ve muayene eksikliklerini (Örn: Far ayarı, fren testi) gidermek için aracı en yakın "OtoDNA Kuantum Garaj" ustalarına yönlendirir.
    *   Eğer men sebebi "Vergi/Ceza Borcu" ise, sistem borçları listeler, kullanıcı ödemeyi yapar ve OtoDNA (hukuki rehberlik sunarak) men kaldırma sürecini otonom olarak yönetir.
### [YAPILACAK] 13. Siber Garaj Geçmişim (OtoDNA Bayi Ziyaret Günlüğü)
Uygulamada kullanıcının tüm servis ve bayi etkileşimlerini saklayan "Geçmişim" adında detaylı bir log (kripto sicil) sayfası oluşturulacaktır. Bu sayfa sıradan bir liste değil, aracın dijital sağlık karnesi gibi çalışır:
*   **Ziyaret Detayları:** Hangi OtoDNA bayisine (Örn: X Oto Kaporta), hangi tarihte ve saatte gidildi? 
*   **İşlem ve Finansal Otopsi:** O ziyarette araca hangi işlemler yapıldı, hangi parçalar değişti ve Karargah üzerinden toplam ne kadar ücret ödendi?
*   **Garanti ve Siber Mahkeme Kayıtları:** Değişen parçaların "Garanti Süresi Kalan Gün" sayacı, kullanıcının o ziyarette yüklediği "Öncesi/Sonrası" fotoğrafları ve eğer yaşandıysa Siber Mahkeme (itiraz/savunma) sonuçları bu sayfada şeffafça listelenir.
*   **Bayi Sadakat Skoru:** Kullanıcı aynı bayiyi birden fazla kez ziyaret ettiyse, sistem o bayiye özel sadakat indirimlerini bu ekrandan otonom olarak hesaplayıp kullanıcıya teklif eder.

### [YAPILACAK] 14. Kuantum Hukuk ve Trafik Asistanı (Yapay Zeka Sesli Yanıt)
Kullanıcıların trafik kuralları ve kanunlarla ilgili her türlü kriz anında danışabilecekleri, Karargah destekli otonom bir "Hukuk Asistanı" entegre edilecektir:
*   **Detaylı Hukuki Analiz:** Kullanıcı örneğin *"Ehliyetsiz araç kullanmanın cezası nedir?"* diye arattığında, asistan yüzeysel bir cevap vermez. Detaylı bir kanun otopsisi yapar: 
    *   *Sürücüye kesilen ceza ne kadar?*
    *   *Araç sahibi farklıysa ona kesilen ek ceza (Ruhsat sahibine ceza) ne kadar?*
    *   *İlk yakalanma ile ikinci yakalanma arasındaki katlamalı farklar nelerdir?*
*   **Kriz Anı Yönlendirmesi:** *"Aracımda uygunsuz/yasaklı bir şey yakalattım, ne olur?"* veya *"Çevirmeye alkollü girdim"* gibi spesifik ve adli sorularda sistem Karayolları Trafik Kanunu ve TCK (Türk Ceza Kanunu) maddelerine göre net, detaylı ve bağlayıcı olmayan hukuki rehberlik sunar.
*   **Sesli (Voice) Yanıt Sistemi:** Panik anında veya direksiyon başında kullanıcının uzun metinler okumasına gerek kalmaz. Yapay Zeka entegrasyonuyla asistan tüm hukuki senaryoları ve cezaları vatandaşa bir avukat gibi **sesli olarak (yazılıya ek olarak)** anlatır.

---
*Not: Bu belge, Karargah strateji toplantıları sonucunda Ünal Bey'in yol haritasını beslemek için mühürlenmiştir.*

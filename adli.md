# ⚖️ OTODNA SİBER MAHKEME: ADLİ VAKALAR VE TÜKETİCİ HAKLARI PROTOKÖLÜ

Bu belge, otomotiv sektöründe sıklıkla karşılaşılan hukuki ihtilafları, ayıplı mal davalarını ve OtoDNA "Siber Mahkeme" modülünün tüketiciyi/ustayı koruyan dijital adli süreçlerini tanımlar.

---

## 1. SIFIR ARAÇLARDA AYIPLI MAL VE FABRİKA DİRENCİ

Müşteri sıfır (0 KM) bir araç satın aldığında ve araçta üretim kaynaklı bir kusur (ayıp) çıktığında, fabrikalar ve yetkili distribütörler genellikle aracı yenisiyle değiştirmek yerine "sürekli tamir (tedavi) yoluna gitmeyi" tercih ederler. Bu durum kullanıcıyı mağdur eder ve aracın piyasa değerini düşürür.

### Tüketicinin Korunması Hakkında Kanun (TKHK) Madde 8-11
Tüketicinin ayıplı bir araç karşısında 4 adet **Seçimlik Hakkı** bulunur:
1.  **Sözleşmeden Dönme (Bedel İadesi):** Aracı iade edip parasını kuruşu kuruşuna geri alma.
2.  **Ayıp Oranında Bedel İndirimi:** Araçtaki kusur kadar (değer kaybı) iade talep etme.
3.  **Ücretsiz Onarım:** Fabrikadan kusurun ücretsiz giderilmesini talep etme.
4.  **Misliyle Değişim:** Aracın ayıpsız (kusursuz) yenisi ile değiştirilmesini talep etme.

**Kritik Kural:** Garanti süresi içinde bir araç aynı arızayı ikiden fazla tekrarlarsa veya farklı arızalar nedeniyle toplamda dörtten fazla servise giderse ve bu durum aracın kullanılmamasını sürekli kılarsa, tüketici **doğrudan misliyle değişim veya bedel iadesi** talep edebilir. Fabrika bunu reddedemez.

---

## 2. FABRİKANIN REDDİ DURUMUNDA OTODNA SİBER MAHKEME MÜDAHALESİ

Eğer fabrika değişime direnirse, OtoDNA "Siber Mahkeme" modülü kullanıcıyı şu dijital zırhlarla korur:

### A. Değiştirilemez (Immutable) Servis Logları
Kullanıcı aracı her servise götürdüğünde, OtoDNA sistemi giriş-çıkış saatlerini, değişen parçaları ve arıza şikayetlerini `WriteBatch` kullanarak Kuantum Ağında mühürler. Bu veriler (timestamp) mahkemede değiştirilemez **Kesin Dijital Delil** niteliği taşır. "Siz aracı servise getirmediniz" yalanını engeller.

### B. OtoDNA Siber Bilirkişi Raporu
Platformdaki bağımsız yetkili OtoDNA Eksperleri, araçtaki arızanın kullanım hatası mı yoksa fabrikasyon (üretim hatası) mu olduğunu dijital ekspertiz kokpitinde görüntülü kanıtlarla mühürler. Bu rapor, Tüketici Mahkemelerinde ön-bilirkişi raporu olarak kullanılır.

### C. Kuantum Değer Kaybı Hesaplayıcısı (Amortisman)
Sürekli tamir gören sıfır bir aracın, Tramer'e yansımasa bile piyasa algısında (boyalı, şanzıman inmiş vb.) yaşadığı değer kaybı, OtoDNA AI Motoru tarafından hesaplanır. Eğer müşteri misliyle değişim alamıyorsa, mahkemeye "Şu kadarlık değer kaybı tazminatı (Bedel İndirimi) talep ediyorum" şeklinde bilimsel bir rapor sunar.

### D. Adli Dilekçe Üreticisi
Kullanıcı, Siber Mahkeme terminalinden "Dava Aç" butonuna tıkladığında; yapay zeka aracın tüm servis geçmişini, arıza loglarını ve ekspertiz kanıtlarını derleyerek **Tüketici Hakem Heyeti** veya **Tüketici Mahkemesi** için resmi formata uygun bir hukuk dilekçesi (PDF) üretir. 

---

## 3. OTOMOTİV SEKTÖRÜNDE SIK YAŞANAN ADLİ VAKALAR

OtoDNA'nın kayıt altına aldığı ve şeffaflaştırmayı hedeflediği ana adli suçlar ve ihtilaflar şunlardır:

### 3.1. Kilometre (Odometer) Düşürme (Nitelikli Dolandırıcılık)
*   **Vaka:** İkinci el değerini artırmak için aracın kilometresinin beyin (ECU) veya gösterge üzerinden silinmesi/düşürülmesi. Yargıtay bunu "Nitelikli Dolandırıcılık" sayar.
*   **OtoDNA Çözümü:** `otonom_bakim_motoru` aracın her muayene, servis ve bakım logunu silsile halinde zincirler. Kilometrede geriye gidiş veya tutarsızlık tespit edildiğinde araca **"KIRMIZI X (KİLOMETRE ŞÜPHESİ)"** damgası vurulur.

### 3.2. Gizli Hasar ve "Boyasız/Hatasız" Yalanı
*   **Vaka:** Ağır hasar almış, takla atmış veya iki farklı aracın kaynakla birleştirilmesi (Eklemeli araç) durumu. Satıcının aracı "Hatasız, Boyasız" diye satması.
*   **OtoDNA Çözümü:** `gercek_ekspertiz_terminali` üzerinden yapılan mikron ölçümleri ve `CorporateAIEngine` kaporta kaynak analizi sayesinde, araç Karargah kayıtlarına bir kez "Hasarlı" olarak mühürlendiğinde, satıcı ilan verirken bunu gizleyemez.

### 3.3. Çalıntı Araç ve Change (Şase Değiştirme) İşlemi
*   **Vaka:** Çalıntı bir aracın şase numarasının, ağır hasarlı/pert olmuş aynı model başka bir aracın şase numarasıyla değiştirilerek (Change) trafiğe sokulması.
*   **OtoDNA Çözümü:** Uygulama içindeki "Siber Göz" OCR tarayıcısı, ruhsattaki şase numarası ile camdaki/motordaki şase numarasını ve OBD cihazından gelen ECU şase bilgisini çapraz doğrular. Uyuşmazlık anında "SİBER İHLAL" alarmı verilir.

### 3.4. Sahte (Yan Sanayi) Parçanın Orijinal Diye Satılması
*   **Vaka:** Yetkili veya özel servisin, müşteriden Orijinal (OEM) parça parası alıp araca kalitesiz yan sanayi veya çıkma parça takması.
*   **OtoDNA Çözümü:** Parça montajı sırasında `siber_parca_degisim_screen` üzerinden kutunun barkodu ve faturası okutulmak zorundadır. Sistem OE numaralarını doğrular, sahtekarlık tespit edilirse ustanın ödemesine blokaj koyar ve Karargaha raporlar.

### 3.5. Yanlış Onarım Sonrası Ağır Motor Arızaları
*   **Vaka:** Triger kayışı değişiminde sente atlaması veya yanlış yağ kullanımı sonucu motorun yatak sarması. Ustanın suçu müşteriye (kullanım hatası) atması.
*   **OtoDNA Çözümü:** "Kusur Hakemliği" devreye girer. Ustanın bakım öncesi ve sonrası girdiği loglar, kullanılan yağın viskozite kodu Karargah kayıtlarında mevcuttur. Kusurun ustada olduğu tespit edilirse "OtoDNA Çapraz Garanti" sistemi müşterinin zararını karşılar ve faturayı hatalı bayiye rücu eder.

---

## 4. MOTOR DEĞİŞİMİ VE RUHSAT BÜROKRASİSİ (SİBER REVİZYON)

Bir aracın motor değişimi (Sandık veya Çıkma) Kuantum Ağında "Mega Revizyon" olarak izlenir ancak uygulamanın ticari ve hukuki işleyişi gerçek dünya koşullarına (bürokrasiye) göre otonom şekillenir:

### 4.1. İşlem Bekleme ve Muayene Radarı
Motor değişimi yapılıp sisteme girildiğinde (OtoDNA veya dışarıdan bir servis aracılığıyla), ruhsata yeni motor numarasının işlenmesi gerekir.
*   **Bekleme Süresi:** Sistem, aracın mevcut TÜVTÜRK muayene geçerlilik tarihine kadar bekler ve araca otonom olarak **"İşlem Bekliyor: Motor Kaydı Yapılmadı"** sarı kodlu uyarısını asar.
*   **İhlal ve Kayıt Dışı Durumu:** Eğer muayene tarihi geçer ve istasyonda gerekli proje onayları/ruhsat güncellemeleri yapılıp sisteme yansıtılmazsa, sistem aracın statüsünü **"Motor Değişmiş, Kayıtlı Değil"** olarak kırmızı kodla mühürler.

### 4.2. Özgür Ticaret ve Şeffaf Satış
Eğer araç sahibi ruhsat yenileme bürokrasisiyle uğraşmak istemeyip aracı satmak isterse, **Karargah bu satışa engel koymaz (Satış kilitlenmez).**
Bunun yerine "Şeffaflık Protokolü" devreye girer: Aracı alacak olan kişi (yeni müşteri), Karargah vitrininde veya QR okutmasında aracın DNA şeceresini incelerken **"Motor Değişmiş, Kayıtlı Değil"** uyarısını açıkça görür. Tüm hukuki sorumluluk, karar ve pazarlık gücü alıcı ile satıcı arasına bırakılır.

### 4.3. Karargah Finansal Kuralı (Komisyon Sınırı)
*   **Uygulama İçi Motor Satışı:** Eğer motor (Sandık/Çıkma) OtoDNA yedek parça ağından, Kuantum Sepet üzerinden satılmışsa Karargah işlemi atomik olarak (`WriteBatch`) mühürler ve **%12 Komisyon (Gazi Payı)** kesintisini tahsil eder.
*   **Dışarıdan (Harici) İşlemler:** Eğer motor değişimi OtoDNA pazar yeri dışında (harici bir kanalla) gerçekleşmiş ancak Karargah sistemine sadece bilgi/sicil olarak yansıtılmışsa, Kuantum finans motoru devreye girmez. Platform üzerinden gerçekleşmeyen bir alışverişten Karargah payı alınamaz; işlem sadece "Sicil Kaydı" olarak tutulur.

### 4.4. Siber Evrak ve Dijital Torpido Zırhı
Motor değişimi işlemi sisteme işlenirken resmi dayanak bulundurulması sağlanır:
*   **Fatura Mevcutsa:** Yeni alınan veya çıkma motorun resmi faturası (PDF veya Fotoğraf) sisteme yüklenerek aracın **"Dijital Torpidosuna"** ebediyen mühürlenir.
*   **Fatura Yoksa:** Eğer işleme ait resmi bir fatura yoksa (dışarıdan alınmış veya eski bir işlemse), işlemi gerçekleştiren servisin oluşturduğu detaylı **"Servis İşlem Kaydı"**, yapılan revizyonun yegane ispatı olarak Dijital Torpidoya kaydedilir. Alıcılar, motorun tarihçesini bu evraklar/kayıtlar üzerinden doğrular.

---

## 5. TRAFİK CEZASI İTİRAZLARI VE SİBER TRAFİK ASİSTANI (HUD)

OtoDNA Karargahı, sürücüleri trafikteki olası ihlallere karşı hem önceden koruyan (Erken Uyarı Radarı) hem de haksız yere ceza yediklerinde savunan (Adli Dilekçe Üreticisi) çift katmanlı bir Siber Trafik Zırhına sahiptir.

### 5.1. Otonom Adli İtiraz Sistemi (Dijital Savunma)
Hatalı kesilen bir trafik cezası (Radar, hatalı park, EDS ihlali vb.) tebliğ edildiğinde, süreç şu adımlarla otonom olarak işler:
1.  **Optik Okuma ve Torpido Mührü:** Kullanıcı, ceza makbuzunu kamerayla taratır. `Siber Göz` (OCR), ceza maddesini (Örn: 51/2-a, 47/1-b), tarih/saati ve konumu okur. Makbuz, kaybolmaması için anında "Dijital Torpido" kasasına ebediyen mühürlenir.
2.  **Siber İstihbarat ve Alibi (Kanıt) Doğrulaması:** Sistem, cezanın kesildiği tarih ve saatteki Karargah GPS loglarına (`smart_tracking`) bakar. Eğer aracın o saatte o konumda olmadığı (ikiz plaka) veya hız limitini aşmadığı kanıtlanırsa, bu veri siber savunmanın temeli olarak ayrılır.
3.  **Sesli Savunma Dinleme (Yapay Zeka Asistanı):** Uygulama, *"Sizi dinliyorum, bu cezaya neden itiraz ediyorsunuz?"* diyerek kullanıcının savunmasını (Sesli Komut veya Metin) alır. Örn: *"Orada park yasak tabelası yoktu, ayrıca acile hasta bırakıyordum."*
4.  **Dilekçe Üretimi ve PDF Çıktısı:** `CorporateLegalEngine` (Karargahın Hukuk Yapay Zekası), kullanıcının sesli anlattığı mazereti hukuki ve teknik bir dile takla attırır. 2918 sayılı Karayolları Trafik Kanunu maddelerini ve Karargah GPS loglarını referans göstererek saniyeler içinde **Sulh Ceza Hakimliğine** verilmek üzere resmi, profesyonel bir itiraz dilekçesi (PDF) oluşturur. Kullanıcıya düşen tek şey bu PDF'in çıktısını alıp imzalamaktır.

### 5.2. Siber Trafik Asistanı ve Yol Bilgisayarı (Seyahat HUD)
Trafik cezalarını yemeden önce kullanıcıyı korumayı hedefleyen, cihazın ön cama yansıtıldığı (HUD) `yol_bilgisayari_screen.dart` arayüzü şu siber radarları barındırır:
*   **Dinamik Hız Radarı ve Limit Asistanı:** GPS üzerinden, kullanıcının o an seyrettiği yolun yasal Asgari ve Azami hız limitlerini (Örn: Şehirlerarası bölünmüş yol 110 km/s) Karargah haritasından çeker. Kullanıcı limiti aştığında (Örn: 125 km/s ile giderken) onu kırmızı alarmlarla boğmaz. Cam efekti (Glassmorphism) barındıran ince bir hız barı turuncuya döner.
*   **Canlı Ceza Hesaplayıcı (Risk Analizi):** Hız limiti %10-%30, %30-%50 veya %50 üzerinde aşıldığında sistem o anki aşım dilimine karşılık gelen Karayolları ceza tarifesini hesaplar. Ekranda küçük bir kalkan ikonunun yanında *"Tahmini Risk: Olası Radar Cezası 1.506 ₺"* şeklinde anlık ve psikolojik bir uyarı fırlatır. Kullanıcı ayağını gazdan çektiğinde bu uyarı otonom olarak silinir.
*   **Kronik İhlal ve Ceza Haritası:** OtoDNA ağına bağlı diğer araçların daha önce hangi koordinatlarda, hangi cezaları yediği anonimleştirilerek haritada "Sıcak Bölgeler (Heatmap)" olarak birleştirilir.
*   **Proaktif Lokasyon Uyarıları:** 
    *   Sistem, kullanıcının bulunduğu koordinatlarda (Örn: Okul Bölgesi veya Elektronik Denetleme Sistemi - EDS) aktif bir radar olma ihtimali varsa *"Dikkat: Bu bölgede kronik radar/EDS ihlali mevcuttur"* şeklinde otonom sesli asistan uyarısı verir.
    *   Araç, park yapılmasının yasak olduğu veya yüksek park cezası yazılan bir koordinatta kontağı kapattığında (Park Statüsüne geçtiğinde), cihaz titrer (Haptic Feedback) ve bildirim atar: *"Siber Uyarı: Bulunduğunuz lokasyonda park ihlali cezası riski yüksektir. Güncel park cezası tutarı: 690 ₺"* diyerek sürücüyü korur.

---

## 6. TİCARİ ARAÇLAR: TAKSİMETRE GÜNCELLEMELERİ VE SİBER TARİFE

Taksiler gibi ticari araçların fiyat tarifelerinin değişmesi, hem fiziksel hem de dijital bürokrasi gerektirir. OtoDNA bu sorunu iki koldan çözer:

### 6.1. Fiziksel Taksimetre Güncelleme (Randevu Radarı)
Belediye (UKOME) taksimetre fiyatlarına zam yaptığında, taksiciler sanayi sitelerinde uzun kuyruklar oluşturur. 
*   **Siber Sıra Yönetimi:** OtoDNA yetkili taksimetre kalibrasyon ve mühürleme servisleri, UKOME kararından saniyeler sonra Karargahtan taksicilere bildirim atar: *"Yeni tarife güncellendi, beklemeden güncellemek için randevu alın."*
*   Taksiciler `siber_randevu_terminali` üzerinden boş saati alır. Güncelleme yapıldığı an servisin kestiği e-Fatura ve **Sanayi Bakanlığı Mühür Formu** doğrudan taksicinin "Dijital Torpidosuna" kaydedilir.

### 6.2. OtoDNA "ÇIĞIR" Ulaşım Ağı (Otonom Taksimetre)
Eğer taksici (veya VIP Transfer) yolcuyu doğrudan OtoDNA'nın kendi ulaşım modülü olan **"ÇIĞIR"** (`otodna_cigir_screen.dart`) üzerinden taşıyorsa:
*   Yolculuk başladığı an telefonun GPS'i üzerinden Kuantum Taksimetre çalışır ve yolculuk sonunda hem müşteriye hem şoföre net fiyat çıkarılır. Zamlı tarife otonom olarak ve hileye kapalı şekilde uygulanmış olur.

---

## 7. KİŞİSEL VERİLERİN KORUNMASI VE ARAÇ DEVİR (SİBER TEMİZLİK) PROTOKOLÜ

Bir araç ikinci elde satıldığında ve Karargah üzerinden **Araç Devir (Mülkiyet Aktarımı)** işlemi gerçekleştiğinde, eski sahibine ait kişisel verilerin (KVKK) korunması için otonom bir "Siber Temizlik" kalkanı devreye girer:

### 7.1. Dijital Torpido Temizliği (Sıfırlama)
Araç devri onaylandığı milisaniye içinde `arac_devir_servisi` çalışır ve Dijital Torpido'yu ikiye ayırır:
*   **Silinen Şahsi Dosyalar:** Eski kullanıcıya ait tüm trafik cezası makbuzları, yakıt fişleri, şahsi ehliyet fotoğrafları, araç ruhsat kopyası (kişisel bilgileri içerdiği için) ve OGS/HGS dökümleri atomik bir işlemle (`FieldValue.delete`) tamamen imha edilir. Yeni alıcı bunları kesinlikle göremez.
*   **Korunan Genetik Dosyalar (Araç Sicili):** Aracın genetiğini (DNA'sını) ilgilendiren teknik belgeler ise ebediyen kalır. Ekspertiz raporları, Motor Değişim (Revizyon) faturaları, ağır bakım servis fişleri, değişen yedek parça garanti sertifikaları ve "Kırmızı X" ihlal logları silinmez. Bu belgeler yeni sahibinin "Dijital Torpidosuna" aracın kusursuz özgeçmişi olarak aktarılır.

---

## 8. S.O.S MÜDAHALE VE LİYAKAT MOTORU (KRİZ YÖNETİMİ)

Acil durumlarda (Kaza, yolda kalma, şarj/yakıt bitmesi) fırlatılan S.O.S sinyallerinin yönetimi, Karargahın "Liyakat Algoritması" ile bayiler arasında bir prestij ve hayatta kalma yarışına dönüştürülür:

### 8.1. Ödül, Ceza ve Şeffaf Radar
*   **Ödüllendirme (Kuantum Boost):** Bölgesine düşen S.O.S sinyaline *"Müdahale Ediyorum"* diyerek sahaya inen ve sorunu çözen bayi/çekici, sistem tarafından otonom olarak ödüllendirilir. Arama sonuçlarında (SEO) üst sıralara çıkarılır, komisyon oranlarında anlık indirimler kazanır ve profiline "Siber Kahraman" rozeti işlenir. Çalışan her zaman üste çıkar.
*   **Cezalandırma (Siber Düşüş):** Radarına S.O.S sinyali düşmesine rağmen sürekli *"Reddet"* diyen veya sinyali görmezden gelen firmaların "İtibar Puanı" yapay zeka tarafından sinsice düşürülür. Algoritma bu firmaları zamanla vitrinin en karanlık sayfalarına iter.
*   **Bayi Arası Şeffaflık:** Fırlatılan bir S.O.S sinyalini hangi firmanın üzerine aldığı, o bölgedeki diğer tüm bayiler tarafından harita üzerinde şeffafça görülür. (Örn: *"Gazi Oto Kurtarma sinyali devraldı"*). Bu, bayiler arasında rekabet yaratır ve sahipsiz iş kalmasını önler.

### 8.2. Kuantum Kapanış Raporu (Mühürleme)
S.O.S krizi başarıyla çözüldüğünde sisteme bir **"S.O.S Başarıyla Giderildi"** bildirimi düşer. Bu bildirim Kara Kutuya (`sistem_loglari`) şu adli detaylarla mühürlenir:
*   Bölgedeki hangi bayiler çağrıyı gördü, kim es geçti?
*   Olay yerine hangi kurtarıcı (Çekici Plakası/Şoför) ulaştı?
*   Araç sahadan alınıp hangi servise/bayiye teslim edildi?
Tüm bu zincirleme lojistik verisi, kullanıcının "Dijital Torpidosuna" ve Karargah istihbaratına şeffafça kazınır.

---

## 9. SİBER KEŞİF VE MEKAN İSTİHBARATI (BÜYÜK VERİ)

OtoDNA sadece arızalarda değil, aracın tüm yaşam döngüsünde arka planda (Background Location) sessizce çalışarak devasa bir "Mekan İstihbaratı" (POI - Point of Interest) toplar. Bu veri, OtoDNA kullanıcılarını yollardaki en ayrıcalıklı VIP zümre haline getirir.

### 9.1. Arka Plan Veri Hasadı ve Yol Radarı
Kullanıcı seyahat ederken Karargah; gidilen yolları, duraklanan dinlenme tesislerini, girilen yakıt ve elektrikli şarj istasyonlarını saniye saniye kaydeder (`yol_bilgisayari_screen.dart`). 
*   **Spesifik S.O.S Çağrıları:** Yolda kalan bir araç artık sadece "Bozuldum" demez. Sistemdeki özel çiplerle **"Benzinim Bitti"** veya **"Bataryam Bitti"** şeklinde spesifik S.O.S fırlatır. Sistem, en yakın (istihbaratı toplanmış) mobil şarj istasyonunu veya akaryakıt destek aracını otonom olarak yönlendirir.

### 9.2. Kuantum Değerlendirme ve VIP İmtiyaz Kalkanı
*   **Otonom İnceleme (Review) Talebi:** Kullanıcı bir dinlenme tesisinden veya şarj istasyonundan ayrıldığında sistem titrer: *"Gazi Dinlenme Tesisleri'nden ayrıldınız. Hizmet kalitesi nasıldı?"*
*   **OtoDNA İtibar Baskısı:** Tesislerin hijyeni, yakıt kalitesi veya yemek fiyatları OtoDNA ekosistemi içinde oylanır. Bu veriler harita üzerinde diğer tüm OtoDNA kullanıcılarına açıkça gösterilir (Örn: "Burada durmayın, yemekler kötü ve şarj cihazları bozuk").
*   **Zorunlu Saygı (VIP Ayrıcalık):** Bu şeffaf istihbarat ağı sayesinde, otoyol üzerindeki hiçbir tesis veya istasyon OtoDNA kullanıcısına kötü hizmet veremez. *"Bu müşteri OtoDNA üyesi, kötü puan verirse binlerce aracı kaybederiz"* korkusuyla (veya bilinciyle), OtoDNA ismini veya logosunu gören her işletme, Karargah üyelerine VIP, düzgün ve ayrıcalıklı hizmet vermek zorunda kalır.

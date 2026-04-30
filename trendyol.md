# 🛒 OTODNA SİBER MARKET VE YEDEK PARÇA MİMARİSİ (TRENDYOL VİZYONU)

Bu doküman, OtoDNA ekosistemindeki e-ticaret (Oto Market, Yedek Parça, Aksesuar ve Lastik satışı) dinamiklerini açıklar. Sahibinden.com mantığı (Araç satışları) `sahibinden.md` dosyasında yönetilirken; Trendyol, Hepsiburada gibi doğrudan ürüne ve sepete yönelik e-ticaret operasyonları bu kurallar dizgesine (Trendyol Vizyonu) tabidir.

---

## 🚀 1. SİBER BAYİ VE GELİŞMİŞ ÜRÜN EKLEME (SAAS ASİSTANLARI)

Mevcut kod mimarisindeki (Siber Gelişmiş Ürün Terminali `siber_gelismis_urun_ekleme.dart`) çalışan devrimsel kolaylıklar sayesinde, tedarikçi ve bayiler sisteme zahmetsizce entegre olur:

### A. Toplu PDF Otonom Yükleme
Bayiler veya yedek parçacılar (Tedarikçiler) yüzlerce araç parçasını sisteme tek tek girmek zorunda değildir. 
*   **Fatura Okuma:** Toptancıdan alınan veya kendi sistemlerinden çıkarılan faturayı (PDF) Kuantum Ağına yüklerler.
*   **Yapay Zeka (Siber AI):** Sistem faturadaki tüm ürünleri (adı, markası, geliş fiyatı) saniyeler içinde okur.
*   **Abonelik Kotası:** Kullanıcının sahip olduğu "Abonelik Kotasına" (Örn: Ultra, VIP vb.) sadık kalarak ürünleri otomatik olarak Kuantum Ağına mühürler.

### B. Global OE Hub Ağı (Orijinal Parça Entegrasyonu)
Ürün veya yedek parça girilirken satıcının her bir vida için fotoğraf çekmesine gerek yoktur.
*   Satıcı sadece "Stok/OE Kodu" (Orijinal Ekipman numarası) yazar.
*   Sistem arka planda "Global Hub" API'sine bağlanarak o parçanın orijinal stüdyo görselini ve uyumlu olduğu araç listesini (Örn: *Mercedes W205 C-Class, W213 E-Class vb.*) otonom olarak çeker.
*   Böylece pazar yerindeki ürünlerin kalitesi standart ve profesyonel (Plaza kalitesinde) olur.

---

## 💰 2. KUANTUM FİNANS MOTORU VE %12 KESİNTİ

Tedarikçi ve satıcıların kafa karışıklığını gidermek için "Kuantum Finans Hesaplayıcı" devreye girer.

1.  **Satıcı Girdileri:** Bayi panele sadece "Net Geliş Fiyatını", "KDV Oranını" ve "Hedeflediği Kâr Marjını" yazar.
2.  **OtoDNA Hizmet Bedeli:** Sistem, arka planda OtoDNA'nın (Aksi anlaşma ile belirtilmedikçe standart) **%12 hizmet ve pazar yeri komisyonunu** otomatik hesaplar.
3.  **Vitrin Fiyatı Mührü:** Hesaplamalar sonucunda "KDV Dahil Nihai Müşteri Vitrin Fiyatı" (Örn: Trendyol'daki sepet fiyatı) anlık oluşturulur ve veri tabanına mühürlenir. Böylece satıcı "Acaba komisyon çıkınca bana ne kalacak?" derdine düşmez, net hakedişini anında görür.

---

## 🛡️ 3. ÜRÜN ROZETLERİ VE GÜVENLİK
Platforma giren ürünlerin kalitesini belirlemek için zorunlu ve opsiyonel mühürler kullanılır:
*   **2 Yıl Garanti Kalkanı:** Tedarikçi parçanın garantili olduğunu taahhüt edebilir.
*   **%100 Orijinal Ürün Mührü:** Orijinal (OEM) ve yan sanayi parçaların ayrımını netleştirmek için kullanılır.
*   **Kurulum Alıcıya Aittir:** Parçanın montajının satıcıyı bağlamadığı durumlarda karışıklığı önler.

---

## ⚖️ 4. SİBER MARKET KURALLARI VE YASAKLAR (TİCARİ DİSİPLİN)
OtoDNA Market'in itibarını ve alıcı güvenini korumak için mağazalara tavizsiz kurallar uygulanır:
*   **İmitasyon ve Sahte Ürün Yasağı:** Ürüne "%100 Orijinal Ürün Mührü" vurulup yan sanayi veya taklit gönderildiği tespit edilirse, bayi doğrudan ihraç komitesine sevk edilir. Sahteciliğin OtoDNA'da yeri yoktur.
*   **Hayalet Stok ve Tedarik İhaneti:** Satıcının (veya tedarikçinin) elinde fiziki olarak bulunmayan, 24 saat içinde kargoya veremeyeceği "hayalet stokları" sisteme girmesi yasaktır. Yapay zeka kargo teslimat sürelerini izler; iptal oranları yüksek olan bayilerin ürünleri algoritma tarafından en alta itilir (Gölge Ban).
*   **Haksız İade Kalkanı:** Oto Market, müşteriyi koruduğu kadar esnafı da korur. Elektronik bir beynin veya hassas bir motor parçasının ambalajı açılıp araca takıldıktan sonra (deneme yanılma yapılarak) "Ben bunu iade edeceğim" denemez. Bu tür suiistimaller "Siber Bilirkişi" tarafından incelenir ve esnaf korunur.

---

## 🏛️ 5. SİTE İSKELETİ VE GÖRSEL KALİTE (PLATİNUM PLAZA TASARIMI)
OtoDNA e-ticaret arayüzü sıradan bir yedek parça sitesi gibi karmaşık ve ucuz görünemez. Sistem, kullanıcının kendini lüks bir otomotiv merkezinde hissedeceği **"Platinum Plaza VIP"** standartlarında inşa edilir:
*   **Zemin Kaplaması (Fildişi Sedef):** Uygulamanın genel arka planı yorucu çiğ beyaz veya boğucu koyu renkler değildir. Kalite ve güven hissini zirveye çıkaran pürüzsüz **Fildişi Sedef (Ivory Pearl - `0xFFFAFAFC`)** rengiyle kaplanmıştır.
*   **Vurgular ve Zırhlar (Metalik Gold):** Önemli fiyat etiketleri, "Siparişi Onayla" butonları, Orijinal Ürün mühürleri ve Kuantum rozetleri **Metalik Gold** tonlarıyla işlenir. İskelet üzerindeki ikonlar ve ayrıştırıcı çizgiler bu altın yansımalarla tasarlanır.
*   **Siber Cam Paneller (Glassmorphism):** Menüler, ürün sepeti panelleri ve kategori filtreleri; fildişi zeminin üzerinde havada asılı duran, arkası bulanık (Buzlu Cam) premium paneller şeklinde tasarlanır. Kaba gölgelendirmeler kesinlikle yasaktır; derinlik, zarif ışık efektleriyle verilir.

---

## ⚙️ 6. OTODNA MARKET ÜRÜN KATEGORİLERİ (DİNAMİK B2B MİMARİSİ)
OtoDNA Siber Market, Türkiye'nin en büyük yedek parça tedarikçilerinin (Dinamik Otomotiv vb.) stok mimarisiyle %100 uyumlu çalışacak şekilde aşağıdaki derin B2B kategori ağacına (Kuantum Filtreleme) sahiptir:

1.  **Periyodik Bakım ve Madeni Yağ:** Filtre Setleri (Yağ, Hava, Polen, Yakıt), Motor Yağları (0W-20, 5W-30 vb.), Şanzıman Yağları, Antifriz ve Oto Kimyasalları.
2.  **Fren ve Güvenlik Sistemleri:** Fren Diskleri, Fren Balataları, Fren Merkez Pompası, ABS Sensörleri, Fren Hortum ve Rekorları.
3.  **Motor, Mekanik ve Yakıt Sistemleri:** Eksantrik ve Triger Setleri, Piston ve Segmanlar, Supap Grubu, Turboşarj, Enjektörler, Yakıt Pompaları ve Contalar.
4.  **Ateşleme ve Elektrik/Elektronik:** Akü, Buji ve Bobinler, Şarj ve Marş Dinamosu (Alternatör), Sensör Grubu (Lambda, MAP, Krank), Otonom Beyinler (ECU).
5.  **Süspansiyon, Ön Takım ve Direksiyon:** Amortisör ve Helezon Yayları, Salıncak ve Rotiller, Rot Başı ve Rot Kolu, Direksiyon Kutusu, Aks ve Poryalar.
6.  **Soğutma ve Isıtma (İklimlendirme):** Su Radyatörü, Klima Kompresörü, Devirdaim (Su Pompası), Termostat, İntercooler.
7.  **Debriyaj ve Şanzıman (Aktarma Organları):** Baskı Balata (Kavrama) Setleri, Volan, Şanzıman Beyni, Tork Konvertör, Şaft ve Diferansiyel Parçaları.
8.  **Kaporta, Aydınlatma ve Dış Trim:** Ön ve Arka Tamponlar, Çamurluk ve Kaputlar, LED/Xenon Far Grupları, Stop Lambaları, Silecekler, Ayna ve Izgaralar.
9.  **Lastik, Jant ve Oto Aksesuar:** Mevsimlik/Kışlık Lastikler, Çelik Alaşım Jantlar, Paspas Setleri, Multimedya Ekranlar, Çeki Demirleri.

> ⚠️ Bu kategori ağacı, ürünlerin "OE (Orijinal Ekipman) Kodu" üzerinden aratılmasıyla otonom olarak doldurulur. Sistem, Dinamik Otomotiv gibi B2B devlerinin standartlarını kullanarak bayilerin toptancıdan aldığı faturayı doğrudan platforma mühürler.

---

## 🛠️ 7. OTO SERVİS VE HIRDAVAT EKİPMANLARI (GARAJ MİMARİSİ)
Sadece yedek parça değil, sisteme kayıtlı "Kuantum Garaj" ustalarının kendi servisleri için ekipman tedarik edebileceği devasa bir **Hırdavat ve Servis Ekipmanları** kategorisi bulunur:

1.  **Mekanik El Aletleri:** Cırcırlı Lokma Takımları, Kombine Anahtar Setleri, Tork Anahtarları, Pense/Kerpeten Grubu, Tornavidalar, Mengene ve İşgenceler.
2.  **Elektrikli ve Akülü El Aletleri:** Akülü Somun Sıkma (Bijon Tabancası), Avuç İçi Taşlama (Canavar), Şarjlı Matkaplar, Polisaj (Pasta-Cila) Makinaları, Dekupaj ve Gönye Testereler.
3.  **Havalı (Pnömatik) Aletler ve Kompresörler:** Sanayi Tipi Hava Kompresörleri, Havalı Somun Sıkma Tabancaları, Havalı Gres ve Yağ Pompaları, Hidrolik Presler, Spiral/Makaralı Hava Hortumları.
4.  **Kaynak Makinaları ve Ekipmanları:** İnvertör Kaynak Makinaları, Gazaltı (MIG/MAG) Kaynakları, Elektrodlar, Otomatik Kararan Kaynak Maskeleri.
5.  **Genel Servis Ekipmanları:** Boya Tabancaları, Takım Arabaları ve Çantaları, Silikon/Köpük Tabancaları, Ölçü Aletleri (Kumpas, Mikrometre).

---

### 🎯 GENEL ÖZET
OtoDNA Siber Market (Trendyol Vizyonu), bayilerin PDF faturalarını okutarak saniyeler içinde binlerce ürünü Global OE verileriyle zenginleştirerek yayına alabildiği; fiyatlamanın %12 platform komisyonu eklenerek yapay zeka tarafından otonom hesaplandığı kusursuz bir "B2B ve B2C" otomotiv e-ticaret merkezidir.

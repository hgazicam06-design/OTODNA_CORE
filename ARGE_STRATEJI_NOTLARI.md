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

---
*Not: Bu belge, Karargah strateji toplantıları sonucunda Ünal Bey'in yol haritasını beslemek için mühürlenmiştir.*

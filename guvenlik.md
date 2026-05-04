# OtoDNA Siber Savunma ve Anti-Klonlama Doktrini

Bu belge, OtoDNA projesinin fikri mülkiyetini, kod mimarisini ve veritabanı güvenliğini korumak amacıyla geliştirilmiş "5 Katmanlı Siber Zırh" protokollerini içermektedir. Sistem canlıya (Release) çıkmadan hemen önce bu protokoller aktif edilecektir.

## Katman 1: Kuantum Obfuscation (Kod Karmaşıklaştırma)
- **Amaç:** Uygulamanın APK/AAB dosyası tersine mühendislik (reverse engineering) ile açıldığında kodların okunmasını engellemek.
- **Yöntem:** Flutter derleme aşamasında `--obfuscate` ve `--split-debug-info` bayrakları (flags) kullanılacaktır.
- **Etki:** Tüm fonksiyon, değişken ve sınıf isimleri (örneğin: `hesaplaKomisyon`) `a(b)` gibi anlamsız sembollere dönüştürülerek kodun mimarisi gizlenecektir.

## Katman 2: Firebase App Check (Dijital Parmak İzi Zırhı)
- **Amaç:** OtoDNA veritabanına sadece orijinal, bizim imzamızı taşıyan uygulamadan erişilmesini sağlamak. Sahte klonların ve botların veritabanına istek atmasını engellemek.
- **Yöntem:** Firebase konsolu üzerinden Play Integrity API (Android) ve DeviceCheck (iOS) aktif edilecek.
- **Etki:** Uygulama imzası eşleşmeyen hiçbir istemci Firestore'dan okuma veya yazma işlemi yapamayacak, anında "403 Forbidden" hatası ile reddedilecektir.

## Katman 3: Android ProGuard / R8 Zırhı
- **Amaç:** Flutter dışındaki Native Android (Java/Kotlin) altyapısını korumak.
- **Yöntem:** `android/app/build.gradle` dosyası içinde `minifyEnabled true` ve `shrinkResources true` ayarları yapılarak ProGuard aktif edilecek.
- **Etki:** Native kodlar sıkıştırılacak, kullanılmayan kütüphaneler silinecek ve kod akışı şifrelenecektir. Bu işlem aynı zamanda uygulamanın boyutunu da küçültecektir.

## Katman 4: Root / Jailbreak Kalkanı (RASP Sensörleri)
- **Amaç:** İşletim sistemi kırılmış (Root'lu veya Jailbreak'li) cihazlardan uygulamanın hafızasına (RAM) sızılmasını ve ekran kaydı alınmasını engellemek.
- **Yöntem:** Sisteme `freerasp` veya `flutter_jailbreak_detection` gibi bir RASP (Runtime Application Self-Protection) kütüphanesi entegre edilecektir.
- **Etki:** Uygulama açılışta cihazın güvenliğini tarayacak. Cihazda yetkisiz bir modifikasyon tespit edilirse, finansal verileri ve şasi bilgilerini korumak adına uygulama kendini otomatik kilitleyecek veya güvenli bir şekilde kapatacaktır.

## Katman 5: Merkezi Otonom Mantık (Açık Şifre Yasası)
- **Amaç:** Uygulama içindeki hassas formüllerin ve API anahtarlarının hackerlar tarafından bulunmasını engellemek.
- **Yöntem:** Hiçbir şifre, komisyon oranı (%12) veya kritik API anahtarı kodun (Dart dosyalarının) içine açık metin (String) olarak gömülmeyecektir. 
- **Etki:** Tüm dış bağlantı anahtarları `flutter_secure_storage` ile cihazın donanımsal şifreleme modülünde (Keystore/Keychain) saklanacak, hayati işlemler ise (hesaplamalar, engellemeler) uygulamanın içinde değil Firebase Cloud Functions (Ankara Merkez) içinde çözülecektir.

---
**Mühürleyen:** Gazi & OtoDNA Kuantum Karargahı
**Durum:** ONAYLANDI - YAYIN ÖNCESİ AKTİF EDİLECEK

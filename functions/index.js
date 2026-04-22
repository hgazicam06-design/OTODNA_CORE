const { onRequest, onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated, onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

// ── 🛡️ OTODNA GÜVENLİK MOTORU ──
// Admin bir ihbarı 'fake' (asılsız) olarak işaretlerse kullanıcı otomatik cezalandırılır.
exports.checkEmergencyStatus = onDocumentUpdated("emergencies/{docId}", (event) => {
    const newValue = event.data.after.data();
    const previousValue = event.data.before.data();

    if (newValue.status === 'fake' && previousValue.status !== 'fake') {
        const userId = newValue.userId;
        console.log(`Kullanıcı kısıtlanıyor: ${userId}`);
        return admin.firestore().collection('users').doc(userId).update({
            status: 'yellow',
            emergencyEnabled: false,
            warningMessage: "DİKKAT: Asılsız ihbar tespiti! SOS yetkileriniz dondurulmuştur."
        });
    }
    return null;
});

// ── 🦅 SİBER DEVRİYE (Otonom Karaliste Yapay Zekası) ──
// Her gece saat 03:00'te çalışır.
exports.siberDevriyeOperasyonu = onSchedule({
    schedule: "0 3 * * *",
    timeZone: "Europe/Istanbul"
}, async (event) => {
    console.log("🦅 Siber Devriye Başladı. Bayiler taranıyor...");
    const db = admin.firestore();
    const bayilerSnapshot = await db.collection('kullanicilar')
        .where('rutbe', '==', 'BAYI')
        .get();

    const batch = db.batch();
    let islemSayisi = 0;

    bayilerSnapshot.forEach((doc) => {
        const bayi = doc.data();
        const cezaPuani = bayi.cezaPuani || 0;
        
        if (cezaPuani >= 100 && !bayi.is_blacklisted) {
            batch.update(doc.ref, {
                is_blacklisted: true,
                rozet: 'BLACK_STAR',
                devriye_notu: 'Siber Devriye tarafından sistemden izole edildi (100+ Ceza Puanı).'
            });
            islemSayisi++;
        } else if (cezaPuani >= 50 && cezaPuani < 100 && bayi.rozet !== 'Gümüş' && !bayi.is_blacklisted) {
            batch.update(doc.ref, {
                rozet: 'Gümüş',
                devriye_notu: 'Siber Devriye tarafından rütbesi Gümüş seviyesine düşürüldü.'
            });
            islemSayisi++;
        }
    });

    if (islemSayisi > 0) await batch.commit();
    console.log(`✅ Siber Devriye Tamamlandı. ${islemSayisi} müdahale.`);
});

// ── 🚀 KUANTUM SİNYALİZASYON MOTORU (FCM Push Notifications) ──
// Yeni bir bildirim Firestore'a eklendiğinde otonom olarak FCM Push yollar.
exports.onBildirimEklendi = onDocumentCreated("vehicles/{saseNo}/bildirimler/{bildirimId}", async (event) => {
    const saseNo = event.params.saseNo;
    const bildirim = event.data.data();
    
    if (!bildirim) return null;

    console.log(`📡 SİBER SİNYAL: ${saseNo} için yeni bir sinyal ateşlendi. Tür: ${bildirim.tur}`);

    const db = admin.firestore();
    const vehicleDoc = await db.collection('vehicles').doc(saseNo).get();

    if (!vehicleDoc.exists) {
        console.log(`⚠️ HATA: ${saseNo} plakalı/şaseli araç Karargahta bulunamadı.`);
        return null;
    }

    const vehicleData = vehicleDoc.data();
    const fcmToken = vehicleData.fcmToken;

    if (!fcmToken) {
        console.log(`⚠️ HATA: Araç sahibinin FCM Mührü (Token) yok. Bildirim gönderilemedi.`);
        return null;
    }

    // Bildirim Türüne Göre Başlık Belirleme
    let baslik = "OtoDNA Bildirimi";
    switch(bildirim.tur) {
        case 'yanlis_park': baslik = "🅿️ Yanlış Park İhlali"; break;
        case 'kaza':        baslik = "💥 DİKKAT: Aracınıza Çarpıldı!"; break;
        case 'cam_acik':    baslik = "🪟 Aracınızın Camı Açık Kalmış"; break;
        case 'far_acik':    baslik = "🔦 Farlarınız Açık Kalmış"; break;
        case 'sos':         baslik = "🚨 ACİL DURUM SİNYALİ"; break;
        case 'mesaj':       baslik = "💬 Bir Vatandaş Mesaj Bıraktı"; break;
    }

    const payload = {
        token: fcmToken,
        notification: {
            title: baslik,
            body: bildirim.mesaj || "Aracınızla ilgili yeni bir gelişme var."
        },
        data: {
            saseNo: saseNo,
            bildirimId: event.params.bildirimId,
            tur: bildirim.tur || "bilinmiyor",
            click_action: "FLUTTER_NOTIFICATION_CLICK"
        }
    };

    try {
        const response = await admin.messaging().send(payload);
        console.log("🚀 SİNYAL BAŞARIYLA HEDEFE ULAŞTI:", response);

        // Bildirim durumunu 'alindi' olarak mühürle
        return event.data.ref.update({ durum: 'alindi' });
    } catch (error) {
        console.error("💥 SİNYAL KOPTU: FCM gönderim hatası:", error);
        return null;
    }
});

// ── 🛡️ SİBER KALKAN: IP ENGELLEME ──
// Araç sahiplerinin spamcıları kalıcı olarak engellemesini sağlar.
exports.ipEngelle = onCall(async (request) => {
    // request.auth -> Kullanıcı giriş yapmış mı?
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'Siber İhlal: Yetkisiz erişim denemesi!');
    }

    const { saseNo, engellenecekIp } = request.data;
    if (!saseNo || !engellenecekIp) {
        throw new HttpsError('invalid-argument', 'Eksik parametreler.');
    }

    console.log(`🛡️ KALKAN AKTİF: ${saseNo} aracına ${engellenecekIp} IP'si engelleniyor...`);

    const db = admin.firestore();
    const vehicleRef = db.collection('vehicles').doc(saseNo);

    try {
        await vehicleRef.update({
            engelliIpler: admin.firestore.FieldValue.arrayUnion(engellenecekIp)
        });
        console.log(`✅ Başarılı: ${engellenecekIp} engellendi.`);
        return { success: true, message: "IP Kara Listeye eklendi." };
    } catch (error) {
        console.error("HATA:", error);
        throw new HttpsError('internal', 'Veritabanı hatası oluştu.');
    }
});
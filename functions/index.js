const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// OTODNA GÜVENLİK MOTORU
// Admin bir ihbarı 'fake' (asılsız) olarak işaretlerse kullanıcı otomatik cezalandırılır.
exports.checkEmergencyStatus = onDocumentUpdated("emergencies/{docId}", (event) => {
    const newValue = event.data.after.data();
    const previousValue = event.data.before.data();

    // Durum 'fake' olarak güncellendiyse tetiklenir
    if (newValue.status === 'fake' && previousValue.status !== 'fake') {
        const userId = newValue.userId;
        
        console.log(`Kullanıcı kısıtlanıyor: ${userId}`);

        return admin.firestore().collection('users').doc(userId).update({
            status: 'yellow', // Güven skoru düşürüldü
            emergencyEnabled: false, // SOS yetkisi donduruldu
            warningMessage: "DİKKAT: Asılsız ihbar tespiti! SOS yetkileriniz dondurulmuştur."
        });
    }
    return null;
});
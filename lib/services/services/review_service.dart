// review_service.dart - Adalet Kilidi

class ReviewService {
  // Yorum Yapma Yetkisi Kontrolü
  bool canUserReview(String userId, String firmId, bool hasCheckedIn) {
    // Eğer kullanıcı dükkanda check-in yapmadıysa veya işlem onaylanmadıysa yorum yapamaz
    if (!hasCheckedIn) {
      print("Uyarı: Bu dükkana gitmeden yorum yapamazsınız!");
      return false;
    }
    return true;
  }

  // Kara Liste Otomatiği
  void checkForBlacklist(String firmId, List<int> ratings) {
    // Son 10 yorumun ortalaması 2'nin altındaysa firmayı incelemeye al veya direkt 1 yıldıza düşür
    double avg = ratings.reduce((a, b) => a + b) / ratings.length;
    if (avg < 2.0) {
      print("DİKKAT: Firma Kara Liste sınırında!");
    }
  }
}
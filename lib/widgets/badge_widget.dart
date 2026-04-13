// badge_widget.dart - Görsel Mühürler

import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final double rating;
  final bool isBlacklisted;

  // super.key ve const eklendi, performans artırıldı
  const BadgeWidget({
    super.key,
    required this.rating,
    this.isBlacklisted = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Öncelikli Kontrol: Kara Liste (Blacklist) Zırhı
    if (isBlacklisted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Colors.black,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text("KARA LİSTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // 2. Yıldız sayısına göre Kuantum Renk ve Unvan belirleme
    Color badgeColor;
    String badgeText;

    if (rating >= 4.8) {
      badgeColor = Colors.amber; // Altın
      badgeText = "ALTIN ESNAF";
    } else if (rating >= 4.0) {
      badgeColor = Colors.grey; // Gümüş
      badgeText = "GÜMÜŞ ESNAF";
    } else if (rating >= 3.0) {
      badgeColor = Colors.orangeAccent; // Bronz
      badgeText = "BRONZ ESNAF";
    } else {
      // 2.9 ve altı için UI'da yer kaplamayan hayalet bileşen
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
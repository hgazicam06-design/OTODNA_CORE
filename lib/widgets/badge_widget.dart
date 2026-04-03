// badge_widget.dart - Görsel Mühürler

import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final double rating;
  final bool isBlacklisted;

  BadgeWidget({required this.rating, this.isBlacklisted = false});

  @override
  Widget build(BuildContext context) {
    if (isBlacklisted) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Colors.black,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text("KARA LİSTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // Yıldız sayısına göre renk ve isim belirleme
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
      return SizedBox.shrink(); // 2 yıldız ve altı (boş rozet)
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(badgeText, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
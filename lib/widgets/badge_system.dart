// badge_system.dart - OtoDNA Liyakat Motoru

import 'package:flutter/material.dart';

class BadgeSystem extends StatelessWidget {
  final int rating; // 1 ile 5 arası yıldız puanı
  final String? blacklistReason; // Kara liste sebebi

  BadgeSystem({required this.rating, this.blacklistReason});

  @override
  Widget build(BuildContext context) {
    return _buildBadge();
  }

  Widget _buildBadge() {
    switch (rating) {
      case 5: // ALTIN
        return _badgeChip(Icons.stars, Colors.amber, "ALTIN ROZET", Colors.black);
      case 4: // GÜMÜŞ
        return _badgeChip(Icons.stars, Colors.grey[300]!, "GÜMÜŞ ROZET", Colors.black54);
      case 3: // BRONZ
        return _badgeChip(Icons.stars, Colors.orange[300]!, "BRONZ ROZET", Colors.brown);
      case 2: // BOŞ ROZET
        return _badgeChip(Icons.star_border, Colors.blueGrey[100]!, "STANDART", Colors.blueGrey);
      case 1: // KARA LİSTE
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _badgeChip(Icons.star, Colors.black, "KARA LİSTE", Colors.white),
            if (blacklistReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Sebep: $blacklistReason",
                  style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _badgeChip(IconData icon, Color bgColor, String label, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
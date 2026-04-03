// Teklif Hazırlama Ekranı İçindeki Buton Grubu

Row(
  children: [
    ActionChip(
      avatar: Icon(Icons.bolt, color: Colors.amber),
      label: Text("Hızlı Periyodik Bakım Ekle"),
      onPressed: () {
        // Bu fonksiyon paket listesini otomatik olarak tabloya dolduracak
        _addPackageToOffer(PackageService.getPeriodicMaintenancePackage());
      },
    ),
    SizedBox(width: 10),
    ActionChip(
      avatar: Icon(Icons.settings_input_component, color: Colors.blue),
      label: Text("Fren Bakımı Ekle"),
      onPressed: () => _addPackageToOffer(PackageService.getBrakeMaintenancePackage()),
    ),
  ],
)
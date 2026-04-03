// Forum Sayfası Ana Yapısı
class ForumMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OtoDNA Sosyal Garaj")),
      body: ListView.builder(
        itemCount: 5, // Örnek sayı
        itemBuilder: (context, index) => _forumPostCard(index),
      ),
      // Soru Sorma Butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        onPressed: () => print("Yeni Soru Sorma Ekranı"),
        child: Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _forumPostCard(int index) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FİAT EGEA GRUBU", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text("Direksiyon Sertleşmesi Sorunu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Sabahları soğuk havada direksiyon çok sert, ısınınca düzeliyor...", style: TextStyle(color: Colors.black87)),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Aynı Dert" Butonu
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.handshake_outlined, size: 18),
                label: Text("Benimle Aynı (15)"),
              ),
              // "Usta Cevabı" Rozeti (Eğer usta cevaplamışsa görünecek)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 14),
                    Text(" USTA CEVAPLADI", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
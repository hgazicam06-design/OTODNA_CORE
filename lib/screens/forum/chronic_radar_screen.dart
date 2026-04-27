import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/chronic_radar_service.dart';
import '../../models/chronic_issue_model.dart';
import '../../widgets/siber_rehber_dialog.dart';
import 'dart:ui';

class ChronicRadarScreen extends StatefulWidget {
  const ChronicRadarScreen({super.key});

  @override
  State<ChronicRadarScreen> createState() => _ChronicRadarScreenState();
}

class _ChronicRadarScreenState extends State<ChronicRadarScreen> {
  final ChronicRadarService _service = ChronicRadarService();
  List<ChronicIssueModel> _issues = [];
  bool _isLoading = true;

  // Filtreler
  String _selectedBrand = "Tümü";
  String _selectedModel = "Tümü";
  
  final List<String> _brands = ["Tümü", "VW", "Renault", "Fiat", "Ford"];
  final Map<String, List<String>> _models = {
    "Tümü": ["Tümü"],
    "VW": ["Tümü", "Golf 7", "Passat B8", "Polo"],
    "Renault": ["Tümü", "Megane 4", "Clio 5"],
    "Fiat": ["Tümü", "Egea", "Fiorino"],
    "Ford": ["Tümü", "Focus", "Courier"],
  };

  @override
  void initState() {
    super.initState();
    _fetchIssues();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    const String baslik = "CHRONIC CLUB (SİBER RADAR)";
    const String icerik = "OtoDNA Siber Radarına hoş geldiniz.\n\n"
        "Bu panel, araç markalarının kronik sorunlarını tespit etmek ve hukuki emsal kararları sizlerle paylaşmak için Yapay Zeka tarafından derlenmiştir.\n\n"
        "Aracınızla ilgili potansiyel sorunları önceden görebilir, çözüm yollarını öğrenebilir ve tek tuşla Kuantum Ağımızdaki yetkili ustalara veya avukatlara ulaşabilirsiniz.";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'chronic_radar_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'chronic_radar_rehber', baslik: baslik, icerik: icerik);
    }
  }

  Future<void> _fetchIssues() async {
    setState(() => _isLoading = true);
    
    // Gerçekte Firestore'dan çekecek, test için boşsa mock data doldurabiliriz.
    String? brandQuery = _selectedBrand != "Tümü" ? _selectedBrand : null;
    String? modelQuery = _selectedModel != "Tümü" ? _selectedModel : null;
    
    _issues = await _service.getChronicIssues(brand: brandQuery, model: modelQuery);
    
    // Eğer Firestore boşsa, UI test için Mock data ekleyelim:
    if (_issues.isEmpty) {
      _issues = [
        ChronicIssueModel(
          id: '1', brand: 'VW', model: 'Golf 7', component: 'Şanzıman', isChronic: true,
          issueTitle: 'DSG Basınç Tüpü Gevşemesi', legalStatus: 'Emsal Karar Mevcut',
          remedy: 'Güçlendirilmiş basınç tüpü montajı ve yazılım güncellemesi.',
          tags: ['DSG', 'Şanzıman', 'Vuruntu'], severity: 'red',
          symptoms: 'Vites geçişlerinde sarsıntı, Ekranda anahtar işareti.',
          provinceStats: {'İstanbul_Maslak': 120, 'Ankara_Ostim': 85},
        ),
        ChronicIssueModel(
          id: '2', brand: 'Renault', model: 'Megane 4', component: 'Motor', isChronic: true,
          issueTitle: '1.5 dCi Triger Sesi', legalStatus: 'Dava Süreci Başlatılabilir',
          remedy: 'Orijinal Triger Seti ve Devirdaim Pompası değişimi.',
          tags: ['Motor', 'Ses'], severity: 'yellow',
          symptoms: 'Sabah ilk çalıştırmada kayış ötmesi.',
          provinceStats: {'Bursa_Nilüfer': 45},
        ),
      ];
      
      // Eğer filtre uygulanmışsa mock listeyi de filtrele
      if (brandQuery != null) _issues = _issues.where((i) => i.brand == brandQuery).toList();
      if (modelQuery != null) _issues = _issues.where((i) => i.model == modelQuery).toList();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("CHRONIC CLUB", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: SiberTema.kuantumCyan),
              tooltip: "Siber Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
        ),
        body: Column(
          children: [
            _buildSiberFiltreBar(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                : _buildPinterestGrid(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSiberFiltreBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: SiberTema.matGrey,
                value: _selectedBrand,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: SiberTema.kuantumCyan),
                style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold),
                items: _brands.map((String b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBrand = val;
                      _selectedModel = "Tümü"; // Reset model when brand changes
                    });
                    _fetchIssues();
                  }
                },
              ),
            ),
          ),
          Container(width: 1, height: 30, color: SiberTema.kuantumCyan.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: SiberTema.matGrey,
                value: _selectedModel,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: SiberTema.kuantumCyan),
                style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold),
                items: (_models[_selectedBrand] ?? ["Tümü"]).map((String m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedModel = val);
                    _fetchIssues();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinterestGrid() {
    if (_issues.isEmpty) {
      return const Center(child: Text("Siber Ağda Kayıt Bulunamadı.", style: TextStyle(color: SiberTema.textMuted)));
    }
    
    // Basit bir ListView olarak başlatalım (Kullanıcı Masonry/Grid isterse StaggeredGridView eklenebilir, şimdilik ListView/Cards)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _issues.length,
      itemBuilder: (context, index) {
        return _buildSiberIstihbaratKarti(_issues[index]);
      },
    );
  }

  Widget _buildSiberIstihbaratKarti(ChronicIssueModel issue) {
    Color cardColor = issue.severity == 'red' ? SiberTema.kanKirmizi : Colors.amber;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: cardColor.withOpacity(0.1), blurRadius: 15)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık & Risk
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cardColor.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(Icons.warning_amber_rounded, color: cardColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(issue.issueTitle.toUpperCase(), style: const TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900)),
                          Text("${issue.brand} ${issue.model} - ${issue.component}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Belirtiler
                const Text("BELİRTİLER:", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(issue.symptoms, style: const TextStyle(color: SiberTema.textMuted, fontSize: 13)),

                const SizedBox(height: 12),
                
                // Muhur / Çözüm
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2))),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: SiberTema.kuantumCyan, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("BİLİRKİŞİ ONAYLIDIR", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text(issue.remedy, style: const TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Hukuki Durum
                Row(
                  children: [
                    const Icon(Icons.gavel, color: SiberTema.textMuted, size: 16),
                    const SizedBox(width: 6),
                    Text("HUKUKİ DURUM: ${issue.legalStatus}", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(color: SiberTema.textMuted),
                const SizedBox(height: 8),

                // Aksiyon Butonları
                Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(Icons.build, "USTA BUL", SiberTema.altinSari, () {}),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionBtn(Icons.shopping_cart, "PARÇA AL", SiberTema.kuantumCyan, () {}),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionBtn(Icons.gavel_rounded, "AVUKAT DESTEĞİ İSTE", Colors.white, () {}, isOutlined: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color, VoidCallback onTap, {bool isOutlined = false}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : color,
        foregroundColor: isOutlined ? color : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isOutlined ? BorderSide(color: color.withOpacity(0.5)) : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      onPressed: onTap,
    );
  }
}

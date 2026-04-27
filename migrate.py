import os
import re

print("SiberTema güncelleniyor...")
siber_tema_path = r"c:\Projeler\otodna\lib\core\siber_tema.dart"

with open(siber_tema_path, 'r', encoding='utf-8') as f:
    tema = f.read()

# Eski renkleri yenileriyle değiştiriyoruz
tema = re.sub(r'static const Color oledBlack = Color\(0xFF000000\);', 'static const Color oledBlack = Color(0xFFF4F6F8); // Fildişi Arka Plan', tema)
tema = re.sub(r'static const Color kuantumCyan = Color\(0xFF00FFC2\);', 'static const Color kuantumCyan = Color(0xFF005A64); // Kurumsal Zümrüt (Primary)', tema)
tema = re.sub(r'static const Color matGrey = Color\(0xFF111111\);', 'static const Color matGrey = Colors.white; // Surface / Kart Rengi', tema)
tema = re.sub(r'static const Color kanKirmizi = Color\(0xFFFF4D4D\);', 'static const Color kanKirmizi = Color(0xFFD32F2F); // Profesyonel Kırmızı', tema)

# Yeni text renkleri ekleniyor
if "static const Color textMain =" not in tema:
    tema = tema.replace(
        'static const Color kanKirmizi = Color(0xFFD32F2F); // Profesyonel Kırmızı',
        'static const Color kanKirmizi = Color(0xFFD32F2F); // Profesyonel Kırmızı\n  static const Color textMain = Color(0xFF1E293B);\n  static const Color textMuted = Color(0xFF64748B);'
    )

# Gradient arka planı kapatıyoruz (şeffaf/null gibi davranması için beyaz/fildişi yapıyoruz)
tema = re.sub(
    r'colors: \[\s*const Color\(0xFF101820\),\s*oledBlack,\s*\],',
    'colors: [oledBlack, oledBlack],',
    tema
)

with open(siber_tema_path, 'w', encoding='utf-8') as f:
    f.write(tema)

print("Tüm ekranlar işleniyor...")

# Kullanıcının verdiği tüm dosyaları bulalım (lib/screens altındaki her dart dosyasını işleyebiliriz)
screens_dir = r"c:\Projeler\otodna\lib\screens"

for root, dirs, files in os.walk(screens_dir):
    for file in files:
        if file.endswith(".dart"):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            original_content = content
            
            # ResponsiveKalkan isOledBackground: true -> false
            content = content.replace('isOledBackground: true', 'isOledBackground: false')
            
            # Text muted renkleri
            content = re.sub(r'color:\s*Colors\.white(?:54|70|38|24|12|10)', 'color: SiberTema.textMuted', content)
            
            # Beyaz metinleri laciverte (textMain) çevirme (sadece TextStyle içinde)
            # Normal 'color: Colors.white' olanları SiberTema.textMain yapıyoruz, ama ikonlar da etkilenebilir. 
            # Bu yüzden TextStyle() kalıbını hedeflemek daha güvenli.
            content = re.sub(r'(TextStyle\([^)]*)color:\s*Colors\.white\b([^)]*\))', r'\1color: SiberTema.textMain\2', content)
            
            # AppBar içindeki leading ve title iconlarının beyaz olmaması lazım
            content = re.sub(r'color:\s*Colors\.white(,\s*size:\s*\d+\s*\))', r'color: SiberTema.kuantumCyan\1', content)
            
            # Elevated butonlarda siyah yazıları beyaza çevir
            content = content.replace('foregroundColor: Colors.black', 'foregroundColor: Colors.white')
            content = content.replace('color: Colors.black', 'color: Colors.white') # Buton içindeki circularProgressIndicator vs.
            
            # Eğer 'SiberTema.textMain' kullanıp da importu yoksa, büyük ihtimal core/siber_tema.dart importu vardır ama yine de emin olalım
            # Genelde hepsi siber_tema.dart import ediyor.
            
            if content != original_content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Güncellendi: {file}")

print("İşlem tamam!")

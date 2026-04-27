const fs = require('fs');
const path = require('path');

console.log("SiberTema güncelleniyor...");
const siberTemaPath = path.join('c:', 'Projeler', 'otodna', 'lib', 'core', 'siber_tema.dart');

let tema = fs.readFileSync(siberTemaPath, 'utf8');

// Eski renkleri yenileriyle değiştiriyoruz
tema = tema.replace(/static const Color oledBlack = Color\(0xFF000000\);/g, 'static const Color oledBlack = Color(0xFFF4F6F8); // Fildişi Arka Plan');
tema = tema.replace(/static const Color kuantumCyan = Color\(0xFF00FFC2\);/g, 'static const Color kuantumCyan = Color(0xFF005A64); // Kurumsal Zümrüt (Primary)');
tema = tema.replace(/static const Color matGrey = Color\(0xFF111111\);/g, 'static const Color matGrey = Colors.white; // Surface / Kart Rengi');
tema = tema.replace(/static const Color kanKirmizi = Color\(0xFFFF4D4D\);/g, 'static const Color kanKirmizi = Color(0xFFD32F2F); // Profesyonel Kırmızı');

// Yeni text renkleri ekleniyor
if (!tema.includes('static const Color textMain =')) {
    tema = tema.replace(
        'static const Color kanKirmizi = Color(0xFFD32F2F); // Profesyonel Kırmızı',
        'static const Color kanKirmizi = Color(0xFFD32F2F); // Profesyonel Kırmızı\n  static const Color textMain = Color(0xFF1E293B);\n  static const Color textMuted = Color(0xFF64748B);'
    );
}

// Gradient arka planı kapatıyoruz
tema = tema.replace(/colors: \[\s*const Color\(0xFF101820\),\s*oledBlack,\s*\],/g, 'colors: [oledBlack, oledBlack],');

fs.writeFileSync(siberTemaPath, tema, 'utf8');
console.log("Tüm ekranlar işleniyor...");

const screensDir = path.join('c:', 'Projeler', 'otodna', 'lib', 'screens');

function processDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            processDir(fullPath);
        } else if (file.endsWith('.dart')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            const originalContent = content;
            
            // ResponsiveKalkan
            content = content.replace(/isOledBackground:\s*true/g, 'isOledBackground: false');
            
            // Text muted renkleri
            content = content.replace(/color:\s*Colors\.white(?:54|70|38|24|12|10)/g, 'color: SiberTema.textMuted');
            
            // Beyaz metinleri laciverte (textMain) çevirme (sadece TextStyle içinde)
            content = content.replace(/(TextStyle\([^)]*)color:\s*Colors\.white\b([^)]*\))/g, '$1color: SiberTema.textMain$2');
            
            // İkon renklerini güncelleme
            content = content.replace(/color:\s*Colors\.white(,\s*size:\s*\d+\s*\))/g, 'color: SiberTema.kuantumCyan$1');
            
            // Elevated butonlarda siyah yazıları beyaza çevir
            content = content.replace(/foregroundColor:\s*Colors\.black/g, 'foregroundColor: Colors.white');
            content = content.replace(/color:\s*Colors\.black/g, 'color: Colors.white');
            
            if (content !== originalContent) {
                fs.writeFileSync(fullPath, content, 'utf8');
                console.log("Güncellendi: " + file);
            }
        }
    }
}

processDir(screensDir);
console.log("İşlem tamam!");

/**
 * OtoDNA Mali Hesaplama Motoru
 * Hedef: 100 TL'lik işlemde %8 net kâr bırakmak.
 */

function hesaplaOtoDNA(satisTutari) {
    // 1. Toplam Komisyon (%10 üzerinden hesaplanır)
    const toplamKomisyon = satisTutari * 0.10; // 100 TL'de 10 TL

    // 2. KDV Payı (%20 KDV üzerinden kesilir)
    // Komisyon tutarının içindeki devlete gidecek vergi
    const kdvTutari = toplamKomisyon - (toplamKomisyon / 1.20); // ~1.67 TL

    // 3. OtoDNA Net Kâr (Vergi düştükten sonra bize kalan)
    const netKar = toplamKomisyon - kdvTutari; // ~8.33 TL (Hedeflenen %8 burada)

    // 4. Esnafa/Ustaya Gidecek Tutar
    const esnafPayi = satisTutari - toplamKomisyon; // 90 TL

    return {
        islem_tutari: satisTutari.toFixed(2) + " TL",
        esnafa_yatacak: esnafPayi.toFixed(2) + " TL",
        otodna_net_kar: netKar.toFixed(2) + " TL",
        devlete_kdv: kdvTutari.toFixed(2) + " TL",
        mesaj: "Ankara Merkez: Finansal işlem mühürlendi."
    };
}

// TEST: 100 TL için sonuçları gör
console.log(hesaplaOtoDNA(100));
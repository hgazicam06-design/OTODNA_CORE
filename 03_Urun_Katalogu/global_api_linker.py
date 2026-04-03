# OtoDNA Global Fiyat ve Parça Karşılaştırıcı
def global_parca_sorgula(oem_no):
    # Bu motor TecDoc ve eBay API'lerine bağlanacak iskelete sahip
    # Örnek: "5G0698151" OEM kodlu balatayı Almanya'da sorgular
    return {
        "parca_adi": "On Fren Balatasi",
        "oem_no": oem_no,
        "global_fiyat_ortalama": "45.00 EUR",
        "turkiye_stok_durumu": "Mevcut",
        "otodna_onay": "Gecerli"
    }
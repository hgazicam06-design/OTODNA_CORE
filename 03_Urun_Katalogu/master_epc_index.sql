CREATE TABLE Global_Parca_Katalogu (
    oem_no VARCHAR(30) PRIMARY KEY, -- Civatasına kadar benzersiz kod
    parca_adi VARCHAR(200),
    ana_kategori VARCHAR(50),      -- Örn: Motor, Şanzıman, Kaporta
    alt_kategori VARCHAR(100),     -- Örn: Silindir Kapağı, Fren Kaliperleri
    alt_grup_detay VARCHAR(100),   -- Örn: "Kaliper Bağlantı Civatası"
    teknik_cizim_id VARCHAR(50),   -- Parçanın şemadaki yeri
    uyumlu_arac_kodlari TEXT[]     -- Bu civata hangi araçlara uyar?
);
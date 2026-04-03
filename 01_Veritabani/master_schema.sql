CREATE TABLE Arac_Katalogu (
    id SERIAL PRIMARY KEY,
    marka VARCHAR(50),      -- örn: Volkswagen
    model VARCHAR(100),     -- örn: Golf
    nesil VARCHAR(50),      -- örn: Golf 7 (2012-2017)
    kasa_tipi VARCHAR(20),  -- örn: Hatchback
    motor_tipi VARCHAR(50)  -- örn: 1.6 TDI BMT
);
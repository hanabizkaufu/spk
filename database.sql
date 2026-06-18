-- =====================================================
-- DATABASE SCHEMA UNTUK SISTEM PENDUKUNG KEPUTUSAN (SPK)
-- METODE: Simple Additive Weighting (SAW)
-- =====================================================

-- Jika database sudah ada, hapus terlebih dahulu
DROP DATABASE IF EXISTS spk_saw;

-- Buat database baru
CREATE DATABASE spk_saw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE spk_saw;

-- =====================================================
-- TABEL 1: KRITERIA
-- =====================================================
-- Tabel ini menyimpan daftar kriteria yang akan digunakan dalam proses pengambilan keputusan
-- Setiap kriteria memiliki bobot (kepentingan) dan tipe (Benefit atau Cost)
CREATE TABLE kriteria (
    id_kriteria INT PRIMARY KEY AUTO_INCREMENT,
    nama_kriteria VARCHAR(100) NOT NULL UNIQUE,
    bobot_kriteria DECIMAL(5, 4) NOT NULL, -- Bobot dalam bentuk desimal (0.1 sampai 1.0)
    tipe_kriteria ENUM('Benefit', 'Cost') NOT NULL, -- Benefit = semakin tinggi semakin baik, Cost = semakin rendah semakin baik
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABEL 2: ALTERNATIF
-- =====================================================
-- Tabel ini menyimpan daftar alternatif (pilihan) yang akan dievaluasi
CREATE TABLE alternatif (
    id_alternatif INT PRIMARY KEY AUTO_INCREMENT,
    nama_alternatif VARCHAR(100) NOT NULL UNIQUE,
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABEL 3: NILAI ALTERNATIF
-- =====================================================
-- Tabel ini menyimpan nilai/skor setiap alternatif untuk setiap kriteria
-- Relasi banyak ke banyak antara alternatif dan kriteria
CREATE TABLE nilai_alternatif (
    id_nilai INT PRIMARY KEY AUTO_INCREMENT,
    id_alternatif INT NOT NULL,
    id_kriteria INT NOT NULL,
    nilai_awal DECIMAL(10, 2) NOT NULL, -- Nilai awal dari setiap alternatif pada kriteria tertentu
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_alternatif) REFERENCES alternatif(id_alternatif) ON DELETE CASCADE,
    FOREIGN KEY (id_kriteria) REFERENCES kriteria(id_kriteria) ON DELETE CASCADE,
    UNIQUE KEY unique_alt_krit (id_alternatif, id_kriteria)
);

-- =====================================================
-- TABEL 4: HASIL PERHITUNGAN SAW (OPSIONAL - UNTUK CACHE)
-- =====================================================
-- Tabel ini menyimpan hasil akhir perhitungan SAW untuk setiap alternatif
-- Berguna untuk cache dan tracking history
CREATE TABLE hasil_saw (
    id_hasil INT PRIMARY KEY AUTO_INCREMENT,
    id_alternatif INT NOT NULL,
    skor_akhir DECIMAL(10, 8) NOT NULL, -- Hasil akhir SAW (0 sampai 1)
    ranking INT NOT NULL, -- Peringkat alternatif berdasarkan skor
    tanggal_hitung TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_alternatif) REFERENCES alternatif(id_alternatif) ON DELETE CASCADE
);

-- =====================================================
-- INDEX UNTUK OPTIMISASI QUERY
-- =====================================================
CREATE INDEX idx_kriteria_tipe ON kriteria(tipe_kriteria);
CREATE INDEX idx_nilai_alt ON nilai_alternatif(id_alternatif);
CREATE INDEX idx_nilai_krit ON nilai_alternatif(id_kriteria);
CREATE INDEX idx_hasil_skor ON hasil_saw(skor_akhir DESC);

-- =====================================================
-- DATA AWAL DUMMY (OPSIONAL - UNTUK TESTING)
-- =====================================================
-- Anda dapat menghapus bagian ini jika tidak memerlukan data awal

INSERT INTO kriteria (nama_kriteria, bobot_kriteria, tipe_kriteria) VALUES
('Harga', 0.30, 'Cost'),           -- Benefit: semakin rendah semakin baik
('Performa', 0.25, 'Benefit'),      -- Benefit: semakin tinggi semakin baik
('Kualitas', 0.25, 'Benefit'),      -- Benefit: semakin tinggi semakin baik
('Daya Tahan', 0.20, 'Benefit');    -- Benefit: semakin tinggi semakin baik

INSERT INTO alternatif (nama_alternatif, keterangan) VALUES
('Produk A', 'Deskripsi produk A'),
('Produk B', 'Deskripsi produk B'),
('Produk C', 'Deskripsi produk C');

INSERT INTO nilai_alternatif (id_alternatif, id_kriteria, nilai_awal) VALUES
-- Produk A
(1, 1, 5000000),
(1, 2, 85),
(1, 3, 90),
(1, 4, 4),
-- Produk B
(2, 1, 7000000),
(2, 2, 90),
(2, 3, 85),
(2, 4, 3.5),
-- Produk C
(3, 1, 6000000),
(3, 2, 80),
(3, 3, 95),
(3, 4, 4.5);

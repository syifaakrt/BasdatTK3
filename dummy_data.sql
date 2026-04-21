CREATE SCHEMA IF NOT EXISTS AEROMILES;
SET search_path TO AEROMILES;

CREATE TABLE PENGGUNA (
    email VARCHAR(100) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    salutation VARCHAR(10) NOT NULL,
    first_mid_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(5) NOT NULL,
    mobile_number VARCHAR(20) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    kewarganegaraan VARCHAR(50) NOT NULL
);

CREATE TABLE TIER (
    id_tier VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    minimal_frekuensi_terbang INT NOT NULL,
    minimal_tier_miles INT NOT NULL
);

CREATE TABLE MEMBER (
    email VARCHAR(100) PRIMARY KEY,
    nomor_member VARCHAR(20) UNIQUE,
    tanggal_bergabung DATE NOT NULL,
    id_tier VARCHAR(10) NOT NULL,
    award_miles INT DEFAULT 0,
    total_miles INT DEFAULT 0,
    CONSTRAINT fk_member_pengguna FOREIGN KEY (email) REFERENCES PENGGUNA (email) ON DELETE CASCADE,
    CONSTRAINT fk_member_tier FOREIGN KEY (id_tier) REFERENCES TIER (id_tier) ON UPDATE CASCADE
);

CREATE TABLE PENYEDIA (
    id SERIAL PRIMARY KEY
);

CREATE TABLE MASKAPAI (
    kode_maskapai VARCHAR(10) PRIMARY KEY,
    nama_maskapai VARCHAR(100) NOT NULL,
    id_penyedia INT NOT NULL,
    CONSTRAINT fk_maskapai_penyedia FOREIGN KEY (id_penyedia) REFERENCES PENYEDIA (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE STAF (
    email VARCHAR(100) PRIMARY KEY,
    id_staf VARCHAR(20) UNIQUE,
    kode_maskapai VARCHAR(10) NOT NULL,
    CONSTRAINT fk_staf_pengguna FOREIGN KEY (email) REFERENCES PENGGUNA(email) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_staf_maskapai FOREIGN KEY (kode_maskapai) REFERENCES MASKAPAI(kode_maskapai) ON UPDATE CASCADE
);

CREATE TABLE MITRA (
    email_mitra VARCHAR(100) PRIMARY KEY,
    id_penyedia INT NOT NULL UNIQUE,
    nama_mitra VARCHAR(100) NOT NULL,
    tanggal_kerja_sama DATE NOT NULL,
    CONSTRAINT fk_mitra_penyedia FOREIGN KEY (id_penyedia) REFERENCES PENYEDIA(id) ON DELETE CASCADE
);

CREATE TABLE IDENTITAS (
    nomor VARCHAR(50) PRIMARY KEY,
    email_member VARCHAR(100) NOT NULL,
    tanggal_habis DATE NOT NULL,
    tanggal_terbit DATE NOT NULL,
    negara_penerbit VARCHAR(50) NOT NULL,
    jenis VARCHAR(30) NOT NULL,
    CONSTRAINT fk_identitas_member FOREIGN KEY (email_member) REFERENCES MEMBER(email) ON DELETE CASCADE
);

CREATE TABLE AWARD_MILES_PACKAGE (
    id VARCHAR(20) PRIMARY KEY,
    harga_paket DECIMAL(15,2) NOT NULL,
    jumlah_award_miles INT NOT NULL
);

CREATE TABLE MEMBER_AWARD_MILES_PACKAGE (
    id_award_miles_package VARCHAR(20) NOT NULL,
    email_member VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_award_miles_package, email_member, timestamp),
    CONSTRAINT fk_mamp_package FOREIGN KEY (id_award_miles_package) REFERENCES AWARD_MILES_PACKAGE(id),
    CONSTRAINT fk_mamp_member FOREIGN KEY (email_member) REFERENCES MEMBER(email) ON DELETE CASCADE
);

CREATE TABLE BANDARA (
    iata_code CHAR(3) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    kota VARCHAR(100) NOT NULL,
    negara VARCHAR(100) NOT NULL
);

CREATE TABLE CLAIM_MISSING_MILES (
    id SERIAL PRIMARY KEY,
    email_member VARCHAR(100) NOT NULL,
    email_staf VARCHAR(100),
    maskapai VARCHAR(10) NOT NULL,
    bandara_asal VARCHAR(3) NOT NULL,
    bandara_tujuan VARCHAR(3) NOT NULL,
    tanggal_penerbangan DATE NOT NULL,
    flight_number VARCHAR(10) NOT NULL,
    nomor_tiket VARCHAR(20) NOT NULL,
    kelas_kabin VARCHAR(20) NOT NULL,
    pnr VARCHAR(10) NOT NULL,
    status_penerimaan VARCHAR(20) NOT NULL DEFAULT 'Menunggu',
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_claim_member FOREIGN KEY (email_member) REFERENCES MEMBER(email) ON DELETE CASCADE,
    CONSTRAINT fk_claim_staf FOREIGN KEY (email_staf) REFERENCES STAF(email) ON DELETE SET NULL,
    CONSTRAINT fk_claim_maskapai FOREIGN KEY (maskapai) REFERENCES MASKAPAI(kode_maskapai),
    CONSTRAINT fk_claim_asal FOREIGN KEY (bandara_asal) REFERENCES BANDARA(iata_code),
    CONSTRAINT fk_claim_tujuan FOREIGN KEY (bandara_tujuan) REFERENCES BANDARA(iata_code),
    CONSTRAINT unique_flight_claim UNIQUE (email_member, flight_number, tanggal_penerbangan, nomor_tiket)
);

CREATE TABLE TRANSFER (
    email_member_1 VARCHAR(100) NOT NULL,
    email_member_2 VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    jumlah INT NOT NULL,
    catatan VARCHAR(255),
    PRIMARY KEY (email_member_1, email_member_2, timestamp),
    CONSTRAINT fk_transfer_pengirim FOREIGN KEY (email_member_1) 
        REFERENCES MEMBER(email) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_penerima FOREIGN KEY (email_member_2) 
        REFERENCES MEMBER(email) ON DELETE CASCADE,
    CONSTRAINT check_not_self_transfer CHECK (email_member_1 <> email_member_2)
);

CREATE TABLE HADIAH (
    kode_hadiah VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    miles INT NOT NULL,
    deskripsi TEXT,
    valid_start_date DATE NOT NULL,
    program_end DATE NOT NULL,
    id_penyedia INT NOT NULL,
    CONSTRAINT fk_hadiah_penyedia FOREIGN KEY (id_penyedia) 
        REFERENCES PENYEDIA(id) ON DELETE CASCADE
);

CREATE TABLE REDEEM (
    email_member VARCHAR(100) NOT NULL,
    kode_hadiah VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (email_member, kode_hadiah, timestamp),
    CONSTRAINT fk_redeem_member FOREIGN KEY (email_member) 
        REFERENCES MEMBER(email) ON DELETE CASCADE,
    CONSTRAINT fk_redeem_hadiah FOREIGN KEY (kode_hadiah) 
        REFERENCES HADIAH(kode_hadiah)
);

CREATE OR REPLACE FUNCTION func_autogen_member() RETURNS TRIGGER AS $$
BEGIN
    NEW.nomor_member := 'M' || LPAD(CAST((SELECT COUNT(*) + 1 FROM AEROMILES.MEMBER) AS TEXT), 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_member_id BEFORE INSERT ON MEMBER FOR EACH ROW EXECUTE FUNCTION func_autogen_member();

CREATE OR REPLACE FUNCTION func_autogen_staf() RETURNS TRIGGER AS $$
BEGIN
    NEW.id_staf := 'S' || LPAD(CAST((SELECT COUNT(*) + 1 FROM AEROMILES.STAF) AS TEXT), 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_staf_id BEFORE INSERT ON STAF FOR EACH ROW EXECUTE FUNCTION func_autogen_staf();

CREATE OR REPLACE FUNCTION func_autogen_amp() RETURNS TRIGGER AS $$
BEGIN
    NEW.id := 'AMP-' || LPAD(CAST((SELECT COUNT(*) + 1 FROM AEROMILES.AWARD_MILES_PACKAGE) AS TEXT), 3, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_amp_id BEFORE INSERT ON AWARD_MILES_PACKAGE FOR EACH ROW EXECUTE FUNCTION func_autogen_amp();

CREATE OR REPLACE FUNCTION func_autogen_hadiah() RETURNS TRIGGER AS $$
BEGIN
    NEW.kode_hadiah := 'RWD-' || LPAD(CAST((SELECT COUNT(*) + 1 FROM AEROMILES.HADIAH) AS TEXT), 3, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_hadiah_id BEFORE INSERT ON HADIAH FOR EACH ROW EXECUTE FUNCTION func_autogen_hadiah();

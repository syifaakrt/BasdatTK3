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

SET search_path TO AEROMILES;

-- =====================
-- TIER (4 rows)
-- =====================
INSERT INTO TIER (id_tier, nama, minimal_frekuensi_terbang, minimal_tier_miles) VALUES
('T001', 'Blue', 0, 0),
('T002', 'Silver', 10, 25000),
('T003', 'Gold', 25, 50000),
('T004', 'Platinum', 50, 100000);

-- =====================
-- PENGGUNA (60 rows)
-- =====================
INSERT INTO PENGGUNA (email, password, salutation, first_mid_name, last_name, country_code, mobile_number, tanggal_lahir, kewarganegaraan) VALUES
('alice.smith@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Alice', 'Smith', '+1', '5551001001', '1990-03-15', 'American'),
('bob.jones@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Bob', 'Jones', '+1', '5551001002', '1985-07-22', 'American'),
('citra.dewi@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Citra', 'Dewi', '+62', '81234567001', '1995-01-10', 'Indonesian'),
('dian.pratama@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Dian', 'Pratama', '+62', '81234567002', '1992-05-18', 'Indonesian'),
('eva.stratt@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Eva', 'Stratt', '+49', '1512345001', '1988-11-30', 'German'),
('frank.ocean@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Frank', 'Ocean', '+49', '1512345002', '1983-09-14', 'German'),
('ryland.grace@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Ryland', 'Grace', '+65', '9123456001', '1997-04-25', 'Singaporean'),
('henry.lim@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Henry', 'Lim', '+65', '9123456002', '1991-08-03', 'Singaporean'),
('irene.santos@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Irene', 'Santos', '+63', '9171234001', '1993-12-07', 'Filipino'),
('jose.garcia@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Jose', 'Garcia', '+63', '9171234002', '1987-06-19', 'Filipino'),
('karen.nguyen@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Karen', 'Nguyen', '+84', '9012345001', '1996-02-28', 'Vietnamese'),
('lan.tran@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Lan', 'Tran', '+84', '9012345002', '1989-10-11', 'Vietnamese'),
('maya.ali@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Maya', 'Ali', '+60', '1112345001', '1994-07-16', 'Malaysian'),
('noor.hassan@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Noor', 'Hassan', '+60', '1112345002', '1986-03-29', 'Malaysian'),
('olivia.brown@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Olivia', 'Brown', '+44', '7912345001', '1998-09-05', 'British'),
('peter.parker@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Peter', 'Parker', '+44', '7912345002', '1982-01-23', 'British'),
('queen.park@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Queen', 'Park', '+82', '1012345001', '1995-05-12', 'Korean'),
('ryan.kim@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Ryan', 'Kim', '+82', '1012345002', '1990-11-08', 'Korean'),
('sara.yamamoto@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Sara', 'Yamamoto', '+81', '9012345001', '1993-08-21', 'Japanese'),
('taro.suzuki@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Taro', 'Suzuki', '+81', '9012345002', '1984-04-17', 'Japanese'),
('uma.chen@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Uma', 'Chen', '+86', '1381234001', '1997-12-03', 'Chinese'),
('victor.wang@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Victor', 'Wang', '+86', '1381234002', '1988-06-30', 'Chinese'),
('wina.sari@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Wina', 'Sari', '+62', '81234567003', '1999-03-14', 'Indonesian'),
('xander.scott@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Xander', 'Scott', '+1', '5551001003', '1991-07-09', 'American'),
('yuki.ito@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Yuki', 'Ito', '+81', '9012345003', '1996-01-26', '  Japanese'),
('zara.ahmed@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Zara', 'Ahmed', '+971', '501234001', '1994-09-18', 'Emirati'),
('adam.clark@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Adam', 'Clark', '+1', '5551001004', '1987-05-07', 'American'),
('bella.ross@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Bella', 'Ross', '+44', '7912345003', '1992-11-24', 'British'),
('carlos.sainz@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Carlos', 'Sainz', '+34', '6121345001', '1985-08-13', 'Spanish'),
('diana.lopez@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Diana', 'Lopez', '+34', '6121345002', '1998-02-06', 'Spanish'),
('ethan.martin@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Ethan', 'Martin', '+33', '6123456001', '1993-06-22', 'French'),
('fiona.bernard@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Fiona', 'Bernard', '+33', '6123456002', '1986-10-15', 'French'),
('george.russell@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'George', 'Russell', '+39', '3381234001', '1990-04-01', 'Italian'),
('hana.ferrari@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Hana', 'Ferrari', '+39', '3381234002', '1995-12-19', 'Italian'),
('ivan.petrov@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Ivan', 'Petrov', '+7', '9121234001', '1983-07-28', 'Russian'),
('julia.volkova@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Julia', 'Volkova', '+7', '9121234002', '1997-03-11', 'Russian'),
('kevin.silva@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Kevin', 'Silva', '+55', '1191234001', '1989-09-04', 'Brazilian'),
('laura.costa@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Laura', 'Costa', '+55', '1191234002', '1994-01-17', 'Brazilian'),
('marco.oliveira@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Marco', 'Oliveira', '+351', '9121234001', '1988-05-30', 'Portuguese'),
('nina.santos@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Nina', 'Santos', '+351', '9121234002', '1996-11-13', 'Portuguese'),
('omar.hassan@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Omar', 'Hassan', '+20', '1012345001', '1991-08-26', 'Egyptian'),
('petra.kova@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Petra', 'Kova', '+420', '7121234001', '1993-04-09', 'Czech'),
('quincy.adams@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Quincy', 'Adams', '+1', '5551001005', '1985-12-22', 'American'),
('rosa.mendez@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Rosa', 'Mendez', '+52', '5512345001', '1998-06-15', 'Mexican'),
('samuel.torres@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Samuel', 'Torres', '+52', '5512345002', '1987-02-28', 'Mexican'),
('tina.wu@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Tina', 'Wu', '+886', '9121234001', '1992-10-11', 'Taiwanese'),
('ulrich.bauer@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Ulrich', 'Bauer', '+49', '1512345003', '1984-07-04', 'German'),
('vera.novak@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Vera', 'Novak', '+421', '9121234001', '1996-03-17', 'Slovak'),
('william.fisher@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'William', 'Fisher', '+1', '5551001006', '1990-11-30', 'American'),
('xiao.li@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Xiao', 'Li', '+86', '1381234003', '1995-08-23', 'Chinese'),
('yasmin.omar@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Yasmin', 'Omar', '+62', '81234567004', '1993-05-06', 'Indonesian'),
('zaki.rahman@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Zaki', 'Rahman', '+62', '81234567005', '1988-01-19', 'Indonesian'),
('aisha.malik@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Aisha', 'Malik', '+92', '3121234001', '1997-09-02', 'Pakistani'),
('bilal.khan@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Bilal', 'Khan', '+92', '3121234002', '1986-05-15', 'Pakistani'),
('clara.johansson@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Clara', 'Johansson', '+46', '7121234001', '1994-01-28', 'Swedish'),
('david.lindqvist@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'David', 'Lindqvist', '+46', '7121234002', '1989-09-11', 'Swedish'),
('elena.popescu@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Elena', 'Popescu', '+40', '7121234001', '1995-05-24', 'Romanian'),
('felix.ionescu@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Felix', 'Ionescu', '+40', '7121234002', '1983-02-07', 'Romanian'),
('gina.thomas@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Ms.', 'Gina', 'Thomas', '+61', '4121234001', '1991-10-20', 'Australian'),
('harry.nguyen@email.com', 'pbkdf2_sha256$29000$Q3JmSeMHfa4L$jO33uFCJU0tJpxhuk1zBwX6cInNgtA6wRsTJRgetMDU=', 'Mr.', 'Harry', 'Nguyen', '+61', '4121234002', '1987-06-03', 'Australian');

-- =====================
-- MEMBER (50 rows) - nomor_member auto-generated by trigger
-- =====================
INSERT INTO MEMBER (email, tanggal_bergabung, id_tier, award_miles, total_miles) VALUES
('alice.smith@email.com', '2020-01-15', 'T003', 15000, 62000),
('bob.jones@email.com', '2019-06-20', 'T004', 8000, 115000),
('citra.dewi@email.com', '2021-03-10', 'T002', 5000, 30000),
('dian.pratama@email.com', '2020-08-25', 'T003', 12000, 55000),
('eva.stratt@email.com', '2022-01-05', 'T001', 2000, 8000),
('frank.ocean@email.com', '2018-11-12', 'T004', 20000, 120000),
('ryland.grace@email.com', '2021-07-19', 'T002', 7000, 28000),
('henry.lim@email.com', '2020-04-30', 'T003', 9000, 58000),
('irene.santos@email.com', '2022-05-14', 'T001', 1500, 5000),
('jose.garcia@email.com', '2019-09-08', 'T003', 11000, 52000),
('karen.nguyen@email.com', '2021-11-23', 'T002', 6000, 27000),
('lan.tran@email.com', '2020-02-17', 'T002', 4500, 26000),
('maya.ali@email.com', '2022-08-01', 'T001', 1000, 3000),
('noor.hassan@email.com', '2019-04-11', 'T003', 13000, 60000),
('olivia.brown@email.com', '2023-01-20', 'T001', 500, 1000),
('peter.parker@email.com', '2018-07-05', 'T004', 25000, 130000),
('queen.park@email.com', '2021-09-28', 'T002', 8000, 29000),
('ryan.kim@email.com', '2020-12-15', 'T003', 10000, 51000),
('sara.yamamoto@email.com', '2022-03-07', 'T001', 2500, 7000),
('taro.suzuki@email.com', '2019-01-30', 'T004', 18000, 105000),
('uma.chen@email.com', '2021-05-16', 'T002', 5500, 26500),
('victor.wang@email.com', '2020-10-09', 'T003', 14000, 57000),
('wina.sari@email.com', '2023-03-22', 'T001', 300, 800),
('xander.scott@email.com', '2020-06-14', 'T002', 7500, 27500),
('yuki.ito@email.com', '2022-11-01', 'T001', 1800, 6000),
('zara.ahmed@email.com', '2021-01-18', 'T002', 6500, 28500),
('adam.clark@email.com', '2019-08-27', 'T003', 16000, 63000),
('bella.ross@email.com', '2022-06-10', 'T001', 2200, 7500),
('carlos.sainz@email.com', '2020-03-03', 'T002', 4000, 25500),
('diana.lopez@email.com', '2023-05-19', 'T001', 400, 900),
('ethan.martin@email.com', '2021-08-14', 'T002', 9000, 31000),
('fiona.bernard@email.com', '2019-12-07', 'T003', 17000, 61000),
('george.russell@email.com', '2020-07-21', 'T003', 11500, 53000),
('hana.ferrari@email.com', '2022-09-04', 'T001', 1200, 4500),
('ivan.petrov@email.com', '2018-05-16', 'T004', 22000, 125000),
('julia.volkova@email.com', '2021-04-29', 'T002', 8500, 30500),
('kevin.silva@email.com', '2020-01-11', 'T003', 13500, 59000),
('laura.costa@email.com', '2022-10-26', 'T001', 900, 2500),
('marco.oliveira@email.com', '2019-07-15', 'T003', 12500, 56000),
('nina.santos@email.com', '2021-12-03', 'T002', 7000, 29500),
('omar.hassan@email.com', '2020-05-28', 'T002', 5000, 25000),
('petra.kova@email.com', '2022-02-14', 'T001', 1600, 5500),
('quincy.adams@email.com', '2019-10-01', 'T004', 19000, 110000),
('rosa.mendez@email.com', '2023-07-08', 'T001', 200, 500),
('samuel.torres@email.com', '2020-09-22', 'T002', 6000, 27000),
('tina.wu@email.com', '2021-06-17', 'T003', 10500, 54000),
('ulrich.bauer@email.com', '2019-03-04', 'T004', 21000, 118000),
('vera.novak@email.com', '2022-07-31', 'T001', 700, 2000),
('william.fisher@email.com', '2020-11-13', 'T003', 15500, 64000),
('xiao.li@email.com', '2021-10-06', 'T002', 6500, 28000);

-- =====================
-- IDENTITAS (30 rows)
-- =====================
INSERT INTO IDENTITAS (nomor, email_member, tanggal_habis, tanggal_terbit, negara_penerbit, jenis) VALUES
('P-US-001234', 'alice.smith@email.com', '2028-03-15', '2018-03-15', 'United States', 'Passport'),
('P-US-001235', 'bob.jones@email.com', '2027-07-22', '2017-07-22', 'United States', 'Passport'),
('P-ID-001001', 'citra.dewi@email.com', '2029-01-10', '2019-01-10', 'Indonesia', 'Passport'),
('P-ID-001002', 'dian.pratama@email.com', '2026-05-18', '2016-05-18', 'Indonesia', 'Passport'),
('P-DE-001001', 'eva.stratt@email.com', '2030-11-30', '2020-11-30', 'Germany', 'Passport'),
('P-DE-001002', 'frank.ocean@email.com', '2027-09-14', '2017-09-14', 'Germany', 'Passport'),
('P-SG-001001', 'ryland.grace@email.com', '2029-04-25', '2019-04-25', 'Singapore', 'Passport'),
('P-SG-001002', 'henry.lim@email.com', '2028-08-03', '2018-08-03', 'Singapore', 'Passport'),
('P-PH-001001', 'irene.santos@email.com', '2030-12-07', '2020-12-07', 'Philippines', 'Passport'),
('P-PH-001002', 'jose.garcia@email.com', '2027-06-19', '2017-06-19', 'Philippines', 'Passport'),
('P-VN-001001', 'karen.nguyen@email.com', '2029-02-28', '2019-02-28', 'Vietnam', 'Passport'),
('P-VN-001002', 'lan.tran@email.com', '2028-10-11', '2018-10-11', 'Vietnam', 'Passport'),
('P-MY-001001', 'maya.ali@email.com', '2030-07-16', '2020-07-16', 'Malaysia', 'Passport'),
('P-MY-001002', 'noor.hassan@email.com', '2027-03-29', '2017-03-29', 'Malaysia', 'Passport'),
('P-GB-001001', 'olivia.brown@email.com', '2031-09-05', '2021-09-05', 'United Kingdom', 'Passport'),
('P-GB-001002', 'peter.parker@email.com', '2026-01-23', '2016-01-23', 'United Kingdom', 'Passport'),
('P-KR-001001', 'queen.park@email.com', '2029-05-12', '2019-05-12', 'South Korea', 'Passport'),
('P-KR-001002', 'ryan.kim@email.com', '2028-11-08', '2018-11-08', 'South Korea', 'Passport'),
('P-JP-001001', 'sara.yamamoto@email.com', '2030-08-21', '2020-08-21', 'Japan', 'Passport'),
('P-JP-001002', 'taro.suzuki@email.com', '2027-04-17', '2017-04-17', 'Japan', 'Passport'),
('P-CN-001001', 'uma.chen@email.com', '2031-12-03', '2021-12-03', 'China', 'Passport'),
('P-CN-001002', 'victor.wang@email.com', '2028-06-30', '2018-06-30', 'China', 'Passport'),
('P-ID-001003', 'wina.sari@email.com', '2031-03-14', '2021-03-14', 'Indonesia', 'Passport'),
('P-US-001236', 'xander.scott@email.com', '2029-07-09', '2019-07-09', 'United States', 'Passport'),
('P-JP-001003', 'yuki.ito@email.com', '2030-01-26', '2020-01-26', 'Japan', 'Passport'),
('P-AE-001001', 'zara.ahmed@email.com', '2028-09-18', '2018-09-18', 'United Arab Emirates', 'Passport'),
('P-US-001237', 'adam.clark@email.com', '2027-05-07', '2017-05-07', 'United States', 'Passport'),
('P-GB-001003', 'bella.ross@email.com', '2030-11-24', '2020-11-24', 'United Kingdom', 'Passport'),
('P-ES-001001', 'carlos.sainz@email.com', '2028-08-13', '2018-08-13', 'Spain', 'Passport'),
('P-ES-001002', 'diana.lopez@email.com', '2031-02-06', '2021-02-06', 'Spain', 'Passport');

-- =====================
-- TRANSFER (15 rows)
-- =====================
INSERT INTO TRANSFER (email_member_1, email_member_2, timestamp, jumlah, catatan) VALUES
('alice.smith@email.com', 'bob.jones@email.com', '2024-01-10 10:30:00', 2000, 'Transfer untuk liburan bersama'),
('frank.ocean@email.com', 'eva.stratt@email.com', '2024-01-15 14:00:00', 5000, 'Hadiah ulang tahun'),
('peter.parker@email.com', 'olivia.brown@email.com', '2024-02-03 09:15:00', 3000, 'Bantuan miles'),
('taro.suzuki@email.com', 'sara.yamamoto@email.com', '2024-02-20 16:45:00', 4000, 'Transfer keluarga'),
('ivan.petrov@email.com', 'julia.volkova@email.com', '2024-03-05 11:00:00', 6000, 'Miles perjalanan bisnis'),
('bob.jones@email.com', 'citra.dewi@email.com', '2024-03-18 13:30:00', 1500, NULL),
('quincy.adams@email.com', 'rosa.mendez@email.com', '2024-04-01 08:00:00', 2500, 'Transfer rutin'),
('ulrich.bauer@email.com', 'vera.novak@email.com', '2024-04-12 15:20:00', 3500, 'Berbagi miles'),
('henry.lim@email.com', 'ryland.grace@email.com', '2024-05-07 10:00:00', 1000, NULL),
('noor.hassan@email.com', 'maya.ali@email.com', '2024-05-19 12:45:00', 2000, 'Bantuan untuk redeem'),
('william.fisher@email.com', 'vera.novak@email.com', '2024-06-02 09:30:00', 1500, NULL),
('adam.clark@email.com', 'bella.ross@email.com', '2024-06-15 14:00:00', 3000, 'Perjalanan bersama'),
('marco.oliveira@email.com', 'nina.santos@email.com', '2024-07-08 11:15:00', 2500, NULL),
('tina.wu@email.com', 'samuel.torres@email.com', '2024-07-22 16:00:00', 1800, 'Miles bonus'),
('kevin.silva@email.com', 'laura.costa@email.com', '2024-08-05 10:30:00', 2200, 'Transfer akhir program');

-- =====================
-- PENYEDIA (8 rows)
-- =====================
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 1 (Garuda Indonesia)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 2 (Singapore Airlines)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 3 (Malaysia Airlines)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 4 (Thai Airways)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 5 (Philippines Airlines)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 6 (Mitra: TravelokaPartner)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 7 (Mitra: HotelIndonesia)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 8 (Mitra: ShopeeTravel)

-- =====================
-- BANDARA (15 rows)
-- =====================
INSERT INTO BANDARA (iata_code, nama, kota, negara) VALUES
('CGK', 'Soekarno-Hatta International Airport', 'Tangerang', 'Indonesia'),
('DPS', 'Ngurah Rai International Airport', 'Denpasar', 'Indonesia'),
('SUB', 'Juanda International Airport', 'Surabaya', 'Indonesia'),
('SIN', 'Singapore Changi Airport', 'Singapore', 'Singapore'),
('KUL', 'Kuala Lumpur International Airport', 'Kuala Lumpur', 'Malaysia'),
('BKK', 'Suvarnabhumi Airport', 'Bangkok', 'Thailand'),
('MNL', 'Ninoy Aquino International Airport', 'Manila', 'Philippines'),
('NRT', 'Narita International Airport', 'Tokyo', 'Japan'),
('ICN', 'Incheon International Airport', 'Seoul', 'South Korea'),
('HKG', 'Hong Kong International Airport', 'Hong Kong', 'China'),
('SYD', 'Sydney Kingsford Smith Airport', 'Sydney', 'Australia'),
('DXB', 'Dubai International Airport', 'Dubai', 'United Arab Emirates'),
('LHR', 'Heathrow Airport', 'London', 'United Kingdom'),
('AMS', 'Amsterdam Airport Schiphol', 'Amsterdam', 'Netherlands'),
('DOH', 'Hamad International Airport', 'Doha', 'Qatar');

-- =====================
-- MASKAPAI (5 rows)
-- =====================
INSERT INTO MASKAPAI (kode_maskapai, nama_maskapai, id_penyedia) VALUES
('GA',  'Garuda Indonesia',      1),
('SQ',  'Singapore Airlines',    2),
('MH',  'Malaysia Airlines',     3),
('TG',  'Thai Airways',          4),
('PR',  'Philippine Airlines',   5);

-- =====================
-- MITRA (5 rows)
-- =====================
INSERT INTO MITRA (email_mitra, id_penyedia, nama_mitra, tanggal_kerja_sama) VALUES
('partner@traveloka.com',       6, 'TravelokaPartner',       '2022-01-15'),
('partner@hotelindonesia.com',  7, 'Hotel Indonesia Kempinski','2021-06-01'),
('partner@shopeetravel.com',    8, 'ShopeeTravel',           '2023-03-10');

INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 9 (Mitra: AgodaPartner)
INSERT INTO PENYEDIA DEFAULT VALUES; -- id = 10 (Mitra: TiketPartner)

INSERT INTO MITRA (email_mitra, id_penyedia, nama_mitra, tanggal_kerja_sama) VALUES
('partner@agoda.com',     9,  'AgodaPartner',  '2022-09-20'),
('partner@tiket.com',     10, 'TiketPartner',  '2023-07-05');

-- =====================
-- HADIAH (10 rows)
-- =====================
INSERT INTO HADIAH (nama, miles, deskripsi, valid_start_date, program_end, id_penyedia) VALUES
('Tiket Domestik PP',           15000, 'Tiket pulang-pergi rute domestik Indonesia via Garuda Indonesia',    '2024-01-01', '2025-12-31', 1),
('Upgrade ke Business Class',   25000, 'Upgrade dari economy class ke business class via Garuda Indonesia',   '2024-01-01', '2025-12-31', 1),
('Voucher Hotel Rp 500.000',     8000, 'Voucher menginap 1 malam di Hotel Indonesia Kempinski Jakarta',       '2024-06-01', '2025-06-30', 7),
('Akses Lounge 1x',              3000, 'Akses lounge seluruh bandara partner ShopeeTravel 1 kali masuk',      '2024-01-01', '2025-12-31', 8),
('Diskon Hotel 30%',             5000, 'Diskon 30% pemesanan hotel melalui Traveloka partner program',         '2024-03-01', '2025-12-31', 6),
('Tiket Singapore Airlines',    20000, 'Tiket penerbangan Singapore Airlines rute Asia tenggara',              '2024-01-01', '2026-01-31', 2),
('Free Bagasi 10kg SQ',          6000, 'Extra bagasi 10kg untuk penerbangan Singapore Airlines',              '2024-04-01', '2025-09-30', 2),
('Voucher Agoda Rp 300.000',     4000, 'Voucher pemesanan hotel melalui Agoda senilai Rp 300.000',            '2024-07-01', '2025-07-31', 9),
('Tiket Pesawat TiketPartner',  12000, 'Tiket pesawat domestik maupun internasional via Tiket.com',           '2024-01-01', '2025-12-31', 10),
('Akses Lounge Premium MH',      7000, 'Akses Malaysia Airlines Golden Lounge di Kuala Lumpur',               '2024-02-01', '2025-12-31', 3);

-- =====================
-- STAF (10 rows)
-- =====================
INSERT INTO STAF (email, kode_maskapai) VALUES
('yasmin.omar@email.com',       'GA'),
('zaki.rahman@email.com',       'GA'),
('aisha.malik@email.com',       'SQ'),
('bilal.khan@email.com',        'SQ'),
('clara.johansson@email.com',   'MH'),
('david.lindqvist@email.com',   'MH'),
('elena.popescu@email.com',     'TG'),
('felix.ionescu@email.com',     'TG'),
('gina.thomas@email.com',       'PR'),
('harry.nguyen@email.com',      'PR');

-- =====================
-- AWARD_MILES_PACKAGE (5 rows)
-- =====================
INSERT INTO AWARD_MILES_PACKAGE (harga_paket, jumlah_award_miles) VALUES
(150000.00,   5000),
(280000.00,  10000),
(500000.00,  20000),
(900000.00,  40000),
(1500000.00, 75000);
 
-- =====================
-- MEMBER_AWARD_MILES_PACKAGE (20 rows)
-- =====================
INSERT INTO MEMBER_AWARD_MILES_PACKAGE (id_award_miles_package, email_member, timestamp) VALUES
('AMP-001', 'alice.smith@email.com',    '2024-01-05 09:00:00'),
('AMP-002', 'bob.jones@email.com',      '2024-01-12 14:30:00'),
('AMP-003', 'citra.dewi@email.com',     '2024-02-01 10:15:00'),
('AMP-001', 'dian.pratama@email.com',   '2024-02-14 11:00:00'),
('AMP-004', 'frank.ocean@email.com',    '2024-02-20 16:00:00'),
('AMP-002', 'henry.lim@email.com',      '2024-03-03 08:45:00'),
('AMP-003', 'ivan.petrov@email.com',    '2024-03-10 13:20:00'),
('AMP-005', 'jose.garcia@email.com',    '2024-03-18 15:30:00'),
('AMP-001', 'karen.nguyen@email.com',   '2024-04-02 09:10:00'),
('AMP-002', 'lan.tran@email.com',       '2024-04-08 12:00:00'),
('AMP-003', 'marco.oliveira@email.com', '2024-04-15 17:00:00'),
('AMP-004', 'noor.hassan@email.com',    '2024-05-01 10:30:00'),
('AMP-001', 'olivia.brown@email.com',   '2024-05-10 14:00:00'),
('AMP-002', 'peter.parker@email.com',   '2024-05-22 11:45:00'),
('AMP-003', 'queen.park@email.com',     '2024-06-01 09:30:00'),
('AMP-005', 'ryan.kim@email.com',       '2024-06-12 16:20:00'),
('AMP-001', 'samuel.torres@email.com',  '2024-06-25 10:00:00'),
('AMP-002', 'taro.suzuki@email.com',    '2024-07-04 13:15:00'),
('AMP-004', 'uma.chen@email.com',       '2024-07-18 15:00:00'),
('AMP-003', 'victor.wang@email.com',    '2024-08-01 11:30:00'); 
 
-- =====================
-- REDEEM (20 rows)
-- =====================
INSERT INTO REDEEM (email_member, kode_hadiah, timestamp) VALUES
('alice.smith@email.com',    'RWD-001', '2024-01-20 10:00:00'),
('bob.jones@email.com',      'RWD-002', '2024-01-25 14:30:00'),
('citra.dewi@email.com',     'RWD-004', '2024-02-05 09:15:00'),
('dian.pratama@email.com',   'RWD-005', '2024-02-18 11:00:00'),
('frank.ocean@email.com',    'RWD-006', '2024-02-28 16:45:00'),
('henry.lim@email.com',      'RWD-003', '2024-03-07 13:00:00'),
('ivan.petrov@email.com',    'RWD-002', '2024-03-15 10:30:00'),
('jose.garcia@email.com',    'RWD-007', '2024-03-25 15:00:00'),
('karen.nguyen@email.com',   'RWD-008', '2024-04-04 08:30:00'),
('lan.tran@email.com',       'RWD-009', '2024-04-10 12:15:00'),
('marco.oliveira@email.com', 'RWD-010', '2024-04-20 17:00:00'),
('noor.hassan@email.com',    'RWD-001', '2024-05-03 09:00:00'),
('olivia.brown@email.com',   'RWD-004', '2024-05-12 14:45:00'),
('peter.parker@email.com',   'RWD-002', '2024-05-24 11:30:00'),
('queen.park@email.com',     'RWD-005', '2024-06-03 10:00:00'),
('ryan.kim@email.com',       'RWD-006', '2024-06-14 16:00:00'),
('samuel.torres@email.com',  'RWD-008', '2024-06-27 13:30:00'),
('taro.suzuki@email.com',    'RWD-003', '2024-07-06 09:45:00'),
('uma.chen@email.com',       'RWD-007', '2024-07-20 15:30:00'),
('victor.wang@email.com',    'RWD-010', '2024-08-03 11:00:00');
 
-- =====================
-- CLAIM_MISSING_MILES (20 rows)
-- =====================
INSERT INTO CLAIM_MISSING_MILES
    (email_member, email_staf, maskapai, bandara_asal, bandara_tujuan,
     tanggal_penerbangan, flight_number, nomor_tiket, kelas_kabin, pnr,
     status_penerimaan, timestamp)
VALUES
('alice.smith@email.com',    'yasmin.omar@email.com',     'GA', 'CGK', 'DPS', '2024-01-08', 'GA-401',  'TKT-GA-0001', 'Economy',  'PNR001', 'Diterima',  '2024-01-10 09:00:00'),
('bob.jones@email.com',      'zaki.rahman@email.com',     'GA', 'CGK', 'SUB', '2024-01-15', 'GA-502',  'TKT-GA-0002', 'Business', 'PNR002', 'Diterima',  '2024-01-17 10:30:00'),
('citra.dewi@email.com',     'aisha.malik@email.com',     'SQ', 'SIN', 'CGK', '2024-01-22', 'SQ-211',  'TKT-SQ-0001', 'Economy',  'PNR003', 'Menunggu',  '2024-01-24 08:45:00'),
('dian.pratama@email.com',   'bilal.khan@email.com',      'SQ', 'CGK', 'SIN', '2024-02-03', 'SQ-212',  'TKT-SQ-0002', 'Economy',  'PNR004', 'Diterima',  '2024-02-05 11:00:00'),
('frank.ocean@email.com',    'clara.johansson@email.com', 'MH', 'KUL', 'CGK', '2024-02-10', 'MH-730',  'TKT-MH-0001', 'Business', 'PNR005', 'Diterima',  '2024-02-12 14:15:00'),
('henry.lim@email.com',      'david.lindqvist@email.com', 'MH', 'CGK', 'KUL', '2024-02-17', 'MH-731',  'TKT-MH-0002', 'Economy',  'PNR006', 'Ditolak',   '2024-02-19 09:30:00'),
('ivan.petrov@email.com',    'elena.popescu@email.com',   'TG', 'BKK', 'CGK', '2024-02-24', 'TG-435',  'TKT-TG-0001', 'Economy',  'PNR007', 'Diterima',  '2024-02-26 13:00:00'),
('jose.garcia@email.com',    'felix.ionescu@email.com',   'TG', 'CGK', 'BKK', '2024-03-02', 'TG-436',  'TKT-TG-0002', 'Business', 'PNR008', 'Menunggu',  '2024-03-04 10:00:00'),
('karen.nguyen@email.com',   'gina.thomas@email.com',     'PR', 'MNL', 'CGK', '2024-03-09', 'PR-512',  'TKT-PR-0001', 'Economy',  'PNR009', 'Diterima',  '2024-03-11 15:30:00'),
('lan.tran@email.com',       'harry.nguyen@email.com',    'PR', 'CGK', 'MNL', '2024-03-16', 'PR-513',  'TKT-PR-0002', 'Economy',  'PNR010', 'Ditolak',   '2024-03-18 08:00:00'),
('marco.oliveira@email.com', 'yasmin.omar@email.com',     'GA', 'CGK', 'NRT', '2024-03-23', 'GA-870',  'TKT-GA-0003', 'Economy',  'PNR011', 'Menunggu',  '2024-03-25 12:00:00'),
('noor.hassan@email.com',    'zaki.rahman@email.com',     'GA', 'DPS', 'CGK', '2024-04-01', 'GA-402',  'TKT-GA-0004', 'Economy',  'PNR012', 'Diterima',  '2024-04-03 09:15:00'),
('olivia.brown@email.com',   'aisha.malik@email.com',     'SQ', 'SIN', 'LHR', '2024-04-08', 'SQ-321',  'TKT-SQ-0003', 'Economy',  'PNR013', 'Menunggu',  '2024-04-10 14:00:00'),
('peter.parker@email.com',   'bilal.khan@email.com',      'SQ', 'LHR', 'SIN', '2024-04-15', 'SQ-322',  'TKT-SQ-0004', 'Business', 'PNR014', 'Diterima',  '2024-04-17 11:45:00'),
('queen.park@email.com',     'clara.johansson@email.com', 'MH', 'KUL', 'ICN', '2024-04-22', 'MH-066',  'TKT-MH-0003', 'Economy',  'PNR015', 'Ditolak',   '2024-04-24 10:30:00'),
('ryan.kim@email.com',       'david.lindqvist@email.com', 'MH', 'ICN', 'KUL', '2024-05-01', 'MH-067',  'TKT-MH-0004', 'Economy',  'PNR016', 'Diterima',  '2024-05-03 09:00:00'),
('samuel.torres@email.com',  'elena.popescu@email.com',   'TG', 'BKK', 'NRT', '2024-05-10', 'TG-681',  'TKT-TG-0003', 'Economy',  'PNR017', 'Menunggu',  '2024-05-12 13:30:00'),
('taro.suzuki@email.com',    'gina.thomas@email.com',     'PR', 'MNL', 'NRT', '2024-05-19', 'PR-822',  'TKT-PR-0003', 'Business', 'PNR018', 'Diterima',  '2024-05-21 16:00:00'),
('uma.chen@email.com',       'harry.nguyen@email.com',    'PR', 'NRT', 'MNL', '2024-05-28', 'PR-823',  'TKT-PR-0004', 'Economy',  'PNR019', 'Diterima',  '2024-05-30 10:15:00'),
('victor.wang@email.com',    'yasmin.omar@email.com',     'GA', 'CGK', 'HKG', '2024-06-05', 'GA-891',  'TKT-GA-0005', 'Business', 'PNR020', 'Menunggu',  '2024-06-07 14:00:00');
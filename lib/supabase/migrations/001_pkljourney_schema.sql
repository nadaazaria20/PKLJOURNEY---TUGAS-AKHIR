-- ============================================================
-- PKLJOURNEY – Database Schema Migration (Clean Reset & Setup)
-- Jalankan di: Supabase Dashboard → SQL Editor
-- ============================================================

-- Hapus tabel lama (jika ada) agar tidak terjadi konflik kolom lama
DROP TABLE IF EXISTS public.attendance_records CASCADE;
DROP TABLE IF EXISTS public.journal_entries CASCADE;
DROP TABLE IF EXISTS public.internship_locations CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- ── 1. TABEL PENGGUNA (users) ────────────────────────────────
CREATE TABLE public.users (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id            UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  username           TEXT NOT NULL UNIQUE,
  password_hash      TEXT NOT NULL,
  name               TEXT NOT NULL,
  role               TEXT NOT NULL CHECK (role IN ('admin','guru','iduka','murid')),
  account_id         TEXT NOT NULL UNIQUE, -- Username / NIP / NISN / ID IDUKA
  mentor_account_id  TEXT,                 -- NIP guru pembimbing sekolah
  iduka_account_id   TEXT,                 -- ID pembimbing industri IDUKA
  company_name       TEXT,
  address            TEXT,
  phone_number       TEXT,
  school             TEXT DEFAULT 'SMK Negeri 1 Jakarta',
  created_at         TIMESTAMPTZ DEFAULT NOW(),
  updated_at         TIMESTAMPTZ DEFAULT NOW()
);

-- ── 2. TABEL LOKASI PKL (internship_locations) ──────────────
CREATE TABLE public.internship_locations (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_account_id TEXT NOT NULL UNIQUE REFERENCES public.users(account_id) ON DELETE CASCADE,
  company_name       TEXT NOT NULL,
  address            TEXT NOT NULL,
  latitude           DOUBLE PRECISION DEFAULT -6.2146,
  longitude          DOUBLE PRECISION DEFAULT 106.8189,
  radius_meters      INTEGER DEFAULT 50,
  created_at         TIMESTAMPTZ DEFAULT NOW(),
  updated_at         TIMESTAMPTZ DEFAULT NOW()
);

-- ── 3. TABEL PRESENSI (attendance_records) ──────────────────
CREATE TABLE public.attendance_records (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_account_id   TEXT NOT NULL REFERENCES public.users(account_id) ON DELETE CASCADE,
  date                 DATE NOT NULL,
  check_in_time        TEXT,
  check_out_time       TEXT,
  check_in_photo       TEXT,
  check_out_photo      TEXT,
  is_approved_by_iduka BOOLEAN NOT NULL DEFAULT FALSE,
  iduka_approver_name  TEXT,
  iduka_approval_time  TEXT,
  notes                TEXT,
  created_at           TIMESTAMPTZ DEFAULT NOW(),
  updated_at           TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (student_account_id, date)
);

-- ── 4. TABEL JURNAL (journal_entries) ───────────────────────
CREATE TABLE public.journal_entries (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_account_id TEXT NOT NULL REFERENCES public.users(account_id) ON DELETE CASCADE,
  title              TEXT NOT NULL,
  description        TEXT NOT NULL,
  date               TEXT NOT NULL,
  time               TEXT NOT NULL,
  tag                TEXT NOT NULL DEFAULT 'Kegiatan',
  is_reviewed        BOOLEAN NOT NULL DEFAULT FALSE,
  image_url          TEXT,
  teacher_note       TEXT,
  created_at         TIMESTAMPTZ DEFAULT NOW(),
  updated_at         TIMESTAMPTZ DEFAULT NOW()
);

-- ── 5. TRIGGER UPDATED_AT ────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_locations_updated_at
  BEFORE UPDATE ON public.internship_locations
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_attendance_updated_at
  BEFORE UPDATE ON public.attendance_records
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_journal_updated_at
  BEFORE UPDATE ON public.journal_entries
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── 6. ROW LEVEL SECURITY (RLS) ──────────────────────────────
ALTER TABLE public.users                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.internship_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries      ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all_ops" ON public.users FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "allow_all_ops" ON public.internship_locations FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "allow_all_ops" ON public.attendance_records FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "allow_all_ops" ON public.journal_entries FOR ALL USING (TRUE) WITH CHECK (TRUE);

-- ── 7. DATA SEED (DEMO USERS 4 ROLE) ─────────────────────────
INSERT INTO public.users (username, password_hash, name, role, account_id, address, phone_number)
VALUES ('admin', 'admin', 'Administrator PKLJOURNEY', 'admin', 'admin',
        'Jl. Budi Utomo No. 7, Jakarta Pusat', '081234567890')
ON CONFLICT (username) DO NOTHING;

INSERT INTO public.users (username, password_hash, name, role, account_id, address, phone_number)
VALUES ('guru', 'guru', 'Danang Dwi Gusti Fajar Yudha, S.Kom.', 'guru', '19820109940201',
        'Jl. Rawamangun Muka No. 12, Jakarta Timur', '081398765432')
ON CONFLICT (username) DO NOTHING;

INSERT INTO public.users (username, password_hash, name, role, account_id,
                          company_name, address, phone_number)
VALUES ('iduka', 'iduka', 'Hendro Prasetyo, S.T.', 'iduka', 'IDUKA-001',
        'PT Aksara Digital Nusantara',
        'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
        '082199887766')
ON CONFLICT (username) DO NOTHING;

INSERT INTO public.users (username, password_hash, name, role, account_id,
                          mentor_account_id, iduka_account_id, company_name, address, phone_number)
VALUES ('murid', 'murid', 'Frida Awan', 'murid', '007812121134',
        '19820109940201', 'IDUKA-001', 'PT Aksara Digital Nusantara',
        'Jl. Tebet Barat Dalam No. 15, Jakarta Selatan', '085711223344')
ON CONFLICT (username) DO NOTHING;

INSERT INTO public.internship_locations (teacher_account_id, company_name, address)
VALUES ('19820109940201', 'PT Aksara Digital Nusantara',
        'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat')
ON CONFLICT (teacher_account_id) DO NOTHING;

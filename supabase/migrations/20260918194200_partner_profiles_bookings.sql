-- ============================================================
-- Migration: partner_profiles + bookings + auto-assignment fn
-- Timestamp: 20260918194200
-- ============================================================

-- 1. partner_profiles table
CREATE TABLE IF NOT EXISTS public.partner_profiles (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       TEXT NOT NULL,
  name          TEXT NOT NULL,
  specialty     TEXT NOT NULL,          -- e.g. 'AC Repair', 'Plumbing', 'Electrical'
  is_available  BOOLEAN NOT NULL DEFAULT true,
  latitude      DOUBLE PRECISION,
  longitude     DOUBLE PRECISION,
  rating        DOUBLE PRECISION DEFAULT 4.5,
  avatar_url    TEXT,
  created_at    TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_partner_profiles_specialty
  ON public.partner_profiles (specialty);

CREATE INDEX IF NOT EXISTS idx_partner_profiles_available
  ON public.partner_profiles (is_available);

ALTER TABLE public.partner_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "partner_profiles_open_read" ON public.partner_profiles;
CREATE POLICY "partner_profiles_open_read"
  ON public.partner_profiles FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "partner_profiles_open_write" ON public.partner_profiles;
CREATE POLICY "partner_profiles_open_write"
  ON public.partner_profiles FOR ALL TO public USING (true) WITH CHECK (true);

-- 2. bookings table
CREATE TABLE IF NOT EXISTS public.bookings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_ref     TEXT NOT NULL UNIQUE,
  customer_id     TEXT,
  partner_id      UUID REFERENCES public.partner_profiles(id) ON DELETE SET NULL,
  service         TEXT NOT NULL,
  address         TEXT,
  customer_lat    DOUBLE PRECISION,
  customer_lng    DOUBLE PRECISION,
  scheduled_at    TEXT,
  status          TEXT NOT NULL DEFAULT 'confirmed',
  total_amount    INTEGER DEFAULT 0,
  payment_id      TEXT,
  payment_method  TEXT,
  partner_name    TEXT,
  created_at      TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bookings_booking_ref
  ON public.bookings (booking_ref);

CREATE INDEX IF NOT EXISTS idx_bookings_partner_id
  ON public.bookings (partner_id);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "bookings_open_access" ON public.bookings;
CREATE POLICY "bookings_open_access"
  ON public.bookings FOR ALL TO public USING (true) WITH CHECK (true);

-- 3. Haversine-based partner auto-selection function
--    Returns the nearest available partner matching the requested specialty.
--    Falls back to any available partner with that specialty if no lat/lng provided.
CREATE OR REPLACE FUNCTION public.find_nearest_partner(
  p_specialty    TEXT,
  p_customer_lat DOUBLE PRECISION DEFAULT NULL,
  p_customer_lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS TABLE (
  partner_id   UUID,
  partner_name TEXT,
  rating       DOUBLE PRECISION,
  avatar_url   TEXT,
  distance_km  DOUBLE PRECISION
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
  IF p_customer_lat IS NOT NULL AND p_customer_lng IS NOT NULL THEN
    -- Return nearest available partner by Haversine distance
    RETURN QUERY
    SELECT
      pp.id                                                          AS partner_id,
      pp.name                                                        AS partner_name,
      pp.rating,
      pp.avatar_url,
      (
        6371.0 * 2.0 * ASIN(
          SQRT(
            POWER(SIN(RADIANS(pp.latitude  - p_customer_lat)  / 2.0), 2) +
            COS(RADIANS(p_customer_lat)) *
            COS(RADIANS(pp.latitude)) *
            POWER(SIN(RADIANS(pp.longitude - p_customer_lng) / 2.0), 2)
          )
        )
      )::DOUBLE PRECISION                                            AS distance_km
    FROM public.partner_profiles pp
    WHERE pp.is_available = true
      AND pp.specialty    = p_specialty
      AND pp.latitude     IS NOT NULL
      AND pp.longitude    IS NOT NULL
    ORDER BY distance_km ASC
    LIMIT 1;
  ELSE
    -- No coordinates: return highest-rated available partner
    RETURN QUERY
    SELECT
      pp.id         AS partner_id,
      pp.name       AS partner_name,
      pp.rating,
      pp.avatar_url,
      NULL::DOUBLE PRECISION AS distance_km
    FROM public.partner_profiles pp
    WHERE pp.is_available = true
      AND pp.specialty    = p_specialty
    ORDER BY pp.rating DESC
    LIMIT 1;
  END IF;
END;
$$;

-- 4. Seed partner profiles (idempotent)
DO $$
DECLARE
  p1 UUID := gen_random_uuid();
  p2 UUID := gen_random_uuid();
  p3 UUID := gen_random_uuid();
  p4 UUID := gen_random_uuid();
  p5 UUID := gen_random_uuid();
  p6 UUID := gen_random_uuid();
  p7 UUID := gen_random_uuid();
  p8 UUID := gen_random_uuid();
BEGIN
  INSERT INTO public.partner_profiles
    (id, user_id, name, specialty, is_available, latitude, longitude, rating, avatar_url)
  VALUES
    -- AC Repair specialists (Bengaluru area)
    (p1, 'partner-ac-001', 'Rajesh Kumar',   'AC Repair',   true,  12.9716, 77.5946, 4.9,
     'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg'),
    (p2, 'partner-ac-002', 'Suresh Nair',    'AC Repair',   true,  12.9352, 77.6245, 4.7,
     'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg'),

    -- Plumbing specialists
    (p3, 'partner-pl-001', 'Arjun Mehta',    'Plumbing',    true,  12.9784, 77.6408, 4.8,
     'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg'),
    (p4, 'partner-pl-002', 'Vikram Singh',   'Plumbing',    true,  12.9121, 77.6446, 4.6,
     'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg'),

    -- Electrical specialists
    (p5, 'partner-el-001', 'Pradeep Sharma', 'Electrical',  true,  12.9592, 77.6974, 4.8,
     'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg'),
    (p6, 'partner-el-002', 'Mohan Das',      'Electrical',  true,  12.9850, 77.7080, 4.5,
     'https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg'),

    -- Carpentry specialists
    (p7, 'partner-ca-001', 'Ravi Verma',     'Carpentry',   true,  12.9010, 77.5700, 4.7,
     'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg'),

    -- Locksmith specialists
    (p8, 'partner-lk-001', 'Sanjay Gupta',   'Locksmith',   true,  12.9650, 77.5900, 4.6,
     'https://images.pexels.com/photos/1300402/pexels-photo-1300402.jpeg')
  ON CONFLICT (id) DO NOTHING;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Seed data insertion skipped: %', SQLERRM;
END $$;

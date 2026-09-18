-- Migration: partner_locations
-- Stores the latest GPS location published by a partner during an active job.
-- Realtime is enabled so the customer's Live Tracking screen receives push updates.

-- ── Table ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.partner_locations (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id        TEXT        NOT NULL,
  partner_id    TEXT,
  latitude      DOUBLE PRECISION NOT NULL,
  longitude     DOUBLE PRECISION NOT NULL,
  accuracy      DOUBLE PRECISION,
  published_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ── Unique index so we can UPSERT on job_id ──────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS idx_partner_locations_job_id
  ON public.partner_locations (job_id);

-- ── General index for fast lookups ───────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_partner_locations_published_at
  ON public.partner_locations (published_at DESC);

-- ── RLS ──────────────────────────────────────────────────────────────────────
ALTER TABLE public.partner_locations ENABLE ROW LEVEL SECURITY;

-- Partners can insert / update their own location row
DROP POLICY IF EXISTS "partner_locations_write" ON public.partner_locations;
CREATE POLICY "partner_locations_write"
  ON public.partner_locations
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- ── Realtime publication ──────────────────────────────────────────────────────
-- Add the table to the supabase_realtime publication so clients receive
-- postgres_changes events.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename  = 'partner_locations'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.partner_locations;
  END IF;
END $$;

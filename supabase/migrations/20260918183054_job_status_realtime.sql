-- ============================================================
-- Fixiqo: Job Status Real-Time Updates Module
-- ============================================================

-- 1. Job status enum
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'job_status_type') THEN
    CREATE TYPE public.job_status_type AS ENUM (
      'accepted',
      'en_route',
      'arrived',
      'in_service',
      'completed',
      'cancelled'
    );
  END IF;
END $$;

-- 2. Job status updates table
CREATE TABLE IF NOT EXISTS public.job_status_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id TEXT NOT NULL,
  booking_id TEXT,
  partner_id TEXT,
  customer_id TEXT,
  status TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_job_status_job_id ON public.job_status_updates(job_id);
CREATE INDEX IF NOT EXISTS idx_job_status_booking_id ON public.job_status_updates(booking_id);
CREATE INDEX IF NOT EXISTS idx_job_status_updated_at ON public.job_status_updates(updated_at DESC);

-- 4. Enable RLS
ALTER TABLE public.job_status_updates ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies (permissive for demo — no auth required)
DROP POLICY IF EXISTS "anon_read_job_status" ON public.job_status_updates;
CREATE POLICY "anon_read_job_status"
ON public.job_status_updates
FOR SELECT
TO anon
USING (true);

DROP POLICY IF EXISTS "anon_insert_job_status" ON public.job_status_updates;
CREATE POLICY "anon_insert_job_status"
ON public.job_status_updates
FOR INSERT
TO anon
WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_job_status" ON public.job_status_updates;
CREATE POLICY "anon_update_job_status"
ON public.job_status_updates
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "auth_read_job_status" ON public.job_status_updates;
CREATE POLICY "auth_read_job_status"
ON public.job_status_updates
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "auth_insert_job_status" ON public.job_status_updates;
CREATE POLICY "auth_insert_job_status"
ON public.job_status_updates
FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "auth_update_job_status" ON public.job_status_updates;
CREATE POLICY "auth_update_job_status"
ON public.job_status_updates
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- 6. Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.job_status_updates;

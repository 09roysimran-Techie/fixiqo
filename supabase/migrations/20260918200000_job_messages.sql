-- Migration: job_messages
-- Enables real-time messaging between customer and partner during an active job

-- 1. Create job_messages table
CREATE TABLE IF NOT EXISTS public.job_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id TEXT NOT NULL,
    sender_id TEXT NOT NULL,
    sender_role TEXT NOT NULL DEFAULT 'customer', -- 'customer' | 'partner'
    sender_name TEXT NOT NULL DEFAULT '',
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_job_messages_job_id ON public.job_messages(job_id);
CREATE INDEX IF NOT EXISTS idx_job_messages_created_at ON public.job_messages(created_at);

-- 3. Enable RLS
ALTER TABLE public.job_messages ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies — open access (same pattern as partner_locations)
DROP POLICY IF EXISTS "job_messages_open_read" ON public.job_messages;
CREATE POLICY "job_messages_open_read"
ON public.job_messages
FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "job_messages_open_insert" ON public.job_messages;
CREATE POLICY "job_messages_open_insert"
ON public.job_messages
FOR INSERT
TO public
WITH CHECK (true);

-- 5. Enable Realtime publication
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime'
          AND schemaname = 'public'
          AND tablename = 'job_messages'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.job_messages;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not add job_messages to realtime publication: %', SQLERRM;
END $$;

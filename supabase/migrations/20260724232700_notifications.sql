-- ============================================================
-- Fixiqo: Real-Time Notifications Module
-- ============================================================

-- 1. Notification type enum
DROP TYPE IF EXISTS public.notification_type CASCADE;
CREATE TYPE public.notification_type AS ENUM (
  'new_job_alert',
  'job_accepted',
  'job_started',
  'job_completed',
  'job_cancelled',
  'booking_confirmed',
  'payment_received'
);

-- 2. Notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_id UUID NOT NULL,
  sender_id UUID,
  notification_type public.notification_type NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}'::jsonb,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_id ON public.notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(recipient_id, is_read);

-- 4. Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies
DROP POLICY IF EXISTS "users_read_own_notifications" ON public.notifications;
CREATE POLICY "users_read_own_notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (recipient_id = auth.uid());

DROP POLICY IF EXISTS "users_insert_notifications" ON public.notifications;
CREATE POLICY "users_insert_notifications"
ON public.notifications
FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "users_update_own_notifications" ON public.notifications;
CREATE POLICY "users_update_own_notifications"
ON public.notifications
FOR UPDATE
TO authenticated
USING (recipient_id = auth.uid())
WITH CHECK (recipient_id = auth.uid());

DROP POLICY IF EXISTS "users_delete_own_notifications" ON public.notifications;
CREATE POLICY "users_delete_own_notifications"
ON public.notifications
FOR DELETE
TO authenticated
USING (recipient_id = auth.uid());

-- Allow anon inserts for demo (no auth in current app)
DROP POLICY IF EXISTS "anon_insert_notifications" ON public.notifications;
CREATE POLICY "anon_insert_notifications"
ON public.notifications
FOR INSERT
TO anon
WITH CHECK (true);

DROP POLICY IF EXISTS "anon_read_notifications" ON public.notifications;
CREATE POLICY "anon_read_notifications"
ON public.notifications
FOR SELECT
TO anon
USING (true);

DROP POLICY IF EXISTS "anon_update_notifications" ON public.notifications;
CREATE POLICY "anon_update_notifications"
ON public.notifications
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

-- 6. Enable Realtime for notifications table
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

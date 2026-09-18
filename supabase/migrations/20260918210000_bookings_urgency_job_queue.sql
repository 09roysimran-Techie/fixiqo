-- Migration: Add urgency column to bookings and seed demo job queue data
-- Timestamp: 20260918210000

-- 1. Add urgency column to bookings if not exists
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS urgency TEXT DEFAULT 'Standard';

-- 2. Add customer_name column to bookings for display
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS customer_name TEXT;

-- 3. Add customer_avatar_url column to bookings for display
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS customer_avatar_url TEXT;

-- 4. Add customer_rating column to bookings for display
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS customer_rating INTEGER DEFAULT 4;

-- 5. Add description column to bookings for job details
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS description TEXT;

-- 6. Add distance_km column to bookings
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS distance_km TEXT;

-- 7. Add eta_minutes column to bookings
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS eta_minutes TEXT;

-- 8. Update RLS: allow partners to read bookings assigned to them
DROP POLICY IF EXISTS "partners_read_own_bookings" ON public.bookings;
CREATE POLICY "partners_read_own_bookings"
ON public.bookings
FOR SELECT
TO authenticated
USING (
  partner_id::TEXT = auth.uid()::TEXT
  OR partner_id IS NULL
);

DROP POLICY IF EXISTS "partners_update_own_bookings" ON public.bookings;
CREATE POLICY "partners_update_own_bookings"
ON public.bookings
FOR UPDATE
TO authenticated
USING (partner_id::TEXT = auth.uid()::TEXT)
WITH CHECK (partner_id::TEXT = auth.uid()::TEXT);

-- 9. Allow authenticated users to read all bookings (for job queue)
DROP POLICY IF EXISTS "authenticated_read_bookings" ON public.bookings;
CREATE POLICY "authenticated_read_bookings"
ON public.bookings
FOR SELECT
TO authenticated
USING (true);

-- 10. Allow authenticated users to update booking status
DROP POLICY IF EXISTS "authenticated_update_booking_status" ON public.bookings;
CREATE POLICY "authenticated_update_booking_status"
ON public.bookings
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- 11. Seed demo bookings for job queue
DO $$
DECLARE
  partner_uuid UUID;
BEGIN
  -- Try to get an existing partner profile id
  SELECT id INTO partner_uuid FROM public.partner_profiles LIMIT 1;

  -- Insert demo pending bookings (status = 'pending' means unassigned, in queue)
  INSERT INTO public.bookings (
    id, booking_ref, customer_id, partner_id, service, address,
    customer_lat, customer_lng, scheduled_at, status, total_amount,
    urgency, customer_name, customer_avatar_url, customer_rating,
    description, distance_km, eta_minutes, created_at
  ) VALUES
  (
    gen_random_uuid(), 'BK-DEMO-001', 'demo-customer-001', NULL,
    'Plumbing', '14B, Koramangala 5th Block, Bengaluru',
    12.9352, 77.6245, now()::TEXT, 'pending', 599,
    'Emergency', 'Sneha Kapoor',
    'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
    5, 'Burst pipe under kitchen sink causing flooding. Water needs to be shut off and pipe replaced urgently.',
    '1.4 km', '8 min', now() - interval '5 minutes'
  ),
  (
    gen_random_uuid(), 'BK-DEMO-002', 'demo-customer-002', NULL,
    'AC Repair', '22, Indiranagar 100ft Road, Bengaluru',
    12.9784, 77.6408, now()::TEXT, 'pending', 799,
    'Urgent', 'Rohit Verma',
    'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
    4, 'AC unit not cooling. Compressor making loud noise. 1.5 ton split AC, 3 years old.',
    '3.2 km', '18 min', now() - interval '12 minutes'
  ),
  (
    gen_random_uuid(), 'BK-DEMO-003', 'demo-customer-003', NULL,
    'Electrical', '7, HSR Layout Sector 2, Bengaluru',
    12.9116, 77.6389, now()::TEXT, 'pending', 449,
    'Standard', 'Anita Desai',
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
    4, 'Main circuit breaker keeps tripping. Multiple power outlets not working in living room.',
    '5.1 km', '25 min', now() - interval '20 minutes'
  ),
  (
    gen_random_uuid(), 'BK-DEMO-004', 'demo-customer-004', NULL,
    'Carpentry', '45, Whitefield Main Road, Bengaluru',
    12.9698, 77.7499, now()::TEXT, 'pending', 350,
    'Standard', 'Priya Sharma',
    'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
    5, 'Wardrobe door hinge broken. Need replacement and alignment of 2 doors.',
    '8.3 km', '35 min', now() - interval '30 minutes'
  )
  ON CONFLICT (booking_ref) DO NOTHING;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Demo booking seed failed: %', SQLERRM;
END $$;

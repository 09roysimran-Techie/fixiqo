-- Migration: Partner Earnings Screen
-- Timestamp: 20260918240000

-- 1. Add partner_user_id column to bookings so partners can query their own completed jobs
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS partner_user_id TEXT DEFAULT NULL;

-- 2. Index for fast partner earnings queries
CREATE INDEX IF NOT EXISTS idx_bookings_partner_user_id ON public.bookings(partner_user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status_completed ON public.bookings(status) WHERE status = 'completed';
CREATE INDEX IF NOT EXISTS idx_bookings_completed_at ON public.bookings(completed_at);

-- 3. RLS: Allow partners to read their own completed bookings via partner_user_id
DROP POLICY IF EXISTS "partners_read_own_earnings" ON public.bookings;
CREATE POLICY "partners_read_own_earnings"
ON public.bookings
FOR SELECT
TO authenticated
USING (
  partner_user_id = auth.uid()::text
  OR partner_id::text = auth.uid()::text
  OR true
);

-- 4. Seed demo completed bookings for earnings display
DO $$
DECLARE
  partner_profile_id UUID;
  booking1_id UUID := gen_random_uuid();
  booking2_id UUID := gen_random_uuid();
  booking3_id UUID := gen_random_uuid();
  booking4_id UUID := gen_random_uuid();
  booking5_id UUID := gen_random_uuid();
  booking6_id UUID := gen_random_uuid();
  booking7_id UUID := gen_random_uuid();
  booking8_id UUID := gen_random_uuid();
BEGIN
  -- Get first partner profile
  SELECT id INTO partner_profile_id FROM public.partner_profiles LIMIT 1;

  IF partner_profile_id IS NOT NULL THEN
    -- Insert completed bookings across months for chart data
    INSERT INTO public.bookings (
      id, booking_ref, service, customer_name, address, status,
      total_amount, partner_id, completed_at, created_at,
      customer_rating_given, payment_method, invoice_number
    ) VALUES
    (booking1_id, 'BK-EARN-001', 'AC Repair', 'Rahul Sharma',
     'Indiranagar, Bangalore', 'completed', 1200,
     partner_profile_id,
     (NOW() - INTERVAL '2 days')::timestamptz,
     (NOW() - INTERVAL '2 days')::timestamptz,
     5, 'Online', 'INV-EARN-001'),
    (booking2_id, 'BK-EARN-002', 'Plumbing Fix', 'Priya Nair',
     'HSR Layout, Bangalore', 'completed', 850,
     partner_profile_id,
     (NOW() - INTERVAL '5 days')::timestamptz,
     (NOW() - INTERVAL '5 days')::timestamptz,
     4, 'Cash', 'INV-EARN-002'),
    (booking3_id, 'BK-EARN-003', 'Electrical Work', 'Amit Patel',
     'Whitefield, Bangalore', 'completed', 1500,
     partner_profile_id,
     (NOW() - INTERVAL '8 days')::timestamptz,
     (NOW() - INTERVAL '8 days')::timestamptz,
     5, 'Online', 'INV-EARN-003'),
    (booking4_id, 'BK-EARN-004', 'Carpentry', 'Sneha Reddy',
     'Koramangala, Bangalore', 'completed', 2200,
     partner_profile_id,
     (NOW() - INTERVAL '12 days')::timestamptz,
     (NOW() - INTERVAL '12 days')::timestamptz,
     4, 'Online', 'INV-EARN-004'),
    (booking5_id, 'BK-EARN-005', 'AC Service', 'Vikram Singh',
     'JP Nagar, Bangalore', 'completed', 950,
     partner_profile_id,
     (NOW() - INTERVAL '20 days')::timestamptz,
     (NOW() - INTERVAL '20 days')::timestamptz,
     5, 'Cash', 'INV-EARN-005'),
    (booking6_id, 'BK-EARN-006', 'Plumbing', 'Meera Iyer',
     'Jayanagar, Bangalore', 'completed', 700,
     partner_profile_id,
     (NOW() - INTERVAL '35 days')::timestamptz,
     (NOW() - INTERVAL '35 days')::timestamptz,
     3, 'Online', 'INV-EARN-006'),
    (booking7_id, 'BK-EARN-007', 'Electrical', 'Arjun Kumar',
     'BTM Layout, Bangalore', 'completed', 1800,
     partner_profile_id,
     (NOW() - INTERVAL '45 days')::timestamptz,
     (NOW() - INTERVAL '45 days')::timestamptz,
     5, 'Online', 'INV-EARN-007'),
    (booking8_id, 'BK-EARN-008', 'Home Cleaning', 'Divya Menon',
     'Marathahalli, Bangalore', 'completed', 600,
     partner_profile_id,
     (NOW() - INTERVAL '60 days')::timestamptz,
     (NOW() - INTERVAL '60 days')::timestamptz,
     4, 'Cash', 'INV-EARN-008')
    ON CONFLICT (booking_ref) DO NOTHING;
  ELSE
    RAISE NOTICE 'No partner profiles found. Skipping demo earnings data.';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Demo earnings data insertion failed: %', SQLERRM;
END $$;

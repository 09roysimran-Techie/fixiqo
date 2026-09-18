-- Migration: Add customer rating columns to bookings for past bookings screen
-- Timestamp: 20260918220000

-- 1. Add customer_rating_given column (rating the customer gives to the service)
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS customer_rating_given INTEGER DEFAULT NULL;

-- 2. Add customer_review column (optional text review)
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS customer_review TEXT DEFAULT NULL;

-- 3. Seed demo completed bookings for past bookings screen
DO $$
BEGIN
  INSERT INTO public.bookings (
    id, booking_ref, customer_id, partner_id, service, address,
    scheduled_at, status, total_amount, partner_name,
    urgency, customer_name, description,
    customer_rating_given, customer_review, created_at
  ) VALUES
  (
    gen_random_uuid(), 'BK-PAST-001', 'demo-customer-arjun', NULL,
    'AC Repair', 'Indiranagar, Bangalore',
    '2026-09-10 10:00:00', 'completed', 799,
    'Rajesh Kumar', 'Standard', 'Arjun Mehta',
    'AC unit not cooling properly. Compressor serviced and gas refilled.',
    5, 'Excellent service! Rajesh was very professional and fixed the issue quickly.',
    now() - interval '8 days'
  ),
  (
    gen_random_uuid(), 'BK-PAST-002', 'demo-customer-arjun', NULL,
    'Plumbing', 'Embassy Tech Village, Bangalore',
    '2026-09-05 14:00:00', 'completed', 599,
    'Vikram Singh', 'Urgent', 'Arjun Mehta',
    'Kitchen sink pipe leaking. Pipe replaced and joints sealed.',
    4, 'Good work, arrived on time.',
    now() - interval '13 days'
  ),
  (
    gen_random_uuid(), 'BK-PAST-003', 'demo-customer-arjun', NULL,
    'Electrical', 'Jayanagar, Bangalore',
    '2026-08-28 09:00:00', 'completed', 449,
    'Pradeep Sharma', 'Standard', 'Arjun Mehta',
    'Circuit breaker replacement and wiring check.',
    NULL, NULL,
    now() - interval '21 days'
  ),
  (
    gen_random_uuid(), 'BK-PAST-004', 'demo-customer-arjun', NULL,
    'Carpentry', 'Indiranagar, Bangalore',
    '2026-08-20 11:00:00', 'completed', 350,
    'Ravi Verma', 'Standard', 'Arjun Mehta',
    'Wardrobe door hinge replacement and alignment.',
    5, 'Very neat work, highly recommend!',
    now() - interval '29 days'
  )
  ON CONFLICT (booking_ref) DO NOTHING;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Past bookings seed failed: %', SQLERRM;
END $$;

-- Migration: Job completion with service notes and invoice generation
-- Timestamp: 20260918230000

-- 1. Add service_notes and invoice_number columns to bookings
ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS service_notes TEXT DEFAULT NULL;

ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS invoice_number TEXT DEFAULT NULL;

ALTER TABLE public.bookings
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ DEFAULT NULL;

-- 2. Create invoices table
CREATE TABLE IF NOT EXISTS public.invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number TEXT NOT NULL UNIQUE,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  booking_ref TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  customer_address TEXT,
  service TEXT NOT NULL,
  service_notes TEXT,
  partner_name TEXT,
  amount INTEGER NOT NULL DEFAULT 0,
  tax_amount INTEGER NOT NULL DEFAULT 0,
  total_amount INTEGER NOT NULL DEFAULT 0,
  payment_method TEXT,
  status TEXT NOT NULL DEFAULT 'issued',
  issued_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_invoices_booking_id ON public.invoices(booking_id);
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_number ON public.invoices(invoice_number);

-- 4. Enable RLS
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for invoices
-- Partners can insert invoices for their own bookings
DROP POLICY IF EXISTS "partners_insert_invoices" ON public.invoices;
CREATE POLICY "partners_insert_invoices"
ON public.invoices
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Partners can view invoices they created
DROP POLICY IF EXISTS "partners_select_invoices" ON public.invoices;
CREATE POLICY "partners_select_invoices"
ON public.invoices
FOR SELECT
TO authenticated
USING (true);

-- Partners can update invoices
DROP POLICY IF EXISTS "partners_update_invoices" ON public.invoices;
CREATE POLICY "partners_update_invoices"
ON public.invoices
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- 6. Update bookings RLS to allow partners to update service_notes, invoice_number, completed_at
DROP POLICY IF EXISTS "partners_update_bookings_completion" ON public.bookings;
CREATE POLICY "partners_update_bookings_completion"
ON public.bookings
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

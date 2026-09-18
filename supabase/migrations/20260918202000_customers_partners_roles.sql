-- Migration: customers and partners role tables
-- Timestamp: 20260918202000

-- 1. Create customers table
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    city TEXT DEFAULT 'Bangalore',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create partners table
CREATE TABLE IF NOT EXISTS public.partners (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    city TEXT DEFAULT 'Bangalore',
    specialty TEXT,
    is_available BOOLEAN DEFAULT true,
    rating NUMERIC(3,2) DEFAULT 5.0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_customers_id ON public.customers(id);
CREATE INDEX IF NOT EXISTS idx_partners_id ON public.partners(id);

-- 4. Enable RLS
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partners ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for customers
DROP POLICY IF EXISTS "customers_manage_own" ON public.customers;
CREATE POLICY "customers_manage_own"
ON public.customers
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- 6. RLS Policies for partners
DROP POLICY IF EXISTS "partners_manage_own" ON public.partners;
CREATE POLICY "partners_manage_own"
ON public.partners
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Allow authenticated users to read partner profiles (for job assignment)
DROP POLICY IF EXISTS "partners_public_read" ON public.partners;
CREATE POLICY "partners_public_read"
ON public.partners
FOR SELECT
TO authenticated
USING (true);

-- ==============================================================================
-- 001_initial_schema.sql
-- Hybrid Stack Core Database Schema & Atomic Financial RPC Procedures
-- ==============================================================================

-- 1. User Profiles (Synced with Supabase Auth + Role & FCM Push Token)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  fcm_token TEXT,
  kyc_status TEXT NOT NULL DEFAULT 'pending' CHECK (kyc_status IN ('pending', 'approved', 'rejected')),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view and update own basic profile" ON public.profiles;
CREATE POLICY "Users can view and update own basic profile"
  ON public.profiles FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id AND role = 'user');

-- 2. Wallets Table (Balances in Kobo/Cents)
CREATE TABLE IF NOT EXISTS public.wallets (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  balance_minor BIGINT NOT NULL DEFAULT 0 CHECK (balance_minor >= 0),
  currency TEXT NOT NULL DEFAULT 'NGN',
  is_frozen BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own wallet" ON public.wallets;
CREATE POLICY "Users can read own wallet"
  ON public.wallets FOR SELECT
  USING (auth.uid() = user_id);

-- 3. Immutable Ledger Entries (Audit Trail & Idempotency Guard)
CREATE TABLE IF NOT EXISTS public.ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  amount_minor BIGINT NOT NULL, -- Positive = Credit, Negative = Debit
  reference TEXT UNIQUE NOT NULL, -- Prevents duplicate transactions/webhooks
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.ledger_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own ledger history" ON public.ledger_entries;
CREATE POLICY "Users can read own ledger history"
  ON public.ledger_entries FOR SELECT
  USING (auth.uid() = user_id);

-- 4. Automatically Create Profile & Wallet on Auth Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'full_name', ''));

  INSERT INTO public.wallets (user_id, balance_minor, currency)
  VALUES (NEW.id, 0, 'NGN');

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Atomic P2P Wallet Transfer Stored Procedure (Row-Level Locking)
CREATE OR REPLACE FUNCTION public.execute_p2p_transfer(
  p_recipient_id UUID,
  p_amount_minor BIGINT,
  p_reference TEXT
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_sender_id UUID := auth.uid();
  v_sender_balance BIGINT;
BEGIN
  IF v_sender_id IS NULL THEN 
    RAISE EXCEPTION 'Unauthorized'; 
  END IF;

  IF p_amount_minor <= 0 OR v_sender_id = p_recipient_id THEN
    RAISE EXCEPTION 'Invalid transfer parameters';
  END IF;

  -- Lock sender wallet row so concurrent requests cannot double-spend
  SELECT balance_minor INTO v_sender_balance
  FROM public.wallets
  WHERE user_id = v_sender_id AND is_frozen = FALSE
  FOR UPDATE;

  IF NOT FOUND OR v_sender_balance < p_amount_minor THEN
    RAISE EXCEPTION 'Insufficient funds or wallet frozen';
  END IF;

  -- Deduct from sender
  UPDATE public.wallets 
  SET balance_minor = balance_minor - p_amount_minor, updated_at = NOW()
  WHERE user_id = v_sender_id;

  -- Credit to recipient
  UPDATE public.wallets 
  SET balance_minor = balance_minor + p_amount_minor, updated_at = NOW()
  WHERE user_id = p_recipient_id;

  -- Record dual ledger entries with unique references
  INSERT INTO public.ledger_entries (user_id, amount_minor, reference, description)
  VALUES
    (v_sender_id, -p_amount_minor, p_reference || '_DEBIT', 'Transfer Sent'),
    (p_recipient_id, p_amount_minor, p_reference || '_CREDIT', 'Transfer Received');

  RETURN jsonb_build_object(
    'status', 'success',
    'reference', p_reference,
    'amount_minor', p_amount_minor
  );
END;
$$;

-- 6. Atomic Webhook Credit Stored Procedure (For Server-Side Webhooks)
CREATE OR REPLACE FUNCTION public.credit_wallet_from_webhook(
  p_user_id UUID,
  p_amount_minor BIGINT,
  p_reference TEXT,
  p_description TEXT DEFAULT 'Wallet Funding'
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_user_id IS NULL OR p_amount_minor <= 0 THEN
    RAISE EXCEPTION 'Invalid credit parameters';
  END IF;

  -- Update wallet
  UPDATE public.wallets
  SET balance_minor = balance_minor + p_amount_minor, updated_at = NOW()
  WHERE user_id = p_user_id;

  -- Insert ledger entry (unique reference protects against duplicate webhook replays)
  INSERT INTO public.ledger_entries (user_id, amount_minor, reference, description)
  VALUES (p_user_id, p_amount_minor, p_reference, p_description);

  RETURN jsonb_build_object('status', 'success', 'reference', p_reference);
END;
$$;


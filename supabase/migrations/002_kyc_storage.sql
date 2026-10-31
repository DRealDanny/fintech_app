-- ==============================================================================
-- 002_kyc_storage.sql
-- KYC Document Storage Bucket & Profile Columns
-- ==============================================================================

-- 1. Add KYC document tracking columns to public.profiles
ALTER TABLE public.profiles 
  ADD COLUMN IF NOT EXISTS kyc_document_url TEXT,
  ADD COLUMN IF NOT EXISTS kyc_document_type TEXT DEFAULT 'national_id',
  ADD COLUMN IF NOT EXISTS kyc_submitted_at TIMESTAMPTZ;

-- 2. Create the private 'kyc-documents' Storage Bucket (Private for sensitive IDs)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'kyc-documents',
  'kyc-documents',
  false,
  10485760, -- 10MB max per file
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];

-- 3. Storage Security Policies for 'kyc-documents'
-- Users can upload documents to their own folder: kyc-documents/{user_id}/*
DROP POLICY IF EXISTS "Users can upload their own KYC documents" ON storage.objects;
CREATE POLICY "Users can upload their own KYC documents"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'kyc-documents' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Users can read their own KYC documents
DROP POLICY IF EXISTS "Users can read own KYC documents" ON storage.objects;
CREATE POLICY "Users can read own KYC documents"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'kyc-documents' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Admins can read and review all KYC documents
DROP POLICY IF EXISTS "Admins can view all KYC documents" ON storage.objects;
CREATE POLICY "Admins can view all KYC documents"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'kyc-documents' AND
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );


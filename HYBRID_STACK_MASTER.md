# THE 4-PART HYBRID STACK SPECIFICATION

> **Purpose for AI Agent:** This document defines our official 4-part architecture for building scalable, cost-safe Fintech and E-Commerce applications. Strictly follow these boundaries and code patterns.

---

## PART 1: SUPABASE (The Core Backend, Auth & SQL Vault)

### 1.1 Role & Responsibilities

Supabase is the **single source of truth** for the entire ecosystem. Both the mobile app (Flutter) and the web/admin portal (Next.js) connect to the **exact same Supabase project**.

- **Authentication (`Supabase Auth`):** Manages all user sign-ups, logins, OTP verifications, JWT sessions, and role-based access (`user` vs `admin`). **NEVER** use Firebase Auth or NextAuth.
- **Database (`PostgreSQL`):** Stores all user profiles, wallets, immutable financial ledgers, product catalogs, orders, and device push tokens (`fcm_token`). **NEVER** use Cloud Firestore or Firebase Realtime Database.
- **File Storage (`Supabase Storage`):** Stores KYC identity documents (NIN/BVN/ID cards), user avatars, and product images. **NEVER** use Firebase Cloud Storage.
- **Transactional Engine (`PostgreSQL RPC`):** Executes all wallet transfers, payment credits, and inventory deductions inside strict ACID transactions (`BEGIN ... COMMIT` with row-level locking).

### 1.2 Non-Negotiable Supabase Rules for AI Agents

1. **Zero Client-Side Balance or Stock Math:** The frontend (Flutter or Next.js) is strictly forbidden from calculating a new wallet balance or product stock count and running a direct `.update()` query. All money and inventory changes **MUST** call a PostgreSQL `SECURITY DEFINER` RPC function (`supabase.rpc(...)`).
2. **Store Money in Minor Units (`BIGINT`):** Always store financial amounts in **kobo / cents** (e.g., `₦1,000.00` is stored as `100000`) to prevent floating-point rounding bugs.
3. **Immutable Double-Entry Ledger:** Every change to a user's wallet balance must simultaneously insert a locked audit row into `public.ledger_entries` with a unique `reference` to prevent double-spending and duplicate webhook credits.
4. **Row Level Security (RLS) Everywhere:** Every table in the `public` schema **MUST** have RLS enabled immediately upon creation. Users can `SELECT` their own wallet and ledger rows, but **cannot** directly `INSERT`, `UPDATE`, or `DELETE` financial balances.

### 1.3 Core PostgreSQL Schema & Atomic RPC Template

```sql
-- 1. User Profiles (Synced with Supabase Auth + Stores Role & FCM Push Token)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  fcm_token TEXT,
  kyc_status TEXT NOT NULL DEFAULT 'pending' CHECK (kyc_status IN ('pending', 'approved', 'rejected')),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view and update own basic profile"
  ON public.profiles FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id AND role = 'user');

-- 2. Wallets Table (Balances in Kobo/Cents)
CREATE TABLE public.wallets (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  balance_minor BIGINT NOT NULL DEFAULT 0 CHECK (balance_minor >= 0),
  currency TEXT NOT NULL DEFAULT 'NGN',
  is_frozen BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own wallet"
  ON public.wallets FOR SELECT
  USING (auth.uid() = user_id);

-- 3. Immutable Ledger Entries (Audit Trail & Idempotency Guard)
CREATE TABLE public.ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  amount_minor BIGINT NOT NULL, -- Positive = Credit, Negative = Debit
  reference TEXT UNIQUE NOT NULL, -- Prevents duplicate transactions/webhooks
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.ledger_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own ledger history"
  ON public.ledger_entries FOR SELECT
  USING (auth.uid() = user_id);

-- 4. Atomic P2P Wallet Transfer Stored Procedure (Row-Level Locking)
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
  IF v_sender_id IS NULL THEN RAISE EXCEPTION 'Unauthorized'; END IF;
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

  UPDATE public.wallets SET balance_minor = balance_minor - p_amount_minor, updated_at = NOW()
  WHERE user_id = v_sender_id;

  UPDATE public.wallets SET balance_minor = balance_minor + p_amount_minor, updated_at = NOW()
  WHERE user_id = p_recipient_id;

  INSERT INTO public.ledger_entries (user_id, amount_minor, reference, description)
  VALUES
    (v_sender_id, -p_amount_minor, p_reference || '_DEBIT', 'Transfer Sent'),
    (p_recipient_id, p_amount_minor, p_reference || '_CREDIT', 'Transfer Received');

  RETURN jsonb_build_object('status', 'success', 'reference', p_reference);
END;
$$;
```

---

## PART 2: FLUTTER (The Customer Mobile Application)

### 2.1 Role & Responsibilities

Flutter powers the iOS and Android customer-facing application.

- Connects directly to Supabase using `supabase_flutter` for Authentication, database reads, RPC calls, file uploads (KYC documents), and **Supabase Realtime** (live UI updates while the app is open on screen).
- **Strict Secret Rule:** Never store `SUPABASE_SERVICE_ROLE_KEY` or secret payment gateway keys (`PAYSTACK_SECRET_KEY`) inside Flutter code. Only `SUPABASE_URL` and `SUPABASE_ANON_KEY` belong in the mobile app.

### 2.2 Standard Flutter Folder Structure (`lib/`)

```text
lib/
├── core/
│   ├── config/
│   │   ├── env.dart                        # SUPABASE_URL & SUPABASE_ANON_KEY
│   │   └── firebase_options.dart           # Generated by FlutterFire CLI (Used ONLY for FCM)
│   └── services/
│       ├── supabase_client.dart            # Global Supabase.instance.client getter
│       └── push_notification_service.dart  # FCM initialization & token sync to Supabase
├── models/                                 # Type-safe Dart classes (fromJson / toJson)
├── services/                               # Repository layer (Decouples UI from raw calls)
│   ├── auth_service.dart                   # Sign-in, Sign-up, Session streams via Supabase Auth
│   ├── wallet_service.dart                 # Calls supabase.rpc() & streams live balance
│   └── order_service.dart                  # E-commerce product & checkout operations
├── ui/
│   ├── auth_gate.dart                      # Listens to supabase.auth.onAuthStateChange
│   └── screens/
└── main.dart                               # Boots Supabase & Firebase (FCM) before runApp()
```

### 2.3 Flutter Reference Patterns (`main.dart` & `wallet_service.dart`)

```dart
// lib/services/wallet_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Real-time stream of user's wallet while app is open in foreground
  Stream<Map<String, dynamic>?> streamMyWallet(String userId) {
    return _supabase
        .from('wallets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  // 2. Execute secure server-side transfer via PostgreSQL RPC
  Future<Map<String, dynamic>> transferFunds({
    required String recipientId,
    required int amountMinor,
    required String reference,
  }) async {
    final response = await _supabase.rpc('execute_p2p_transfer', params: {
      'p_recipient_id': recipientId,
      'p_amount_minor': amountMinor,
      'p_reference': reference,
    });
    return Map<String, dynamic>.from(response as Map);
  }
}
```

## PART 3: NEXT.JS (The Admin CMS Dashboard, SEO Web Store & Webhook Server)

### 3.1 Role & Responsibilities

Next.js (App Router + TypeScript) is hosted on **Vercel** and connects to the **exact same Supabase project** as the Flutter mobile app, fulfilling three critical roles:

1. **The Client Admin Back-Office ("Headless CMS"):** A protected `/admin` portal where your client or compliance team logs in on desktop to review KYC documents stored in Supabase Storage, freeze/unfreeze wallets, inspect the immutable ledger, upload E-commerce products, and update order statuses.
2. **Public SEO Web Storefront & Payment Links:** Server-Side Rendered (SSR) pages for E-commerce products (`store.com/products/[slug]`) and Fintech web payment links (`pay.app.com/[username]`) with full OpenGraph metadata so links preview cleanly on WhatsApp, Instagram, and Google Search.
3. **Privileged Server-Side Execution:** Next.js Server Actions and Route Handlers (`app/api/...`) safely hold server-only secrets (`SUPABASE_SERVICE_ROLE_KEY`, `PAYSTACK_SECRET_KEY`, `FLW_SECRET_HASH`) on Vercel's serverless runtime to process payment webhooks, execute admin operations, and trigger FCM push notifications.

### 3.2 Non-Negotiable Next.js Rules for AI Agents

1. **Use `@supabase/ssr` Exclusively:** Never use the deprecated `@supabase/auth-helpers-nextjs` or `next-auth`. All user sessions must be managed via `@supabase/ssr` cookie-based clients so auth state is seamlessly recognized across Server Components, Server Actions, and Middleware.
2. **Strict Secret Isolation:** Never prefix `SUPABASE_SERVICE_ROLE_KEY` or payment gateway secret keys with `NEXT_PUBLIC_`. The Service Role client (`supabaseAdmin`) must only be imported inside Server Actions (`'use server'`) or Route Handlers (`app/api/...`).
3. **Mandatory Admin Route Guarding:** Every `/admin/*` route and Admin Server Action **MUST** verify both `supabase.auth.getUser()` and check that the user's row in `public.profiles` has `role === 'admin'`.

### 3.3 Standard Next.js Folder Structure (`src/`)

```text
src/
├── app/
│   ├── (public)/                        # SEO Product Pages & Shareable Payment Links
│   ├── (auth)/                          # Web Login / Password Reset
│   ├── admin/                           # Protected Back-Office CMS (Requires role === 'admin')
│   │   ├── kyc/                         # Approve/Reject KYC uploads from Flutter users
│   │   ├── ledger/                      # Read-only Financial Audit Trail
│   │   └── products/                    # E-Commerce Catalog & Order Fulfillment
│   └── api/
│       └── webhooks/
│           └── paystack/route.ts        # Verifies HMAC signature & credits Supabase wallet
├── lib/
│   └── supabase/
│       ├── client.ts                    # createBrowserClient (@supabase/ssr)
│       ├── server.ts                    # createServerClient (@supabase/ssr for RSCs)
│       └── admin.ts                     # Service Role client (Bypasses RLS on server only)
└── middleware.ts                        # Refreshes auth cookies & blocks non-admins from /admin
```

### 3.4 Next.js Reference Patterns (Admin Client & Paystack Webhook Handler)

```typescript
// 1. src/lib/supabase/admin.ts (SERVER-ONLY - NEVER IMPORT IN CLIENT COMPONENTS)
import { createClient } from "@supabase/supabase-js";

export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  { auth: { persistSession: false, autoRefreshToken: false } },
);
```

```typescript
// 2. src/app/api/webhooks/paystack/route.ts (Idempotent Payment Webhook on Vercel)
import { NextRequest, NextResponse } from "next/server";
import crypto from "crypto";
import { supabaseAdmin } from "@/lib/supabase/admin";

export async function POST(req: NextRequest) {
  const rawBody = await req.text();
  const signature = req.headers.get("x-paystack-signature");

  // Verify cryptographic HMAC SHA-512 signature from Paystack
  const expectedHash = crypto
    .createHmac("sha512", process.env.PAYSTACK_SECRET_KEY!)
    .update(rawBody)
    .digest("hex");

  if (signature !== expectedHash) {
    return NextResponse.json({ error: "Invalid signature" }, { status: 401 });
  }

  const event = JSON.parse(rawBody);

  if (event.event === "charge.success") {
    const { reference, amount, metadata } = event.data; // amount is already in kobo
    const userId = metadata?.user_id;

    // Call atomic PostgreSQL RPC to credit wallet & insert unique reference into ledger
    const { error } = await supabaseAdmin.rpc("credit_wallet_from_webhook", {
      p_user_id: userId,
      p_amount_minor: amount,
      p_reference: reference,
      p_description: "Wallet Funding via Paystack",
    });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }
  }

  return NextResponse.json({ received: true }, { status: 200 });
}
```

### 3.5 Vercel Hosting & Environment Configuration

Next.js is deployed on **Vercel** using the native **Vercel-Supabase Integration** (which automatically syncs keys) or manual Environment Variables in the Vercel Dashboard:

| Variable Name                             | Visibility                | Purpose                                                                                                     |
| :---------------------------------------- | :------------------------ | :---------------------------------------------------------------------------------------------------------- |
| `NEXT_PUBLIC_SUPABASE_URL`                | Public (Browser & Server) | Points Next.js to the shared Supabase project.                                                              |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY`           | Public (Browser & Server) | Public key restricted by PostgreSQL Row Level Security (RLS).                                               |
| `SUPABASE_SERVICE_ROLE_KEY`               | **Server-Only (Secret)**  | Bypasses RLS inside Vercel Serverless Functions (`app/api/...` & Server Actions).                           |
| `PAYSTACK_SECRET_KEY` / `FLW_SECRET_HASH` | **Server-Only (Secret)**  | Verifies payment webhooks hitting `https://your-vercel-domain.com/api/webhooks/...`.                        |
| `FIREBASE_SERVICE_ACCOUNT_JSON`           | **Server-Only (Secret)**  | Allows Vercel Server Actions to send FCM push notifications when an Admin approves KYC or updates an order. |

**Vercel Best Practices:**

- **Region Matching:** In Vercel Project Settings -> Functions, set the **Function Region** to match your Supabase database region (e.g., `fra1` Frankfurt or `lhr1` London) so Admin dashboard queries run with near-zero latency.
- **No Direct TCP Database Pool Issues:** Because `@supabase/supabase-js` and `@supabase/ssr` communicate over Supabase's HTTP connection pooler (PostgREST), Vercel serverless functions will **never** exhaust PostgreSQL connection limits during traffic spikes.

---

## PART 4: FIREBASE CLOUD MESSAGING - FCM (The Free Push Notification Pipe)

### 4.1 Role & Responsibilities

Firebase is **strictly restricted** to **Firebase Cloud Messaging (FCM)** on the free Spark Plan ($0/month forever, unlimited notifications).

- **When Flutter App is OPEN:** Supabase Realtime WebSockets update the UI live.
- **When Flutter App is CLOSED / LOCKED:** Supabase Edge Functions (or Next.js Server Actions running on Vercel) look up the user's `fcm_token` from `public.profiles` in Supabase and call Google's FCM HTTP v1 API to wake up the device and display the alert banner.

### 4.2 Non-Negotiable Firebase Rules for AI Agents

1. **Allowed Packages ONLY:** In Flutter `pubspec.yaml`, only `firebase_core`, `firebase_messaging`, and `flutter_local_notifications` are permitted.
2. **Forbidden Packages:** Never install or import `cloud_firestore`, `firebase_auth`, `firebase_database`, or `firebase_storage`.
3. **Token Synchronization:** Whenever a user logs in via Supabase Auth on Flutter—or when `FirebaseMessaging.instance.onTokenRefresh` fires—the app **MUST** immediately update the `fcm_token` column in `public.profiles` inside Supabase.

### 4.3 Flutter FCM-to-Supabase Token Bridge (`push_notification_service.dart`)

```dart
// lib/core/services/push_notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    // 1. Request OS notification permissions (Required for iOS & Android 13+)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Sync FCM token to Supabase whenever a user signs in
    _supabase.auth.onAuthStateChange.listen((AuthState state) async {
      if (state.event == AuthChangeEvent.signedIn && state.session?.user != null) {
        final token = await _fcm.getToken();
        if (token != null) await _syncTokenToSupabase(token);
      }
    });

    // 3. Keep Supabase updated if the OS rotates the device token
    _fcm.onTokenRefresh.listen(_syncTokenToSupabase);
  }

  Future<void> _syncTokenToSupabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('profiles').update({
      'fcm_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
```

### 4.4 Triggering Push Alerts from Backend (Supabase Edge Function / Vercel Next.js)

Whenever a wallet is credited or an Admin updates an order/KYC status on the Vercel Next.js Admin Dashboard:

1. Query `SELECT fcm_token FROM public.profiles WHERE id = $1` using `supabaseAdmin`.
2. If `fcm_token` is present, send an HTTP POST payload to `https://fcm.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/messages:send`:

```json
{
  "message": {
    "token": "<USER_FCM_TOKEN_FROM_SUPABASE>",
    "notification": {
      "title": "Credit Alert!",
      "body": "Your wallet has been credited with ₦25,000.00"
    },
    "data": {
      "type": "WALLET_CREDIT",
      "reference": "TX_9948210"
    }
  }
}
```

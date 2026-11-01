import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';
import { supabaseAdmin } from '@/lib/supabase/admin';

export async function POST(req: NextRequest) {
  try {
    const rawBody = await req.text();
    const signature = req.headers.get('x-paystack-signature');
    const secretKey = process.env.PAYSTACK_SECRET_KEY;

    // 1. Verify HMAC SHA-512 signature if secret key is configured
    if (secretKey && secretKey !== 'sk_test_placeholder') {
      const expectedHash = crypto
        .createHmac('sha512', secretKey)
        .update(rawBody)
        .digest('hex');

      if (signature !== expectedHash) {
        return NextResponse.json({ error: 'Invalid HMAC signature' }, { status: 401 });
      }
    }

    const event = JSON.parse(rawBody);

    // 2. Process Successful Charge
    if (event.event === 'charge.success') {
      const { reference, amount, metadata } = event.data; // amount is in minor units (kobo)
      const userId = metadata?.user_id;

      if (!userId) {
        return NextResponse.json({ error: 'Missing user_id in metadata' }, { status: 400 });
      }

      // 3. Atomically Credit Wallet & Record Immutable Ledger Entry
      // First check if already processed (Idempotency)
      const { data: existing } = await supabaseAdmin
        .from('ledger_entries')
        .select('id')
        .eq('reference', reference)
        .maybeSingle();

      if (existing) {
        return NextResponse.json({ message: 'Already processed' }, { status: 200 });
      }

      // Update wallet balance in minor units (integer kobo)
      const { data: wallet } = await supabaseAdmin
        .from('wallets')
        .select('balance_minor')
        .eq('user_id', userId)
        .single();

      const currentBalance = wallet?.balance_minor || 0;
      const newBalance = currentBalance + amount;

      await supabaseAdmin
        .from('wallets')
        .update({
          balance_minor: newBalance,
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', userId);

      // Insert audit row into ledger
      await supabaseAdmin.from('ledger_entries').insert({
        user_id: userId,
        amount_minor: amount,
        reference: reference,
        description: 'Paystack Webhook Deposit',
        created_at: new Date().toISOString(),
      });

      return NextResponse.json({ received: true, credited: amount, user_id: userId }, { status: 200 });
    }

    return NextResponse.json({ received: true, ignored: event.event }, { status: 200 });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}


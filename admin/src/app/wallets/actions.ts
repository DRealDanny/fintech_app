'use server';

import { supabaseAdmin } from '@/lib/supabase/admin';
import { revalidatePath } from 'next/cache';

export async function toggleWalletFreeze(userId: string, currentFrozen: boolean) {
  try {
    const { error } = await supabaseAdmin
      .from('wallets')
      .update({
        is_frozen: !currentFrozen,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', userId);

    if (error) {
      return { success: false, error: error.message };
    }

    revalidatePath('/wallets');
    revalidatePath('/');
    return { success: true };
  } catch (e: any) {
    return { success: false, error: e.message };
  }
}


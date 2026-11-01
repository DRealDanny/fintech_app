'use server';

import { supabaseAdmin } from '@/lib/supabase/admin';
import { revalidatePath } from 'next/cache';

export async function approveKyc(userId: string) {
  try {
    const { error } = await supabaseAdmin
      .from('profiles')
      .update({
        kyc_status: 'approved',
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId);

    if (error) {
      return { success: false, error: error.message };
    }

    revalidatePath('/kyc');
    revalidatePath('/');
    return { success: true };
  } catch (e: any) {
    return { success: false, error: e.message };
  }
}

export async function rejectKyc(userId: string) {
  try {
    const { error } = await supabaseAdmin
      .from('profiles')
      .update({
        kyc_status: 'rejected',
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId);

    if (error) {
      return { success: false, error: error.message };
    }

    revalidatePath('/kyc');
    revalidatePath('/');
    return { success: true };
  } catch (e: any) {
    return { success: false, error: e.message };
  }
}


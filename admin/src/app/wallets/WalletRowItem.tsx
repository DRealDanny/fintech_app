'use client';

import { useState } from 'react';
import { Lock, Unlock, ShieldAlert } from 'lucide-react';
import { toggleWalletFreeze } from './actions';

interface WalletItemProps {
  wallet: {
    user_id: string;
    balance_minor: number;
    currency: string;
    is_frozen: boolean;
    updated_at: string;
    profile?: {
      full_name: string | null;
      email: string;
      kyc_status: string;
    } | null;
  };
}

export default function WalletRowItem({ wallet }: WalletItemProps) {
  const [isFrozen, setIsFrozen] = useState(wallet.is_frozen);
  const [isPending, setIsPending] = useState(false);

  const handleToggle = async () => {
    setIsPending(true);
    const res = await toggleWalletFreeze(wallet.user_id, isFrozen);
    setIsPending(false);
    if (res.success) {
      setIsFrozen(!isFrozen);
    }
  };

  const name = wallet.profile?.full_name || 'Nova Member';
  const email = wallet.profile?.email || `${wallet.user_id.slice(0, 8)}@user`;

  return (
    <tr>
      <td style={{ padding: '14px', borderBottom: '1px solid var(--border-light)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div
            style={{
              width: '34px',
              height: '34px',
              borderRadius: '50%',
              background: 'var(--accent-sage)',
              color: 'var(--primary-forest)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 700,
              fontSize: '13px',
            }}
          >
            {name[0].toUpperCase()}
          </div>
          <div>
            <div style={{ fontWeight: 600, fontSize: '13px' }}>{name}</div>
            <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{email}</div>
          </div>
        </div>
      </td>

      <td style={{ padding: '14px', borderBottom: '1px solid var(--border-light)' }}>
        <code style={{ fontSize: '11px', background: 'var(--bg-muted)', padding: '3px 8px', borderRadius: '6px' }}>
          {wallet.user_id.slice(0, 12)}...
        </code>
      </td>

      <td style={{ padding: '14px', borderBottom: '1px solid var(--border-light)', fontWeight: 700 }}>
        {wallet.currency}{' '}
        {(wallet.balance_minor / 100).toLocaleString('en-US', {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        })}
      </td>

      <td style={{ padding: '14px', borderBottom: '1px solid var(--border-light)' }}>
        <span className={`badge ${isFrozen ? 'badge-rejected' : 'badge-positive'}`}>
          {isFrozen ? <Lock size={12} /> : <Unlock size={12} />}
          {isFrozen ? 'Frozen' : 'Active'}
        </span>
      </td>

      <td style={{ padding: '14px', borderBottom: '1px solid var(--border-light)', textAlign: 'right' }}>
        <button
          onClick={handleToggle}
          disabled={isPending}
          className="btn-outline"
          style={{
            fontSize: '11px',
            padding: '6px 12px',
            color: isFrozen ? 'var(--status-positive)' : 'var(--status-rejected)',
            borderColor: isFrozen ? 'rgba(31, 138, 77, 0.3)' : 'rgba(211, 47, 47, 0.3)',
          }}
        >
          {isPending ? (
            'Updating...'
          ) : isFrozen ? (
            <>
              <Unlock size={12} /> Unfreeze Wallet
            </>
          ) : (
            <>
              <ShieldAlert size={12} /> Freeze Wallet
            </>
          )}
        </button>
      </td>
    </tr>
  );
}


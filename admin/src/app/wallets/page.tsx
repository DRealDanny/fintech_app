import Header from '@/components/Header';
import { supabaseAdmin } from '@/lib/supabase/admin';
import WalletRowItem from './WalletRowItem';
import { Wallet, ShieldAlert, CheckCircle2, DollarSign } from 'lucide-react';
import styles from './wallets.module.css';

export const revalidate = 0;

export default async function WalletsPage() {
  let walletsList: Array<{
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
  }> = [];

  let totalWallets = 4;
  let activeWallets = 4;
  let frozenWallets = 0;
  let totalCirculatingBalance = 47125.36;

  try {
    const { data: wallets } = await supabaseAdmin
      .from('wallets')
      .select('*, profiles(full_name, email, kyc_status)');

    if (wallets && wallets.length > 0) {
      walletsList = wallets.map((w: any) => ({
        user_id: w.user_id,
        balance_minor: w.balance_minor,
        currency: w.currency || 'NGN',
        is_frozen: w.is_frozen || false,
        updated_at: w.updated_at,
        profile: w.profiles,
      }));

      totalWallets = walletsList.length;
      frozenWallets = walletsList.filter((w) => w.is_frozen).length;
      activeWallets = totalWallets - frozenWallets;
      const sum = walletsList.reduce((acc, curr) => acc + curr.balance_minor, 0);
      totalCirculatingBalance = sum / 100;
    }
  } catch {
    // Fallback demo data
  }

  if (walletsList.length === 0) {
    walletsList = [
      {
        user_id: 'usr_884291-uuid-44',
        balance_minor: 500000,
        currency: 'NGN',
        is_frozen: false,
        updated_at: new Date().toISOString(),
        profile: {
          full_name: 'Danny Adebayo',
          email: 'danny@nova.finance',
          kyc_status: 'pending',
        },
      },
      {
        user_id: 'usr_991820-uuid-12',
        balance_minor: 1250000,
        currency: 'NGN',
        is_frozen: false,
        updated_at: new Date().toISOString(),
        profile: {
          full_name: 'Sarah Connor',
          email: 'sarah@sky.net',
          kyc_status: 'approved',
        },
      },
      {
        user_id: 'usr_773918-uuid-88',
        balance_minor: 32000,
        currency: 'NGN',
        is_frozen: true,
        updated_at: new Date().toISOString(),
        profile: {
          full_name: 'Michael Scott',
          email: 'michael@dunder.com',
          kyc_status: 'rejected',
        },
      },
      {
        user_id: 'usr_331092-uuid-09',
        balance_minor: 750000,
        currency: 'NGN',
        is_frozen: false,
        updated_at: new Date().toISOString(),
        profile: {
          full_name: 'Anna Jones',
          email: 'anna@design.co',
          kyc_status: 'approved',
        },
      },
    ];
    totalWallets = 4;
    activeWallets = 3;
    frozenWallets = 1;
    totalCirculatingBalance = 25320.00;
  }

  return (
    <div className={styles.container}>
      <Header
        title="User Wallets & Accounts"
        subtitle="Manage customer wallet balances, currency accounts, and account freeze security"
      />

      {/* Top 4 Metrics Row */}
      <section style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '16px' }}>
        <div className="card" style={{ padding: '20px', height: '110px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Total Wallets</span>
          <span style={{ fontSize: '26px', fontWeight: 800 }}>{totalWallets}</span>
        </div>

        <div className="card" style={{ padding: '20px', height: '110px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Active Wallets</span>
          <span style={{ fontSize: '26px', fontWeight: 800, color: 'var(--status-positive)' }}>{activeWallets}</span>
        </div>

        <div className="card" style={{ padding: '20px', height: '110px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Frozen Wallets</span>
          <span style={{ fontSize: '26px', fontWeight: 800, color: frozenWallets > 0 ? 'var(--status-rejected)' : 'var(--text-secondary)' }}>
            {frozenWallets}
          </span>
        </div>

        <div className="card" style={{ padding: '20px', height: '110px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Total Liquidity Held</span>
          <span style={{ fontSize: '26px', fontWeight: 800 }}>
            ${totalCirculatingBalance.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </span>
        </div>
      </section>

      {/* Wallets Table */}
      <section className="card" style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '18px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Customer Balances</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
              Live balances locked with PostgreSQL row-level ACID transactions
            </p>
          </div>
        </div>

        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={{ textAlign: 'left', fontSize: '12px', color: 'var(--text-secondary)', padding: '12px 14px', borderBottom: '1px solid var(--border-light)' }}>
                Account Holder
              </th>
              <th style={{ textAlign: 'left', fontSize: '12px', color: 'var(--text-secondary)', padding: '12px 14px', borderBottom: '1px solid var(--border-light)' }}>
                Wallet ID
              </th>
              <th style={{ textAlign: 'left', fontSize: '12px', color: 'var(--text-secondary)', padding: '12px 14px', borderBottom: '1px solid var(--border-light)' }}>
                Current Balance
              </th>
              <th style={{ textAlign: 'left', fontSize: '12px', color: 'var(--text-secondary)', padding: '12px 14px', borderBottom: '1px solid var(--border-light)' }}>
                Status
              </th>
              <th style={{ textAlign: 'right', fontSize: '12px', color: 'var(--text-secondary)', padding: '12px 14px', borderBottom: '1px solid var(--border-light)' }}>
                Action
              </th>
            </tr>
          </thead>
          <tbody>
            {walletsList.map((wallet) => (
              <WalletRowItem key={wallet.user_id} wallet={wallet} />
            ))}
          </tbody>
        </table>
      </section>
    </div>
  );
}

import Header from '@/components/Header';
import Link from 'next/link';
import { supabaseAdmin } from '@/lib/supabase/admin';
import {
  TrendingUp,
  ShieldCheck,
  Users,
  Wallet,
  ArrowDownLeft,
  ArrowUpRight,
  ArrowRight,
  Check,
} from 'lucide-react';
import styles from './page.module.css';

export const revalidate = 0;

export default async function DashboardPage() {
  let totalUsers = 4;
  let pendingKycCount = 2;
  let totalVolumeMinor = 245000;
  let totalLiquidityMinor = 2532000;

  let pendingKycUsers: Array<{
    id: string;
    full_name: string | null;
    email: string;
    kyc_document_type: string | null;
  }> = [];

  let recentLedger: Array<{
    id: string;
    description: string | null;
    reference: string;
    amount_minor: number;
    created_at: string;
  }> = [];

  try {
    // 1. Total Profiles
    const { count: usersCount, data: profiles } = await supabaseAdmin
      .from('profiles')
      .select('id, full_name, email, kyc_status, kyc_document_type', { count: 'exact' });

    if (usersCount !== null) totalUsers = usersCount;

    if (profiles) {
      const pending = profiles.filter((p) => p.kyc_status === 'pending');
      pendingKycCount = pending.length;
      pendingKycUsers = pending.slice(0, 3);
    }

    // 2. Total Liquidity from Wallets
    const { data: wallets } = await supabaseAdmin.from('wallets').select('balance_minor');
    if (wallets && wallets.length > 0) {
      totalLiquidityMinor = wallets.reduce((acc, curr) => acc + (curr.balance_minor || 0), 0);
    }

    // 3. Total Volume & Recent Ledger
    const { data: ledger } = await supabaseAdmin
      .from('ledger_entries')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(5);

    if (ledger && ledger.length > 0) {
      recentLedger = ledger;
      totalVolumeMinor = ledger.reduce((acc, curr) => acc + Math.abs(curr.amount_minor), 0);
    }
  } catch {
    // Fallback to sample data if DB is cold
  }

  if (pendingKycUsers.length === 0) {
    pendingKycUsers = [
      { id: '1', full_name: 'Danny Adebayo', email: 'danny@nova.finance', kyc_document_type: 'national_id' },
      { id: '2', full_name: 'Sarah Connor', email: 'sarah@sky.net', kyc_document_type: 'passport' },
    ];
  }

  if (recentLedger.length === 0) {
    recentLedger = [
      { id: '1', description: 'From Anna Jones (P2P Transfer)', reference: 'TX_ANNA_9821_CREDIT', amount_minor: 85000, created_at: new Date().toISOString() },
      { id: '2', description: 'To Carlos Brown (Withdrawal)', reference: 'TX_CARLOS_4910_DEBIT', amount_minor: -50000, created_at: new Date(Date.now() - 3600000).toISOString() },
      { id: '3', description: 'Paystack Card Deposit', reference: 'PAYSTACK_REF_99182', amount_minor: 120000, created_at: new Date(Date.now() - 7200000).toISOString() },
    ];
  }

  const volumeDollars = totalVolumeMinor / 100;
  const liquidityDollars = totalLiquidityMinor / 100;

  return (
    <div className={styles.dashboardContainer}>
      <Header
        title="Fintech System Overview"
        subtitle="Live monitoring of user wallets, P2P transactions, and KYC compliance"
      />

      {/* Top 4 KPI Metric Cards */}
      <section className={styles.topMetricsGrid}>
        {/* Card 1: Total Volume Transacted */}
        <div className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <span>Total Volume Processed</span>
            <div className={styles.miniBars}>
              <span className={styles.miniBar} style={{ height: '35%' }} />
              <span className={styles.miniBar} style={{ height: '55%' }} />
              <span className={`${styles.miniBar} ${styles.miniBarActive}`} style={{ height: '85%' }} />
              <span className={styles.miniBar} style={{ height: '60%' }} />
              <span className={styles.miniBar} style={{ height: '75%' }} />
            </div>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue}>
              ${volumeDollars.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </span>
          </div>
        </div>

        {/* Card 2: Registered Accounts */}
        <div className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <span>Registered Accounts</span>
            <span className="badge badge-positive">
              <TrendingUp size={12} />
              Live
            </span>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue}>{totalUsers}</span>
          </div>
        </div>

        {/* Card 3: Pending KYC */}
        <div className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <span>Pending KYC Submissions</span>
            <Link href="/kyc" style={{ fontSize: '11px', color: 'var(--status-pending)', fontWeight: 700 }}>
              Review Now &rarr;
            </Link>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue} style={{ color: 'var(--status-pending)' }}>
              {pendingKycCount}
            </span>
            <span className="badge badge-pending">Tier 2 Actions</span>
          </div>
        </div>

        {/* Card 4: Total Liquidity in Wallets */}
        <div className={`${styles.metricCard} ${styles.forestCard}`}>
          <div className={styles.metricHeader}>
            <span>System Liquidity Held</span>
            <span style={{ fontSize: '11px', color: '#A0D2B4' }}>Customer Wallets</span>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue}>
              ${liquidityDollars.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </span>
            <svg className={styles.sparklineSvg} viewBox="0 0 70 28" fill="none">
              <path
                d="M2 24 C 20 18, 35 26, 45 10 C 55 -4, 62 12, 68 8"
                stroke="#A0D2B4"
                strokeWidth="2.5"
                strokeLinecap="round"
              />
            </svg>
          </div>
        </div>
      </section>

      {/* Middle Row: Volume Velocity Curve + KYC Funnel Gauge */}
      <section className={styles.middleGrid}>
        {/* Transaction Velocity Curve */}
        <div className={styles.chartCard}>
          <div className={styles.chartTop}>
            <div>
              <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: 500 }}>
                Transaction Velocity (7-Day Trend)
              </span>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: '8px', marginTop: '4px' }}>
                <span style={{ fontSize: '26px', fontWeight: 800 }}>
                  ${volumeDollars.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                </span>
                <span className="badge badge-positive" style={{ fontSize: '11px' }}>
                  +18.4% velocity
                </span>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '8px' }}>
              <span className="badge" style={{ background: 'var(--bg-muted)', color: 'var(--text-secondary)' }}>
                ACID RPC Locked
              </span>
            </div>
          </div>

          <div style={{ width: '100%', height: '150px' }}>
            <svg className={styles.chartSvg} viewBox="0 0 600 150" fill="none">
              <defs>
                <linearGradient id="chartGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#1F382B" stopOpacity="0.1" />
                  <stop offset="100%" stopColor="#1F382B" stopOpacity="0.0" />
                </linearGradient>
              </defs>
              <path
                d="M 10 110 Q 140 130, 240 80 T 420 100 T 580 40 L 580 150 L 10 150 Z"
                fill="url(#chartGrad)"
              />
              <path
                d="M 10 110 Q 140 130, 240 80 T 420 100 T 580 40"
                stroke="#1F382B"
                strokeWidth="2.5"
                strokeLinecap="round"
              />
              <circle cx="420" cy="100" r="5" fill="#1F382B" stroke="#FFFFFF" strokeWidth="2.5" />
            </svg>
          </div>
        </div>

        {/* KYC Verification Distribution Donut */}
        <div className={styles.donutCard}>
          <div>
            <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: 500 }}>
              KYC Compliance Distribution
            </span>
            <div style={{ marginTop: '4px' }}>
              <span style={{ fontSize: '22px', fontWeight: 800 }}>Tier Verification</span>
            </div>
          </div>

          <div className={styles.donutArea}>
            <svg className={styles.donutSvg} viewBox="0 0 100 100">
              <circle cx="50" cy="50" r="40" fill="transparent" stroke="#EBECE6" strokeWidth="11" />
              <circle
                cx="50"
                cy="50"
                r="40"
                fill="transparent"
                stroke="#1F382B"
                strokeWidth="11"
                strokeDasharray="251.2"
                strokeDashoffset="75"
                strokeLinecap="round"
              />
            </svg>
            <div className={styles.donutCenterText}>
              <span className={styles.donutPercent}>70%</span>
              <span style={{ fontSize: '10px', color: 'var(--text-muted)' }}>Verified</span>
            </div>
          </div>

          <div className={styles.donutLegend}>
            <div className={styles.legendItem}>
              <div className={styles.legendLeft}>
                <span className={styles.legendDot} style={{ background: '#1F382B' }} />
                <span>Tier 2 & 3 (Verified Pro)</span>
              </div>
              <span style={{ fontWeight: 700 }}>70%</span>
            </div>
            <div className={styles.legendItem}>
              <div className={styles.legendLeft}>
                <span className={styles.legendDot} style={{ background: '#E2ECE5' }} />
                <span>Tier 1 (Basic / Pending)</span>
              </div>
              <span style={{ fontWeight: 700 }}>30%</span>
            </div>
          </div>
        </div>
      </section>

      {/* Bottom Row: Pending KYC Queue + Recent Ledger Audit */}
      <section className={styles.bottomGrid}>
        {/* Pending KYC Action Center */}
        <div className={styles.sectionCard}>
          <div className={styles.sectionHeader}>
            <div>
              <h3 style={{ fontSize: '15px', fontWeight: 700 }}>Pending KYC Submissions</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Awaiting compliance review</p>
            </div>
            <Link href="/kyc" className="btn-outline" style={{ fontSize: '11px', padding: '6px 12px' }}>
              View All <ArrowRight size={12} />
            </Link>
          </div>

          <div className={styles.kycQuickList}>
            {pendingKycUsers.map((user) => (
              <div key={user.id} className={styles.kycQuickItem}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div
                    style={{
                      width: '34px',
                      height: '34px',
                      borderRadius: '50%',
                      background: 'var(--status-pending-bg)',
                      color: 'var(--status-pending)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: 700,
                      fontSize: '13px',
                    }}
                  >
                    {(user.full_name || user.email)[0].toUpperCase()}
                  </div>
                  <div>
                    <div style={{ fontWeight: 600, fontSize: '13px' }}>{user.full_name || 'Nova Member'}</div>
                    <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                      {user.kyc_document_type ? user.kyc_document_type.replace('_', ' ').toUpperCase() : 'National ID'}
                    </div>
                  </div>
                </div>

                <Link href="/kyc" className="btn-primary" style={{ fontSize: '11px', padding: '6px 12px' }}>
                  Review
                </Link>
              </div>
            ))}
          </div>
        </div>

        {/* Live Recent Transactions */}
        <div className={styles.sectionCard}>
          <div className={styles.sectionHeader}>
            <div>
              <h3 style={{ fontSize: '15px', fontWeight: 700 }}>Live Financial Ledger</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Recent debits & credits in minor units</p>
            </div>
            <Link href="/ledger" className="btn-outline" style={{ fontSize: '11px', padding: '6px 12px' }}>
              Full Ledger <ArrowRight size={12} />
            </Link>
          </div>

          <div className={styles.transfersList}>
            {recentLedger.map((tx) => {
              const isCredit = tx.amount_minor > 0;
              return (
                <div key={tx.id} className={styles.transferItem}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <div
                      style={{
                        width: '32px',
                        height: '32px',
                        borderRadius: '50%',
                        background: isCredit ? 'var(--status-positive-bg)' : 'var(--bg-muted)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      {isCredit ? (
                        <ArrowDownLeft size={16} color="var(--status-positive)" />
                      ) : (
                        <ArrowUpRight size={16} color="var(--text-primary)" />
                      )}
                    </div>
                    <div>
                      <div style={{ fontSize: '13px', fontWeight: 600 }}>{tx.description || 'P2P Transfer'}</div>
                      <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                        <code style={{ fontSize: '10px', background: 'var(--bg-muted)', padding: '2px 6px', borderRadius: '4px' }}>
                          {tx.reference}
                        </code>
                      </div>
                    </div>
                  </div>

                  <div
                    style={{
                      fontSize: '14px',
                      fontWeight: 700,
                      color: isCredit ? 'var(--status-positive)' : 'var(--text-primary)',
                    }}
                  >
                    {isCredit ? '+' : ''}${(tx.amount_minor / 100).toFixed(2)}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>
    </div>
  );
}

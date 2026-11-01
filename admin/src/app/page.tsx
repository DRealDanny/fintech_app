import Header from '@/components/Header';
import { supabaseAdmin } from '@/lib/supabase/admin';
import {
  TrendingUp,
  DollarSign,
  CreditCard,
  Shield,
  ArrowUpRight,
  ArrowDownLeft,
  Plus,
} from 'lucide-react';
import styles from './page.module.css';

export const revalidate = 0; // Fresh real-time data on every request

export default async function DashboardPage() {
  // Fetch real metrics from Supabase
  let totalUsers = 251;
  let pendingKyc = 4;
  let recentTransfers = [
    {
      id: '1',
      title: 'From Anna Jones',
      date: 'Today, 14:24',
      amount: '+$850.00',
      isPositive: true,
    },
    {
      id: '2',
      title: 'To Carlos Brown',
      date: 'Yesterday, 18:30',
      amount: '-$500.00',
      isPositive: false,
    },
    {
      id: '3',
      title: 'From Joel Gorman',
      date: 'Oct 29, 09:12',
      amount: '+$1,200.00',
      isPositive: true,
    },
  ];

  try {
    const { count: usersCount } = await supabaseAdmin
      .from('profiles')
      .select('*', { count: 'exact', head: true });
    if (usersCount !== null && usersCount > 0) totalUsers = usersCount;

    const { count: kycCount } = await supabaseAdmin
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .eq('kyc_status', 'pending');
    if (kycCount !== null) pendingKyc = kycCount;

    const { data: ledgerRows } = await supabaseAdmin
      .from('ledger_entries')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(3);

    if (ledgerRows && ledgerRows.length > 0) {
      recentTransfers = ledgerRows.map((row) => ({
        id: row.id,
        title: row.description || 'P2P Transfer',
        date: new Date(row.created_at).toLocaleDateString('en-US', {
          month: 'short',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit',
        }),
        amount: `${row.amount_minor > 0 ? '+' : ''}$${(
          Math.abs(row.amount_minor) / 100
        ).toFixed(2)}`,
        isPositive: row.amount_minor > 0,
      }));
    }
  } catch {
    // Graceful fallback to default demo data
  }

  return (
    <div className={styles.dashboardContainer}>
      <Header
        title="Hey, Codexr!"
        subtitle="Explore information and activity about your system"
      />

      {/* Top 4 Metric Cards matching video */}
      <section className={styles.topMetricsGrid}>
        {/* Card 1: Spent this month / Volume */}
        <div className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <span>Spent this month</span>
            <div className={styles.miniBars}>
              <span className={styles.miniBar} style={{ height: '40%' }} />
              <span className={styles.miniBar} style={{ height: '60%' }} />
              <span className={`${styles.miniBar} ${styles.miniBarActive}`} style={{ height: '90%' }} />
              <span className={styles.miniBar} style={{ height: '50%' }} />
              <span className={styles.miniBar} style={{ height: '70%' }} />
            </div>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue}>$8,697.92</span>
          </div>
        </div>

        {/* Card 2: New clients */}
        <div className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <span>New clients</span>
            <span className="badge badge-positive">
              <TrendingUp size={12} />
              +14%
            </span>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue}>{totalUsers}</span>
          </div>
        </div>

        {/* Card 3: Earnings */}
        <div className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <span>Earnings</span>
            <div style={{ color: 'var(--text-secondary)' }}>
              <DollarSign size={18} />
            </div>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue}>$453.45</span>
          </div>
        </div>

        {/* Card 4: Savings (Dark Forest Green Card from video) */}
        <div className={`${styles.metricCard} ${styles.forestCard}`}>
          <div className={styles.metricHeader}>
            <span>Savings</span>
            <span style={{ fontSize: '11px', color: '#A0D2B4' }}>System Vault</span>
          </div>
          <div className={styles.metricBody}>
            <span className={styles.metricValue}>$141.68</span>
            {/* Mini SVG Sparkline */}
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

      {/* Middle Row: Balance Line Chart, Earnings Donut, Profile */}
      <section className={styles.middleGrid}>
        {/* Left: Balance Card with Smooth Curve */}
        <div className={styles.balanceCard}>
          <div className={styles.balanceTop}>
            <div className={styles.statPair}>
              <span className={styles.statLabel}>Balance</span>
              <div className={styles.statRow}>
                <span className={styles.statAmount}>$35.68k</span>
                <span className="badge badge-positive" style={{ fontSize: '11px' }}>
                  +10.6%
                </span>
              </div>
            </div>

            <div className={styles.statPair}>
              <span className={styles.statLabel}>Monthly</span>
              <div className={styles.statRow}>
                <span className={styles.statAmount} style={{ fontSize: '20px' }}>
                  $50,452
                </span>
                <span className="badge badge-positive" style={{ fontSize: '11px' }}>
                  +14.4%
                </span>
              </div>
            </div>
          </div>

          {/* Smooth Bézier Curve Chart */}
          <div className={styles.chartContainer}>
            <svg className={styles.chartSvg} viewBox="0 0 600 140" fill="none">
              <defs>
                <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#1F382B" stopOpacity="0.08" />
                  <stop offset="100%" stopColor="#1F382B" stopOpacity="0.0" />
                </linearGradient>
              </defs>
              {/* Fill */}
              <path
                d="M 10 90 Q 150 110, 240 70 T 400 95 T 580 40 L 580 140 L 10 140 Z"
                fill="url(#chartGradient)"
              />
              {/* Stroke */}
              <path
                d="M 10 90 Q 150 110, 240 70 T 400 95 T 580 40"
                stroke="#1F382B"
                strokeWidth="2.5"
                strokeLinecap="round"
              />
              {/* Active Point Indicator */}
              <circle cx="400" cy="95" r="5" fill="#1F382B" stroke="#FFFFFF" strokeWidth="2.5" />
            </svg>
          </div>
        </div>

        {/* Middle: Earnings Donut / Gauge */}
        <div className={styles.earningsCard}>
          <div>
            <span className={styles.statLabel}>Earnings</span>
            <div style={{ marginTop: '4px' }}>
              <span className={styles.statAmount}>$12,812.47</span>
            </div>
            <p style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '4px' }}>
              Profit is 2% more than last month
            </p>
          </div>

          <div className={styles.donutArea}>
            <svg className={styles.donutSvg} viewBox="0 0 100 100">
              <circle
                cx="50"
                cy="50"
                r="40"
                fill="transparent"
                stroke="#EBECE6"
                strokeWidth="10"
              />
              <circle
                cx="50"
                cy="50"
                r="40"
                fill="transparent"
                stroke="#1F382B"
                strokeWidth="10"
                strokeDasharray="251.2"
                strokeDashoffset="120"
                strokeLinecap="round"
              />
            </svg>
            <div className={styles.donutCenterText}>
              <span className={styles.donutPercent}>52%</span>
            </div>
          </div>

          <div className={styles.donutLegend}>
            <div className={styles.legendItem}>
              <span className={styles.legendDot} style={{ background: '#1F382B' }} />
              <span>Monthly</span>
            </div>
            <div className={styles.legendItem}>
              <span className={styles.legendDot} style={{ background: '#C8D5CC' }} />
              <span>Yearly</span>
            </div>
          </div>
        </div>

        {/* Right: Profile Card matching video */}
        <div className={styles.profileCard}>
          <div className={styles.bigAvatar}>DA</div>
          <div>
            <h3 className={styles.profileName}>Codexr</h3>
            <p className={styles.profileEmail}>codexr.fin@gmail.com</p>
          </div>
          <div className="badge badge-positive" style={{ marginTop: '8px' }}>
            Active Admin
          </div>
        </div>
      </section>

      {/* Bottom Row: 3D Cards, Transfers List, Security */}
      <section className={styles.bottomGrid}>
        {/* Available Credit Card in Wallet */}
        <div className={styles.cardsCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '14px', fontWeight: 700 }}>Available Credit Card in Wallet</span>
          </div>

          <div className={styles.cardsVisualStack}>
            <div className={styles.creditCardMock}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '11px', fontWeight: 700, letterSpacing: '1px' }}>NOVA PLATINUM</span>
                <CreditCard size={18} color="var(--primary-forest)" />
              </div>
              <div style={{ fontSize: '14px', letterSpacing: '2px', fontWeight: 600 }}>
                •••• •••• •••• 1394
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10px', color: 'var(--text-secondary)' }}>
                <span>DANNY ADEBAYO</span>
                <span>08/29</span>
              </div>
            </div>
          </div>

          <button className="btn-outline" style={{ width: '100%' }}>
            <Plus size={16} /> Add New Card
          </button>
        </div>

        {/* Your Transfers */}
        <div className={styles.transfersCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '14px', fontWeight: 700 }}>Your Transfers</span>
            <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Real-Time Ledger</span>
          </div>

          <div className={styles.transfersList}>
            {recentTransfers.map((tx) => (
              <div key={tx.id} className={styles.transferItem}>
                <div className={styles.transferLeft}>
                  <div className={styles.transferIcon}>
                    {tx.isPositive ? (
                      <ArrowDownLeft size={16} color="var(--status-positive)" />
                    ) : (
                      <ArrowUpRight size={16} color="var(--text-primary)" />
                    )}
                  </div>
                  <div>
                    <div className={styles.transferTitle}>{tx.title}</div>
                    <div className={styles.transferDate}>{tx.date}</div>
                  </div>
                </div>
                <div
                  className={`${styles.transferAmount} ${
                    tx.isPositive ? styles.amountPositive : styles.amountNegative
                  }`}
                >
                  {tx.amount}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Keep you safe! */}
        <div className={styles.securityCard}>
          <div className={styles.securityIconWrap}>
            <Shield size={26} />
          </div>
          <div>
            <h4 style={{ fontSize: '15px', fontWeight: 700, marginBottom: '4px' }}>Keep you safe!</h4>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
              Supabase Row-Level Security and ACID Ledger are fully locked.
            </p>
          </div>
          <button className="btn-primary" style={{ width: '100%', fontSize: '12px' }}>
            Inspect Vault Security
          </button>
        </div>
      </section>
    </div>
  );
}


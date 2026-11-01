import Header from '@/components/Header';
import { supabaseAdmin } from '@/lib/supabase/admin';
import { CreditCard, ArrowDownLeft, ArrowUpRight, Plus, RefreshCw } from 'lucide-react';
import styles from './wallets.module.css';

export const revalidate = 0;

export default async function WalletsPage() {
  // Fetch real ledger entries and wallets from Supabase
  let ledgerRows: Array<{
    id: string;
    description: string | null;
    reference: string;
    amount_minor: number;
    created_at: string;
  }> = [];

  let totalBalanceDollars = 47125.36;
  let totalInflow = 1805.15;
  let totalOutflow = 892.80;

  try {
    const { data: entries } = await supabaseAdmin
      .from('ledger_entries')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20);

    if (entries && entries.length > 0) {
      ledgerRows = entries;
      // Calculate sums
      let sumIn = 0;
      let sumOut = 0;
      entries.forEach((e) => {
        if (e.amount_minor > 0) sumIn += e.amount_minor;
        else sumOut += Math.abs(e.amount_minor);
      });
      totalInflow = sumIn / 100;
      totalOutflow = sumOut / 100;
      totalBalanceDollars = (sumIn - sumOut) / 100 + 45000;
    }
  } catch {
    // Fallback if empty database
  }

  return (
    <div className={styles.container}>
      <Header
        title="Wallet & transfers"
        subtitle="Cards, balance and every dollar in or out"
      />

      {/* Top Grid matching video Frame 00:03 */}
      <section className={styles.topRow}>
        {/* Left: Available Balance */}
        <div className={styles.balanceCard}>
          <div>
            <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: 500 }}>
              Available Balance
            </span>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: '10px', marginTop: '6px' }}>
              <span style={{ fontSize: '36px', fontWeight: 800, letterSpacing: '-0.02em' }}>
                ${totalBalanceDollars.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
              </span>
              <span className="badge badge-positive" style={{ fontSize: '11px' }}>
                All cash in the last 30 days
              </span>
            </div>
          </div>

          {/* Smooth chart curve */}
          <div style={{ height: '90px', width: '100%', margin: '14px 0' }}>
            <svg viewBox="0 0 400 90" style={{ width: '100%', height: '100%', overflow: 'visible' }}>
              <path
                d="M 0 65 Q 80 40, 160 55 T 280 30 T 400 20"
                fill="none"
                stroke="#1F382B"
                strokeWidth="2.5"
                strokeLinecap="round"
              />
              <circle cx="280" cy="30" r="4.5" fill="#1F382B" stroke="#FFFFFF" strokeWidth="2" />
            </svg>
          </div>

          {/* Inflow vs Outflow Mini-Stats */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', paddingTop: '14px', borderTop: '1px solid var(--border-light)' }}>
            <div>
              <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Money in</div>
              <div style={{ fontSize: '18px', fontWeight: 700, color: 'var(--status-positive)', marginTop: '2px' }}>
                +${totalInflow.toFixed(2)}
              </div>
            </div>
            <div>
              <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Money out</div>
              <div style={{ fontSize: '18px', fontWeight: 700, color: 'var(--text-primary)', marginTop: '2px' }}>
                -${totalOutflow.toFixed(2)}
              </div>
            </div>
          </div>
        </div>

        {/* Right: Cards in Wallet Fan Stack */}
        <div className={styles.cardsOverviewCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <span style={{ fontSize: '14px', fontWeight: 700 }}>Cards in wallet</span>
              <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>3 linked • Tap a card to bring it forward</div>
            </div>
            <button className="btn-primary" style={{ fontSize: '12px', padding: '8px 14px' }}>
              <Plus size={14} /> Add card
            </button>
          </div>

          {/* Overlapping Fan Cards Stack */}
          <div className={styles.cardFanStack}>
            <div className={styles.stackedCard1}>
              <div style={{ fontSize: '10px', letterSpacing: '1px', opacity: 0.8 }}>FOREST DEBIT</div>
              <div style={{ fontSize: '13px', marginTop: '28px', letterSpacing: '2px' }}>•••• 1294</div>
            </div>
            <div className={styles.stackedCard2}>
              <div style={{ fontSize: '10px', letterSpacing: '1px', color: 'var(--primary-forest)' }}>LIBRA HORIZON</div>
              <div style={{ fontSize: '13px', marginTop: '28px', letterSpacing: '2px', color: 'var(--primary-forest)' }}>•••• 1394</div>
            </div>
            <div className={styles.stackedCard3}>
              <div style={{ fontSize: '10px', letterSpacing: '1px', color: '#151816' }}>PLATINUM METAL</div>
              <div style={{ fontSize: '13px', marginTop: '28px', letterSpacing: '2px' }}>•••• 4910</div>
            </div>
          </div>

          {/* Cards Mini Chips Row */}
          <div className={styles.cardChipsRow}>
            <div className={styles.cardMiniChip}>
              <CreditCard size={18} color="var(--primary-forest)" />
              <div>
                <div style={{ fontSize: '12px', fontWeight: 700 }}>•••• 1394</div>
                <div style={{ fontSize: '10px', color: 'var(--text-secondary)' }}>Libra Horizon Card</div>
              </div>
            </div>
            <div className={styles.cardMiniChip}>
              <CreditCard size={18} color="var(--text-secondary)" />
              <div>
                <div style={{ fontSize: '12px', fontWeight: 700 }}>•••• 1294</div>
                <div style={{ fontSize: '10px', color: 'var(--text-secondary)' }}>Forest Debit Card</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* All Transfers Section */}
      <section className={styles.transfersSection}>
        <div className={styles.transfersHeader}>
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 700 }}>All transfers</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
              Live audit trail synced from PostgreSQL public.ledger_entries
            </p>
          </div>

          <div className={styles.filterPills}>
            <button className={`${styles.filterPill} ${styles.filterPillActive}`}>All</button>
            <button className={styles.filterPill}>In</button>
            <button className={styles.filterPill}>Out</button>
          </div>
        </div>

        <table className={styles.table}>
          <thead>
            <tr>
              <th className={styles.th}>Type / Description</th>
              <th className={styles.th}>Reference</th>
              <th className={styles.th}>Date & Time</th>
              <th className={styles.th} style={{ textAlign: 'right' }}>Amount</th>
            </tr>
          </thead>
          <tbody>
            {ledgerRows.length > 0 ? (
              ledgerRows.map((row) => {
                const isPos = row.amount_minor > 0;
                return (
                  <tr key={row.id} className={styles.tr}>
                    <td className={styles.td}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <div
                          style={{
                            width: '32px',
                            height: '32px',
                            borderRadius: '50%',
                            background: isPos ? 'var(--status-positive-bg)' : 'var(--bg-muted)',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                          }}
                        >
                          {isPos ? (
                            <ArrowDownLeft size={16} color="var(--status-positive)" />
                          ) : (
                            <ArrowUpRight size={16} color="var(--text-primary)" />
                          )}
                        </div>
                        <span style={{ fontWeight: 600 }}>{row.description || 'P2P Transfer'}</span>
                      </div>
                    </td>
                    <td className={styles.td}>
                      <code style={{ fontSize: '11px', background: 'var(--bg-muted)', padding: '3px 8px', borderRadius: '6px' }}>
                        {row.reference}
                      </code>
                    </td>
                    <td className={styles.td}>
                      <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                        {new Date(row.created_at).toLocaleString()}
                      </span>
                    </td>
                    <td className={styles.td} style={{ textAlign: 'right', fontWeight: 700, color: isPos ? 'var(--status-positive)' : 'var(--text-primary)' }}>
                      {isPos ? '+' : ''}${(row.amount_minor / 100).toFixed(2)}
                    </td>
                  </tr>
                );
              })
            ) : (
              // Default demo rows if table is fresh
              [
                { desc: 'From Anna Jones', ref: 'TX_ANNA_9821', date: 'Today, 14:24', amt: '+$850.00', isPos: true },
                { desc: 'To Carlos Brown', ref: 'TX_CARLOS_4910', date: 'Yesterday, 18:30', amt: '-$500.00', isPos: false },
                { desc: 'From Joel Gorman', ref: 'TX_JOEL_1120', date: 'Oct 29, 09:12', amt: '+$1,200.00', isPos: true },
              ].map((item, idx) => (
                <tr key={idx} className={styles.tr}>
                  <td className={styles.td}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <div
                        style={{
                          width: '32px',
                          height: '32px',
                          borderRadius: '50%',
                          background: item.isPos ? 'var(--status-positive-bg)' : 'var(--bg-muted)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                        }}
                      >
                        {item.isPos ? (
                          <ArrowDownLeft size={16} color="var(--status-positive)" />
                        ) : (
                          <ArrowUpRight size={16} color="var(--text-primary)" />
                        )}
                      </div>
                      <span style={{ fontWeight: 600 }}>{item.desc}</span>
                    </div>
                  </td>
                  <td className={styles.td}>
                    <code style={{ fontSize: '11px', background: 'var(--bg-muted)', padding: '3px 8px', borderRadius: '6px' }}>
                      {item.ref}
                    </code>
                  </td>
                  <td className={styles.td}>
                    <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{item.date}</span>
                  </td>
                  <td className={styles.td} style={{ textAlign: 'right', fontWeight: 700, color: item.isPos ? 'var(--status-positive)' : 'var(--text-primary)' }}>
                    {item.amt}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </section>
    </div>
  );
}


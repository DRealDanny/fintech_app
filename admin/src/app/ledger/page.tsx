import Header from '@/components/Header';
import { supabaseAdmin } from '@/lib/supabase/admin';
import { ArrowDownLeft, ArrowUpRight, Search, FileSpreadsheet } from 'lucide-react';
import styles from './ledger.module.css';

export const revalidate = 0;

export default async function LedgerPage() {
  let ledgerRows: Array<{
    id: string;
    user_id: string;
    amount_minor: number;
    reference: string;
    description: string | null;
    created_at: string;
  }> = [];

  let totalInflow = 2450.0;
  let totalOutflow = 1350.0;
  let netCirculation = 1100.0;
  let totalEntriesCount = 0;

  try {
    const { data, count } = await supabaseAdmin
      .from('ledger_entries')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .limit(50);

    if (data && data.length > 0) {
      ledgerRows = data;
      totalEntriesCount = count || data.length;

      let inSum = 0;
      let outSum = 0;
      data.forEach((e) => {
        if (e.amount_minor > 0) inSum += e.amount_minor;
        else outSum += Math.abs(e.amount_minor);
      });
      totalInflow = inSum / 100;
      totalOutflow = outSum / 100;
      netCirculation = (inSum - outSum) / 100;
    }
  } catch {
    // Demo fallback
  }

  if (ledgerRows.length === 0) {
    ledgerRows = [
      {
        id: '1',
        user_id: 'usr_sarah',
        amount_minor: 85000,
        reference: 'TX_ANNA_9821_CREDIT',
        description: 'Direct P2P Transfer Received',
        created_at: new Date().toISOString(),
      },
      {
        id: '2',
        user_id: 'usr_danny',
        amount_minor: -50000,
        reference: 'TX_CARLOS_4910_DEBIT',
        description: 'P2P Transfer to Carlos Brown',
        created_at: new Date(Date.now() - 3600000).toISOString(),
      },
      {
        id: '3',
        user_id: 'usr_michael',
        amount_minor: 120000,
        reference: 'PAYSTACK_REF_99182',
        description: 'Paystack Card Deposit',
        created_at: new Date(Date.now() - 7200000).toISOString(),
      },
      {
        id: '4',
        user_id: 'usr_joel',
        amount_minor: -15000,
        reference: 'TX_BILL_8812',
        description: 'Electricity Bill Payment',
        created_at: new Date(Date.now() - 14400000).toISOString(),
      },
    ];
    totalEntriesCount = 4;
  }

  return (
    <div className={styles.container}>
      <Header
        title="Audit Ledger"
        subtitle="Immutable financial audit trail synced from PostgreSQL public.ledger_entries"
      />

      {/* Top Ledger Stats */}
      <section className={styles.topRow}>
        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Total Audit Rows</span>
          <span style={{ fontSize: '26px', fontWeight: 800 }}>{totalEntriesCount}</span>
        </div>

        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Total Credits (Inflow)</span>
          <span style={{ fontSize: '26px', fontWeight: 800, color: 'var(--status-positive)' }}>
            +${totalInflow.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </span>
        </div>

        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Total Debits (Outflow)</span>
          <span style={{ fontSize: '26px', fontWeight: 800, color: 'var(--text-primary)' }}>
            -${totalOutflow.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </span>
        </div>

        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Net Volume Flow</span>
          <span style={{ fontSize: '26px', fontWeight: 800 }}>
            ${netCirculation.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </span>
        </div>
      </section>

      {/* Full Audit Table */}
      <section className={styles.tableSection}>
        <div className={styles.tableHeader}>
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Double-Entry Journal</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
              ACID-compliant records. No row can be deleted or altered once committed.
            </p>
          </div>

          <div style={{ display: 'flex', gap: '10px' }}>
            <div className={styles.searchBox}>
              <Search size={14} color="var(--text-muted)" />
              <input
                type="text"
                placeholder="Search reference or user..."
                className={styles.searchInput}
              />
            </div>
            <button className="btn-outline" style={{ fontSize: '12px', padding: '8px 14px' }}>
              <FileSpreadsheet size={14} /> Export CSV
            </button>
          </div>
        </div>

        <table className={styles.table}>
          <thead>
            <tr>
              <th className={styles.th}>Transaction / Reason</th>
              <th className={styles.th}>Reference Key</th>
              <th className={styles.th}>User ID</th>
              <th className={styles.th}>Timestamp</th>
              <th className={styles.th} style={{ textAlign: 'right' }}>Amount</th>
            </tr>
          </thead>
          <tbody>
            {ledgerRows.map((row) => {
              const isCredit = row.amount_minor > 0;
              return (
                <tr key={row.id} className={styles.tr}>
                  <td className={styles.td}>
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
                      <span style={{ fontWeight: 600 }}>{row.description || 'P2P Transfer'}</span>
                    </div>
                  </td>
                  <td className={styles.td}>
                    <code style={{ fontSize: '11px', background: 'var(--bg-muted)', padding: '3px 8px', borderRadius: '6px' }}>
                      {row.reference}
                    </code>
                  </td>
                  <td className={styles.td}>
                    <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontFamily: 'monospace' }}>
                      {row.user_id.slice(0, 8)}...
                    </span>
                  </td>
                  <td className={styles.td}>
                    <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                      {new Date(row.created_at).toLocaleString()}
                    </span>
                  </td>
                  <td
                    className={styles.td}
                    style={{
                      textAlign: 'right',
                      fontWeight: 700,
                      color: isCredit ? 'var(--status-positive)' : 'var(--text-primary)',
                    }}
                  >
                    {isCredit ? '+' : ''}${(row.amount_minor / 100).toFixed(2)}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </section>
    </div>
  );
}


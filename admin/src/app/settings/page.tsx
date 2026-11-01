import Header from '@/components/Header';
import { Database, Shield, Webhook, Server } from 'lucide-react';
import styles from './settings.module.css';

export default function SettingsPage() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://ohxsupxcadoufyhoijyt.supabase.co';

  return (
    <div className={styles.container}>
      <Header
        title="System & API Configuration"
        subtitle="Manage live Supabase backend connection, storage buckets, and payment webhooks"
      />

      <div className={styles.grid}>
        {/* Backend Database Card */}
        <div className={styles.card}>
          <div className={styles.cardHeader}>
            <div className={styles.iconWrap}>
              <Database size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Supabase Core Vault</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>PostgreSQL single source of truth</p>
            </div>
          </div>

          <div>
            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>Project URL</span>
              <span className={styles.itemValue}>{supabaseUrl}</span>
            </div>

            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>Row Level Security (RLS)</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
                <span className="badge badge-positive">Enforced on all tables</span>
              </div>
            </div>

            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>ACID Transfer Engine</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
                <span className="badge badge-positive">public.execute_p2p_transfer active</span>
              </div>
            </div>
          </div>
        </div>

        {/* Storage & KYC Bucket Card */}
        <div className={styles.card}>
          <div className={styles.cardHeader}>
            <div className={styles.iconWrap}>
              <Shield size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Supabase Storage</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Private document encryption vault</p>
            </div>
          </div>

          <div>
            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>KYC Documents Bucket</span>
              <span className={styles.itemValue}>kyc-documents (Private)</span>
            </div>

            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>Access Policy</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
                <span className="badge badge-positive">Signed 1-Hour URLs Only</span>
              </div>
            </div>

            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>Allowed Document Mimes</span>
              <span className={styles.itemValue}>image/jpeg, image/png, application/pdf</span>
            </div>
          </div>
        </div>

        {/* Webhook Endpoint Card */}
        <div className={styles.card}>
          <div className={styles.cardHeader}>
            <div className={styles.iconWrap}>
              <Webhook size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Paystack Webhook</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Automated card & deposit listener</p>
            </div>
          </div>

          <div>
            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>Webhook Listener Route</span>
              <span className={styles.itemValue}>/api/webhooks/paystack</span>
            </div>

            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>Signature Verification</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
                <span className="badge badge-positive">HMAC SHA-512 cryptographic check</span>
              </div>
            </div>
          </div>
        </div>

        {/* Mobile App Stack Card */}
        <div className={styles.card}>
          <div className={styles.cardHeader}>
            <div className={styles.iconWrap}>
              <Server size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Flutter Mobile Integration</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Hybrid Stack Part 2</p>
            </div>
          </div>

          <div>
            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>State Architecture</span>
              <span className={styles.itemValue}>Feature-First Clean Architecture (Riverpod)</span>
            </div>

            <div className={styles.itemRow}>
              <span className={styles.itemLabel}>Currency Engine</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
                <span className="badge badge-positive">Minor units (kobo/cents BIGINT)</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}


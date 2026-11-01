import Header from '@/components/Header';
import { supabaseAdmin } from '@/lib/supabase/admin';
import KycCardItem from './KycCardItem';
import styles from './kyc.module.css';

export const revalidate = 0;

export default async function KycPage() {
  let userProfiles: Array<{
    id: string;
    full_name: string | null;
    email: string;
    kyc_status: string;
    kyc_document_type: string | null;
    kyc_document_url: string | null;
    signed_url?: string | null;
    kyc_submitted_at: string | null;
  }> = [];

  let totalCount = 8;
  let approvedCount = 6;
  let pendingCount = 2;

  try {
    const { data: profiles } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .order('updated_at', { ascending: false });

    if (profiles && profiles.length > 0) {
      totalCount = profiles.length;
      approvedCount = profiles.filter((p) => p.kyc_status === 'approved').length;
      pendingCount = profiles.filter((p) => p.kyc_status === 'pending').length;

      // Create signed URLs for uploaded KYC documents from Supabase Storage
      userProfiles = await Promise.all(
        profiles.map(async (p) => {
          let signedUrl: string | null = null;
          if (p.kyc_document_url) {
            try {
              const { data } = await supabaseAdmin.storage
                .from('kyc-documents')
                .createSignedUrl(p.kyc_document_url, 3600); // 1-hour secure link
              signedUrl = data?.signedUrl || null;
            } catch {
              // Ignore signed URL error
            }
          }
          return {
            id: p.id,
            full_name: p.full_name,
            email: p.email,
            kyc_status: p.kyc_status || 'pending',
            kyc_document_type: p.kyc_document_type,
            kyc_document_url: p.kyc_document_url,
            signed_url: signedUrl,
            kyc_submitted_at: p.kyc_submitted_at,
          };
        })
      );
    }
  } catch {
    // Demo fallback
  }

  // If no profiles in database yet, provide sample data matching video
  if (userProfiles.length === 0) {
    userProfiles = [
      {
        id: 'usr_demo_1',
        full_name: 'Danny Adebayo',
        email: 'danny@nova.finance',
        kyc_status: 'pending',
        kyc_document_type: 'national_id',
        kyc_document_url: null,
        signed_url: null,
        kyc_submitted_at: new Date().toISOString(),
      },
      {
        id: 'usr_demo_2',
        full_name: 'Sarah Connor',
        email: 'sarah.connor@sky.net',
        kyc_status: 'pending',
        kyc_document_type: 'passport',
        kyc_document_url: null,
        signed_url: null,
        kyc_submitted_at: new Date(Date.now() - 3600000).toISOString(),
      },
      {
        id: 'usr_demo_3',
        full_name: 'Michael Scott',
        email: 'michael.scott@dunder.com',
        kyc_status: 'approved',
        kyc_document_type: 'drivers_license',
        kyc_document_url: null,
        signed_url: null,
        kyc_submitted_at: new Date(Date.now() - 86400000).toISOString(),
      },
      {
        id: 'usr_demo_4',
        full_name: 'Anna Jones',
        email: 'anna.jones@design.co',
        kyc_status: 'approved',
        kyc_document_type: 'passport',
        kyc_document_url: null,
        signed_url: null,
        kyc_submitted_at: new Date(Date.now() - 172800000).toISOString(),
      },
    ];
  }

  return (
    <div className={styles.container}>
      <Header
        title="KYC Verification Queue"
        subtitle="Review identity documents uploaded from mobile and unlock Tier 2 limits"
      />

      {/* Top 4 Metrics Grid matching video Frame 00:04 */}
      <section className={styles.topMetricsGrid}>
        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: 500 }}>
            Total Profiles
          </span>
          <span style={{ fontSize: '28px', fontWeight: 800 }}>{totalCount}</span>
        </div>

        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: 500 }}>
            Pending Submissions
          </span>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: '8px' }}>
            <span style={{ fontSize: '28px', fontWeight: 800, color: 'var(--status-pending)' }}>
              {pendingCount}
            </span>
            <span className="badge badge-pending" style={{ fontSize: '11px' }}>
              Action Required
            </span>
          </div>
        </div>

        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: 500 }}>
            Approved Members
          </span>
          <span style={{ fontSize: '28px', fontWeight: 800, color: 'var(--status-positive)' }}>
            {approvedCount}
          </span>
        </div>

        <div className={styles.metricCard}>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: 500 }}>
            Approval Rate
          </span>
          <span style={{ fontSize: '28px', fontWeight: 800 }}>
            {totalCount > 0 ? `${Math.round((approvedCount / totalCount) * 100)}%` : '100%'}
          </span>
        </div>
      </section>

      {/* Grid of KYC Cards */}
      <section className={styles.kycGrid}>
        {userProfiles.map((user) => (
          <KycCardItem key={user.id} user={user} />
        ))}
      </section>
    </div>
  );
}


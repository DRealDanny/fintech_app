'use client';

import { useState } from 'react';
import { Check, X, Shield, Clock, FileText } from 'lucide-react';
import { approveKyc, rejectKyc } from './actions';
import styles from './kyc.module.css';

interface KycItemProps {
  user: {
    id: string;
    full_name: string | null;
    email: string;
    kyc_status: string;
    kyc_document_type: string | null;
    kyc_document_url: string | null;
    signed_url?: string | null;
    kyc_submitted_at: string | null;
  };
}

export default function KycCardItem({ user }: KycItemProps) {
  const [isPending, setIsPending] = useState(false);
  const [status, setStatus] = useState(user.kyc_status);

  const handleApprove = async () => {
    setIsPending(true);
    const res = await approveKyc(user.id);
    setIsPending(false);
    if (res.success) {
      setStatus('approved');
    }
  };

  const handleReject = async () => {
    setIsPending(true);
    const res = await rejectKyc(user.id);
    setIsPending(false);
    if (res.success) {
      setStatus('rejected');
    }
  };

  const initial = (user.full_name || user.email || 'U')[0].toUpperCase();

  return (
    <div className={styles.kycCard}>
      <div className={styles.cardHeader}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div className={styles.userAvatar}>{initial}</div>
          <div className={styles.userInfo}>
            <span className={styles.userName}>
              {user.full_name || 'Anonymous User'}
            </span>
            <span className={styles.userMeta}>{user.email}</span>
          </div>
        </div>

        <span
          className={`badge ${
            status === 'approved'
              ? 'badge-positive'
              : status === 'pending'
              ? 'badge-pending'
              : 'badge-rejected'
          }`}
        >
          {status === 'approved' && <Check size={12} />}
          {status === 'pending' && <Clock size={12} />}
          {status === 'rejected' && <X size={12} />}
          {status === 'approved'
            ? 'Approved'
            : status === 'pending'
            ? 'Pending Review'
            : 'Rejected'}
        </span>
      </div>

      {/* Document Preview Box */}
      <div className={styles.documentPreviewBox}>
        {user.signed_url ? (
          <img
            src={user.signed_url}
            alt="KYC Document Preview"
            className={styles.documentImage}
          />
        ) : (
          <div className={styles.noDocPlaceholder}>
            <FileText size={32} />
            <span>
              {user.kyc_document_type
                ? `Type: ${user.kyc_document_type.replace('_', ' ').toUpperCase()}`
                : 'National ID / Passport'}
            </span>
          </div>
        )}
      </div>

      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: 'var(--text-secondary)' }}>
        <span>
          Submitted:{' '}
          {user.kyc_submitted_at
            ? new Date(user.kyc_submitted_at).toLocaleDateString()
            : 'Recent'}
        </span>
        <span style={{ fontWeight: 600, color: 'var(--text-primary)' }}>Tier 2 Verification</span>
      </div>

      {status === 'pending' && (
        <div className={styles.actionsRow}>
          <button
            onClick={handleApprove}
            disabled={isPending}
            className={styles.btnApprove}
          >
            <Check size={14} />
            {isPending ? 'Updating...' : 'Approve Tier 2'}
          </button>
          <button
            onClick={handleReject}
            disabled={isPending}
            className={styles.btnReject}
          >
            <X size={14} />
            Reject
          </button>
        </div>
      )}
    </div>
  );
}


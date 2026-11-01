'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutGrid,
  ShieldCheck,
  Wallet,
  ReceiptText,
  Settings,
} from 'lucide-react';
import styles from './Sidebar.module.css';

export default function Sidebar() {
  const pathname = usePathname();

  const navItems = [
    {
      href: '/',
      label: 'Overview',
      icon: LayoutGrid,
    },
    {
      href: '/kyc',
      label: 'KYC Review',
      icon: ShieldCheck,
      badge: 'Action',
    },
    {
      href: '/wallets',
      label: 'User Wallets',
      icon: Wallet,
    },
    {
      href: '/ledger',
      label: 'Audit Ledger',
      icon: ReceiptText,
    },
    {
      href: '/settings',
      label: 'System & API',
      icon: Settings,
    },
  ];

  return (
    <aside className={styles.sidebar}>
      <div className={styles.topSection}>
        {/* Brand Header */}
        <Link href="/" className={styles.brandArea}>
          <div className={styles.logoIcon}>
            <svg
              width="22"
              height="22"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <circle cx="12" cy="12" r="4" />
              <path d="M12 2v2" />
              <path d="M12 20v2" />
              <path d="m4.93 4.93 1.41 1.41" />
              <path d="m17.66 17.66 1.41 1.41" />
              <path d="M2 12h2" />
              <path d="M20 12h2" />
              <path d="m6.34 17.66-1.41 1.41" />
              <path d="m19.07 4.93-1.41 1.41" />
            </svg>
          </div>
          <div className={styles.brandText}>
            <span className={styles.brandTitle}>Nova Admin</span>
            <span className={styles.brandSubtitle}>Fintech Portal</span>
          </div>
        </Link>

        {/* Navigation Items with visible Labels & Badges */}
        <nav className={styles.navGroup}>
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive =
              item.href === '/'
                ? pathname === '/'
                : pathname === item.href || pathname?.startsWith(`${item.href}/`);

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`${styles.navItem} ${
                  isActive ? styles.navItemActive : ''
                }`}
              >
                <Icon size={18} strokeWidth={isActive ? 2.4 : 1.8} />
                <span className={styles.navLabel}>{item.label}</span>
                {item.badge && (
                  <span
                    className={`${styles.navBadge} ${
                      isActive ? styles.navBadgeActive : ''
                    }`}
                  >
                    {item.badge}
                  </span>
                )}
              </Link>
            );
          })}
        </nav>
      </div>

      <div className={styles.bottomSection}>
        {/* Live System Status Indicator */}
        <div className={styles.statusCard}>
          <div className={styles.statusDot} />
          <div>
            <div className={styles.statusLabel}>PostgreSQL Live</div>
            <div className={styles.statusSub}>RLS Vault Locked</div>
          </div>
        </div>

        {/* Admin User Info */}
        <div className={styles.adminProfile}>
          <div className={styles.avatar}>DA</div>
          <div className={styles.adminDetails}>
            <span className={styles.adminName}>Danny Adebayo</span>
            <span className={styles.adminRole}>Compliance Admin</span>
          </div>
        </div>
      </div>
    </aside>
  );
}

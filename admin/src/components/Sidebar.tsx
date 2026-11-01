'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutGrid,
  Wallet,
  ShieldCheck,
  ReceiptText,
  Settings,
} from 'lucide-react';
import styles from './Sidebar.module.css';

export default function Sidebar() {
  const pathname = usePathname();

  const navItems = [
    { href: '/', label: 'Dashboard', icon: LayoutGrid },
    { href: '/wallets', label: 'Wallets & Transfers', icon: Wallet },
    { href: '/kyc', label: 'KYC Verification', icon: ShieldCheck },
    { href: '/ledger', label: 'Financial Ledger', icon: ReceiptText },
    { href: '/settings', label: 'Settings', icon: Settings },
  ];

  return (
    <aside className={styles.sidebar}>
      <div className={styles.topSection}>
        {/* Flower / Sunburst Logo matching video */}
        <Link href="/" className={styles.logoButton} aria-label="Home">
          <svg
            width="32"
            height="32"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
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
        </Link>

        {/* Navigation Icon List */}
        <nav className={styles.navGroup}>
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive =
              item.href === '/'
                ? pathname === '/'
                : pathname?.startsWith(item.href);

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`${styles.navItem} ${
                  isActive ? styles.navItemActive : ''
                }`}
                title={item.label}
              >
                <Icon size={22} strokeWidth={isActive ? 2.2 : 1.8} />
              </Link>
            );
          })}
        </nav>
      </div>

      <div className={styles.bottomSection}>
        {/* Admin profile avatar */}
        <div className={styles.userAvatar} title="Admin User">
          DA
        </div>
      </div>
    </aside>
  );
}


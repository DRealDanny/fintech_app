'use client';

import { Search, Bell, Link2 } from 'lucide-react';
import styles from './Header.module.css';

interface HeaderProps {
  title?: string;
  subtitle?: string;
}

export default function Header({
  title = 'Hey, Codexr!',
  subtitle = 'Explore information and activity about your system',
}: HeaderProps) {
  return (
    <header className={styles.header}>
      <div className={styles.titleArea}>
        <h1 className={styles.title}>{title}</h1>
        <p className={styles.subtitle}>{subtitle}</p>
      </div>

      <div className={styles.actionsArea}>
        <div className={styles.searchPill}>
          <Search size={16} className={styles.searchIcon} />
          <input
            type="text"
            placeholder="Search or ask system..."
            className={styles.searchInput}
          />
        </div>

        <button className={styles.iconButton} aria-label="Notifications">
          <Bell size={18} />
          <span className={styles.badgeDot} />
        </button>

        <button className={styles.iconButton} aria-label="Share Link">
          <Link2 size={18} />
        </button>
      </div>
    </header>
  );
}


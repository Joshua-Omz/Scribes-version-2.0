import React from 'react';
import Link from 'next/link';

export function Footer() {
  return (
    <footer className="relative z-10 border-t-[0.5px] border-[var(--color-border)] px-[24px] md:px-[60px] py-[40px] flex flex-col md:flex-row items-center justify-between gap-[16px] bg-[var(--color-background)]">
      <Link href="/" className="font-serif text-[18px] font-semibold text-[var(--color-secondary-text)] no-underline">
        Scribes
      </Link>
      <p className="font-serif text-[13px] italic text-[var(--color-secondary-text)] opacity-60 max-w-[400px] text-center">
        "For the earth will be filled with the knowledge of the glory of the Lord, as the waters cover the sea." — Habakkuk 2:14
      </p>
      <p className="text-[12px] text-[var(--color-secondary-text)] opacity-50">
        © {new Date().getFullYear()} Scribes. All rights reserved.
      </p>
    </footer>
  );
}

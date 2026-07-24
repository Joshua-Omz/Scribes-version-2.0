import React from 'react';
import { Reveal } from './ui/Reveal';

export function Vision() {
  return (
    <div id="vision" className="relative z-10 bg-[var(--color-surface)] border-t-[0.5px] border-b-[0.5px] border-[var(--color-border)] py-[140px] px-[24px] text-center overflow-hidden">
      
      {/* Concentric Circles Background */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full border-[0.5px] border-[var(--color-gold-primary)] opacity-[0.06] pointer-events-none" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[900px] h-[900px] rounded-full border-[0.5px] border-[var(--color-gold-primary)] opacity-[0.03] pointer-events-none" />

      <Reveal className="relative z-10 max-w-[860px] mx-auto">
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[40px]">
          Our vision — Habakkuk 2:14
        </p>
        
        <blockquote className="font-serif text-[clamp(28px,4.5vw,52px)] font-light italic leading-[1.3] text-[var(--color-primary-text)] mb-[32px]">
          "For the earth will be filled with the<br />
          <strong className="font-normal font-semibold text-[var(--color-gold-primary)]">knowledge of the glory of the Lord,</strong><br />
          as the waters cover the sea."
        </blockquote>
        
        <p className="text-[12px] font-normal tracking-[2px] uppercase text-[var(--color-secondary-text)] mb-[52px]">
          Habakkuk 2:14 · ESV
        </p>

        {/* Ornament Divider */}
        <div className="flex items-center justify-center gap-[16px] max-w-[320px] mx-auto mb-[52px]">
          <div className="flex-1 h-[0.5px] bg-gradient-to-r from-transparent via-[var(--color-gold-primary)] to-transparent opacity-50" />
          <div className="w-[24px] h-[24px] border-[0.5px] border-[var(--color-gold-primary)] rotate-45 opacity-60 flex-shrink-0 relative">
            <div className="absolute inset-[4px] border-[0.5px] border-[var(--color-gold-primary)]" />
          </div>
          <div className="flex-1 h-[0.5px] bg-gradient-to-r from-transparent via-[var(--color-gold-primary)] to-transparent opacity-50" />
        </div>

        <p className="font-serif text-[19px] font-light italic text-[var(--color-secondary-text)] max-w-[580px] mx-auto leading-[1.7]">
          Scribes is one small instrument in that filling. Every post is a drop.
          Every reader is the sea receiving it.
        </p>
      </Reveal>
    </div>
  );
}

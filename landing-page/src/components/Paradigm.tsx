import React from 'react';
import { Reveal } from './ui/Reveal';

export function Paradigm() {
  return (
    <div id="paradigm" className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px]">
          The Void vs. The Sanctuary
        </p>
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          A place to consume only what edifies, <br />
          write what matters, and build a <br />
          <em className="italic text-[var(--color-gold-primary)]">legacy of His grace.</em>
        </h2>
        <p className="text-[16px] font-light text-[var(--color-secondary-text)] max-w-[560px] leading-[1.8]">
          The modern internet is loud and spiritually draining. Note-taking apps feel like filing cabinets; social feeds feel like a battlefield. Scribes is an intentional ecosystem—an environment where the interface recedes so the Spirit of Christ can speak.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-[24px] mt-[80px]">
          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[48px] md:p-[52px] relative overflow-hidden group hover:bg-[rgba(255,255,255,0.04)] transition-colors duration-300 shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <div className="absolute top-0 left-0 w-[3px] h-full bg-[var(--color-gold-primary)] opacity-0 group-hover:opacity-100 transition-opacity duration-300 shadow-[0_0_15px_var(--color-gold-primary)]" />
            <span className="font-serif text-[72px] font-light text-[var(--color-gold-primary)] opacity-12 leading-[1] mb-[24px] block">I</span>
            <h3 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">The Modern Void</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              Where content is consumed endlessly but digested rarely. Platforms designed for engagement over edification leave the spirit depleted and the mind scattered.
            </p>
          </div>
          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[48px] md:p-[52px] relative overflow-hidden group hover:bg-[rgba(255,255,255,0.04)] transition-colors duration-300 shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <div className="absolute top-0 left-0 w-[3px] h-full bg-[var(--color-gold-primary)] opacity-0 group-hover:opacity-100 transition-opacity duration-300 shadow-[0_0_15px_var(--color-gold-primary)]" />
            <span className="font-serif text-[72px] font-light text-[var(--color-gold-primary)] opacity-12 leading-[1] mb-[24px] block">II</span>
            <h3 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">The Scribes Paradigm</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              A sanctuary built on an uncompromising foundation. Here, words carry weight. The focus is restored, and the noise is removed. You do not doom-scroll; you dwell on Him.
            </p>
          </div>
        </div>
      </Reveal>
    </div>
  );
}

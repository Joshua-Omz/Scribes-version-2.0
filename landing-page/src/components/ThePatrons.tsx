"use client";
import React from 'react';
import { Reveal } from './ui/Reveal';
import { PrimaryCTA } from './ui/PrimaryCTA';

export function ThePatrons() {
  return (
    <div className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto text-center">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px] flex items-center justify-center gap-[14px]">
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
          The Patrons
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
        </p>
        
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          Funding the <em className="italic text-[var(--color-gold-primary)]">Sanctuary.</em>
        </h2>
        
        <div className="text-left max-w-[680px] mx-auto mb-[80px]">
          <p className="text-[16px] font-light text-[var(--color-secondary-text)] leading-[1.8] mb-[24px]">
            Scribes is not a startup; it is a movement. We are not building to eventually gatekeep spiritual revelation behind a subscription, nor are we building to sell your attention to advertisers. 
          </p>
          <p className="text-[16px] font-light text-[var(--color-secondary-text)] leading-[1.8] mb-[24px]">
            Why become a financier? Because pure, undefiled spaces require sovereign backing. Throughout history, the greatest cathedrals and translation efforts of the Word were not funded by market forces, but by patrons who recognized the eternal weight of what was being built.
          </p>
          <p className="text-[16px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
            We invite Kingdom financiers—those entrusted with wealth for divine purposes—to underwrite this sanctuary. By funding Scribes, you ensure that anyone, anywhere, regardless of their financial state, has access to a distraction-free environment to know Jesus more intimately.
          </p>
        </div>

        <div className="pt-[60px] border-t-[0.5px] border-[var(--color-border)]">
          <h2 className="font-serif text-[clamp(28px,4vw,48px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
            A Vision Without <em className="italic text-[var(--color-gold-primary)]">Price Tags.</em>
          </h2>
          <p className="text-[16px] font-light text-[var(--color-secondary-text)] max-w-[560px] mx-auto leading-[1.8] mb-[40px]">
            Scribes fundamentally rejects the pursuit of corporate profit. There will be no paywalls on the Gospel. We invite you to invest directly into the expansion of His movement.
          </p>
          <PrimaryCTA href="#donate">Sow into the Sanctuary</PrimaryCTA>
        </div>
      </Reveal>
    </div>
  );
}

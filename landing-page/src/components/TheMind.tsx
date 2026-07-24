import React from 'react';
import { Reveal } from './ui/Reveal';
import { OrnamentalDivider } from './ui/OrnamentalDivider';

export function TheMind() {
  return (
    <div className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto text-center">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px] flex items-center justify-center gap-[14px]">
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
          The Mind
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
        </p>
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          Authentic Synthesis: <br />
          <em className="italic text-[var(--color-gold-primary)]">From Mind to Page.</em>
        </h2>
        <p className="text-[16px] font-light text-[var(--color-secondary-text)] max-w-[560px] mx-auto leading-[1.8] mb-[40px]">
          Scribes doesn't write for you; it thinks with you. The AI acts as a digital scribe, taking raw thoughts or sermons and formatting them into authentic, articulate content directly from the mind, without losing your true voice or spiritual weight.
        </p>
        <OrnamentalDivider />
      </Reveal>
    </div>
  );
}

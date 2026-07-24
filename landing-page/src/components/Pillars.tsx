import React from 'react';
import { Reveal } from './ui/Reveal';
import { OrnamentalDivider } from './ui/OrnamentalDivider';

export function Pillars() {
  return (
    <div id="pillars" className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px]">
          The Three Pillars of Practice
        </p>
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          An interactive sanctuary<br />
          <em className="italic text-[var(--color-gold-primary)]">for the attentive mind.</em>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-[24px] mt-[80px]">
          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[32px] hover:bg-[rgba(255,255,255,0.04)] transition-colors duration-300 shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <span className="font-serif text-[13px] font-normal text-[var(--color-gold-primary)] tracking-[2px] mb-[20px] block">01 — THE SEEK & SCROLL</span>
            <h3 className="font-serif text-[24px] font-semibold text-[var(--color-primary-text)] mb-[12px] leading-[1.2]">Edification without the noise</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              A continuous feed of profound, curated content. You will not find outrage or distraction here—only the quiet brilliance of believers thinking deeply on the person of Jesus.
            </p>
          </div>
          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[32px] hover:bg-[rgba(255,255,255,0.04)] transition-colors duration-300 shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <span className="font-serif text-[13px] font-normal text-[var(--color-gold-primary)] tracking-[2px] mb-[20px] block">02 — MY NOTES</span>
            <h3 className="font-serif text-[24px] font-semibold text-[var(--color-primary-text)] mb-[12px] leading-[1.2]">The weight of words</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              A block-based, intuitive card layout for capturing divine insights. Organize your revelations of Him with the dignity they deserve.
            </p>
          </div>
          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[32px] hover:bg-[rgba(255,255,255,0.04)] transition-colors duration-300 shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <span className="font-serif text-[13px] font-normal text-[var(--color-gold-primary)] tracking-[2px] mb-[20px] block">03 — THE READER</span>
            <h3 className="font-serif text-[24px] font-semibold text-[var(--color-primary-text)] mb-[12px] leading-[1.2]">Distraction-free focus</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              An immersive typography-first environment that treats reading as a sacred act. The interface bows out, leaving you alone with the text.
            </p>
          </div>
        </div>

        <OrnamentalDivider />
      </Reveal>
    </div>
  );
}

"use client";
import React from 'react';
import { Reveal } from './ui/Reveal';
import { GhostButton } from './ui/GhostButton';

export function TheBuilders() {
  return (
    <div className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto text-center">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px] flex items-center justify-center gap-[14px]">
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
          The Call
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
        </p>
        
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          The Guild of Digital <em className="italic text-[var(--color-gold-primary)]">Craftsmen.</em>
        </h2>
        <p className="text-[16px] font-light text-[var(--color-secondary-text)] max-w-[560px] mx-auto leading-[1.8] mb-[40px]">
          Operating with a transparent, open-source ethos, Scribes is a call to master builders. We are constructing a digital tabernacle for Christ and require exceptional hands: Flutter Engineers, Go Developers, and DevOps Architects.
        </p>
        
        <div className="flex items-center justify-center gap-[20px] flex-wrap mb-[80px]">
          <GhostButton href="https://github.com/Scribes">Contribute Your Craft</GhostButton>
        </div>

        <div className="text-left pt-[40px] border-t-[0.5px] border-[var(--color-border)] mb-[80px]">
          <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px]">
            The Foundation
          </p>
          <h3 className="font-serif text-[clamp(28px,4vw,48px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
            Built on uncompromising <em className="italic text-[var(--color-gold-primary)]">integrity.</em>
          </h3>
          <p className="text-[16px] font-light text-[var(--color-secondary-text)] max-w-[560px] leading-[1.8] mb-[40px]">
            A beautiful sanctuary requires a flawless foundation. Ensuring the code is as clean and eternal as the thoughts it stores, we are building a four-layer architecture of unprecedented speed, security, and concurrent data handling.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-[24px]">
            <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
              <h4 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">Flutter Frontend</h4>
              <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
                A fluid, native, and graceful UI. Delivered across platforms without compromising the aesthetic laws of the sanctuary.
              </p>
            </div>
            <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
              <h4 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">Go Backend</h4>
              <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
                Forged in Golang for ironclad reliability. It processes the weight of our global library with speed and unwavering security.
              </p>
            </div>
          </div>
        </div>

      </Reveal>
    </div>
  );
}

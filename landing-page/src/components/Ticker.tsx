import React from 'react';

const excerpts = [
  "He who has ears to hear, let him hear — and not merely agree, but be changed.",
  "Grace is not the absence of demand. It is the presence of power to meet it.",
  "Every wound in scripture is an invitation to look at the one who heals.",
  "The Kingdom is not a place you arrive at. It is a reality you carry.",
  "Meditation is not emptying the mind. It is filling it with what is true."
];

export function Ticker() {
  return (
    <div className="relative z-10 p-0 overflow-hidden border-y-[0.5px] border-[var(--color-border)]">
      <p className="text-center text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] pt-[28px] pb-[20px]">
        From the community
      </p>
      
      <div className="flex w-max animate-[ticker_40s_linear_infinite] motion-reduce:animate-none hover:[animation-play-state:paused] pb-[32px]">
        {[...excerpts, ...excerpts].map((excerpt, idx) => (
          <div key={idx} className="flex items-center gap-0 px-[48px] whitespace-nowrap shrink-0">
            <span className="font-serif text-[19px] italic font-light text-[var(--color-primary-text)] opacity-85">
              "{excerpt}"
            </span>
            <span className="w-[4px] h-[4px] rounded-full bg-[var(--color-gold-primary)] mx-[48px] opacity-50 shrink-0" />
          </div>
        ))}
      </div>
    </div>
  );
}

import React from 'react';
import { Reveal } from './ui/Reveal';

export function HowItWorks() {
  const steps = [
    {
      num: '01 — Capture',
      title: 'Write what you received',
      desc: 'Your private Notes workspace is for what arrives uninvited — a sermon line that stayed with you, a verse that meant something different this morning, a 2am impression. Plain and honest. Not for anyone else yet.'
    },
    {
      num: '02 — Refine',
      title: 'Shape it into a teaching',
      desc: 'When a note is ready to be shared, move it to a Draft. Add a title, a category, scripture references. A full rich-text editor gives it the form a teaching deserves. Nothing is published until you say so.'
    },
    {
      num: '03 — Publish',
      title: 'Release it permanently',
      desc: 'A published post carries your name and cannot be silently altered. It is a permanent record of what you believed and wrote on that day. It is searchable, shareable, and open to the world.'
    }
  ];

  const types = [
    'Scripture meditations', 'Sermon notes', 'Theological questions',
    'Personal charges', 'Study reflections', 'Kingdom insights',
    'Devotional reads', 'Prophetic impressions'
  ];

  return (
    <div className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px]">
          How it works
        </p>
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          From private note<br />
          <em className="italic text-[var(--color-gold-primary)]">to permanent teaching.</em>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-[24px] mt-[80px]">
          {steps.map((step, idx) => (
            <div 
              key={idx}
              className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)] transition-colors duration-300 hover:bg-[rgba(255,255,255,0.04)] hover:border-[rgba(201,168,76,0.3)]"
            >
              <span className="font-serif text-[13px] font-normal text-[var(--color-gold-primary)] tracking-[2px] mb-[20px] block">
                {step.num}
              </span>
              <h3 className="font-serif text-[24px] font-semibold text-[var(--color-primary-text)] mb-[12px] leading-[1.2]">
                {step.title}
              </h3>
              <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
                {step.desc}
              </p>
            </div>
          ))}
        </div>

        {/* Ornament Divider */}
        <div className="flex items-center justify-center gap-[16px] max-w-[320px] mx-auto mt-[100px] mb-[100px]">
          <div className="flex-1 h-[0.5px] bg-gradient-to-r from-transparent via-[var(--color-gold-primary)] to-transparent opacity-50" />
          <div className="w-[24px] h-[24px] border-[0.5px] border-[var(--color-gold-primary)] rotate-45 opacity-60 flex-shrink-0 relative">
            <div className="absolute inset-[4px] border-[0.5px] border-[var(--color-gold-primary)]" />
          </div>
          <div className="flex-1 h-[0.5px] bg-gradient-to-r from-transparent via-[var(--color-gold-primary)] to-transparent opacity-50" />
        </div>

        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[24px] text-center">
          What believers publish on Scribes
        </p>
        <div className="flex flex-wrap justify-center gap-[12px] max-w-[900px] mx-auto">
          {types.map((type, idx) => (
            <div 
              key={idx}
              className="font-sans text-[13px] font-normal text-[var(--color-gold-primary)] border-[0.5px] border-[rgba(201,168,76,0.3)] px-[20px] py-[10px] rounded-[3px] transition-all duration-200 hover:bg-[rgba(201,168,76,0.08)] hover:border-[var(--color-gold-primary)] cursor-default"
            >
              {type}
            </div>
          ))}
        </div>
      </Reveal>
    </div>
  );
}

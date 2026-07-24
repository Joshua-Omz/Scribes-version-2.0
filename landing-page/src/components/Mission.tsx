import React from 'react';
import { Reveal } from './ui/Reveal';

export function Mission() {
  const missions = [
    {
      num: 'I',
      title: 'Nourish through the word',
      desc: 'Edifying content — scripture reflections, sermon notes, theological meditations — preserved exactly as they were given, attributed to the one who received them, and open to anyone who needs them.'
    },
    {
      num: 'II',
      title: 'Bless beyond the congregation',
      desc: 'A teaching published on Scribes is not locked behind a membership or a paywall. It is open. A person who has never stepped inside a church can read it. That is the point.'
    },
    {
      num: 'III',
      title: 'Preserve what was given',
      desc: 'Knowledge received is knowledge that can be lost. Scribes treats every post as a durable artifact — traceable, authored, immutable in spirit. Nothing is silently erased.'
    },
    {
      num: 'IV',
      title: 'Bring people to Christ',
      desc: 'Through the quality, seriousness, and beauty of what believers write, Scribes is designed so that an unbeliever who encounters this platform may feel, before anything else, that what is here is worth reading. The word does the rest.'
    }
  ];

  return (
    <div id="mission" className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px]">
          Our mission
        </p>
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          That everyone gets<br />
          <em className="italic text-[var(--color-gold-primary)]">a taste of the Word.</em>
        </h2>
        <p className="text-[16px] font-light text-[var(--color-secondary-text)] max-w-[560px] leading-[1.8]">
          Scribes exists so that the spiritual insights given to believers — the
          excerpts, meditations, charges, and questions that emerge from genuine
          encounter with God — find a permanent home, and from that home, reach
          anyone who is searching.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-[24px] mt-[80px]">
          {missions.map((mission, idx) => (
            <div 
              key={idx} 
              className="group relative bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] md:p-[52px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)] overflow-hidden transition-all duration-300 hover:bg-[rgba(255,255,255,0.04)] hover:border-[rgba(201,168,76,0.3)]"
            >
              {/* Left Gold Accent Bar */}
              <div className="absolute top-0 left-0 w-[3px] h-full bg-[var(--color-gold-primary)] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              
              <span className="font-serif text-[72px] font-light text-[var(--color-gold-primary)] opacity-[0.12] leading-[1] mb-[24px] block">
                {mission.num}
              </span>
              <h3 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">
                {mission.title}
              </h3>
              <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
                {mission.desc}
              </p>
            </div>
          ))}
        </div>
      </Reveal>
    </div>
  );
}

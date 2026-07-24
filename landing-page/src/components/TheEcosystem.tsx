"use client";
import React from 'react';
import { Reveal } from './ui/Reveal';
import { PrimaryCTA } from './ui/PrimaryCTA';

export function TheEcosystem() {
  return (
    <div className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto text-center">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px] flex items-center justify-center gap-[14px]">
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
          The Ecosystem
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
        </p>
        
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          The Three Pillars of the <br />
          <em className="italic text-[var(--color-gold-primary)]">Sanctuary.</em>
        </h2>
        
        <p className="text-[16px] font-light text-[var(--color-secondary-text)] max-w-[600px] mx-auto leading-[1.8] mb-[80px]">
          Scribes is designed to be a digital sanctuary housing three distinct pillars of the spiritual community, operating in harmony to preserve and share divine revelation.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-[24px] text-left mb-[120px]">
          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <span className="font-serif text-[48px] font-light text-[var(--color-gold-primary)] opacity-20 leading-[1] mb-[20px] block">01</span>
            <h3 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">Verified Scribes</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              Credible, vetted voices within the platform—ministers, teachers, and writers who have demonstrated profound spiritual depth. As Verified Scribes, they are entrusted to publish teachings, theological insights, and words of knowledge that edify the wider community.
            </p>
          </div>

          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <span className="font-serif text-[48px] font-light text-[var(--color-gold-primary)] opacity-20 leading-[1] mb-[20px] block">02</span>
            <h3 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">Kingdom Institutions</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              Ministries and churches establishing their official presence. When a church publishes official teachings, they become the parent source. Notes taken by individual members during a service are intrinsically linked back to the church's official teaching, ensuring doctrinal integrity.
            </p>
          </div>

          <div className="bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)]">
            <span className="font-serif text-[48px] font-light text-[var(--color-gold-primary)] opacity-20 leading-[1] mb-[20px] block">03</span>
            <h3 className="font-serif text-[26px] font-semibold text-[var(--color-primary-text)] mb-[14px] leading-[1.2]">The Seekers</h3>
            <p className="text-[14px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
              The heartbeat of the sanctuary. These individuals utilize Scribes to document their personal spiritual journeys—capturing personal sermon notes, revelations, and rhema words. They can occasionally publish their insights to bless the wider community.
            </p>
          </div>
        </div>

        <div className="pt-[80px] border-t-[0.5px] border-[var(--color-border)] max-w-[800px] mx-auto text-left">
          <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px]">
            The Cold Start Strategy
          </p>
          <h2 className="font-serif text-[clamp(28px,4vw,48px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[24px]">
            The Foundational <em className="italic text-[var(--color-gold-primary)]">Beta Phase.</em>
          </h2>
          
          <div className="space-y-[24px] text-[16px] font-light text-[var(--color-secondary-text)] leading-[1.8]">
            <p>
              Before opening the gates of the sanctuary to the public, Scribes is executing an intentional "Cold Start" rollout.
            </p>
            <p>
              <strong className="text-[var(--color-primary-text)] font-normal">The First Move:</strong> We are exclusively inviting those called to be official Verified Scribes—individuals graced with the gift of the word of knowledge and a passion for writing rhema teachings.
            </p>
            <p>
              During this initial phase, these foundational authors will use Scribes to publish their finest work. This is not about immediate engagement; it is about laying the cornerstones of the library. They are curating the sacred atmosphere and establishing the high standard of content that will greet the public when the platform fully opens.
            </p>
          </div>

          <div className="mt-[60px] text-center">
            <PrimaryCTA href="/#waitlist">Join the Sanctuary</PrimaryCTA>
          </div>
        </div>
      </Reveal>
    </div>
  );
}

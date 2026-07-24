"use client";
import React, { useState } from 'react';
import { Reveal } from './ui/Reveal';
import { PrimaryCTA } from './ui/PrimaryCTA';
import Link from 'next/link';

export function TheInvitation() {
  const [role, setRole] = useState('seeker');

  return (
    <div className="relative z-10 text-center px-[24px] md:px-[60px] py-[160px] border-t-[0.5px] border-[var(--color-border)] overflow-hidden">
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 font-serif text-[clamp(80px,15vw,200px)] font-bold italic text-[var(--color-gold-primary)] opacity-5 whitespace-nowrap pointer-events-none select-none tracking-[-0.02em]">
        Scribes
      </div>
      <Reveal className="relative z-10">
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[28px]">
          Begin
        </p>
        <h2 className="font-serif text-[clamp(40px,6vw,72px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px] max-w-[700px] mx-auto">
          What has He given <br />
          you <em className="italic text-[var(--color-gold-primary)]">to say?</em>
        </h2>
        <p className="text-[15px] font-light text-[var(--color-secondary-text)] max-w-[480px] mx-auto leading-[1.8] mb-[24px]">
          Join a community of believers writing His works into permanence.
          Open to anyone who wants to read. Built for those who have a testimony to share.
        </p>
        
        <div className="mb-[40px]">
          <Link href="/ecosystem" className="text-[13px] font-medium tracking-[1px] uppercase text-[var(--color-gold-primary)] hover:text-[var(--color-primary-text)] transition-colors border-b-[0.5px] border-[var(--color-gold-primary)] pb-[2px]">
            Learn about the Scribes Ecosystem
          </Link>
        </div>
        
        <form className="max-w-[400px] mx-auto flex flex-col gap-[16px] items-stretch text-left">
          
          <div className="flex flex-col gap-[12px] mb-[12px]">
            <p className="text-[12px] uppercase tracking-[1px] text-[var(--color-secondary-text)] mb-[4px]">Select your Path</p>
            
            <label className={`flex items-center gap-[12px] p-[16px] rounded-[6px] border-[0.5px] cursor-pointer transition-all duration-200 ${role === 'scribe' ? 'border-[var(--color-gold-primary)] bg-[rgba(201,168,76,0.05)]' : 'border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[rgba(255,255,255,0.2)]'}`}>
              <div className={`w-[16px] h-[16px] rounded-full border-[1px] flex items-center justify-center ${role === 'scribe' ? 'border-[var(--color-gold-primary)]' : 'border-[var(--color-secondary-text)]'}`}>
                {role === 'scribe' && <div className="w-[8px] h-[8px] rounded-full bg-[var(--color-gold-primary)]" />}
              </div>
              <span className="text-[14px] text-[var(--color-primary-text)] font-sans">Register as a Verified Scribe</span>
              <input type="radio" name="role" value="scribe" checked={role === 'scribe'} onChange={() => setRole('scribe')} className="hidden" />
            </label>

            <label className={`flex items-center gap-[12px] p-[16px] rounded-[6px] border-[0.5px] cursor-pointer transition-all duration-200 ${role === 'institution' ? 'border-[var(--color-gold-primary)] bg-[rgba(201,168,76,0.05)]' : 'border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[rgba(255,255,255,0.2)]'}`}>
              <div className={`w-[16px] h-[16px] rounded-full border-[1px] flex items-center justify-center ${role === 'institution' ? 'border-[var(--color-gold-primary)]' : 'border-[var(--color-secondary-text)]'}`}>
                {role === 'institution' && <div className="w-[8px] h-[8px] rounded-full bg-[var(--color-gold-primary)]" />}
              </div>
              <span className="text-[14px] text-[var(--color-primary-text)] font-sans">Register a Kingdom Institution</span>
              <input type="radio" name="role" value="institution" checked={role === 'institution'} onChange={() => setRole('institution')} className="hidden" />
            </label>

            <label className={`flex items-center gap-[12px] p-[16px] rounded-[6px] border-[0.5px] cursor-pointer transition-all duration-200 ${role === 'seeker' ? 'border-[var(--color-gold-primary)] bg-[rgba(201,168,76,0.05)]' : 'border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[rgba(255,255,255,0.2)]'}`}>
              <div className={`w-[16px] h-[16px] rounded-full border-[1px] flex items-center justify-center ${role === 'seeker' ? 'border-[var(--color-gold-primary)]' : 'border-[var(--color-secondary-text)]'}`}>
                {role === 'seeker' && <div className="w-[8px] h-[8px] rounded-full bg-[var(--color-gold-primary)]" />}
              </div>
              <span className="text-[14px] text-[var(--color-primary-text)] font-sans">Register as a Seeker (Waitlist)</span>
              <input type="radio" name="role" value="seeker" checked={role === 'seeker'} onChange={() => setRole('seeker')} className="hidden" />
            </label>
          </div>

          <input 
            type="text" 
            placeholder={role === 'institution' ? "Institution Name" : "Name"} 
            required
            className="bg-[var(--color-surface)] border-[0.5px] border-[var(--color-border)] rounded-[3px] px-[16px] py-[12px] text-[14px] text-[var(--color-primary-text)] font-sans focus:outline-none focus:border-[var(--color-gold-primary)] transition-colors"
          />
          <input 
            type="email" 
            placeholder="Email" 
            required
            className="bg-[var(--color-surface)] border-[0.5px] border-[var(--color-border)] rounded-[3px] px-[16px] py-[12px] text-[14px] text-[var(--color-primary-text)] font-sans focus:outline-none focus:border-[var(--color-gold-primary)] transition-colors"
          />
          <textarea 
            placeholder="Intent (Optional)" 
            rows={3}
            className="bg-[var(--color-surface)] border-[0.5px] border-[var(--color-border)] rounded-[3px] px-[16px] py-[12px] text-[14px] text-[var(--color-primary-text)] font-sans focus:outline-none focus:border-[var(--color-gold-primary)] transition-colors resize-none"
          />
          <PrimaryCTA className="mt-[8px] w-full text-center">Request Access</PrimaryCTA>
        </form>
      </Reveal>
    </div>
  );
}

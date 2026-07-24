"use client";
import React, { useRef } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { PrimaryCTA } from './ui/PrimaryCTA';
import { GhostButton } from './ui/GhostButton';

export function Hero() {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"]
  });
  
  const yBg = useTransform(scrollYProgress, [0, 1], ["0%", "40%"]);
  const yMockup = useTransform(scrollYProgress, [0, 1], ["0%", "15%"]);
  const opacityMist = useTransform(scrollYProgress, [0, 0.5], [1, 0]);

  return (
    <section ref={ref} className="relative z-10 min-h-screen flex flex-col items-center justify-start text-center px-[24px] md:px-[60px] pt-[160px] pb-[100px] overflow-hidden">
      
      {/* Golden Mist Background (Parallax) */}
      <motion.div 
        style={{ y: yBg, opacity: opacityMist }}
        className="absolute inset-0 z-0 pointer-events-none flex items-center justify-center"
      >
        <div className="absolute top-[40%] w-[800px] h-[800px] bg-[var(--color-gold-primary)] opacity-[0.15] blur-[120px] rounded-full mix-blend-screen" />
        <div className="absolute top-[60%] w-[1200px] h-[600px] bg-[var(--color-gold-muted)] opacity-[0.1] blur-[150px] rounded-[50%] mix-blend-screen" />
      </motion.div>

      <div className="relative z-10 flex flex-col items-center w-full max-w-[1200px] mx-auto">
        <motion.p 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
          className="font-sans text-[11px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[32px] flex items-center gap-[14px]"
        >
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
          A Sanctuary for the Mind of Christ
          <span className="block w-[40px] h-[0.5px] bg-[var(--color-gold-primary)]" />
        </motion.p>
        
        <motion.h1 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: "easeOut", delay: 0.1 }}
          className="font-serif text-[clamp(52px,8vw,96px)] font-light leading-[1.05] tracking-[-0.01em] text-[var(--color-primary-text)] mb-[12px] max-w-[900px]"
        >
          Where the Word made flesh <br />
          <em className="italic text-[var(--color-gold-primary)]">finds its scribes.</em>
        </motion.h1>
        
        <motion.p 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: "easeOut", delay: 0.2 }}
          className="font-serif text-[clamp(20px,3vw,28px)] font-light italic text-[var(--color-secondary-text)] mb-[52px] max-w-[680px] leading-[1.5]"
        >
          Step away from the noise. Discover a sacred digital library designed for divine revelation, deep research, and beholding the beauty of Jesus.
        </motion.p>
        
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: "easeOut", delay: 0.3 }}
          className="flex items-center justify-center gap-[20px] flex-wrap mb-[80px]"
        >
          <PrimaryCTA href="#waitlist">Enter the Sanctuary</PrimaryCTA>
          <GhostButton href="#paradigm">Discover the Vision</GhostButton>
        </motion.div>

        {/* Mockup Emerging from Mist */}
        <motion.div
          style={{ y: yMockup }}
          initial={{ y: 100, opacity: 0, scale: 0.95 }}
          animate={{ y: 0, opacity: 1, scale: 1 }}
          transition={{ duration: 1.5, ease: [0.16, 1, 0.3, 1], delay: 0.5 }}
          className="relative w-full max-w-[320px] md:max-w-[400px] mx-auto z-20"
        >
          {/* Subtle glow behind the mockup */}
          <div className="absolute inset-0 bg-[var(--color-gold-primary)] blur-[60px] opacity-30 mix-blend-screen" />
          <img 
            src="/mockup.jpg" 
            alt="Scribes Mobile App" 
            className="relative w-full h-auto drop-shadow-2xl rounded-[32px] border-[0.5px] border-[var(--color-border)]"
          />
        </motion.div>
      </div>
    </section>
  );
}

"use client";
import React from 'react';
import { motion, useReducedMotion } from 'framer-motion';

export function Reveal({ children, className, delay = 0 }: { children: React.ReactNode; className?: string; delay?: number }) {
  const shouldReduceMotion = useReducedMotion();
  
  return (
    <motion.div
      initial={{ opacity: shouldReduceMotion ? 1 : 0, y: shouldReduceMotion ? 0 : 40, filter: 'blur(4px)' }}
      whileInView={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
      viewport={{ once: true, amount: 0.12 }}
      transition={{ 
        duration: shouldReduceMotion ? 0 : 1.2, 
        ease: [0.16, 1, 0.3, 1], // Custom spring-like easing
        delay: shouldReduceMotion ? 0 : delay 
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

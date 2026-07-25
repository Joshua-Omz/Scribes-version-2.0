"use client";
import React from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';
import Link from 'next/link';

interface PrimaryCTAProps {
  href?: string;
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  type?: 'button' | 'submit' | 'reset';
  disabled?: boolean;
}

export function PrimaryCTA({
  href,
  children,
  className,
  onClick,
  type = 'button',
  disabled = false,
}: PrimaryCTAProps) {
  const baseClasses = cn(
    "inline-block font-sans text-[14px] font-medium text-[var(--color-background)] bg-[var(--color-gold-primary)] px-[36px] py-[14px] rounded-[3px] tracking-[0.04em] border-none cursor-pointer transition-colors duration-200 no-underline",
    disabled && "pointer-events-none opacity-70",
    className
  );

  const hoverEffect = { 
    y: -2, 
    scale: 1.02,
    backgroundColor: 'var(--color-gold-muted)',
    boxShadow: '0 8px 30px rgba(201,168,76,0.3)' 
  };

  if (href) {
    return (
      <Link href={href} passHref legacyBehavior>
        <motion.a
          whileHover={hoverEffect}
          whileTap={{ scale: 0.98 }}
          transition={{ duration: 0.3, ease: "easeOut" }}
          className={baseClasses}
          onClick={onClick}
        >
          {children}
        </motion.a>
      </Link>
    );
  }

  return (
    <motion.button
      whileHover={hoverEffect}
      whileTap={{ scale: 0.98 }}
      transition={{ duration: 0.3, ease: "easeOut" }}
      className={baseClasses}
      onClick={onClick}
      type={type}
      disabled={disabled}
    >
      {children}
    </motion.button>
  );
}

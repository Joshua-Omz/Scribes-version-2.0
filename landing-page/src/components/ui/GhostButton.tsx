"use client";
import React from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';
import Link from 'next/link';

interface GhostButtonProps {
  href?: string;
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
}

export function GhostButton({ href, children, className, onClick }: GhostButtonProps) {
  const baseClasses = cn(
    "inline-block font-sans text-[14px] font-normal text-[var(--color-primary-text)] bg-transparent px-[36px] py-[14px] rounded-[3px] border-[0.5px] border-[rgba(242,237,228,0.3)] cursor-pointer tracking-[0.02em] transition-colors duration-200 no-underline backdrop-blur-md",
    className
  );

  const hoverEffect = {
    borderColor: 'var(--color-gold-primary)',
    color: 'var(--color-gold-primary)',
    y: -2,
    scale: 1.02,
    boxShadow: '0 8px 30px rgba(201,168,76,0.15)'
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
    >
      {children}
    </motion.button>
  );
}

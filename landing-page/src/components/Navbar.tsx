"use client";
import React, { useState } from 'react';
import Link from 'next/link';
import { ThemeSwitcher } from './ThemeSwitcher';
import { Menu, X, Home, Eye, LayoutGrid, Layers, Heart, Users, Send } from 'lucide-react';
import { AnimatePresence, motion } from 'framer-motion';

export function Navbar() {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  const desktopLinks = [
    { label: 'Home', href: '/' },
    { label: 'Ecosystem', href: '/ecosystem' },
    { label: 'Guild', href: '/guild' },
    { label: 'Give', href: '/patrons' },
  ];

  const drawerLinks = [
    { label: 'Home', icon: Home, href: '/' },
    { label: 'Vision', icon: Eye, href: '/#paradigm' },
    { label: 'Ecosystem', icon: Users, href: '/ecosystem' },
    { label: 'Pillars', icon: LayoutGrid, href: '/#pillars' },
    { label: 'Guild', icon: Layers, href: '/guild' },
    { label: 'Give', icon: Heart, href: '/patrons' },
    { label: 'Join', icon: Send, href: '/#waitlist' },
  ];

  return (
    <>
      <nav className="fixed top-0 left-0 right-0 z-[100] flex items-center justify-between px-[24px] md:px-[60px] py-[16px] md:py-[20px] border-b-[0.5px] border-[var(--color-border)] bg-[rgba(12,10,8,0.92)] backdrop-blur-[12px]">
        {/* Logo */}
        <Link href="/" className="font-serif text-[22px] font-semibold text-[var(--color-primary-text)] tracking-[0.04em] no-underline flex items-center gap-[10px]">
          <span className="flex items-center gap-[6px] opacity-50">
            <span className="block w-[18px] h-[1px] bg-[var(--color-gold-primary)]" />
          </span>
          Scribes
          <span className="flex items-center gap-[6px] opacity-50">
            <span className="block w-[18px] h-[1px] bg-[var(--color-gold-primary)]" />
          </span>
        </Link>
        
        {/* Desktop Links & Actions */}
        <div className="flex items-center gap-[24px]">
          {/* Desktop Links */}
          <div className="hidden md:flex items-center gap-[24px]">
            {desktopLinks.map((link) => (
              <Link
                key={link.label}
                href={link.href}
                className="font-sans text-[14px] font-medium text-[var(--color-secondary-text)] hover:text-[var(--color-gold-primary)] transition-colors duration-200"
              >
                {link.label}
              </Link>
            ))}
          </div>

          <div className="hidden md:block w-[1px] h-[20px] bg-[var(--color-border)]" />

          {/* Actions (Always visible) */}
          <div className="flex items-center gap-[16px]">
            <ThemeSwitcher />
            <Link 
              href="#waitlist" 
              className="hidden md:flex font-sans text-[13px] font-medium text-[var(--color-background)] bg-[var(--color-gold-primary)] py-[9px] px-[22px] rounded-[3px] no-underline tracking-[0.02em] transition-colors duration-200 hover:bg-[var(--color-gold-muted)]"
            >
              Join the community
            </Link>
            
            {/* Mobile Hamburger */}
            <button 
              className="md:hidden text-[var(--color-primary-text)] hover:text-[var(--color-gold-primary)] transition-colors"
              onClick={() => setIsDrawerOpen(true)}
            >
              <Menu size={24} strokeWidth={1.5} />
            </button>
          </div>
        </div>
      </nav>

      {/* Mobile Drawer Overlay */}
      <AnimatePresence>
        {isDrawerOpen && (
          <React.Fragment>
            {/* Backdrop */}
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-[101] bg-black/60 backdrop-blur-sm md:hidden"
              onClick={() => setIsDrawerOpen(false)}
            />

            {/* Drawer */}
            <motion.div 
              initial={{ x: '100%' }}
              animate={{ x: 0 }}
              exit={{ x: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 z-[102] w-[280px] bg-[rgba(12,10,8,0.95)] backdrop-blur-[24px] border-l-[0.5px] border-[var(--color-border)] shadow-[-8px_0_32px_rgba(0,0,0,0.5)] flex flex-col md:hidden"
            >
              <div className="flex items-center justify-between px-[24px] py-[20px] border-b-[0.5px] border-[var(--color-border)]">
                <span className="font-serif text-[18px] font-semibold text-[var(--color-primary-text)]">
                  Menu
                </span>
                <button 
                  className="text-[var(--color-secondary-text)] hover:text-[var(--color-gold-primary)] transition-colors p-2 -mr-2"
                  onClick={() => setIsDrawerOpen(false)}
                >
                  <X size={24} strokeWidth={1.5} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto py-[24px] px-[16px] flex flex-col gap-[8px]">
                {drawerLinks.map((link) => (
                  <Link
                    key={link.label}
                    href={link.href}
                    onClick={() => setIsDrawerOpen(false)}
                    className="flex items-center gap-[16px] px-[16px] py-[16px] rounded-[8px] text-[var(--color-secondary-text)] hover:bg-[rgba(255,255,255,0.03)] hover:text-[var(--color-gold-primary)] transition-all duration-200"
                  >
                    <link.icon size={20} strokeWidth={1.5} />
                    <span className="font-sans text-[15px] font-medium tracking-[0.02em]">
                      {link.label}
                    </span>
                  </Link>
                ))}
              </div>

              <div className="p-[24px] border-t-[0.5px] border-[var(--color-border)]">
                <Link 
                  href="#waitlist" 
                  onClick={() => setIsDrawerOpen(false)}
                  className="flex justify-center w-full font-sans text-[14px] font-medium text-[var(--color-background)] bg-[var(--color-gold-primary)] py-[14px] rounded-[3px] no-underline tracking-[0.02em] transition-colors duration-200 hover:bg-[var(--color-gold-muted)]"
                >
                  Join the community
                </Link>
              </div>
            </motion.div>
          </React.Fragment>
        )}
      </AnimatePresence>
    </>
  );
}

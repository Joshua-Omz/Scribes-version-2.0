import React from 'react';
import { cn } from '@/lib/utils';

export function OrnamentalDivider({ className }: { className?: string }) {
  return (
    <div className={cn("flex items-center gap-[16px] my-[80px] mx-auto max-w-[320px]", className)}>
      <div className="flex-1 h-[0.5px] bg-gradient-to-r from-transparent via-[var(--color-gold-primary)] to-transparent" />
      <div className="w-[24px] h-[24px] border-[0.5px] border-[var(--color-gold-primary)] rotate-45 opacity-60 shrink-0 relative">
        <div className="absolute inset-[4px] border-[0.5px] border-[var(--color-gold-primary)]" />
      </div>
      <div className="flex-1 h-[0.5px] bg-gradient-to-r from-transparent via-[var(--color-gold-primary)] to-transparent" />
    </div>
  );
}

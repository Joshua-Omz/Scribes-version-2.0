"use client";

import { useTheme } from "next-themes";
import { useEffect, useState } from "react";
import { Moon, Sun, Monitor, Paintbrush } from "lucide-react";

export function ThemeSwitcher() {
  const [mounted, setMounted] = useState(false);
  const { theme, setTheme } = useTheme();

  // useEffect only runs on the client, so now we can safely show the UI
  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    // Return a placeholder of the same size to avoid layout shift
    return <div className="w-[120px] h-[36px] opacity-0" />;
  }

  const cycleTheme = () => {
    if (theme === 'system') setTheme('dark');
    else if (theme === 'dark') setTheme('parchment');
    else if (theme === 'parchment') setTheme('silver');
    else setTheme('system');
  };

  const getIcon = () => {
    switch (theme) {
      case 'system': return <Monitor size={14} />;
      case 'dark': return <Moon size={14} />;
      case 'parchment': return <Sun size={14} />;
      case 'silver': return <Paintbrush size={14} />;
      default: return <Monitor size={14} />;
    }
  };

  const getLabel = () => {
    switch (theme) {
      case 'system': return 'System';
      case 'dark': return 'Night';
      case 'parchment': return 'Parchment';
      case 'silver': return 'Silver';
      default: return 'System';
    }
  };

  return (
    <button
      onClick={cycleTheme}
      className="flex items-center gap-[8px] bg-[rgba(255,255,255,0.03)] hover:bg-[rgba(255,255,255,0.08)] border-[0.5px] border-[rgba(255,255,255,0.05)] hover:border-[var(--color-gold-primary)] transition-all duration-200 px-[14px] py-[8px] rounded-[6px] text-[12px] font-medium text-[var(--color-primary-text)] font-sans"
    >
      {getIcon()}
      <span>{getLabel()}</span>
    </button>
  );
}

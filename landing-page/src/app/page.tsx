import { Navbar } from '@/components/Navbar';
import { Hero } from '@/components/Hero';
import { Ticker } from '@/components/Ticker';
import { Vision } from '@/components/Vision';
import { Mission } from '@/components/Mission';
import { Paradigm } from '@/components/Paradigm';
import { Pillars } from '@/components/Pillars';
import { HowItWorks } from '@/components/HowItWorks';
import { PostPreview } from '@/components/PostPreview';
import { TheInvitation } from '@/components/TheInvitation';
import { Footer } from '@/components/Footer';

export default function Home() {
  return (
    <main className="min-h-screen bg-[var(--color-background)] pb-[100px]">
      <Navbar />
      <Hero />
      <Ticker />
      <Vision />
      <Mission />
      <Paradigm />
      <Pillars />
      <HowItWorks />
      <PostPreview />
      <div id="waitlist">
        <TheInvitation />
      </div>
      <Footer />
    </main>
  );
}

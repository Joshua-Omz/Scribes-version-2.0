import { Navbar } from '@/components/Navbar';
import { TheBuilders } from '@/components/TheBuilders';
import { Footer } from '@/components/Footer';

export default function GuildPage() {
  return (
    <main className="min-h-screen bg-[var(--color-background)] pb-[100px] pt-[80px]">
      <Navbar />
      <TheBuilders />
      <Footer />
    </main>
  );
}

import { Navbar } from '@/components/Navbar';
import { ThePatrons } from '@/components/ThePatrons';
import { Footer } from '@/components/Footer';

export default function PatronsPage() {
  return (
    <main className="min-h-screen bg-[var(--color-background)] pb-[100px] pt-[80px]">
      <Navbar />
      <ThePatrons />
      <Footer />
    </main>
  );
}

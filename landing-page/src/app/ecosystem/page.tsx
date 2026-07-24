import { Navbar } from '@/components/Navbar';
import { TheEcosystem } from '@/components/TheEcosystem';
import { Footer } from '@/components/Footer';

export default function EcosystemPage() {
  return (
    <main className="min-h-screen bg-[var(--color-background)] pb-[100px] pt-[80px]">
      <Navbar />
      <TheEcosystem />
      <Footer />
    </main>
  );
}

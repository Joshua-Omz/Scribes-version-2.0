import React from 'react';
import { Reveal } from './ui/Reveal';

export function PostPreview() {
  const posts = [
    {
      category: 'Theology',
      title: 'On the silence of God and why it is not absence',
      excerpt: 'We mistake quietness for withdrawal. But the shepherd does not speak to the sheep constantly — he leads them. His silence is often the shape of his direction, not the proof of his distance...',
      author: '@samuel.o',
      reactions: ['Amen 14', 'Insightful 8']
    },
    {
      category: 'Prayer',
      title: 'A charge to the one who has stopped praying',
      excerpt: 'You did not stop because prayer failed. You stopped because it cost something and nothing appeared to change. But appearance is not the currency of the Kingdom. Persistence is. Return...',
      author: '@grace.a',
      reactions: ['Amen 31', 'Insightful 12']
    },
    {
      category: 'Hermeneutics',
      title: 'Why "context is king" is insufficient and what replaces it',
      excerpt: 'Context tells you what a passage meant. The Spirit tells you what it means. These are not the same thing, and collapsing them into one is how we produce scholars who know the text but miss the author...',
      author: '@daniel.k',
      reactions: ['Amen 22', 'Thought-Provoking 18']
    }
  ];

  return (
    <div className="relative z-10 px-[24px] md:px-[60px] py-[120px] max-w-[1200px] mx-auto">
      <Reveal>
        <p className="text-[10px] font-medium tracking-[3px] uppercase text-[var(--color-gold-primary)] mb-[20px]">
          From the platform
        </p>
        <h2 className="font-serif text-[clamp(36px,5vw,60px)] font-light leading-[1.1] text-[var(--color-primary-text)] mb-[20px]">
          The kind of writing<br />
          <em className="italic text-[var(--color-gold-primary)]">Scribes carries.</em>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-[24px] mt-[80px]">
          {posts.map((post, idx) => (
            <div 
              key={idx}
              className="group flex flex-col justify-between bg-[rgba(255,255,255,0.02)] backdrop-blur-[24px] border-[0.5px] border-[rgba(255,255,255,0.05)] rounded-[12px] p-[40px] shadow-[0_8px_32px_0_rgba(0,0,0,0.3)] transition-all duration-300 hover:bg-[rgba(255,255,255,0.04)] hover:border-[rgba(201,168,76,0.3)] cursor-pointer"
            >
              <div>
                <p className="text-[10px] font-medium tracking-[2px] uppercase text-[var(--color-gold-primary)] mb-[20px] flex items-center gap-[8px]">
                  <span className="block w-[16px] h-[0.5px] bg-[var(--color-gold-primary)]" />
                  {post.category}
                </p>
                <h3 className="font-serif text-[22px] font-semibold text-[var(--color-primary-text)] leading-[1.25] mb-[16px] group-hover:text-[var(--color-gold-primary)] transition-colors duration-300">
                  {post.title}
                </h3>
                <p className="text-[13px] font-light text-[var(--color-secondary-text)] leading-[1.8] mb-[28px]">
                  {post.excerpt}
                </p>
              </div>
              
              <div className="flex items-center justify-between pt-[20px] border-t-[0.5px] border-[rgba(255,255,255,0.05)] group-hover:border-[rgba(201,168,76,0.3)] transition-colors duration-300">
                <span className="text-[12px] font-normal text-[var(--color-secondary-text)]">
                  {post.author}
                </span>
                <div className="flex gap-[12px] text-[11px] text-[var(--color-secondary-text)]">
                  {post.reactions.map((reaction, i) => (
                    <span key={i}>{reaction}</span>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </Reveal>
    </div>
  );
}

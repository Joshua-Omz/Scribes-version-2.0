---
name: Scribes
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#474740'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#78776f'
  outline-variant: '#c9c7bd'
  surface-tint: '#5f5e58'
  primary: '#5f5e58'
  on-primary: '#ffffff'
  primary-container: '#f5f2ea'
  on-primary-container: '#6f6e68'
  inverse-primary: '#c9c6bf'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e5e2e1'
  on-secondary-container: '#656464'
  tertiary: '#735c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#fff1d2'
  on-tertiary-container: '#866b00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2da'
  primary-fixed-dim: '#c9c6bf'
  on-primary-fixed: '#1c1c17'
  on-primary-fixed-variant: '#474741'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c9c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474646'
  tertiary-fixed: '#ffe088'
  tertiary-fixed-dim: '#e9c349'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#574500'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
typography:
  display-lg:
    fontFamily: EB Garamond
    fontSize: 48px
    fontWeight: '400'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: EB Garamond
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.2'
  headline-md:
    fontFamily: EB Garamond
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.2'
  headline-sm:
    fontFamily: EB Garamond
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: -0.01em
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.0'
    letterSpacing: 0.1em
spacing:
  unit: 8px
  container-max: 1120px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 20px
---

## Brand & Style
The brand personality is **timeless, authoritative, and scholarly**. It is designed to evoke the feeling of opening a significant, leather-bound volume—a vessel for spiritual knowledge that feels both ancient and enduring. The target audience includes seekers, scholars, and practitioners who value depth over speed.

The design style is **Minimalist-Classical**. It relies on symmetrical balance, generous whitespace, and a high-contrast editorial feel. The UI avoids modern trends like vibrant blurs or "squishy" physics, opting instead for a static, architectural permanence. Visual richness is achieved through delicate textures (parchment, ink-bleed) and traditional ornamentation rather than digital effects.

## Colors
The palette is derived from the history of bookmaking. 

- **Primary (#F5F2EA):** A "Deep Parchment" used for the main background surface. It is softer than pure white, reducing eye strain for long-form reading and providing a warm, organic base.
- **Contrast (#0B0B0B):** "Deep Ink." This is used for all body text and primary headlines, ensuring maximum legibility and a sense of permanence.
- **Accent (#D4AF37):** "Burnished Gold." Reserved for significance—interactive elements, icons of enlightenment, fleurons, and key call-to-outs.
- **Neutral (#1A1A1A):** "Charcoal." Used for secondary UI elements, footers, and metadata to provide depth without distracting from the ink-on-paper experience.

## Typography
The typography is the core of this design system. We use **EB Garamond** (a high-quality open-source equivalent to Cormorant) for all significant headings to evoke classical scripture. It should be set with tight tracking in display sizes to appear more like a wordmark.

**Inter** is utilized for functional text, navigation, and dense metadata. By using a clean sans-serif for the "utility" of the platform, we maintain a professional, modern clarity that balances the romanticism of the serif headings. 

Special attention is paid to **body-lg**, which is optimized for deep reading with a generous line height and slightly increased font size. **label-caps** is used for category tags and "chapter" markers to provide a structured, archival feel.

## Layout & Spacing
The layout follows a **Fixed Grid** model on desktop to mimic the centered proportions of a book's printed area. Content is strictly centered to create a sense of balance and focus.

- **Desktop:** 12-column grid within a 1120px container. Large outer margins create "breathing room" reminiscent of a manuscript's wide gutters.
- **Mobile:** Single column with 20px safe areas. The focus remains on vertical scrolling and reading clarity.
- **Spacing Rhythm:** Based on an 8px scale. Use large vertical gaps (64px+) between sections to allow ideas to stand on their own. Avoid dense clusters of information.

## Elevation & Depth
In keeping with the theme of permanence, this system avoids digital shadows. Depth is communicated through **Tonal Layers** and **Keyline Borders**.

- **Surfaces:** All UI sits on the Deep Parchment base. Secondary surfaces (like cards or sidebars) are defined by a 1px solid border in a slightly darker parchment or Charcoal (#1A1A1A at 10% opacity) rather than shadows.
- **Depth:** Elements do not "float" above the page; they are "etched" into it or "placed" upon it. 
- **Dividers:** Use delicate, 1px horizontal lines. For major section breaks, use a centered "Burnished Gold" fleuron or ornamental glyph.

## Shapes
The shape language is **Sharp (0)**. 

Curves are perceived as modern and casual. To maintain a sense of durability and scholarship, all buttons, input fields, and containers utilize 90-degree corners. The only organic curves should come from the letterforms of the typography and the classical ornaments (Byzantine interlace) used as decorative elements.

## Components

- **Buttons:** Rectangular with a 1px border. The primary button is Charcoal with Parchment text. The secondary button is an outline ghost style. High-priority actions may use a Gold bottom-border for emphasis.
- **Cards:** Defined by a 1px Charcoal border (15% opacity). No shadows. Card headers should be centered and use EB Garamond.
- **Inputs:** Simple bottom-border (1px Charcoal). Labels use the `label-caps` style and sit above the field.
- **Chips/Tags:** Small, sharp-edged boxes with a light parchment fill and `label-caps` text. They should look like archival labels.
- **Ornaments:** Symmetrical interlace dividers used to separate chapters or articles. These are always colored in Burnished Gold.
- **Lists:** Unordered lists use a small gold diamond or fleuron instead of a standard bullet point.
- **Reading Progress:** A thin, horizontal gold line at the very top of the viewport that fills as the user scrolls, acting as a "bookmark."

OUTWARD DESIGN PRINCIPLE:

Scribes is built by believers, for believers — 
but its public face is open to everyone.

Public screens (Explore, Post Detail, 
Public Profile, shared post links) must:
- Feel intellectually serious, not religiously 
  exclusive — the tone is closer to a great 
  essay than a church bulletin
- Never assume the reader shares the faith — 
  invite curiosity, do not presuppose it
- Let the quality of the writing do the 
  evangelism — the UI steps back and 
  lets the content speak
- Avoid iconography that signals 
  "Christians only" on entry screens — 
  the cross, the dove, the fish — 
  these are for the content, not the chrome

Private screens (Feed, Notes, Drafts, 
Compose) carry the full manuscript weight — 
this is the inner room for the community.

The strategy: beautiful, serious, 
open-handed public face. 
Rich, reverent private space.
The gospel moves through the writing. 
The design just refuses to get in the way.
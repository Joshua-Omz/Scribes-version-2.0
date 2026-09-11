---
name: app-brand-asset-pipeline
description: >
  Ingests a raw brand logo image, extracts alpha transparency, generates
  multi-density native launcher icons (Android mipmaps, iOS AppIcon, Web
  favicons/PWA icons), creates a centralized BrandLogo design-system widget,
  aligns color palette tokens to the logo, and invalidates build caches.
  Use when the user provides a new logo image and wants it propagated
  across the entire Flutter application.
---

# App Brand Asset Pipeline

## When to Use This Skill

Activate when:
- The user provides a new logo/brand mark image (PNG, JPEG, SVG)
- The user asks to "update the logo", "replace the icon", "rebrand", or "fix the launcher icon"
- The user reports visual artifacts on launcher icons (white boxes on dark wallpapers, pixelated favicons, stale cached icons)

Do NOT use when:
- The user only wants to change color tokens without a new logo image
- The user is working on non-branding UI changes

---

## Foundation: Why This Skill Exists

Replacing a logo in a production Flutter application touches **four distinct architectural sub-systems**:

1. **Vector & Asset Processing** — Alpha keying, SVG path extraction, bounding-box normalization
2. **Design System Tokens** — Brand atoms, palette alignment, widget unification
3. **Native OS Launcher Layers** — Android mipmaps, iOS XCAssets, Web favicons/PWA icons
4. **Build Engine** — Asset manifests, cache invalidation

Skipping any layer creates visual artifacts: white rectangular boxes on dark wallpapers, pixelated favicons, or stale launcher icons retained by platform build caches.

> **Think of it like a corporate identity rollout**: You don't just hand the receptionist a new business card. You update the master vector at head office, replace the outdoor billboard, mint new building badges, print new employee IDs, and stamp digital email signatures. Skip any department and the company looks fragmented.

---

## Step 1: Master Image Ingestion & Alpha Extraction

### Problem
User-uploaded logos are frequently solid-background JPEGs rather than transparent PNGs.

### Procedure
1. **Inspect** dimensions, color profile, and bounding box (PIL/Pillow or equivalent).
2. **Alpha extraction** — Luminance-based alpha thresholding (RGBA) to preserve smooth anti-aliased edges rather than jagged binary cutoffs. Avoid simple `== white` pixel matching; use color-distance thresholding for JPEG compression artifact tolerance.
3. **Normalize** — Crop tightly to the symbol's bounding box and center into a 1024×1024 square master canvas.
4. **Save outputs**:
   - Transparent master raster: `assets/logo/<app>_logo.png` (1024×1024)
   - Clean SVG vector: `assets/logo/<app>_logo.svg` (for zero-artifact in-app rendering)
   - Original untouched: `assets/logo/<app>_logo_original.<ext>` (audit trail)

### Drawbacks
- Automated alpha keying from JPEG works well for high-contrast backgrounds (white/black) but can leave minor fringe artifacts on heavily compressed images.
- **Mitigation**: The SVG vector handles all in-app rendering; keyed raster is only for native launcher thumbnails where SVG isn't supported.

---

## Step 2: Native Multi-Density Launcher Generation

### Target Matrix

| Platform | Target Path | Resolution | Padding / Safe Zone |
|---|---|---|---|
| **Android** | `mipmap-mdpi/ic_launcher.png` | 48 × 48 | 18% safe-zone margin |
| **Android** | `mipmap-hdpi/ic_launcher.png` | 72 × 72 | 18% safe-zone margin |
| **Android** | `mipmap-xhdpi/ic_launcher.png` | 96 × 96 | 18% safe-zone margin |
| **Android** | `mipmap-xxhdpi/ic_launcher.png` | 144 × 144 | 18% safe-zone margin |
| **Android** | `mipmap-xxxhdpi/ic_launcher.png` | 192 × 192 | 18% safe-zone margin |
| **iOS** | `AppIcon.appiconset/AppIcon-1024.png` | 1024 × 1024 | 15% margin (no rounded corners — iOS masks automatically) |
| **Web** | `web/favicon.png` | 32 × 32 | 10% minimal padding |
| **Web** | `web/icons/Icon-192.png` | 192 × 192 | 15% standard padding |
| **Web** | `web/icons/Icon-512.png` | 512 × 512 | 15% standard padding |
| **Web Maskable** | `web/icons/Icon-maskable-192.png` | 192 × 192 | 22% safe-zone for Android PWA |
| **Web Maskable** | `web/icons/Icon-maskable-512.png` | 512 × 512 | 22% safe-zone for Android PWA |

### Tooling Option
If `flutter_launcher_icons` is in `dev_dependencies` (check `pubspec.yaml`), configure it properly and run:
```bash
dart run flutter_launcher_icons
```
Otherwise, generate manually from the 1024×1024 master and place at the correct paths.

### iOS Important Note
Apple HIG mandates: **No alpha transparency** in the App Store icon. The iOS icon must have a solid background fill (use the app's primary background color).

---

## Step 3: Design System & Widget Unification

### The Anti-Pattern (Never Do This)
```dart
// ❌ Scattered across 10 screens
Image.asset('assets/scribes.png', width: 40)  // splash_screen.dart
SvgPicture.asset('assets/logo.svg')           // auth_gate_screen.dart
Image.asset('assets/branding/scribes_mark.png') // drawer.dart
```

### The Correct Pattern
Expose a single design-system atom in `core/widgets/`:

```dart
// lib/core/widgets/scribes_brand_logo.dart

enum BrandLogoVariant { iconOnly, horizontal, stacked }

class ScribesBrandLogo extends ConsumerWidget {
  final BrandLogoVariant variant;
  final double? size;
  
  const ScribesBrandLogo({
    super.key,
    this.variant = BrandLogoVariant.iconOnly,
    this.size,
  });
  
  // ... renders SVG with colorFilter from theme
}
```

**Three canonical variants**:
1. `iconOnly` — Just the emblem for AppBars and list rows
2. `horizontal` — Emblem + Typography lockup for web headers and splash
3. `stacked` — Centered emblem inside branded squircle with optional tagline

### Color Palette Alignment
- Sample dominant hex values directly from the logo image
- Map them to `AppColors` / `ScribesColors` tokens so buttons, badges, and the logo remain visually cohesive
- Document the extracted palette in comments

---

## Step 4: Build Manifest & Config Updates

### Files to Update
1. **`pubspec.yaml`** — Ensure new asset paths are registered under `flutter.assets`
2. **`pubspec.yaml` → `flutter_launcher_icons`** — Update `image_path` to point to new master
3. **`pubspec.yaml` → `flutter_native_splash`** — Update `image` and `image_dark`
4. **`web/manifest.json`** — Verify icon paths, update `background_color` and `theme_color` to match brand
5. **`web/index.html`** — Verify `<link rel="icon">` and `<meta name="theme-color">`

### Cache Invalidation
Always run after branding changes to prevent stale intermediates:
```powershell
flutter clean
flutter pub get
dart run flutter_launcher_icons  # if configured
dart run flutter_native_splash:create  # if configured
flutter test
```

---

## Step 5: Verification Checklist

- [ ] Logo renders correctly on Splash screen (both light and dark themes)
- [ ] Logo renders correctly on Auth Gate screen
- [ ] Top AppBar brand mark displays without distortion
- [ ] Navigation Drawer brand mark is consistent
- [ ] Android launcher icon: no white box artifacts on dark wallpaper
- [ ] Web favicon is sharp at 32×32
- [ ] Web PWA icons render correctly in `manifest.json`
- [ ] All three theme variants (Night, Parchment, Silver) render the logo appropriately
- [ ] No hardcoded `Image.asset('...')` paths remain outside the `ScribesBrandLogo` widget

---

## Ground Truth & Documentation

- **Android**: [Material Design Icon Guidelines](https://m3.material.io/styles/icons/designing-icons) — 48dp baseline grid, adaptive safe-zone boundaries
- **Apple HIG**: [App Icon Specifications](https://developer.apple.com/design/human-interface-guidelines/app-icons) — 1024×1024 square, no alpha for App Store
- **Web PWA**: [W3C Web Application Manifest](https://www.w3.org/TR/appmanifest/) — separate standard and `maskable` icon targets
- **Flutter**: [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) and [flutter_native_splash](https://pub.dev/packages/flutter_native_splash) packages

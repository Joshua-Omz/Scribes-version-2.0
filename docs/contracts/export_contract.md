# Scribes — Post Export Implementation Handoff
**Version 1.0 · Flutter PDF generation, referencing the full design contract**

> The design law is fully specified in `scribes_export_template_design_guide.md`. This document is the execution layer — what package to use, exact file structure, the real async pipeline from tap to shared file, and how to prove it actually works before calling it done.

---

## 1. Scope

This builds **PDF export of a published Post** — standard or Passage type — triggered by an explicit user action (an "Export" button on Post Detail, visible only to the post's author, or on any public post per platform's outward-read philosophy — confirm which with product before building, see Open Question in §7).

Not in scope for this pass: image-format export (PNG/JPEG), link preview cards, or Notes export. Per the earlier scoping decision, only published Posts are exportable.

---

## 2. Packages

```yaml
# pubspec.yaml — add these two, both maintained by the same team (DavBfr)

dependencies:
  pdf: ^3.11.1        # builds the PDF document itself, widget-style API
  printing: ^5.13.3   # handles share sheet, save-to-device, and print preview
```

`pdf` builds the document in memory using a widget tree deliberately similar to Flutter's own (`pw.Widget`, `pw.Text`, `pw.Image`, `pw.MultiPage`, etc — note the `pw.` prefix, distinct from Flutter's own `Widget` classes, since both packages are imported in the same file). `printing` takes the resulting bytes and gets them onto the device or into a share sheet — it does not build the document itself.

---

## 3. File Structure

```
lib/features/export/
├── data/
│   └── export_repository.dart      — fetches all raw bytes needed (images, verses, fonts)
├── domain/
│   └── export_asset_bundle.dart     — the gathered-and-ready data model, see §4
├── application/
│   └── post_export_service.dart     — orchestrates: gather → build → save/share
└── presentation/
    ├── export_button.dart           — the trigger UI, lives on Post Detail
    ├── export_loading_sheet.dart     — "Preparing export…" state while assets fetch
    └── pdf/
        ├── pdf_theme.dart            — fonts + theme-token color mapping, one file, reused everywhere
        ├── pdf_header.dart           — wordmark + hairline, repeats every page
        ├── pdf_footer.dart           — page number / final-page tagline logic
        ├── pdf_title_block.dart      — title, author, scripture chip
        ├── pdf_body_standard.dart    — standard post body rendering
        ├── pdf_body_passage.dart     — passage panel-by-panel rendering
        └── pdf_watermark.dart        — the layered, low-opacity mark
```

Keeping each visual section (`pdf_header.dart`, `pdf_footer.dart`, etc.) in its own file matters here specifically because `scribes_export_template_design_guide.md` treats each section as independently governed law — a reviewer checking compliance against the design doc should be able to open one file per section, not hunt through a single 800-line build method.

---

## 4. The Data Gathering Step (Before Any PDF Code Runs)

```dart
// lib/features/export/domain/export_asset_bundle.dart

class ExportAssetBundle {
  final Post post;
  final Uint8List? coverImageBytes;
  final List<Uint8List>? panelImageBytes;   // only populated for Passage posts, in panel order
  final List<Verse>? scriptureVerses;        // only populated if post.scriptureRef != null
  final Uint8List watermarkBytes;
  final pw.Font cormorantRegular;
  final pw.Font cormorantItalic;
  final pw.Font dmSansRegular;
  final ScribesTheme activeTheme;            // Night | Parchment | Silver — see §5
}
```

```dart
// lib/features/export/data/export_repository.dart

class ExportRepository {
  Future<ExportAssetBundle> gatherAssets(Post post, ScribesTheme theme) async {
    final coverBytes = post.coverImageUrl != null
        ? await _fetchImageBytes(post.coverImageUrl!)
        : null;

    final panelBytes = post.postType == PostType.passage
        ? await Future.wait(
            post.panels
                .where((p) => p.type == PanelType.image)
                .map((p) => _fetchImageBytes(p.imageUrl!)),
          )
        : null;

    final verses = post.scriptureRef != null
        ? await _bibleRepository.getVerseRange(post.scriptureRef!)
        : null;

    final watermark = await rootBundle.load('assets/branding/scribes_mark.png');

    final cormorantRegular = await PdfGoogleFonts.cormorantGaramondRegular();
    final cormorantItalic  = await PdfGoogleFonts.cormorantGaramondItalic();
    final dmSansRegular    = await PdfGoogleFonts.dmSansRegular();

    return ExportAssetBundle(
      post: post,
      coverImageBytes: coverBytes,
      panelImageBytes: panelBytes,
      scriptureVerses: verses,
      watermarkBytes: watermark.buffer.asUint8List(),
      cormorantRegular: cormorantRegular,
      cormorantItalic: cormorantItalic,
      dmSansRegular: dmSansRegular,
      activeTheme: theme,
    );
  }

  Future<Uint8List> _fetchImageBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }
}
```

**This step is entirely network-bound and can take a few seconds** — every image fetches over HTTP, fonts may need to download on first use (Google Fonts fetches on demand unless bundled locally — see §7 Open Question on whether to bundle fonts as assets instead, to keep export working offline). The UI must show a loading state for this stage; never let the export button appear to hang with no feedback.

---

## 5. Theme Mapping — Bridging App Theme to PDF Colors

The design doc requires the export to inherit the user's active in-app theme. `pw.PdfColor` needs literal RGB values, not Flutter `Color` objects, so this mapping has to be explicit:

```dart
// lib/features/export/presentation/pdf/pdf_theme.dart

class PdfThemeTokens {
  final PdfColor background;
  final PdfColor surface;
  final PdfColor primaryText;
  final PdfColor secondaryText;
  final PdfColor gold;
  final PdfColor border;

  static PdfThemeTokens forTheme(ScribesTheme theme) {
    switch (theme) {
      case ScribesTheme.night:
        return PdfThemeTokens(
          background: PdfColor.fromHex('#0A0A0A'),
          surface: PdfColor.fromHex('#111111'),
          primaryText: PdfColor.fromHex('#F0EDE6'),
          secondaryText: PdfColor.fromHex('#A8A29A'),  // confirm exact token from design_brief.md
          gold: PdfColor.fromHex('#C9A84C'),
          border: PdfColor.fromHex('#2A2520'),
        );
      case ScribesTheme.parchment:
        return PdfThemeTokens(
          background: PdfColor.fromHex('#F5F0E8'),
          surface: PdfColor.fromHex('#FDFAF4'),
          primaryText: PdfColor.fromHex('#1A1612'),
          secondaryText: PdfColor.fromHex('#6B6255'),  // confirm exact token
          gold: PdfColor.fromHex('#9A7020'),
          border: PdfColor.fromHex('#DDD5C0'),
        );
      case ScribesTheme.silver:
        return PdfThemeTokens(
          background: PdfColor.fromHex('#F2F2F4'),
          surface: PdfColor.fromHex('#FFFFFF'),
          primaryText: PdfColor.fromHex('#111116'),
          secondaryText: PdfColor.fromHex('#5C5C66'),  // confirm exact token
          gold: PdfColor.fromHex('#B08A2A'),
          border: PdfColor.fromHex('#00000000'),        // Silver theme has no border per design_brief.md
        );
    }
  }
}
```

**Every hex value here must be copy-verified against `scribes_design_brief.md` directly before implementation** — do not trust the values transcribed above as final; they were carried over from the export design guide, which itself pulled from the design brief, and any copy error compounds silently across three documents if not checked at the source once more.

---

## 6. The Watermark — Concrete Layering Implementation

Per the design guide's §5.4 rule (6-8% opacity, centered, spans 60-70% page width, behind text, present on every page):

```dart
// lib/features/export/presentation/pdf/pdf_watermark.dart

pw.Widget buildWatermarkLayer(Uint8List watermarkBytes, PdfThemeTokens tokens, double pageWidth) {
  return pw.Positioned(
    top: 250,
    left: pageWidth * 0.15,   // centers a 70%-width image
    right: pageWidth * 0.15,
    child: pw.Opacity(
      opacity: 0.07,
      child: pw.Image(
        pw.MemoryImage(watermarkBytes),
        fit: pw.BoxFit.contain,
      ),
    ),
  );
}
```

```dart
// lib/features/export/presentation/pdf/pdf_header.dart
// The watermark lives INSIDE the header callback so MultiPage
// repeats it automatically on every generated page without
// manual page-count tracking.

pw.Widget buildHeader(pw.Context context, ExportAssetBundle assets) {
  final tokens = PdfThemeTokens.forTheme(assets.activeTheme);
  return pw.Stack(
    children: [
      buildWatermarkLayer(assets.watermarkBytes, tokens, context.page.pageFormat.width),
      pw.Column(
        children: [
          buildWordmark(assets.cormorantRegular, tokens),
          pw.Divider(color: tokens.border, thickness: 0.5),
        ],
      ),
    ],
  );
}
```

**Placeholder handling per the design doc's §10:** until the real logo asset is supplied, `watermarkBytes` should come from a conditionally empty/transparent fallback, not a substitute mark:

```dart
Future<Uint8List?> _loadWatermarkOrNull() async {
  try {
    final data = await rootBundle.load('assets/branding/scribes_mark.png');
    return data.buffer.asUint8List();
  } catch (_) {
    return null;  // asset not yet supplied — render nothing, per design doc, not a stand-in
  }
}

// Then in buildHeader: only call buildWatermarkLayer(...) if bytes != null
```

---

## 7. Open Questions to Resolve Before Building

These need product decisions, not engineering assumptions — flagging rather than guessing:

1. **Who can trigger export — author only, or anyone viewing a public post?** The design doc and this handoff assume export is a legitimate action on published content, but the actual permission boundary hasn't been stated anywhere. Given Scribes' outward-read philosophy, "anyone can export a public post" is plausible — but that's a product call, not an inferred default.
2. **Font bundling — Google Fonts on-demand fetch, or bundled as local assets?** `PdfGoogleFonts` fetches fonts over network on first use and caches them. If export needs to work with no connectivity (e.g., a user exporting a Passage they downloaded earlier for offline reading), Cormorant Garamond and DM Sans should ship as bundled `.ttf` assets in `assets/fonts/` instead, loaded via `pw.Font.ttf()`. Recommend bundling — it's a small one-time app size cost and removes a network dependency from a feature that's fundamentally about the post *not* needing the app to remain readable.
3. **Print-mode override (Parchment-default per design doc §3) — where does this toggle live in the UI?** Not specified yet; needs a small UI decision (e.g. a toggle in the export loading sheet) before implementation.

---

## 8. Full Pipeline, Tied Together

```dart
// lib/features/export/application/post_export_service.dart

class PostExportService {
  final ExportRepository _repository;

  Future<void> exportPost(Post post, ScribesTheme theme, {bool preview = true}) async {
    // Stage 1 — Gather (network-bound, show loading state around this call)
    final assets = await _repository.gatherAssets(post, theme);

    // Stage 2 — Build (pure in-memory, synchronous once assets are ready)
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => buildHeader(context, assets),
        footer: (context) => buildFooter(context, assets),
        build: (context) => post.postType == PostType.passage
            ? buildPassageBody(assets)
            : buildStandardBody(assets),
      ),
    );

    // Stage 3 — Serialize
    final bytes = await pdf.save();

    // Stage 4 — Hand off to the user
    if (preview) {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } else {
      await Printing.sharePdf(bytes: bytes, filename: '${post.title}.pdf');
    }
  }
}
```

---

## 9. Verification — Not Just "It Compiles and Produces a File"

Given the project's established discipline around not accepting scaffolded-but-unverified work as done:

- [ ] Export a standard post with a cover image — confirm the image actually appears in the output PDF, not just a blank space where it should be
- [ ] Export a Passage post with multiple image panels — confirm every panel appears, in correct order
- [ ] Export a post with a scripture reference — confirm the verse text in the PDF matches a direct `GET /bible/:book/:chapter/:verses` call for the same reference, not just "some text appeared"
- [ ] Export a post long enough to span 3+ pages — confirm header, footer (page number), and watermark all repeat correctly on every page, and the full tagline footer appears only on the final page
- [ ] Confirm no paragraph is cut mid-word at a page break (widow/orphan handling)
- [ ] Open the exported PDF in a completely separate app (not the one that generated it) — confirms fonts are actually embedded, not just referenced, per the design doc's PDF format note
- [ ] Test with each of the three themes — confirm colors match the hex values in `scribes_design_brief.md` exactly, not an approximation
- [ ] Confirm the watermark is present, positioned correctly, and at genuinely low opacity — not accidentally at full opacity or missing entirely
- [ ] Test with airplane mode on, assuming fonts are bundled per the §7 recommendation — confirm export still succeeds with no network

---

*Scribes Post Export Implementation Handoff v1.0*
*Full design law: scribes_export_template_design_guide.md — this document is the execution and verification layer*
*Uses `pdf` + `printing` packages · Document built in code, not screenshotted · Three open product questions flagged in §7*
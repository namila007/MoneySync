# MoneySync — Design System Specification

> Source of truth: `app-design/_ds/modernist-84a8c775-3534-43dc-a99f-d41df6500cd8/styles.css`
> Prototype: `app-design/MoneySync.dc.html`

## Design language

**Modernist-brutalist.** Sharp corners, warm neutrals, bold typography, high contrast. The aesthetic rejects rounded Material defaults in favor of editorial precision — like a financial newspaper meets a Swiss design grid.

Key attributes:
- **Zero border radius** everywhere — cards, buttons, inputs, tags, dialogs
- **Warm neutral palette** — not cool gray, not pure white; earth-toned surfaces
- **Red-orange accent** (#ec3013) — energetic, urgent, distinctive for a finance app
- **Archivo typeface** — geometric sans-serif, extra-bold headings (800), clean body (400)
- **2px solid borders** — visible structure, not subtle shadows
- **Uppercase micro-labels** — 10-11px, letter-spacing 0.06-0.1em, for metadata

---

## Color tokens

### Base

| Token | Hex | Usage |
|-------|-----|-------|
| `--color-bg` | `#f3f2f2` | Scaffold background |
| `--color-surface` | `#eae9e9` | Cards, elevated surfaces |
| `--color-text` | `#201e1d` | Primary text, icons |
| `--color-accent` | `#ec3013` | Primary actions, links, active states |
| `--color-accent-2` | `#e15b47` | Secondary accent (rare) |
| `--color-divider` | `color-mix(in srgb, #201e1d 40%, transparent)` | Borders, rules |

### Neutral ramp (OKLCH-aligned lightness)

| Token | Hex | Usage |
|-------|-----|-------|
| `--color-neutral-100` | `#f8f4f4` | Tag backgrounds, subtle fills |
| `--color-neutral-200` | `#eae7e7` | Sender avatar backgrounds |
| `--color-neutral-300` | `#d7d3d3` | Outer page background |
| `--color-neutral-400` | `#bab6b6` | Disabled states |
| `--color-neutral-500` | `#9b9797` | Placeholder text |
| `--color-neutral-600` | `#7d7979` | Muted text, metadata |
| `--color-neutral-700` | `#605d5d` | Secondary text |
| `--color-neutral-800` | `#444141` | Tag text |
| `--color-neutral-900` | `#2d2b2b` | Shadow color, dialog backdrop |

### Accent ramp

| Token | Hex | Usage |
|-------|-----|-------|
| `--color-accent-100` | `#fff2ef` | Accent tint backgrounds (info cards) |
| `--color-accent-200` | `#ffe0d9` | Hover states on accent elements |
| `--color-accent-300` | `#ffc4b8` | — |
| `--color-accent-400` | `#ff9783` | — |
| `--color-accent-500` | `#ff563c` | — |
| `--color-accent-600` | `#dd2b0f` | Button hover |
| `--color-accent-700` | `#ae1800` | Button active, amount text |
| `--color-accent-800` | `#7c1405` | Tag text on accent-100 bg |
| `--color-accent-900` | `#4d170e` | — |

### Semantic colors (derived, not in prototype but required)

| Semantic | Light | Dark | Usage |
|----------|-------|------|-------|
| Success | `#1a7a3a` | `#4ade80` | Confirmed creation, connected status |
| Warning | `#b45309` | `#fbbf24` | Review needed, retry pending |
| Error | `#ae1800` (accent-700) | `#ff563c` (accent-500) | Failed mutations, destructive actions |
| Info | `#005a9c` (legacy seed) | `#60a5fa` | Informational banners |

---

## Typography

### Typeface

**Archivo** (Google Fonts) — loaded at weights 400, 600, 800.

```dart
// Flutter font asset declaration (pubspec.yaml)
fonts:
  - family: Archivo
    fonts:
      - asset: fonts/Archivo-Regular.ttf
        weight: 400
      - asset: fonts/Archivo-SemiBold.ttf
        weight: 600
      - asset: fonts/Archivo-ExtraBold.ttf
        weight: 800
```

### Type scale

| Role | Size | Weight | Letter-spacing | Line-height | Usage |
|------|------|--------|----------------|-------------|-------|
| Display | 42px | 800 | -0.015em | 1.12 | Hero numbers (dashboard counts) |
| H1 | 42px | 800 | -0.015em | 1.12 | Page titles |
| H2 | 32px | 800 | -0.015em | 1.12 | Section headers |
| H3 | 25px | 800 | -0.015em | 1.12 | Card titles (large) |
| H4 | 20px | 800 | -0.015em | 1.12 | Dialog titles, sub-sections |
| H5 | 16px | 800 | -0.015em | 1.12 | Card titles, nav brand |
| H6 | 13px | 800 | 0.08em | 1.12 | Section labels (UPPERCASE) |
| Body | 15px | 400 | normal | 1.55 | Default body text |
| Body small | 13px | 400 | normal | 1.55 | Card body, descriptions |
| Body xs | 12px | 400 | normal | 1.55 | Metadata, timestamps |
| Label | 14px | 800 | normal | 1.2 | Buttons, inputs |
| Micro | 11px | 400 | 0.06-0.1em | 1.4 | Tags, kickers, uppercase metadata |
| Amount | 26px | 800 | -0.015em | 1.12 | Dashboard summary amounts |
| Count | 20px | 800 | -0.015em | 1.12 | Status grid counts |

---

## Spacing

4px base grid. All spacing is a multiple of 4.

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Tight gaps (icon to text) |
| `space-2` | 8px | Card internal gaps, button padding vertical |
| `space-3` | 12px | Card padding, standard gaps |
| `space-4` | 16px | Section margins, page horizontal padding |
| `space-6` | 24px | Section separation |
| `space-8` | 32px | Large section breaks |

**Touch targets:** 48px minimum (Android requirement). Buttons use 36px visual height but hit area extends to 48px.

---

## Elevation / Borders

**No rounded corners.** All border-radius values are 0px.

**Borders are the primary separator**, not shadows:

| Element | Border |
|---------|--------|
| Cards | 1px solid `--color-divider` (no fill change needed) |
| Active card / selected | 2px solid `--color-accent` |
| Top/bottom app bar | 2px solid `--color-divider` |
| Input fields | 1px solid `--color-divider`, focus: 1px solid `--color-accent` |
| Dividers / rules | 2px solid `--color-divider` |

**Shadows** (used sparingly, only for FAB and dialogs):

| Token | Value | Usage |
|-------|-------|-------|
| `shadow-sm` | `0 1px 2px rgba(45,43,43,0.14)` | Subtle lift |
| `shadow-md` | `0 3px 10px rgba(45,43,43,0.16)` | FAB |
| `shadow-lg` | `0 12px 32px rgba(45,43,43,0.22)` | Dialogs, modals |

---

## Component specifications

### Buttons

| Variant | Background | Text | Border | Height |
|---------|-----------|------|--------|--------|
| Primary | `--color-accent` | `--color-bg` | none | 36px |
| Secondary | transparent | `--color-text` | 1px solid `--color-divider` | 36px |
| Ghost | transparent | `--color-accent` | none | 36px |
| Icon | transparent | inherited | none | 36x36px |
| Block | (full width) | — | — | 36px, margin-top 8px |

All buttons: Archivo 800, 14px, padding 8px 14.4px, 0px radius.
Disabled: opacity 0.45.

### Cards

- Background: `--color-surface`
- Padding: 12px
- Gap between children: 8px
- Border: none (surface color distinguishes from bg)
- Border-radius: 0px
- Optional: 1px border for definition in dense layouts

### Input fields

- Background: `--color-surface`
- Border: 1px solid `--color-divider`
- Border-radius: 0px
- Height: 36px min
- Font: 14px, inherit family
- Caret: `--color-accent`
- Focus: border-color `--color-accent`, no outline
- Label: 12px, 70% text opacity, 5px bottom margin

### Tags / Chips

| Variant | Background | Text | Border |
|---------|-----------|------|--------|
| Accent | `--color-accent-100` | `--color-accent-800` | none |
| Neutral | `--color-neutral-100` | `--color-neutral-800` | none |
| Outline | transparent | `--color-accent` | 1px solid `--color-accent` |

All tags: 11px, 0.02em letter-spacing, padding 3px 10px, 0px radius.

### Segmented control

- Container: 1px solid `--color-divider`, 0px radius, overflow hidden
- Option: padding 7px 12px, 13px font
- Selected: background `--color-accent`, text `--color-bg`
- Separator: 1px solid `--color-divider` between options

### Dialog

- Background: `--color-surface`
- Padding: 16px
- Border-radius: 0px
- Shadow: `--shadow-lg`
- Title: Archivo 800, 20px
- Body: 14px, 85% opacity
- Actions: flex-end, 8px gap

### Bottom navigation bar

- Border-top: 2px solid `--color-divider`
- Background: `--color-bg`
- Item: flex column, 9px vertical padding, 11px font, icon 20x20
- Active: `--color-accent` text/icon
- Inactive: `--color-neutral-600` text/icon

---

## Dark theme mapping

Dark theme inverts the warm neutral ramp and adjusts accent for contrast:

| Token | Light | Dark |
|-------|-------|------|
| bg | `#f3f2f2` | `#1a1918` |
| surface | `#eae9e9` | `#252423` |
| text | `#201e1d` | `#edebea` |
| divider | 40% text mix | 30% text mix |
| accent | `#ec3013` | `#ff563c` (accent-500) |

---

## Migration notes

### Current state (Material 3 defaults)

- Seed color: `#005A9C` (trust blue) → **replaced by** `#ec3013` (red-orange)
- Border radius: Material 3 defaults (4-12px) → **replaced by** 0px everywhere
- Font: system default → **replaced by** Archivo 400/600/800
- Elevation: Material shadow system → **replaced by** border-first + selective shadows
- Typography: M3 default scale → **replaced by** custom Archivo scale with uppercase H6

### Hardcoded colors to replace

| File | Current | Target |
|------|---------|--------|
| `data_control_page.dart` | `Colors.orange` | `colorScheme.error` or warning token |
| `security_privacy_page.dart` | `Colors.green` | success semantic token |
| `wallet_connection_page.dart` | `Colors.amber`/`Colors.green` | warning/success semantic tokens |

### Theme extension required

Create `AppThemeExtension` (or `MoneySyncTheme`) with:
- Semantic color tokens (success, warning, error, info)
- Spacing constants (space1..space8)
- Typography presets (display, h1..h6, body, micro, amount)
- Border radii (all zero, but explicit for clarity)

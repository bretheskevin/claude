---
name: install-shadcn-theme
description: Use when the user provides a tweakcn.com or similar URL to install a shadcn/ui theme. Triggers on theme installation requests with a link.
---

# Install shadcn/ui Theme from URL

## Overview

Fetch a shadcn/ui theme from a provided URL (e.g. tweakcn.com), extract all CSS variables, apply them to `globals.css`, update font imports in the layout, and **verify every required variable is present** in both light and dark modes.

## Process

### 1. Fetch the theme

Use the `WebFetch` tool directly (NOT a subagent) to fetch the theme URL. Subagents have been observed returning default shadcn values instead of the actual theme data.

**Fetch twice** — once for the main color variables, once specifically for sidebar/muted/popover/font/shadow variables. tweakcn pages often don't render all variables in a single fetch.

**First fetch prompt:** "Extract ALL CSS variables from this theme. I need the exact :root and .dark blocks with every variable including --background, --foreground, --primary, --card, --popover, --secondary, --muted, --accent, --destructive, --border, --input, --ring, --chart-1 through --chart-5. Return exact values."

**Second fetch prompt:** "I need these specific CSS variables: --popover, --popover-foreground, --muted, --muted-foreground, --sidebar, --sidebar-foreground, --sidebar-primary, --sidebar-primary-foreground, --sidebar-accent, --sidebar-accent-foreground, --sidebar-border, --sidebar-ring, --font-sans, --font-serif, --font-mono, --radius, --spacing, --shadow-color, --shadow-opacity, --shadow-blur, --shadow-spread, --shadow-offset-x, --shadow-offset-y. Return exact values for BOTH :root and .dark."

**CRITICAL: Validate the fetched data.** The theme page shows a theme name — verify the `--primary` value is NOT `oklch(0.205 0 0)` (that's the shadcn default neutral, meaning the fetch failed to extract the actual theme). If the primary looks like a plain grayscale value with chroma 0, the fetch returned defaults — retry or fetch manually.

Extract:
- `:root` (light mode) variables
- `.dark` variables
- Shared variables (fonts, spacing, shadows)

### 2. Find the current theme files

Locate in the project:
- The main CSS file with shadcn theme variables (typically `globals.css` or `app.css` containing `:root` and `.dark` selectors)
- The layout file with font imports (typically `layout.tsx` with `next/font/google` imports)

### 3. Apply the theme

Replace the CSS variables in `:root` and `.dark` blocks with the new theme values. Update:
- All color variables
- Border radius (`--radius`)
- Shadow variables
- Font stack variables (`--font-sans`, `--font-serif`, `--font-mono`)
- Spacing and tracking variables

Update the layout font imports to match the new `--font-sans`, `--font-serif`, and `--font-mono` values. Use `next/font/google` for Google Fonts. Add font weight arrays for variable fonts that require them (e.g. Space_Mono, PT_Serif need explicit `weight: ["400", "700"]`).

Add ALL font CSS variables to the `<html>` className (e.g. `${fontSans.variable} ${fontMono.variable} ${fontSerif.variable}`).

### 4. MANDATORY: Verify every variable

After applying, **you MUST verify** that both `:root` and `.dark` contain ALL of the following required variables. Missing any variable is a blocking error — do not consider the task complete until all are present.

#### Required Color Variables (must exist in BOTH `:root` AND `.dark`)

| Variable | Purpose |
|----------|---------|
| `--background` | Page background |
| `--foreground` | Default text color |
| `--card` | Card background |
| `--card-foreground` | Card text |
| `--popover` | Popover background |
| `--popover-foreground` | Popover text |
| `--primary` | Primary brand color |
| `--primary-foreground` | Text on primary |
| `--secondary` | Secondary color |
| `--secondary-foreground` | Text on secondary |
| `--muted` | Muted backgrounds |
| `--muted-foreground` | Muted text |
| `--accent` | Accent color |
| `--accent-foreground` | Text on accent |
| `--destructive` | Destructive/error color |
| `--destructive-foreground` | Text on destructive |
| `--border` | Default border color |
| `--input` | Input border color |
| `--ring` | Focus ring color |

#### Required Chart Variables (must exist in BOTH `:root` AND `.dark`)

| Variable |
|----------|
| `--chart-1` |
| `--chart-2` |
| `--chart-3` |
| `--chart-4` |
| `--chart-5` |

#### Required Sidebar Variables (must exist in BOTH `:root` AND `.dark`)

| Variable |
|----------|
| `--sidebar` |
| `--sidebar-foreground` |
| `--sidebar-primary` |
| `--sidebar-primary-foreground` |
| `--sidebar-accent` |
| `--sidebar-accent-foreground` |
| `--sidebar-border` |
| `--sidebar-ring` |

#### Required Layout Variables (must exist in at least `:root`)

| Variable |
|----------|
| `--radius` |
| `--font-sans` |
| `--font-mono` |
| `--font-serif` |
| `--spacing` |

#### Required Shadow Variables (must exist in at least `:root`)

| Variable |
|----------|
| `--shadow-2xs` |
| `--shadow-xs` |
| `--shadow-sm` |
| `--shadow` |
| `--shadow-md` |
| `--shadow-lg` |
| `--shadow-xl` |
| `--shadow-2xl` |

### Verification method

After editing, grep the CSS file for each variable name. Report a checklist:

```
Light mode (:root):
  [x] --background  [x] --foreground  [x] --card  ...
  [x] --chart-1 ... [x] --chart-5
  [x] --sidebar ... [x] --sidebar-ring
  [x] --radius  [x] --font-sans  [x] --font-mono  [x] --font-serif
  [x] --shadow-2xs ... [x] --shadow-2xl

Dark mode (.dark):
  [x] --background  [x] --foreground  [x] --card  ...
  [x] --chart-1 ... [x] --chart-5
  [x] --sidebar ... [x] --sidebar-ring
```

If ANY variable is missing, add it with a sensible default derived from the theme's color palette or from the previous theme.

### 5. Preserve non-theme CSS

Do NOT modify:
- The `@import` statements at the top
- The `@custom-variant` declaration
- The `@theme inline` block (Tailwind v4 theme mapping)
- The `@layer base` block

## Common Mistakes

- **Subagent returns default theme instead of actual theme** — the #1 failure mode. Always use `WebFetch` directly. If `--primary` is `oklch(0.205 0 0)` (neutral black), the fetch failed. Retry.
- **Single fetch misses variables** — tweakcn pages don't always render all variables in one fetch. Always do two fetches: one for colors, one for sidebar/font/shadow.
- **Forgetting `--font-serif`** — many themes include it, many layouts don't wire it up. Always add it.
- **Missing font weights** — some Google Fonts (Space_Mono, PT_Serif) require explicit `weight` arrays in `next/font/google`.
- **Not checking dark sidebar vars** — some themes use oklch defaults for dark sidebar. Keep them as-is if that's what the theme provides.
- **Editing `@theme inline`** — this block just maps CSS vars to Tailwind. It doesn't need to change when swapping themes.

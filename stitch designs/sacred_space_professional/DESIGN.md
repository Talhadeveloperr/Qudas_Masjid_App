---
name: Sacred Space Professional
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#3f4941'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#6f7a71'
  outline-variant: '#bec9bf'
  surface-tint: '#086c41'
  primary: '#004e2d'
  on-primary: '#ffffff'
  primary-container: '#00693e'
  on-primary-container: '#8fe6af'
  inverse-primary: '#82d8a3'
  secondary: '#735c00'
  on-secondary: '#ffffff'
  secondary-container: '#fed65b'
  on-secondary-container: '#745c00'
  tertiary: '#294759'
  on-tertiary: '#ffffff'
  tertiary-container: '#415f71'
  on-tertiary-container: '#b9d8ed'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#9ef5be'
  primary-fixed-dim: '#82d8a3'
  on-primary-fixed: '#002110'
  on-primary-fixed-variant: '#00522f'
  secondary-fixed: '#ffe088'
  secondary-fixed-dim: '#e9c349'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#574500'
  tertiary-fixed: '#c8e7fd'
  tertiary-fixed-dim: '#accbe0'
  on-tertiary-fixed: '#001e2d'
  on-tertiary-fixed-variant: '#2c4a5c'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -1px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.5px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  margin-mobile: 16px
  margin-tablet: 32px
  gutter: 16px
---

## Brand & Style

The design system is engineered for a premium Masjid Management experience, blending traditional reverence with high-end SaaS utility. It targets administrators and congregants who require a tool that feels authoritative yet welcoming. 

The visual style is **Corporate / Modern** with subtle **Glassmorphic** influences. It prioritizes clarity and serenity through generous whitespace, high-quality typography, and sophisticated elevation. The emotional response should be one of peace, reliability, and precision. Every interaction must feel intentional and grounded, reflecting the importance of the communal and spiritual tasks the app facilitates.

## Colors

The color system utilizes a primary dark green to anchor the identity in tradition, paired with a gold accent for "Sacred Highlights" (Prayer times, Jummah announcements). 

Four distinct palettes are supported:
- **Green (Default):** Deep forest primary with gold highlights on a pristine white surface.
- **White:** A high-clarity slate and gray palette for maximum legibility in outdoor light.
- **Black:** A true pitch-black background (#000000) for OLED efficiency, utilizing neon green or gold for critical status indicators.
- **Blue:** A professional navy core with cyan accents for a more technical, administrative feel.

Functional colors (Success, Error, Warning) should follow standard semantic patterns but use slightly desaturated tones to maintain the premium aesthetic.

## Typography

The typography strategy uses **Plus Jakarta Sans** for headlines to provide a modern, friendly, and geometric feel that remains professional. **Inter** is used for all body text to ensure maximum readability in data-dense views like donation logs or prayer schedules. **JetBrains Mono** is selectively used for time-based data (Iqamah times) and administrative IDs to provide a precise, technical edge.

Scale adjustments for mobile focus on reducing the `display` and `headline-lg` sizes to prevent awkward line breaks while maintaining the established hierarchy.

## Layout & Spacing

This design system uses an **8px linear scale** for all spatial relationships. On mobile, a **4-column fluid grid** is used with 16px side margins. On tablets, the grid expands to **8 columns** with 32px margins.

Spacing is used to create "visual grouping" without the need for heavy lines. Use `md` (16px) for padding inside containers and `lg` (24px) for vertical section separation. Large components (like the Prayer Time card) should utilize `xl` (32px) bottom margins to ensure they stand out as primary focal points.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Ambient Shadows**. 

1. **Surface (Level 0):** The base background color.
2. **Surface Container (Level 1):** Subtle 2-4dp elevation or a slightly tinted background color for cards.
3. **Elevated (Level 2):** Primary interactive elements (Active Prayer Time, Featured Events). Use a soft shadow: `Y: 4, Blur: 12, Color: Primary/10% Opacity`.
4. **Overlay (Level 3):** Dialogs and Bottom Sheets. These should use a backdrop blur (10px) to maintain context with the layer below.

Avoid harsh black shadows; always tint shadows with the primary color to maintain a premium, cohesive look.

## Shapes

The shape language is defined by a **high-radius, friendly geometry**. 
- **Standard Containers:** 16px (`rounded-lg`) for all main cards and modules.
- **Buttons:** 12px for standard buttons; full pill-shape for chips and tags.
- **Input Fields:** 12px to match button language.
- **Top Sheets/Bottom Sheets:** 24px top-corner radius to emphasize the "soft drawer" feel.

The 16px radius is the "hero" measurement of the design system, creating a modern, app-centric look that contrasts beautifully against the clean typography.

## Components

### Buttons
- **Primary:** Filled with Primary color, 12px radius, Title-Small weight.
- **Secondary/Outline:** 1.5px border in Neutral/20%, no fill.
- **Floating Action Button:** Large 16px radius, Secondary (Gold) color to indicate primary Masjid actions (e.g., Donate, Register).

### Cards (The "Prayer Card")
The central component of the app. 16px radius, level 1 elevation. For the "Active Prayer," use a Primary color background with Gold accents and an internal padding of 24px.

### Input Fields
Filled style with a subtle bottom-stroke only or 12px rounded borders with a light gray fill (#F1F5F9). Labels should always be visible above the field in `label-md`.

### Chips & Tags
Used for categories like "Sisters Only," "Youth," or "Lecture." 32px (Pill) radius, small font size, and light background tints of the primary/secondary colors.

### Lists
Standard list items should have a minimum height of 64px to remain touch-friendly, utilizing a 16px horizontal gutter between leading icons and title text.
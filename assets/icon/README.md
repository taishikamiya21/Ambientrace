# App Icon Assets

Place your app icon files here:

## Required Files

1. **app_icon.png** (1024x1024)
   - Main app icon
   - Used for iOS and Android

2. **app_icon_foreground.png** (1024x1024, optional)
   - Foreground layer for Android adaptive icons
   - Should have transparent background
   - Icon should be centered with safe zone consideration

## Design Guidelines

**Concept:** Ambientrace - "Trace the Atmosphere"

Suggested icon ideas:
- Abstract gradient representing "atmosphere"
- Minimalist circle with dissolving effect
- Simple "A" letterform with blur/fade effect

**Colors:**
- Background: #0A0A0F (near black)
- Accent: Subtle gradient or white

## Generate Icons

After placing the icon files, run:

```bash
dart run flutter_launcher_icons
```

This will generate all required sizes for iOS and Android.

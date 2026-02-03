# Instructions for Claude Code (Phase 3: Polish & Publish)

Phase 2 ("Less is More") is complete. The app is now a focused, minimalist tool.
**The Goal:** Ensure the app works flawlessly on real devices and prepare it for the App Store.

## Context
**Current State:**
- ✅ AI Sketch & Step Count removed.
- ✅ Atmosphere section consolidated.
- ✅ Core features (Gemini, Location, Weather) implemented.

**Problem:**
- ⚠️ Real device testing (iOS) is pending.
- ⚠️ macOS location permissions are flaky.
- ⚠️ No app icon or store assets.

## Task 1: Real Device Verification (Priority High)
**Target:** iOS & Android (Physical Devices)

1.  **Permissions:**
    - Verify Camera, Location, and Microphone (for noise) permission flows.
    - Ensure graceful degradation if permissions are denied.
2.  **Functionality:**
    - Test "Share" (Trace Card generation) on actual hardware.
    - Verify Geocoding works on mobile (even if skipped on macOS).

## Task 2: Store Preparation
**Target:** `ios/Runner/Assets.xcassets`, `android/app/src/main/res`

1.  **App Icon:**
    - Generate and set the App Icon (using the "Ambientrace" logo/concept).
    - Ensure all sizes are present.
2.  **Screenshots:**
    - Capture clean screenshots of:
        - Home (History)
        - Capture (Camera/Animation)
        - Detail (Trace Card)
3.  **Metadata:**
    - Draft Description and Keywords.

## Task 3: UI/UX Polish (Details)
**File:** `lib/screens/`

1.  **Error Feedback:**
    - If API fails (Gemini/Weather), show user-friendly Toasts/Snackbars instead of raw error dumps.
2.  **Visual Tweaks:**
    - Ensure the "Dissolve" animation is smooth on 60fps devices.
    - Check Dark Mode contrast.

## Features to Maintain (Do Not Re-add)
| Feature | Status | Reason |
| :--- | :--- | :--- |
| **AI Sketch** | ❌ **KEEP DELETED** | Contradicts "imagination from data". |
| **Step Count** | ❌ **KEEP HIDDEN** | Not a fitness app. |

## Final Output
The app should be **Release Candidate (RC)** ready. Stable, beautiful, and crash-free.

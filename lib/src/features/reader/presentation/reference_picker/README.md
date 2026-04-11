# Reference Picker Module

This module owns choosing and opening Bible references.

## Files

- `reference_bar.dart`
  - Barrel export used by callers that only need the public picker entry points.
- `chapter_bar.dart`
  - Reader chapter bar with previous/next controls and picker entry.
- `reference_picker_screen.dart`
  - Main book/chapter/verse selection flow.
- `reference_screen.dart`
  - Separate cross-reference listing screen used when opening parser references.

## Editing Rule

Keep reference navigation concerns here instead of mixing them back into the reader view module.

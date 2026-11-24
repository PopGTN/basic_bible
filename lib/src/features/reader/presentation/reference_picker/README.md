# Reference Picker Module

This module owns choosing and opening Bible references.

## Files

- `chapter_bar.dart`
  - Reader chapter bar: a round play button (audio placeholder) beside the previous/next + picker pill.
- `reference_picker_screen.dart`
  - Main book/chapter/verse selection flow.
- `reference_screen.dart`
  - Separate cross-reference listing screen used when opening parser references.

## Editing Rule

Keep reference navigation concerns here instead of mixing them back into the reader view module.

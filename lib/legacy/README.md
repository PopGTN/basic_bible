# Legacy Code

This folder contains older experiment code that is not part of the current Bible app architecture.

Current rule:
- treat `lib/src/` as the real application
- do not build new features on top of files in `lib/legacy/`
- only touch legacy files if you are intentionally migrating or deleting them

The `todo/` code here is preserved for reference, but it is not part of the main product flow.

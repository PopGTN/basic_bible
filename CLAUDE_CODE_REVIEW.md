# Claude Code Review Instructions

Use this prompt when asking Claude Code to review the personal annotations work in this repo.

## Review Prompt
Please review the recent personal annotations changes in this Flutter app with a senior code-review mindset.

Focus on:

- correctness bugs
- reader-behavior regressions
- data-model risks
- Drift migration safety
- provider/state-management problems
- UI flows that will break in real use
- testing gaps that matter to confidence

Important project context:

- Parser footnotes and cross-references are source content, not personal notes.
- Personal annotations are a new separate feature for saved highlights and notes.
- Notes can optionally carry a connected highlight color.
- Each linked note verse must preserve the translation id and translation label that were visible when it was added.
- V1 is whole-verse only; partial-verse support is future work.

Please inspect these areas especially closely:

- reader selection flow in `lib/src/features/reader/presentation/bible_viewer_tab.dart`
- annotation providers/repository/model boundaries under `lib/src/features/annotations/`
- Drift schema and migration logic in `lib/src/services/app_database.dart`
- Notes navigation and open-in-reader flow

Please report:

1. Findings first, ordered by severity.
2. File references with line numbers where possible.
3. Open questions or assumptions second.
4. A brief summary last.

Please do not spend most of the review describing what the code does.
Prioritize risks, regressions, and missing safeguards.

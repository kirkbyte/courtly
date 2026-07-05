# Courtly — court booking app (portfolio / reference project)

Open-source Flutter showcase: pub-workspace monorepo, clean layering,
Riverpod discipline, token-based design system, fake data by design.

## Current status (2026-07-05)

- v1.0 feature-complete: pseudo-login, club catalog with filters, booking
  flow (club → courts → day → slot grid → confirmation), my bookings with
  cancellation, profile (theme, language, notifications, rename, delete
  account). CI (analyze + tests) runs on GitHub Actions; generated code
  (`*.g.dart`, `*.tailor.dart`, l10n) is gitignored and rebuilt by codegen.
- Design source of truth: theme_tailor tokens in
  `packages/core/lib/src/theme/` — change palette/typography there only.
- Known gaps: Inter font not yet bundled (hook: `_fontFamily` in
  `app_text_styles.dart`), README lacks screenshots and a booking-flow GIF.

## Hard rules

- **No code copied from any other project.** This repo must stand alone;
  patterns and practices only, never source.
- Workspace: `apps/client` + `packages/core` (theme, tokens, l10n en/ru,
  shared widgets) + `packages/api` (abstract `*Api` contracts + fake
  implementations with seed data).
- Layers: FakeApi → Repository (+ LocalDatasource for shared_preferences) →
  domain (pure Dart rules) → Riverpod notifiers → UI. Business rules live in
  `domain`, never in notifiers. UI talks to providers only.
- No raw `Color(0xFF…)`, `TextStyle(…)`, or magic paddings — theme_tailor
  tokens (`AppColors` / `AppTextStyles` / `AppSpacing`) only.
- Commits: Conventional Commits; never commit without an explicit user
  request; no Co-Authored-By trailers.
- Public repo, English README, MIT license.

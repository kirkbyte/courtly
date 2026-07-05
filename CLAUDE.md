# Courtly — court booking app (portfolio / reference project)

Open-source Flutter showcase: pub-workspace monorepo, clean layering,
Riverpod discipline, token-based design system, fake data by design.

## Current status (2026-07-05)

- Design approved and written to
  `docs/superpowers/specs/2026-07-04-courtly-design.md` — **read it first**.
- Workspace skeleton scaffolded by the user (root pubspec workspace,
  `apps/client`, `packages/core`, `packages/api`, LICENSE, README,
  .gitignore, .vscode/launch.json). No feature code yet.
- **Next step:** superpowers `writing-plans` skill to turn the spec into an
  implementation plan, then implement it step by step.

## Hard rules

- **No code copied from any other project.** This repo must stand alone;
  patterns and practices only, never source.
- Planned workspace: `apps/client` + `packages/core` (theme, tokens, l10n
  en/ru, shared widgets) + `packages/api` (abstract `*Api` contracts + fake
  implementations with seed data).
- Layers: FakeApi → Repository (+ LocalDatasource for shared_preferences) →
  domain (pure Dart rules) → Riverpod notifiers → UI. Business rules live in
  `domain`, never in notifiers. UI talks to providers only.
- No raw `Color(0xFF…)`, `TextStyle(…)`, or magic paddings — theme_tailor
  tokens (`AppColors` / `AppTextStyles` / `AppSpacing`) only.
- Commits: Conventional Commits; never commit without an explicit user
  request; no Co-Authored-By trailers.
- Public repo, English README, MIT license.

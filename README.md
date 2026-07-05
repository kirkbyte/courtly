# Courtly 🎾

**Русская версия: [README.ru.md](README.ru.md)**

> **Reference / portfolio project.** A tennis & padel court booking app built
> to showcase Flutter architecture practices: a pub-workspace monorepo, strict
> layering, Riverpod discipline, a token-based design system, en/ru
> localization and tests. It is not a production service — all data is fake by
> design, and that is an architectural decision, not a shortcut.

![CI](https://github.com/kirkbyte/courtly/actions/workflows/ci.yml/badge.svg)

## Screenshots

<!-- TODO: light + dark screenshots (catalog, slot grid, bookings) and a
booking-flow GIF — captured from a simulator, stored in docs/media/. -->

## Highlights

- **Pub-workspace monorepo:** `apps/client` + `packages/core` (theme, tokens,
  l10n, shared widgets) + `packages/api` (contracts + fakes).
- **Strict layering** — dependencies point one way only:

  ```
  FakeClubsApi / FakeBookingsApi     packages/api: seed data, 300–800 ms
          │                          simulated latency, flag-triggered errors
          ▼
  *Repository                        depends on abstract *Api; BookingsRepository
          │                          also uses BookingsLocalDatasource
          ▼                          (shared_preferences) so bookings survive
  domain                             restarts. Pure Dart: slot availability,
          │                          grouping by local day, price calculation
          ▼
  Riverpod notifiers                 screen state: loading / data / error
          ▼
  UI                                 talks to providers only
  ```

- **Token-based design system:** theme_tailor `AppColors` / `AppTextStyles` /
  `AppSpacing`; no raw `Color(0xFF…)`, `TextStyle(…)` or magic paddings in UI
  code. Light and dark themes from the same token set (design source:
  `docs/design/tokens.css`).
- **Localization:** English + Russian, switchable at runtime.
- **Three states everywhere:** every list screen renders loading (skeleton),
  error (with retry) and empty states; the fake layer can fail on demand via a
  `shouldFail` flag.
- **Tests:** unit tests for domain rules and repositories, widget tests for
  the catalog, slot grid and bookings screens. GitHub Actions runs
  `flutter analyze` + all three packages' tests.

## Why the data is fake

The app runs for anyone who clones the repo — no API keys, no servers, no
setup. The repository/API split demonstrates dependency inversion: the
repositories depend on abstract `ClubsApi` / `BookingsApi` contracts, and the
fakes are just one implementation.

**To plug in a real REST API:** implement `ClubsApi` and `BookingsApi` with an
HTTP client in `packages/api`, then swap two providers in
`apps/client/lib/app/di.dart`. Nothing else changes — repositories, domain,
notifiers and UI are agnostic to where the data comes from.

## What I would add in production

- Certificate pinning for API traffic.
- Secure token storage (Keychain / Keystore via `flutter_secure_storage`) —
  the current pseudo-session deliberately keeps a display name in
  shared_preferences because there are no secrets to protect.
- Code obfuscation (`--obfuscate --split-debug-info`).
- Crash reporting and analytics.
- Real authentication and a payment flow.

## Getting started

```bash
# from the repo root — resolves the whole workspace
dart pub get

# generated code is not committed — generate it once after cloning
(cd packages/core && flutter gen-l10n && dart run build_runner build --delete-conflicting-outputs)
(cd apps/client && dart run build_runner build --delete-conflicting-outputs)

# run the app
cd apps/client && flutter run

# tests
cd packages/api && dart test
cd packages/core && flutter test
cd apps/client && flutter test
```

Re-run the same codegen commands after changing `@riverpod` /
`@TailorMixin` code or ARB files.

## License

[MIT](LICENSE)

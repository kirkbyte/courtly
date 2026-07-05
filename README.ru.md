# Courtly 🎾

**English version: [README.md](README.md)**

> **Референсный / портфолио-проект.** Приложение для бронирования теннисных и
> падел-кортов, созданное как витрина архитектурных практик Flutter:
> монорепозиторий на pub workspace, строгая слоистость, дисциплина Riverpod,
> дизайн-система на токенах, локализация en/ru и тесты. Это не боевой сервис —
> все данные намеренно фейковые, и это архитектурное решение, а не срезанный
> угол.

![CI](https://github.com/kirkbyte/courtly/actions/workflows/ci.yml/badge.svg)

## Скриншоты

<!-- TODO: скриншоты светлой + тёмной темы (каталог, сетка слотов, брони) и
GIF флоу бронирования — снятые с симулятора, хранятся в docs/media/. -->

## Основное

- **Монорепозиторий на pub workspace:** `apps/client` + `packages/core` (тема,
  токены, локализация, общие виджеты) + `packages/api` (контракты + фейки).
- **Строгая слоистость** — зависимости направлены только в одну сторону:

  ```
  FakeClubsApi / FakeBookingsApi     packages/api: сид-данные, задержка
          │                          300–800 мс, ошибки по флагу
          ▼
  *Repository                        зависит от абстрактного *Api;
          │                          BookingsRepository также использует
          ▼                          BookingsLocalDatasource (shared_preferences),
  domain                             чтобы брони переживали перезапуск.
          │                          Чистый Dart: доступность слотов,
          ▼                          группировка по локальным дням, расчёт цены
  Riverpod-нотифаеры                 состояние экрана: loading / data / error
          ▼
  UI                                 работает только с провайдерами
  ```

- **Дизайн-система на токенах:** theme_tailor `AppColors` / `AppTextStyles` /
  `AppSpacing`; в UI-коде нет сырых `Color(0xFF…)`, `TextStyle(…)` и магических
  отступов. Светлая и тёмная темы из одного набора токенов (источник дизайна:
  `docs/design/tokens.css`).
- **Локализация:** английский + русский, переключается в рантайме.
- **Три состояния везде:** каждый экран-список умеет loading (скелетон),
  error (с retry) и empty; фейковый слой может падать по требованию через флаг
  `shouldFail`.
- **Тесты:** unit-тесты доменных правил и репозиториев, widget-тесты каталога,
  сетки слотов и экрана броней. GitHub Actions запускает `flutter analyze` +
  тесты всех трёх пакетов.

## Почему данные фейковые

Приложение запускается у любого, кто склонировал репозиторий — без API-ключей,
серверов и настройки. Разделение repository/API демонстрирует инверсию
зависимостей: репозитории зависят от абстрактных контрактов `ClubsApi` /
`BookingsApi`, а фейки — лишь одна из реализаций.

**Чтобы подключить настоящий REST API:** реализуйте `ClubsApi` и `BookingsApi`
поверх HTTP-клиента в `packages/api` и подмените два провайдера в
`apps/client/lib/app/di.dart`. Больше ничего не меняется — репозитории, domain,
нотифаеры и UI не знают, откуда приходят данные.

## Что я добавил бы в продакшене

- Certificate pinning для API-трафика.
- Безопасное хранение токенов (Keychain / Keystore через
  `flutter_secure_storage`) — текущая псевдо-сессия сознательно держит
  отображаемое имя в shared_preferences, потому что защищать нечего.
- Обфускацию кода (`--obfuscate --split-debug-info`).
- Крэш-репортинг и аналитику.
- Настоящую аутентификацию и флоу оплаты.

## Как запустить

```bash
# из корня репозитория — резолвит весь workspace
dart pub get

# сгенерированный код не коммитится — после клонирования сгенерируйте его
(cd packages/core && flutter gen-l10n && dart run build_runner build --delete-conflicting-outputs)
(cd apps/client && dart run build_runner build --delete-conflicting-outputs)

# запуск приложения
cd apps/client && flutter run

# тесты
cd packages/api && dart test
cd packages/core && flutter test
cd apps/client && flutter test
```

Те же команды кодогенерации нужно повторять после изменения кода с
`@riverpod` / `@TailorMixin` или ARB-файлов.

## Лицензия

[MIT](LICENSE)

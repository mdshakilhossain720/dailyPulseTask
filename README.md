# DailyPulse

DailyPulse is a Flutter news aggregator that loads top headlines and search results from [NewsAPI.org](https://newsapi.org/). It demonstrates a small production-style codebase: **clean architecture**, **flutter_bloc**, **Dio**, and **go_router**.

## Features

- Browse **top headlines** by country and **category** (general, business, technology, and so on).
- **Search** articles via the `/everything` endpoint (keyword query).
- Open an **article detail** screen with image, description, truncated content, and **Open in browser**.
- **Shimmer** placeholders while loading; **error** and **empty** states with retry actions.

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK compatible with `pubspec.yaml`, currently `^3.11.4`).
- A **free developer API key** from [NewsAPI — register](https://newsapi.org/register).

## Setup

### 1. Install dependencies

```bash
cd dailypulse
flutter pub get
```

### 2. Provide the NewsAPI key

The key is injected at **compile time** using Dart defines (see `lib/core/network/api_endpoints.dart`). It is **not** hardcoded in source files that you commit.

**Option A — JSON file (recommended for local development)**

1. Copy the example file and add your key:

   ```bash
   cp api_keys.json.example api_keys.json
   ```

2. Edit `api_keys.json` and set `NEWS_API_KEY` to your real key.

3. `api_keys.json` is **gitignored**; do not commit it.

4. Run the app:

   ```bash
   flutter run --dart-define-from-file=api_keys.json
   ```

   In **VS Code / Cursor**, use the **dailypulse** launch configuration in `.vscode/launch.json`, which passes the same flag.

**Option B — inline define**

```bash
flutter run --dart-define=NEWS_API_KEY=your_key_here
```

Use the same `--dart-define` or `--dart-define-from-file` flags for release builds, for example:

```bash
flutter build apk --dart-define-from-file=api_keys.json
```

### 3. Run tests

```bash
flutter test
```

## Architecture

The app follows **layered clean architecture** so that UI and business rules do not depend on HTTP or JSON details.

| Layer | Responsibility |
|--------|----------------|
| **Domain** | Entities (`Article`), repository **interfaces**, and **use cases** (`GetTopHeadlinesUseCase`, `SearchNewsUseCase`). No Flutter or Dio imports. |
| **Data** | **Remote data source** (Dio calls to NewsAPI), **DTOs** (`ArticleModel` with `fromJson` / `toEntity`), and **repository implementations** that map failures to a small `Result` type (`Success` / `Failure`). |
| **Presentation** | **Bloc** (`NewsBloc` + events/states), screens, and widgets. The Bloc calls use cases only. |

**Why this shape**

- **Testability:** You can swap the repository or mock the data source without changing the Bloc contract.
- **Stable domain:** `Article` stays independent of API field renames; mapping lives in `ArticleModel`.
- **Explicit errors:** `Result<T>` keeps success and failure paths clear without throwing across layers for expected failures.

**Other choices**

- **flutter_bloc** for predictable event-driven state (headlines, category changes, search, refresh).
- **Dio** with a dedicated **API key interceptor** sending `X-Api-Key` (supported by NewsAPI) so query strings stay free of secrets.
- **go_router** for declarative routes; article details receive an `Article` via `extra`.
- **Shimmer** and **cached network images** for perceived performance and smoother lists.

## Project layout (high level)

```
lib/
├── core/                 # Networking, theme, router, shared utils/widgets
├── features/news/
│   ├── data/             # Models, remote datasource, repository impl
│   ├── domain/           # Entities, repository contract, use cases
│   └── presentation/     # Bloc, screens, feature widgets
└── main.dart             # Composition root (manual dependency wiring)
```

## NewsAPI notes

- Read the [top-headlines](https://newsapi.org/docs/endpoints/top-headlines) and [everything](https://newsapi.org/docs/endpoints/everything) documentation for parameters and limits.
- The **developer (free)** plan may restrict requests from non-localhost origins when used from production mobile builds; for real devices you may need a **paid plan** or a **backend proxy** that holds the key. Emulators and `localhost` development are typical for the free tier.

## License

This sample project is for demonstration. News content is provided by third-party sources via NewsAPI; respect their terms of use.

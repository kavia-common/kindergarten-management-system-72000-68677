# Contributing

- App supports two modes:
  - local: uses SQLite for all features, no backend needed.
  - prod: uses HTTP API (set API_BASE_URL in .env).

- Make sure to update `.env.example` if you add new environment variables.

- When adding services:
  - Add dependencies to pubspec.yaml first.
  - Do not read .env directly; use flutter_dotenv's dotenv.env.
  - Avoid using BuildContext across async gaps.

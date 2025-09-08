# kindergarten_frontend

Kindergarten management mobile app (Flutter) with:
- Administrative Dashboard
- Student and Staff management
- Attendance tracking
- Class schedule management
- Parent-teacher messaging
- Notifications

Style: Modern, minimalistic. Colors:
- Primary: #4CAF50
- Secondary: #FFC107
- Accent: #FF5722

## Run

1) Copy environment example and adjust:
```
cp .env.example .env
# MODE=local uses SQLite
# MODE=prod uses backend API via API_BASE_URL
```

2) Install and run:
```
flutter pub get
flutter run
```

## Architecture

- lib/main.dart: App entry (loads .env, sets theme, providers)
- lib/src/core/app_theme.dart: Theme and color scheme
- lib/src/core/navigation.dart: Bottom tab navigation
- lib/src/models/*: Entity models
- lib/src/services/local_db.dart: SQLite database (development)
- lib/src/services/api_client.dart: HTTP client (production)
- lib/src/services/data_repository.dart: Data abstraction switching between local/API
- lib/src/state/app_state.dart: Global overview stats for dashboard
- lib/src/features/*: Feature screens (CRUD with modal form overlays)
- lib/src/widgets/ui.dart: Reusable UI helpers

## Local development

- Default MODE=local saves data to SQLite at `kindergarten.db`.
- No backend required.

## Production

- Set MODE=prod and provide API_BASE_URL in `.env`.
- Endpoints in api_client.dart are stubs; align them with your backend API.

## Notes

- This app follows strict async context rules: no widget access after awaits beyond state updates.
- Forms are presented with modal bottom sheets (overlays) for CRUD operations.

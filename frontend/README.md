# frontend

Flutter frontend for Social Network.

## Environment configuration

This app uses compile-time variables with `--dart-define-from-file`.

- `APP_ENV`: `dev` or `prod`
- `API_BASE_URL`: backend API base URL
- `START_ROUTE`: optional start route for quick navigation testing

Use the prepared files:

- `env/dev.json`
- `env/prod.example.json`

Create your real production file (not committed):

```bash
cp env/prod.example.json env/prod.json
```

On Windows PowerShell:

```powershell
Copy-Item env/prod.example.json env/prod.json
```

If `API_BASE_URL` is missing, the app falls back to `http://localhost:3001/api`.

## Run commands

Development:

```bash
flutter run --dart-define-from-file=env/dev.json
```

Production-like local run:

```bash
flutter run --release --dart-define-from-file=env/prod.json
```

## Build commands

Android APK (dev):

```bash
flutter build apk --dart-define-from-file=env/dev.json
```

Android APK (prod):

```bash
flutter build apk --release --dart-define-from-file=env/prod.json
```

Web (prod):

```bash
flutter build web --dart-define-from-file=env/prod.json
```

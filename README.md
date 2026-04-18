# elementum_admin

Admin Center for the Elementum project.

## Deployment

The project is configured for automated deployment to GitHub Pages via GitHub Actions.

### Setup GitHub Secrets

To make the production deployment work, you must add the following **Actions Secrets** to your GitHub repository (`Settings -> Secrets and variables -> Actions`):

1. `SUPABASE_URL_PROD`: The URL of your production Supabase project.
2. `SUPABASE_ANON_KEY_PROD`: The Anonymous key of your production Supabase project.

### Local Development

For local development, the app uses the `DEV` configuration by default. You can override these values or provide production values locally using `--dart-define`:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL_PROD=your_url --dart-define=SUPABASE_ANON_KEY_PROD=your_key
```

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

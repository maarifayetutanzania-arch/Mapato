# Mapato Binafsi

Mapato Binafsi is a Flutter personal-finance application for income, expenses, monthly budgets, savings goals, debts, and reports. The app supports English and Kiswahili, Android/iOS, and an optional Firebase Hosting web build. Financial documents are scoped to the Firebase Authentication UID.

## Development Requirements

- Flutter stable 3.47 or newer (Dart 3.10 or newer)
- Node.js 22 and Java 21 for Cloud Functions and Firebase emulators
- Firebase CLI and FlutterFire CLI
- Xcode on macOS to build/run iOS locally. Codespaces is Linux; use the included macOS GitHub Actions job for iOS build validation.

Open this repository in GitHub Codespaces to use `.devcontainer/devcontainer.json`. Its post-create step installs Flutter dependencies, Firebase CLI, FlutterFire CLI, and the Functions dependencies. If the global `flutterfire` executable is not on PATH, run `dart pub global run flutterfire_cli:flutterfire configure`.

## Firebase Project Setup

1. Create a Firebase project in the Firebase Console. Enable Authentication, Cloud Firestore, Realtime Database, App Check, Analytics, and Cloud Functions. Enable the email/password authentication provider because custom-token sign-in creates Firebase Auth users with verified email addresses.
2. Install/login to the CLIs:

	```sh
	npm install -g firebase-tools
	firebase login
	dart pub global activate flutterfire_cli
	```

3. Register Android (`tz.co.mapato.mapato_binafsi`), iOS (`tz.co.mapato.mapatoBinafsi`), and web apps. Generate native platform configuration and a local FlutterFire options file:

	```sh
	PROJECT_ID="your-firebase-project-id"
	flutterfire configure \
	  --project="$PROJECT_ID" \
	  --platforms=android,ios,web \
	  --out=lib/firebase_options.generated.dart
	```

	FlutterFire replaces the unconfigured template with the project's client options. These Firebase client identifiers (including Firebase API keys) are public app configuration, not Admin credentials. Never put a service-account JSON, Admin private key, or Resend API key in Flutter assets or source control.

4. Make a local run-configuration file from `firebase.local.json.example` and set the Firebase values from the Firebase Console / generated options. Keep `firebase.local.json` local; it is ignored by Git. Supply it to Flutter as a Dart define file:

	```sh
	cp firebase.local.json.example firebase.local.json
	flutter run --dart-define-from-file=firebase.local.json
	```

	For a web release, provide the same file to `flutter build web`. `FIREBASE_APPCHECK_RECAPTCHA_KEY` is the public reCAPTCHA v3 site key from App Check. Local debug builds use debug providers instead.

5. Create the project's default Realtime Database instance in the Firebase Console and keep its URL in the local define file. `_authChallenges` is accessible only to the Admin SDK; Realtime Database rules deny every client read/write.

Firebase Auth is the source of truth. Profile and finance data live under `users/{uid}`. The OTP challenge is stored in Realtime Database as a short-lived HMAC verifier, not as a plaintext code or Firestore document. Server-owned transaction aggregates live under `users/{uid}/summaries`; client writes are denied.

## Email OTP Functions

The app's six-digit email OTP uses the `requestEmailCode` and `verifyEmailCode` callable Cloud Functions in `functions/src/index.ts`. Codes expire after 10 minutes; resend requests are limited to 3 per 15-minute window and verification attempts to 5. App Check is enforced on both callables. Email delivery uses Resend and the sender domain must be verified with Resend.

Set secrets through Firebase Secret Manager prompts (do not pipe secrets through logs or commit them):

```sh
firebase functions:secrets:set MAPATO_OTP_HMAC_KEY --project "$PROJECT_ID"
firebase functions:secrets:set RESEND_API_KEY --project "$PROJECT_ID"
```

Generate a strong HMAC key with `openssl rand -hex 32` and enter it directly at the secret prompt. Configure the non-secret verified sender address in `functions/.env.$PROJECT_ID`:

```sh
cp functions/env.example "functions/.env.$PROJECT_ID"
```

Edit that local file to replace `noreply@example.invalid`. It is ignored by Git. Cloud Functions Gen 2 deployment requires the Firebase/Google Cloud Blaze billing plan.

## App Check

In Firebase Console, register each Android/iOS/web app under App Check. Release providers are Play Integrity, App Attest with Device Check fallback, and reCAPTCHA v3 for web. Before enforcing App Check for other Firebase services, register valid production apps/providers in the console.

Debug builds activate debug providers. Run once, copy the generated debug token from the device/browser log, then register that token under the matching app's App Check debug-token settings. For web, an optional local `FIREBASE_APPCHECK_DEBUG_TOKEN` define can supply a registered token. Do not use debug providers/tokens in release builds.

## Local Checks

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
cd functions && npm ci && npm run build
cd ..
```

Run security-rule tests with the Firebase emulators (Java 21 required):

```sh
npx firebase-tools emulators:exec \
  --only firestore,database \
  --project demo-mapato-security \
  "npm --prefix functions run test:rules"
```

The emulator tests check profile/ledger ownership, invalid transaction data, client-denied summaries, and client-denied OTP challenge paths. They do not require production credentials.

## Deployment

Choose a Firebase project and apply it to the CLI:

```sh
firebase use --add
```

Deploy security rules, indexes, and the Realtime Database rules:

```sh
firebase deploy --only firestore:rules,firestore:indexes,database --project "$PROJECT_ID"
```

Build and deploy the Flutter web app (Hosting only):

```sh
flutter build web --release --dart-define-from-file=firebase.local.json
firebase deploy --only hosting --project "$PROJECT_ID"
```

Deploy Cloud Functions (the configured predeploy step runs the TypeScript build):

```sh
firebase deploy --only functions --project "$PROJECT_ID"
```

`firebase deploy --project "$PROJECT_ID"` deploys every resource present in `firebase.json`: Firestore rules/indexes, Realtime Database rules, Functions, and Hosting. It does not build the Flutter web bundle; run `flutter build web` first. Native Android/iOS binaries are built with Flutter/Gradle and Xcode, not Firebase Hosting.

## Codespaces and CI

The Dev Container installs Flutter stable, Dart, Node 22, Java 21, Firebase CLI, and FlutterFire CLI. `.github/workflows/flutter.yml` runs format/analyze/tests, web and Android build checks, Cloud Functions type-checking, and an iOS no-code-sign build on macOS.

## Security and Release Checklist

- Replace the sample privacy/terms/help text with reviewed, organization-specific legal/support content.
- Register App Check providers and debug tokens in the Firebase Console before enabling production enforcement.
- Configure Resend secrets and a verified sender domain; do not place secrets in `.env` files committed to Git.
- Run emulator rule tests and inspect Firebase indexes/rules before deployment.
- Configure Crashlytics symbol uploads and verify Analytics/Crashlytics in each native release build.
- Review `npm audit --prefix functions` and update the lockfile before production releases.
- Test Android and iOS on real devices and verify release App Check, OTP delivery, offline behavior, and account deletion/retention policy.

The current Flutter client uses Firestore's native offline cache on supported platforms. The notification switch currently stores a local preference; push delivery requires an FCM registration/token workflow before it should be presented as an active notification service.

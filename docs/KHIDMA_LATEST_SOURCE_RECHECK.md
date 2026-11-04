# Customer refresh from the latest supplied Khidma source

Reviewed on 27 October 2026 against `F:/Codebases/khidma_plus/khidma_user`.
This report supersedes the branding, version and validation details of the first migration report.

## Applied changes

- Replaced all five Android launcher densities and every referenced iOS launcher
  image with the refreshed source files. Copies are byte identical.
  Removed 18 unassigned old Fixit icon PNGs from the iOS catalog after backing them up.
- Replaced the old KHIDMA wordmark with the original full-colour **K+** PNG in
  splash, login, registration, placeholders and missing-image states. Removed the
  six retired wordmark SVGs. The shared image widget now renders both PNG and SVG
  assets without applying icon tints to the PNG logo.
- Adaptive launchers and Android 12+ splash use the latest original K+ artwork;
  themed launchers and small notification icons use a matching white silhouette.
  Android 12+ dark-mode resources use the same branded splash, and native FCM
  notification accents use `#5465FF`.
- Copied the original Android `notification_sound.mp3` and iOS
  `notification_sound.aiff`, registered the iOS sound in Runner's resources,
  connected the normal notification channel, retained the legacy channel ID and
  notification-click action, and protected the sound from resource shrinking.
  Android preserves an existing installed channel's sound/user preferences.
  Background iOS remote notification sounds also depend on the server payload.
- Release/Profile APNs use `production`, matching the refreshed source. Debug uses
  `development`. Existing Apple sign-in and associated-domain capabilities remain
  available for the new application's features.
- Removed template Xcode version overrides; native versions now follow Flutter's
  build name/number. Prepared version **8.2.0+72**, above the refreshed source's
  **8.1.0+16** and the new customer's previous **8.1.0+71**. Private store build
  history still determines the final upload number.
- Corrected the template's missing local English fallback flag reference and its
  accidental treatment as an HTTP image. Expanded the audit to inspect exact case
  for every declared and literal asset path.
- Added native URL query declarations used by the customer's existing contact,
  map, browser and store-opening code, matching the coverage already present in
  the provider. Without these, `canLaunchUrl` checks could reject installed apps.

## Rechecked and already current

| Item | Result |
| --- | --- |
| App name | Khidma Plus |
| Android ID | `com.services.khadamat` |
| iOS ID / team | `com.khidmaplus` / `KD9Z8QMD3Y` |
| Firebase files | Exact matches to refreshed source, project `khidma-plus-52001` |
| Dart Firebase registration | Matches the actual production package's native registration |
| Release keystore, properties and certificate | Exact matches to refreshed source |
| Maps keys, Google sign-in URLs and store links | Match the app identity in refreshed source |
| Brand / font | `#5465FF` / Outfit, unchanged in refreshed source |
| Splash background, onboarding and provider invitation artwork | Already exact matches |
| Referenced iOS native launch artwork/storyboard | Already exact matches |

## Validation

- Identity/asset audit: **14 groups passed**.
- Native XML/plist/entitlement/storyboard/SVG parsing and Android resource
  compilation passed.
- Widget image-rendering tests: **2 passed**, covering PNG logos, SVG icons,
  original logo colours, image sizes and the bundled fallback flag in light/dark mode.
- Xcode resource parsing confirms the custom sound belongs to Runner's resource
  phase and push environments differ correctly between debug and release/profile.
- Full Flutter analysis: **no issues found**.
- Android debug APK rebuilt successfully. Inspecting the APK confirmed the latest
  logo, icon, background, adaptive artwork and original notification sound are
  packaged, and the merged ID/version and generated Firebase registration agree.
  Artifact: `build/app/outputs/flutter-apk/app-debug.apk`.
  Final SHA-256: `37EC3EDE5E405E0A4B0D5B7C4F091D400DEDBEF5DBFB36C728EFDD793A9D4831`.

Changed pre-refresh assets/configuration are backed up under
`../../.migration/customer-before-refresh`. Source hashes and copy inventory are
under `../../.migration/customer-refreshed-source-inventory.json` and
`../../.migration/customer-refresh-copied-files.json`. The legacy project was read
only. Backend compatibility/data migration, device notification/auth checks and
iOS archive validation remain as described in `KHIDMA_MIGRATION.md`; this source
refresh does not connect incompatible Fixit and eDemand APIs.

# Khidma Plus customer migration

The latest source refresh is documented in [KHIDMA_LATEST_SOURCE_RECHECK.md](KHIDMA_LATEST_SOURCE_RECHECK.md).
It supersedes the original branding, version and validation results below.

Status: branding and native identity migrated; **not ready for production release**.
The new customer app is `eDemand Customer/eDemand`. The provider app and the
legacy source at `F:/Codebases/khidma_plus/khidma_user` were not modified.
A copy of the original customer template is at
`../../.migration/customer-template-original` (build/cache directories excluded).

## Identity carried over

| Setting | Customer value |
| --- | --- |
| Display name | Khidma Plus |
| Android application ID / namespace | `com.services.khadamat` |
| iOS bundle identifier | `com.khidmaplus` |
| Apple development team | `KD9Z8QMD3Y` |
| Firebase project | `khidma-plus-52001` |
| Firebase Android application | `1:526848120057:android:eb5e568c30feed321ebe28` |
| Firebase iOS application | `1:526848120057:ios:c03056bb831585a31ebe28` |
| Brand primary | `#5465FF` |
| Font | Outfit, loaded with Google Fonts as in the old app |
| Android store | `https://play.google.com/store/apps/details?id=com.services.khadamat` |
| Apple store | `https://apps.apple.com/app/id6755617892` |
| Source version prepared | `8.1.0+71` |

The old Dart Firebase options referred to `com.webiots.fixit_user`'s Android
registration. The new Dart options instead match the live application ID's entry
in the original `google-services.json`. Both native Firebase configuration files
are copied unchanged. iOS Google sign-in's client ID and reversed URL scheme are
aligned with the original iOS Firebase plist. The duplicate Firebase plist resource
entry in the template's Xcode project was removed.

## Branding and assets

- All five Android launcher densities and all referenced iOS app icons are exact
  copies of the old files. Launcher regeneration uses the original `app_icon.png`.
- The old splash artwork and visible Khidma Plus name are used in the Flutter
  splash. The old iOS native launch storyboard and launch images are copied.
  Android 12+ has a Khidma splash and an adaptive launcher with the original
  wordmark converted into vector paths.
- All six template branding SVGs are replaced with Khidma wordmark variants or
  Khidma placeholders. These are native vectors, not embedded raster SVG images.
- The three onboarding photos are replaced by the old app's `ob-1.png`,
  `onboarding3.png`, and `postPage.png`; layout contains their transparent artwork
  without cropping. The provider invitation image is also reused from the old app.
- The new template's SVG illustrations and navigation assets use Khidma's primary
  ramp. Payment logos, flags, skin tones, and status colours retain their meaning.
  The maintenance Lottie animation's blue accents also use Khidma's primary;
  success/error animations retain their green/red status colours.
  Design token JSON files and the generated primary ramp are updated together.
  The primary brand ramp stays fixed when panel settings refresh.
- The template declared `pageNotFound.svg` but did not include it. A new Khidma
  404/home-search vector illustration fills that gap. All 126 declared asset
  constants now resolve to existing files/directories.
- The old app used a full-colour launcher as its small notification icon, which
  does not provide a proper monochrome Android notification resource. A new
  white **K+** notification vector is provided at `drawable/ic_stat_khidma.xml`.
  Native FCM and local/chat notifications use it. The existing
  `high_importance_channel` ID is retained to respect users' channel settings.
- Vendor footer attribution, vendor app identifiers, signing team, map-key
  placeholders, and vendor deep-link configuration are replaced in runtime files.

The template's internal Dart package name stays `e_demand`; it is used by imports
and is unrelated to the name or ID shown to users and stores.

## Signing and integrations

The original `android/key.properties`, upload keystore, and upload certificate are
copied locally. They remain excluded from source control by the project ignore
rules. Release builds now use `signingConfigs.release` and fail if the upload
signing setup is missing; they no longer silently use a debug key.

The keystore opened successfully during verification. Its SHA-256 fingerprint is:

```text
86:29:38:A2:38:15:25:E0:F3:AE:AD:64:EF:1F:38:36:B2:00:16:8A:BE:72:27:27:50:B1:BC:C1:0B:1D:CD:3E
```

The existing Maps key was copied to Android and iOS. Native Firebase identity,
OAuth client configuration, early background-handler registration, isolate
Firebase initialization, notification channels, and notification icon
configuration are wired in the source. Actual Google login, phone authentication,
APNs delivery, and Maps quota/key restrictions still need device testing.

The template's global acceptance of invalid TLS certificates is removed. HTTPS
certificate validation applies normally. Android cleartext traffic is disabled.

Ads remain disabled by default (`KHIDMA_ENABLE_ADS=false`), because the old app
has no AdMob identity. The Google sample application IDs remain in native config
solely for the inactive template SDK; do not enable advertising until replacing
both native IDs and configuring genuine ad units in the panel. Clarity remains
inactive because no project ID was present in the old app.

## Required backend decision

The old app uses **Fixit**, at `https://admin.khidmaplus.com/api`. The purchased
app expects **eDemand** endpoints under `/api/v1/`. They are different products,
not interchangeable versions of the same API. For example:

| Capability | Existing Fixit API / storage | eDemand client expects |
| --- | --- | --- |
| Login / profile | `/login`, `/social/login`, `/self` | `/verify_user`, `/manage_user`, `/get_user_info` |
| Settings | `/settings`, `/appearance` | `/get_settings`, `/get_theme_colors` |
| Home / services | `/dashboard/user`, `/service`, `/category` | `/get_home_screen_data`, `/get_all_services`, `/get_categories` |
| Checkout / bookings | `/checkout`, `/booking` | `/place_order`, `/get_all_bookings`, `/get_booking_details` |
| Chat | Firestore and legacy notification/function logic | API chat history, provider lists and message endpoints |
| Payments | Legacy payment-method and verification contracts | eDemand order, payment-intent and payment-status contracts |

Changing the URL alone cannot migrate users or make these contracts compatible.
The compatible eDemand backend and verified migration were subsequently deployed
on 28 October 2026. The default `KHIDMA_BACKEND_ORIGIN` is now
`https://admin.khidmaplus.com`, serving customer requests under `/api/v1/`.
An explicit build-time define can select another environment. Empty or non-HTTPS
origins still fail with a service-unavailable message.

Before connecting production traffic, account for customer IDs, Firebase UIDs,
phone/email uniqueness, password hashes and password reset, addresses, provider
and service IDs, categories, historical bookings and invoices, service packages,
wallet balances and ledger entries, refunds, coupons/referrals, favourites,
reviews, custom requests/bids, chat history/attachments, tax/currency/country
rules, permissions, and notification payload/redirection formats. Availability
and meaning of the old features need explicit mapping to the new backend.

The old app stores its own session/preferences in SharedPreferences; the new app
uses Hive for its session. Legacy bearer tokens are not imported into the new
backend. Existing app data is not cleared. Plan and test reauthentication and
preference migration once the backend strategy is chosen. Reusing a Firebase
project alone does not transfer backend passwords, bookings, balances, or chat.

Payment credentials, merchant configuration, callbacks, SMTP/SMS, legal/support
content, service coverage, remote translations, provider links and remote update
settings are supplied by the backend. They cannot be migrated solely from the
customer client's source. The eDemand customer must also communicate with a
compatible provider application before rollout.

## Deep links and external setup

The known brand-owned host from the old configuration, `admin.khidmaplus.com`,
is used in the native link declarations and the default `KHIDMA_LINK_ORIGIN`.
This is configuration only: these eDemand share routes were not demonstrated to
exist on the live host. The iOS custom scheme is `khidmaplus`.

Configure the final host and its `/provider-details/`, `/service-details/`, and
`/blog-details/` routes, Android `/.well-known/assetlinks.json` using the **Play
app-signing certificate**, and Apple's `/.well-known/apple-app-site-association`
for `KD9Z8QMD3Y.com.khidmaplus`. Keep Dart link origin, Android manifest host and
iOS associated domains synchronized if the final host changes. The private
upload key's certificate may differ from Play's app-signing certificate.

Confirm Firebase Google/phone/Apple auth providers, Android debug and Play signing
fingerprints, iOS APNs key/certificate, Apple sign-in capability, Maps platform
restrictions, and iOS provisioning in the existing project/accounts. Firebase
rules, cloud functions, server secrets, APNs credentials and deployed backend
settings were neither changed nor validated remotely.

## Validation and release gate

Passed locally:

- `node tool/audit_khidma_identity.cjs`: 13 audit groups covering native IDs,
  Firebase registration/OAuth consistency, original signing-file hashes, native
  launcher hashes, source artwork hashes, notification wiring, brand/font/store
  settings, every declared AppAssets path, and source version ordering.
- XML parsing of 133 Android resources, manifests, plists and SVG documents.
- Android native resource compilation with Android SDK 36's `aapt2` succeeded.
- Dart formatter parsed all 463 Dart source files successfully (`--output=none`).
- Keystore password/alias and private-key entry verified without printing secrets.
  The upload certificate's SHA-1 is present in the Android OAuth registration.

Not completed:

- Full dependency resolution, analysis, compilation, tests and device previews.
  Offline resolution failed because `flutter_shader_snap` is not cached; online
  resolution failed reaching `https://pub.dev` (socket/proxy error). Several
  template dependency versions are newer than the installed cache. Dependencies
  were not downgraded merely to make an offline build appear to pass.
- Android device testing, signed upgrade over a store-installed version, login,
  background/terminated notifications, Maps, booking/payment/refund, sharing,
  locale/RTL/dark mode, and data migration testing.
- iOS archive/TestFlight validation. This requires macOS/Xcode and existing Apple
  account provisioning; it cannot be performed in this Windows session.
- Store-console version verification. `8.1.0+71` exceeds the supplied old source
  (`8.0.4+4`) and template (`5.2.0+70`); the real store's highest uploaded version
  must be checked before selecting final build numbers.

After backend compatibility/data migration is established, run from this project:

```powershell
node tool/audit_khidma_identity.cjs
flutter pub get
flutter analyze
flutter build appbundle --release --dart-define=KHIDMA_BACKEND_ORIGIN=https://admin.khidmaplus.com --dart-define=KHIDMA_LINK_ORIGIN=https://admin.khidmaplus.com
```

As of 28 October 2026, the default backend is the live eDemand server at
`https://admin.khidmaplus.com`; customer requests use `/api/v1/`. A build-time
`KHIDMA_BACKEND_ORIGIN` define can still select another environment. Existing
installed/store builds must be replaced with a newly built app to receive this
configuration.
Commit a resolved lockfile once dependency resolution succeeds. On macOS, also
resolve CocoaPods and produce/validate an iOS archive with the same Dart defines.
Use staged store rollout only after the customer/provider/backend combination
has passed upgrade and end-to-end tests. Nothing has been deployed or published.

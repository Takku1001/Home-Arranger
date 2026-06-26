# AR Furniture

An augmented-reality furniture shopping app built with Flutter. Browse a catalogue of
100+ 3D furniture models, preview them at real-world scale in your room using ARCore,
and manage a cart, orders, and an admin dashboard backed by Firebase.

## Tech Stack

- **Framework:** Flutter (Dart `>=3.0`)
- **AR:** `arcore_flutter_plugin`, `vector_math`
- **Backend:** Firebase — Authentication, Cloud Firestore, Storage
- **State:** `InheritedNotifier` (`CartProvider` / `CartNotifier`)
- **Other:** `permission_handler`, `http`, `flutter_cache_manager`, `path_provider`

## Project Structure

```
lib/
  main.dart              App entry, theming, and route table
  firebase_options.dart  Generated Firebase config
  models/                Furniture, cart, and order data models
  providers/             Cart state management
  screens/               Auth, home/store, AR view, product, cart, orders, admin
  widgets/               Reusable UI (furniture card, AR controls, sidebar, chips)
assets/
  models/                3D furniture models (.glb)
  images/                Furniture thumbnails (.png)
test/                    Unit and widget tests
```

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x (Dart 3+)
- Android device/emulator with **ARCore support** for the AR view
- A Firebase project (the included `firebase_options.dart` and
  `android/app/google-services.json` are wired to the demo project; replace them with
  your own via `flutterfire configure` to use a different backend)

## Build & Run

```bash
flutter pub get          # fetch dependencies
flutter test             # run the test suite
flutter run              # launch on a connected device/emulator
flutter build apk        # build a release Android APK
```

## Usage

- **Sign up / log in** through the auth screen (Firebase Auth).
- **Browse** the store, open a product for details, and **view it in AR** to place and
  scale the model in your space.
- **Add to cart**, review quantities and totals, and **place orders** (tracked in
  Firestore).
- **Admin:** open the admin login from the menu. Demo credentials — username `FAR`,
  password `FAR123` — open a dashboard to manage orders.

## Author

Muhammad Rayyan Malik

## License

Released under the [MIT License](LICENSE).

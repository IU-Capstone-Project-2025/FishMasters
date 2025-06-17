# FishMasters Frontend

## Mobile App Build

- Install [Flutter SDK](https://flutter.dev)
- Change directory and check tooling:

        cd mobile_app && flutter doctor

- Resolve dependencies:
  - Android SDK (can be installed with [Android Studio](https://developer.android.com/studio))
  - [XCode](https://developer.apple.com/xcode/) (MacOS only)
- Install required packages:

        flutter pub get

- Build Android Installer:

        flutter build apk --release

- Build iOS Application (MacOS only):

        flutter build ios --release

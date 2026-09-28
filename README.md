# Sacred Songs & Solos (+ Tunes)

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Tablet-brightgreen)](#)
[![License](https://img.shields.io/badge/License-Proprietary-blue)](#)

A modern, beautifully designed Christian hymn book application for Android, iOS, and tablets. **Sacred Songs & Solos** brings together 1,200 beloved hymns with audio tunes, real-time search, personalized reading modes, custom hymn composition, and cloud hymn synchronization.

---

## ✨ Features

### 🎵 1,200 Hymns with Audio Tunes
* Complete collection of 1,200 traditional *Sacred Songs and Solos* hymns.
* Bundled and progressive remote-downloaded MIDI audio tunes with smart caching.
* Dedicated audio playback bar with play, pause, and stop controls.
* Audio player gracefully pauses on phone calls and resets appropriately when switching tabs or closing hymns.

### 🔍 Instant Search & Quick Navigation
* Instant, real-time search across hymn numbers, titles, authors, and full lyrics.
* Sorting options by number (1 to 1200) or alphabetical title order (A to Z).
* Fast smooth-scrolling draggable scrollbar for rapid indexing.

### ⭐ Favorites & Bookmarks
* Instant one-tap bookmarking to save your favorite hymns.
* Dedicated **Favorites** tab with live list updates.
* Favorites are safely preserved during remote updates and app upgrades.

### ✍️ Compose & Manage Custom Hymns
* Add your own custom church or choir songs with dedicated author, tune name, and lyrics fields.
* Edit and delete composed hymns anytime.
* Composed songs appear directly in your hymn list with a distinct badge.

### 🎨 Material 3 Themes & Dark Mode
* Curated theme palette:
  * **Classic**
  * **Nature Green**
  * **Royal Indigo**
  * **Sunset Coral**
  * **Deep Charcoal**
  * **Midnight Slate**
* Seamless **Night Mode / Dark Mode** toggle for low-light worship and church services.

### 📖 Distraction-Free Reading Customization
* **Live Font Sizing:** Choose comfortable text sizes from 14pt up to 36pt.
* **Line Spacing:** Adjust line spacing (1.0 to 2.0) for optimal readability.
* **Color Customization:** Configure reader background and text colors to your preference.
* **Keep Screen Awake (Wakelock):** Prevent the screen from dimming or turning off during choir practice, organ accompaniment, or sermon singing.

### 📱 Responsive Tablet Layout
* Native multi-pane tablet support:
  * Left pane displays the scrollable hymn list and search index.
  * Right pane displays full lyrics and interactive audio playback controls simultaneously.

### 🔄 Cloud Hymn Synchronization
* Check for remote updates to fetch lyric corrections or new additions without needing a new app store release.
* Non-blocking background sync checks that never overwrite local user favorites.

### 📤 Share Hymns
* One-tap sharing of hymn titles and full lyrics via WhatsApp, SMS, email, and social apps.

---

## 🛠️ Architecture & Tech Stack

* **UI Framework:** [Flutter](https://flutter.dev) (Material 3 Design System)
* **Language:** Dart 3
* **Local Database:** SQLite via [`sqflite`](https://pub.dev/packages/sqflite) with unified transactional storage.
* **State Management:** Zero-dependency, lightweight reactive architecture utilizing Flutter's built-in `ChangeNotifier` and `ListenableBuilder`:
  * `HymnsNotifier` — Synchronizes list state and favorites across All, Favorite, and Tablet views.
  * `ReadingSettingsNotifier` — Live reactivity for reader typography, line spacing, and theme colors.
  * `appThemeNotifier` — Reactive app-wide theme mode switching.
* **Audio Engine:** [`audioplayers`](https://pub.dev/packages/audioplayers) supporting local assets and cached remote streams.
* **Navigation & Gestures:** Modern `PopScope` with full Android 13+ Predictive Back gesture support.

---

## 📁 Project Structure

```text
lib/
├── ads/                        # AdMob banners and adaptive ad components
├── model/
│   ├── db_helper.dart          # SQLite database schema, CRUD & migrations
│   ├── globals.dart            # Global state, theme definitions & audio references
│   ├── hymn.dart               # Hymn data model
│   └── hymn_list.dart          # Default embedded seed data
├── service/
│   └── hymn_sync_service.dart  # Cloud sync service for remote updates
├── state/
│   ├── hymns_notifier.dart     # Reactive hymn list & favorite state coordinator
│   └── reading_settings_notifier.dart # Reactive reader settings (font, colors, spacing)
├── util/
│   ├── app_dialog.dart         # Reusable Material 3 dialogs & exit confirmation
│   ├── hymn_details.dart       # Hymn reading screen with audio playback bar
│   ├── hymn_listing.dart       # All hymns list view with search & sort
│   ├── fav_hymn_listing.dart   # Bookmarked favorites list view
│   ├── main_details_screen.dart# Main tabbed view & responsive tablet layout
│   ├── my_drawer.dart          # Navigation drawer & app actions
│   ├── compose_song.dart       # Custom song composer screen
│   ├── added_songs.dart        # Composed songs management screen
│   ├── settings.dart           # Font size, spacing, wakelock & color settings
│   └── ...
└── main.dart                   # Application entry point & service bootstrap
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK: `>= 3.16.0` (Recommended `3.22+` / `3.47+`)
* Dart SDK: `>= 3.0.0`
* Android Studio / VS Code / Antigravity IDE
* Android SDK (API 34+) or Xcode for iOS

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/techoveride/sacred-songs-and-solos.git
   cd sacred-songs-and-solos
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Run automated unit tests:**
   ```bash
   flutter test
   ```

---

## 🤝 Support & Contact

* **Developer Team:** Hymnestry
* **Email:** [hymnestryteam@outlook.com](mailto:hymnestryteam@outlook.com)
* **Website:** [https://hymnestry.techoveride.com/](https://hymnestry.techoveride.com/)

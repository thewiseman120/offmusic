## 🎯 **Prompt: Build a Responsive Offline Music Player App in Flutter (With Random Album Art)**

---

### ✅ **Objective**

Create a beautiful, responsive **offline music player app** using **Flutter**. The app should scan the user's device for local audio files, categorize them like Spotify, and provide a clean and bouncy UI. When a song **does not have embedded album art**, display a **random image from the app’s assets**:
`Album Art (1).jpg`, `Album Art (2).jpg`, ..., `Album Art (6).jpg`.

This image should be **randomly selected at runtime** each time the song is played — **it should not be saved or reused**.

---

## 🧱 Step-by-Step Process

---

### 1️⃣ **Project Setup**

* Use **Flutter 3.x** or newer.
* Add required packages:

  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    permission_handler: ^11.0.0
    just_audio: ^0.9.35
    audio_service: ^0.18.10
    on_audio_query: ^2.6.0
    provider: ^6.1.0
    path_provider: ^2.0.15
  ```
* Enable Android permissions in `AndroidManifest.xml`:

  ```xml
  <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  ```

---

### 2️⃣ **App Theme & UI**

* Use a **light gradient background** (e.g., pastel lavender to light blue) across all screens.
* Add **bouncy transitions and animations** using:

  * `AnimatedSwitcher`
  * `AnimatedContainer`
  * Custom `PageRouteBuilder` transitions
* Use `BottomNavigationBar` for sections:

  * Home
  * Search
  * Playlists
  * Settings

---

### 3️⃣ **Permission & Media Scan**

* On app startup:

  * Ask for storage/media permissions using `permission_handler`.
  * After permission is granted, use **on\_audio\_query** to scan and retrieve:

    * Title, artist, album, duration
    * Embedded album art (via bytes)
    * File URI/path
  * Store this data temporarily in a list (no local DB needed unless for playlists/favorites).

---

### 4️⃣ **Sections (Spotify-Style Layout)**

Organize scanned songs into categories:

* All Songs
* Artists
* Albums
* Genres
* Recently Played
* Favorites

Use tabs or swipeable pages (`TabBarView`) for navigation.

---

### 5️⃣ **Now Playing Screen**

When a user taps a song:

* Navigate to the **Now Playing screen** showing:

  * Song title, artist
  * Album art (see below)
  * Playback controls (play, pause, skip, shuffle, repeat)
  * Seek bar with progress

---

### 6️⃣ **💡 Random Album Art Logic**

* Prepare 6 image files in the `assets/images` folder:

  ```
  assets/images/Album Art (1).jpg
  assets/images/Album Art (2).jpg
  assets/images/Album Art (3).jpg
  assets/images/Album Art (4).jpg
  assets/images/Album Art (5).jpg
  assets/images/Album Art (6).jpg
  ```
* Add to `pubspec.yaml`:

  ```yaml
  assets:
    - assets/images/
  ```
* In the player screen:

  ```dart
  import 'dart:math';

  // List of asset album arts
  final List<String> albumArts = [
    'assets/images/Album Art (1).jpg',
    'assets/images/Album Art (2).jpg',
    'assets/images/Album Art (3).jpg',
    'assets/images/Album Art (4).jpg',
    'assets/images/Album Art (5).jpg',
    'assets/images/Album Art (6).jpg',
  ];

  // Function to get a random image
  String getRandomAlbumArt() {
    final random = Random();
    return albumArts[random.nextInt(albumArts.length)];
  }

  // In widget:
  Widget albumArtWidget(Uint8List? embeddedArtBytes) {
    if (embeddedArtBytes != null) {
      return Image.memory(embeddedArtBytes);
    } else {
      final randomArt = getRandomAlbumArt();
      return Image.asset(randomArt);
    }
  }
  ```
* This logic ensures:

  * A new image is chosen every time the song is played.
  * No persistent state or cache is used.

---

### 7️⃣ **Music Playback**

* Use `just_audio` with `audio_service` for:

  * Background playback
  * Notification controls
  * Media session integration
* Link song metadata to `AudioSource`.

---

### 8️⃣ **Favorites & Playlists (Optional)**

* Store favorites and playlists using local DB (`sqflite`) or `shared_preferences`.
* Add UI for:

  * Marking songs as favorite
  * Creating/editing playlists

---

### 9️⃣ **Responsive Design**

* Use `LayoutBuilder` or `MediaQuery` to scale UI on all screen sizes.
* Test on:

  * Small phones
  * Tablets
  * Foldables (if possible)

---

### 🔚 Final Notes

* All features must work completely **offline**.
* Ensure clean and scalable code using Provider or Riverpod.
* Ensure smooth performance even with large libraries.

### Testing on Android Device

To test the app natively on your Android device, you can use the following commands:

```bash
flutter devices          # Check if device is detected
flutter run             # Run on connected device
```

This approach allows you to test the app directly on your Android device without needing to create an APK file. Make sure your device is connected to your computer via USB and has USB debugging enabled.

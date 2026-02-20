# OffMusic App: Present Situation vs. Initial Requirements

## 1. Project Setup
- **Flutter 3.x+**: Intended and reflected in project metadata.
- **Dependencies**: `permission_handler`, `on_audio_query`, `provider`, `path_provider`, and `shared_preferences` are present and used.
- **Playback stack**: Current implementation uses `audioplayers` (not `just_audio` + `audio_service`).
- **Android Permissions**: `AndroidManifest.xml` includes `READ_MEDIA_AUDIO` and `READ_EXTERNAL_STORAGE`.

## 2. App Theme & UI
- **Gradient Background**: Implemented across major screens.
- **Bouncy Animations**: `AnimatedContainer` and animated transitions are used.
- **BottomNavigationBar**: Standardized to Home, Search, Playlists, Settings.

## 3. Permission & Media Scan
- **Permissions**: Requested at startup using `permission_handler`.
- **Media Scan**: Uses `on_audio_query` to scan local audio metadata and map to app models.

## 4. Sections (Spotify-Style Layout)
- **Implemented**: All Songs, Artists, Albums, Favorites.
- **Not implemented as dedicated sections**: Genres, Recently Played.

## 5. Now Playing Screen
- Shows title, artist, artwork, playback controls, shuffle/repeat toggles, and seek bar.

## 6. Random Album Art Logic
- Uses 6 bundled images in `assets/images/Album Art (1-6).jpg`.
- A random fallback image is selected at runtime when embedded artwork is unavailable.

## 7. Music Playback
- Playback is functional with `audioplayers` and now includes explicit in-memory queue tracking for next/previous.
- Background notification/media-session behavior from `audio_service` is not currently implemented.

## 8. Favorites & Playlists
- Implemented with `shared_preferences` persistence.

## 9. Responsive Design
- Uses responsive helpers and adaptive spacing/font/layout decisions.

## 10. Current Risks / Gaps
- Genres and Recently Played still need product-level implementation.
- Integration behavior should be expanded with stronger automated tests in CI and on-device checks.

---
*Last updated to match current code behavior.*

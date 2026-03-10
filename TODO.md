# Dzenn — TODO.md (MVP Roadmap)

> Sequential development plan for Dzenn (macOS Focus App)

---

## Core Foundation

1. Project setup✅
2. Folder structure✅
3. Main app window✅
4. Floating window system✅
5. Always-on-top overlay✅
6. Drag floating window✅
7. Start / Stop focus session✅
8. Timer Engine (countdown core)✅

---

## Focus System

9. Task input UI (main app)❌ -- tdk perlu fitur ini
10. Duration selector UI -- cari ref design dlu biar enk ✅
11. Session state machine✅
12. Break mode✅
13. Pause / Resume✅
14. Multi-session per day✅ (tunda full tracking)

---

## Menu Bar App (MVP)

15. Status bar icon (menu bar) ✅
16. Menu bar UI: slider (interval) ✅
17. Menu bar UI: quick presets (5m / 15m / 25m) ✅
18. Menu bar UI: Start/Pause toggle ✅
19. Menu bar UI: Timer label (current) ✅
20. Menu bar UI: “…” menu (Settings / Contact / Quit) ✅

---

## Settings (Main App)

21. Open main app from menu bar Settings ✅
22. Configure quick presets (3 options) ✅
23. Sound toggle/config ✅
24. Floating theme selector ✅ + opacity setting ✅
25. Floating image toggle ✅
26. Show/hide timer in floating ✅

---

## UX Layer

27. Floating controls (pause/stop) ❌
28. Keyboard shortcuts ❌
29. Smooth animations ❌
30. Theme system (basic) ❌
31. UI polish ❌

## Testing

32. Coba tes dengar sound paki blutooh atua kabel

--- --- AFTER MVP (RELAES 1.1.0)

## System Layer

32. App activity tracking (tunda) ⏳
33. Active app detection (tunda) ⏳
34. App switch logging (tunda) ⏳
35. Focus pattern detection (tunda) ⏳

--- AFTER MVP (RELAES 1.1.0)

## Data Layer (Deferred)

36. Session model (tracking) ⏳
37. Focus history model ⏳
38. Stats model ⏳
39. Local persistence layer (JSON) ⏳
40. Session storage ⏳
41. Daily aggregation ⏳

---

## Stats Engine (Deferred)

42. Stats calculation engine ⏳
43. Daily focus time ⏳
44. Weekly summary ⏳
45. Session analytics ⏳
46. Focus consistency logic ⏳

---

## UI Dashboard (Deferred)

47. Stats dashboard UI ⏳
48. Session history UI ⏳
49. Focus timeline UI ⏳
50. Minimal analytics view ⏳

---

## MVP Finalization

51. Settings panel polish ❌
52. Preferences system ❌
53. Permissions flow ❌
54. Onboarding ❌
55. Error handling ❌
56. App state recovery ❌
57. Data integrity checks ❌
58. Performance optimization ❌
59. UX refinement ❌
60. MVP stabilization ❌

---

## MVP DONE

61. Internal testing ❌
62. MVP ready build ❌

---

# Release & Distribution (Public)

63. Pastikan `Bundle Identifier` final (reverse domain) ✅
64. Pastikan `Version` + `Build` (CFBundleShortVersionString + CFBundleVersion) ❌
65. Pastikan entitlements yang dibutuhkan (Sandbox, Hardened Runtime, iCloud? etc) ✅/❌
66. Archive build via Xcode (Release) ✅/❌
67. Buat paket distribusi (pilih salah satu) ✅/❌
68. Opsi A: `.dmg` (paling umum) ✅/❌ --> kkny pake .zip aja

69. Siapkan instruksi bypass Gatekeeper (karena tanpa notarization) ✅/❌
70. Test install di Mac lain (fresh user) ✅/❌
71. Siapkan halaman download + release notes ✅/❌
72. (Optional) Auto‑update via Sparkle ✅/❌
73. (Optional) Homebrew tap + cask ✅/❌
74. Buat icon aplikasi (AppIcon) ✅/❌

Notes:

- Tanpa auto‑update, user harus download versi baru manual.
- Versi lama **tetap bisa jalan** selama tidak ada dependency server yang memaksa upgrade.
- Jika pakai Sparkle, kamu bisa pilih `soft update` (rekomendasi)
- `forced update` hanya jika benar‑benar perlu

---

# Homebrew (Recommended)

- Buat repo tap: `homebrew-dzenn`
- Buat cask `dzenn-pomodoro.rb`
- Isi cask: `version`, `sha256`, `url` (DMG), `name`, `desc`, `homepage`
- Update `version` + `sha256` setiap rilis
- Instruksi user:
- `brew tap <username>/dzenn`
- `brew install --cask dzenn-pomodoro`
- Update user:
- `brew update`
- `brew upgrade --cask dzenn-pomodoro`

---

# ILMU BARU

- Cara add sound ke project
  > setelh sound ada d folder, buka file inspector (⌥ + ⌘ + 1)
  > d target membership, checlist project

---

# RAPIKAN FLOATINGAPPSETTINGVIEW :

SIDEBAR JDI :

- Core
- Floating

GLASSY EFEFCT :
mainnya d file

- dzenn/UI/Floating/FloatingTheme.swift
- dzenn/UI/Floating/FloatingTimerWindow.swift

nnti baru dipanggil di
dzenn/UI/Main/FloatingAppSettingsView.swift (jdi disini g pelru dirubah)

---

# cara menaytukan sidebar + traffic light

Goal:

- Bikin traffic light bawaan macOS terlihat menyatu di dalam area sidebar (tanpa tombol custom), sambil tetap jaga behavior native.
- Layout utama tetap 2 area visual: `sidebar` dan `detail`.

Pendekatan:

- Pakai `NSWindow` style `.fullSizeContentView`, lalu set `titlebarAppearsTransparent = true` dan `titleVisibility = .hidden` di `dzenn/Managers/WindowManager.swift`.
- Biarkan traffic light tetap bawaan/native (close aktif, minimize + zoom disable), jangan ganti dengan SwiftUI custom.
- Di `MainView`, root layout pakai `ignoresSafeArea(.container, edges: .top)` supaya background/sidebar bisa naik ke area title bar.
- Sidebar diberi `titlebarInset` (spacer atas) untuk ruang tombol traffic light + navigation tetap rapi.
- geser traffic light sedikit jika pelru pakai standardWindowButton frame dan trafficLightsHorizontalOffset
- Padding universal konten diterapkan konsisten per kolom (left/right/top/bottom) agar border sidebar tetap kelihatan.

---

# Build & Distribusi Singkat (tanpa Developer Account)

- Sebelum build final: set `Build Configuration = Release`, cek `Version` + `Build` valid.
- Build dulu, lalu `Products` > klik kanan `dzenn.app` > `Show in Finder`.
- Ambil `dzenn.app` dari folder `Release` (bukan Debug).
- Distribusi paling simpel: compress jadi `dzenn-macos-<versi>.zip` lalu upload ke GitHub Releases + landing page.
- Jika pakai `Archive > Direct Distribution`, bisa dipakai jika export tidak gagal signing; kalau gagal, pakai jalur build Release + zip.
- Karena tidak notarized: tulis panduan `Open Anyway` di `Privacy & Security` untuk user.

## Catatan Workflow (biar tidak bingung)

- Karena belum punya Apple Developer Program ($99/tahun), pakai alur: `Build Release` -> ambil `dzenn.app` -> compress `.zip` -> upload ke Releases/website.
- Sebelum build final, ubah Scheme `Run` dan `Profile` ke `Release`.
- Untuk ngoding harian, ubah lagi Scheme ke `Debug`, lanjut edit code, test, lalu saat mau rilis balik lagi ke `Release`.
- cel appnya itu di `Product > Show build folder in finder > release `
- Jika ada update kecil setelah rilis:
- Naikkan `Version`/`Build`.
- Build `Release` lagi.
- Ganti app lama di `/Applications` dengan app baru.
- Launchpad akan tetap menampilkan app yang sama (bundle ID sama); yang berubah adalah versi aplikasinya.

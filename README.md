#  Musician

**Musician** adalah aplikasi pemutar musik streaming berbasis Flutter yang memungkinkan pengguna menjelajahi tangga lagu terpopuler, mencari lagu atau artis secara real-time, dan memutar musik langsung dari aplikasi dengan pengalaman player yang modern dan minimalis.

##  Fitur Utama

- **Login dengan Google** — autentikasi cepat dan aman menggunakan akun Google, dengan sesi yang tersimpan otomatis (auto-login).
- **Top Charts** — menampilkan daftar lagu terpopuler saat ini.
- **Recently Played** — riwayat lagu yang baru saja diputar, ditampilkan di beranda.
- **Pencarian Real-time** — cari lagu atau artis langsung saat mengetik.
- **Mini Player** — kontrol pemutaran cepat yang selalu terlihat di bagian bawah layar.
- **Full Player Screen** — tampilan pemutar lengkap dengan cover lagu, slider durasi, shuffle, dan repeat (off/all/one).
- **Antrian Lagu (Up Next)** — lihat dan pilih lagu berikutnya dari daftar putar melalui panel geser (draggable sheet).
- **Local Notification** — menampilkan notifikasi berisi info lagu yang sedang diputar (judul, artis, dan status play/pause), mendukung Android, iOS, dan Web.

## Alur Aplikasi

1. **Login**
   Pengguna membuka aplikasi dan login menggunakan akun Google.
2. **Sesi Tersimpan**
   Setelah login berhasil, data sesi (email, nama, foto profil) disimpan di local storage agar pengguna tidak perlu login ulang setiap kali membuka aplikasi.
3. **Halaman Welcome**
   Pengguna dengan sesi yang sudah tersimpan akan diarahkan ke halaman Welcome, yang menampilkan tombol **Start**.
4. **Tekan Start → Halaman Home**
   Saat tombol **Start** ditekan, pengguna masuk ke halaman Home.
5. **Di Halaman Home, pengguna dapat:**
   - **Mencari lagu/artis** lewat search bar secara real-time.
   - **Memutar musik** dari Top Charts, Recently Played, maupun hasil pencarian.
   - Saat lagu diputar, pengguna dapat masuk ke Player Screen untuk mengatur **shuffle** (acak urutan lagu) dan **loop/repeat** (ulangi satu lagu atau seluruh antrian), serta melihat antrian lagu berikutnya (Up Next).

```
┌─────────────────────────────────────────────────────────────────┐
│                         START APP                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                  ┌───────────────────────┐
                  │  Cek Session di        │
                  │  Shared Preferences   │
                  └───────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
       ┌─────────────┐                ┌─────────────┐
       │  Ada Session │                │ Tidak Ada   │
       │  (Logged In) │                │  Session    │
       └─────────────┘                └─────────────┘
              │                               │
              ▼                               ▼
   ┌────────────────────┐          ┌────────────────────┐
   │  Welcome Screen    │          │  Login Screen      │
   │  (Tampil Start)    │          │  (Tampil Google)   │
   └────────────────────┘          └────────────────────┘
              │                               │
              │                               ▼
              │                    ┌────────────────────┐
              │                    │  Click Google      │
              │                    │  Sign In Button    │
              │                    └────────────────────┘
              │                               │
              │                               ▼
              │                    ┌────────────────────┐
              │                    │  Proses Login      │
              │                    │  (Google Auth)     │
              │                    └────────────────────┘
              │                               │
              │                    ┌───────────┴───────────┐
              │                    │                       │
              │                    ▼                       ▼
              │             ┌───────────┐          ┌─────────────┐
              │             │  Berhasil │          │   Gagal     │
              │             └───────────┘          └─────────────┘
              │                    │                       │
              │                    ▼                       ▼
              │        ┌────────────────────┐     ┌────────────────┐
              │        │  Simpan Session ke │     │  Tampilkan     │
              │        │  Shared Preferences│     │  Error Message │
              │        └────────────────────┘     └────────────────┘
              │                    │                       │
              │                    ▼                       │
              │        ┌────────────────────┐              │
              │        │  Welcome Screen    │              │
              │        │  (Tampil Start)    │              │
              │        └────────────────────┘              │
              │                    │                       │
              └────────────────────┘                       │
                                   │                       │
                                   ▼                       │
                    ┌─────────────────────────────┐       │
                    │   Click Tombol "Start"       │       │
                    └─────────────────────────────┘       │
                                   │                       │
                                   ▼                       │
                    ┌─────────────────────────────┐       │
                    │      HOME SCREEN             │       │
                    └─────────────────────────────┘       │
                                   │                       │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
          ▼                        ▼                        ▼
┌──────────────────┐  ┌────────────────────┐  ┌────────────────────┐
│   Search Bar     │  │  Top Charts        │  │  Recently Played   │
│  (Cari Lagu/     │  │  (List Lagu        │  │  (Riwayat Lagu     │
│   Artis)         │  │   Populer)         │  │   Terakhir)        │
└──────────────────┘  └────────────────────┘  └────────────────────┘
          │                        │                        │
          └────────────────────────┼────────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │   Click Play Lagu           │
                    └─────────────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │   Player Service            │
                    │   (Audio Streaming)         │
                    └─────────────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │   Mini Player Bar           │
                    │   (Bottom - Kontrol Cepat)  │
                    └─────────────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │   Click Mini Player         │
                    │   (Buka Full Player)        │
                    └─────────────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │  Notifikasi Lokal           │
                    │  (Info Lagu + Kontrol)     │
                    └─────────────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │   END / Back to Home        │
                    └─────────────────────────────┘
```

##  Desain

Desain UI/UX aplikasi ini dapat dilihat di Figma:

[Figma Design – Musician]([URL_FIGMA_DISINI](https://www.figma.com/design/mH5SmnPPMeJg73yFv3DC5J/Ariffanka_MusicAppDesain?node-id=0-1&t=mX17f6LiQVX5jtKF-1))

## Tech Stack

- **Flutter** & **Dart**
- **Provider** — state management
- **Deezer API** — sumber data lagu, chart, dan pencarian
- **flutter_local_notifications** — notifikasi lokal lintas platform

##  Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

Untuk menjalankan di browser (Chrome):

```bash
flutter run -d chrome
```

## Notes
Mohon maaf apabila masih banyak kekurangan pada aplikasi yang saya buat. Untuk UI/UX dari Figma dengan aplikasi yang saya buat terdapat beberapa perbedaan seperti tata letak dan beberapa warna, karena saya merasa lebih bagus/fit ketika saya running dibandingkan di Figma.

Untuk fitur local notification, saya tidak tahu berjalan semestinya atau tidak karena saya menggunakan Chrome browser untuk running, tapi ketika saya play musik ada notif "allow notification" yang membuktikan jika local notification berjalan ketika lagu diputar.

Jika ada bug dan error biasa dilaporkan ke saya, sekian dari saya terimakasih.

## 👤 Dibuat oleh

**Muhammad Ariffanka**

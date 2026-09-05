# 📱 Aplikasi Flutter – Tugas Kelompok

Aplikasi mobile berbasis **Flutter (Dart)** yang mencakup fitur login, data kelompok, operasi aritmatika, pengecekan ganjil/genap, dan penjumlahan total angka dari input pengguna, lengkap dengan tampilan UI (bukan hanya CLI).

---

## 👥 Anggota Kelompok

| No |     Nama     |       NIM      |              Peran Utama        |    GitHub Username   |
|----|--------------|----------------|---------------------------------|----------------------|
| 1  | _(isi nama)_ |  _(isi NIM)_   |                                 |     @_(isi)_         |
| 2  | Sepi Ananda  |    124240066   |                                 |     @VanderMaand     |
| 3  | _(isi nama)_ |   _(isi NIM)_  |      |     @_(isi)_         |
> ⚠️ **Wajib diisi di awal pengerjaan** — data ini juga digunakan untuk penilaian individu dalam kelompok.

---

## 🎯 Deskripsi Aplikasi

Aplikasi ini berupa aplikasi mobile Flutter dengan beberapa layar (screen) yang dapat diakses melalui menu utama setelah login:

1. **Login Screen** — form input username & password, verifikasi sebelum masuk ke Home
2. **Home Screen (Menu Utama)** — daftar menu berupa tombol/card menuju tiap fitur
3. **Data Kelompok Screen** — menampilkan identitas anggota kelompok
4. **Tambah & Kurang Screen** — form input dua angka + tombol proses penjumlahan dan pengurangan
5. **Kali & Bagi Screen** — form input dua angka + tombol proses perkalian dan pembagian (dengan validasi pembagian nol)
6. **Ganjil/Genap Screen** — form input satu angka, menampilkan hasil ganjil/genap
7. **Jumlah Total Screen** — input angka berulang (misal dipisah koma, atau tombol "tambah angka") lalu menampilkan total keseluruhan

> Navigasi antar layar menggunakan `Navigator.push()` / named routes, bukan `switch-case` di terminal seperti versi CLI.

---

## 🗂️ Struktur Folder Project (Flutter)

```
mobilecalculator/
├── .gitignore
├── README.md
├── pubspec.yaml
├── android/                 # generated otomatis oleh Flutter
├── ios/                     # generated otomatis oleh Flutter
├── lib/
│   ├── main.dart             # Entry point, MaterialApp & routing
│   ├── screens/
│   │   ├── login_screen.dart          # Milik: Anggota 1
│   │   ├── home_screen.dart           # Milik: Anggota 1
│   │   ├── data_kelompok_screen.dart  # Milik: Anggota 1
│   │   ├── aritmatika_screen.dart     # Milik: Anggota 2 (tambah/kurang/kali/bagi)
│   │   ├── ganjil_genap_screen.dart   # Milik: Anggota 3
│   │   └── total_angka_screen.dart    # Milik: Anggota 3
│   └── widgets/               # (opsional) widget custom yang dipakai berulang
│       └── custom_button.dart
└── test/                     # unit test / widget test (opsional)
```

**Aturan penting:**
- Setiap screen dikerjakan di file **terpisah** di dalam `lib/screens/`, **jangan** menulis semua UI dan logika langsung di `main.dart`.
- `main.dart` hanya berisi `MaterialApp`, daftar `routes`, dan pemanggilan `HomeScreen` sebagai halaman awal.
- File `android/`, `ios/`, `build/` dihasilkan otomatis oleh Flutter — **tidak perlu di-commit** manual (sudah diatur di `.gitignore`).

---

## ⚙️ Cara Menjalankan Program

### 1. Pastikan Flutter SDK sudah terinstall
Cek dengan:
```bash
flutter --version
flutter doctor
```
Jika belum ada, ikuti panduan instalasi di [flutter.dev/get-started](https://flutter.dev/docs/get-started/install) sesuai OS masing-masing (Windows/Mac/Linux). Jalankan `flutter doctor` untuk memastikan semua kebutuhan (Android SDK, emulator, dll) sudah terpenuhi.

### 2. Clone repository
```bash
git clone https://github.com/VanderMaand/mobilecalculator?tab=readme-ov-file
cd mobilecalculator
```

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Jalankan aplikasi
Pastikan sudah ada emulator Android/iOS yang running, atau device fisik yang tersambung (USB debugging aktif), lalu:
```bash
flutter run
```
Untuk mengecek device yang tersedia:
```bash
flutter devices
```

> 💡 Setiap anggota **disarankan pakai emulator/device yang sama jenisnya** (misal sama-sama Android) di awal, supaya tidak ada perbedaan tampilan/behavior yang membingungkan saat diskusi bug.

---

## 🌱 Panduan Alur Kerja Git (Wajib Dibaca Semua Anggota)

### Branch yang digunakan
| Branch | Fungsi |
|---|---|
| `main` | Kode final yang sudah teruji, siap diupload ke SPADA |
| `dev` | Branch kerja bersama, tempat semua fitur digabungkan sebelum ke `main` |
| `feature/nama-fitur` | Branch pribadi tiap anggota saat mengerjakan fitur |

### Langkah kerja setiap kali akan mengerjakan sesuatu

```bash
# 1. Pindah ke dev dan tarik update terbaru
git checkout dev
git pull origin dev

# 2. Buat/pindah ke branch fitur pribadi
git checkout -b feature/nama-fitur      # hanya sekali di awal
git checkout feature/nama-fitur         # untuk lanjutan berikutnya

# 3. Setelah selesai coding, commit
git add .
git commit -m "Tambah validasi input login"

# 4. Push ke GitHub
git push origin feature/nama-fitur

# 5. Buka Pull Request (PR) di GitHub: feature/nama-fitur → dev
# 6. Minta 1 anggota lain review sebelum merge
# 7. Setelah disetujui, merge ke dev
```

### Membuat Project Flutter Pertama Kali (untuk Repo Owner)

```bash
flutter create flutter_app_kelompok_x
cd flutter_app_kelompok_x
git init
git add .
git commit -m "Initial Flutter project setup"
git branch -M main
git remote add origin https://github.com/username-owner/flutter_app_kelompok_x.git
git push -u origin main
git checkout -b dev
git push -u origin dev
```

Setelah itu, buat folder `lib/screens/` dan file skeleton kosong untuk tiap screen, commit, lalu push ke `dev` sebagai titik awal sebelum anggota lain mulai bekerja di branch fitur masing-masing.

`pubspec.yaml` minimal (nama project bisa disesuaikan):
```yaml
name: flutter_app_kelompok_x
description: Aplikasi Flutter tugas kelompok
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### Aturan commit message
Gunakan format singkat & jelas:
```
Tambah fitur pembagian dengan validasi nol
Perbaiki bug pada menu ganjil/genap
Update tampilan menu utama
```
❌ Hindari commit message seperti `update`, `fix`, `asdf`.

### Aturan Pull Request
- Judul PR jelas, contoh: `Fitur: Aritmatika (Tambah, Kurang, Kali, Bagi)`
- Deskripsi PR mencantumkan apa yang ditambahkan/diubah
- **Wajib direview minimal 1 anggota lain** sebelum merge ke `dev`
- Jangan langsung push ke `main`

### Jika terjadi conflict
1. Jangan panik — diskusikan di grup siapa yang mengedit bagian itu
2. Buka file yang conflict, akan ada tanda:
   ```
   <<<<<<< HEAD
   kode versi kamu
   =======
   kode versi teman
   >>>>>>> feature/nama-fitur
   ```
3. Pilih/gabungkan kode yang benar, hapus tanda `<<<<<<<`, `=======`, `>>>>>>>`
4. `git add .` → `git commit` → `git push` lagi

---

## ✅ Checklist Progres Pengerjaan

Update checklist ini secara berkala agar semua anggota tahu progres masing-masing.

- [ ] Setup project Flutter (`flutter create`) & push ke `main`/`dev`
- [ ] Skeleton `main.dart` (MaterialApp & routes)
- [ ] `login_screen.dart`
- [ ] `home_screen.dart` (menu utama)
- [ ] `data_kelompok_screen.dart`
- [ ] `aritmatika_screen.dart` (Tambah, Kurang, Kali, Bagi + validasi bagi nol)
- [ ] `ganjil_genap_screen.dart`
- [ ] `total_angka_screen.dart`
- [ ] Integrasi navigasi antar screen
- [ ] Testing menyeluruh (semua menu + input tidak valid, di emulator/device)
- [ ] Merge `dev` → `main`
- [ ] Upload individu ke SPADA
- [ ] Siapkan bahan presentasi & demo aplikasi

---

## 🧪 Standar Pengujian Sebelum Merge

Sebelum membuat PR, pastikan sudah menguji langsung di emulator/device:
- Input angka normal (positif, negatif, nol) lewat `TextField`
- Input yang bukan angka atau field kosong (harus ditangani dengan validasi/`SnackBar`, tidak boleh crash merah/`Exception`)
- Untuk pembagian: pastikan pembagi nol ditangani dengan pesan error di UI, bukan `Infinity`/crash
- Untuk login: username/password salah harus menampilkan pesan error yang jelas (misal `SnackBar` atau teks merah)
- Tombol "Kembali" / navigasi `Navigator.pop()` berjalan normal dari tiap screen ke Home
- Tampilan tidak error/overflow di ukuran layar berbeda (cek minimal 1 emulator kecil & 1 besar jika memungkinkan)

---

## 📤 Panduan Upload ke SPADA (Individu)

Meskipun dikerjakan berkelompok, upload dilakukan **per individu**. Setiap anggota:
1. Pastikan sudah `git pull` versi `main` terbaru
2. Sertakan seluruh source code (folder `bin/` dan `lib/`)
3. Sertakan screenshot hasil run tiap menu
4. Sertakan README ini (sudah terisi lengkap) sebagai bukti pembagian tugas
5. Upload sesuai batas waktu yang ditentukan dosen

---

## 🎤 Panduan Presentasi

Pembagian penjelasan disarankan sesuai peran masing-masing:
- **Anggota 1**: alur program, login, data kelompok
- **Anggota 2**: logika aritmatika, validasi input
- **Anggota 3**: ganjil/genap, akumulasi jumlah total

Siapkan juga penjelasan singkat tentang alur kolaborasi Git (branch, PR, merge) karena ini bagian dari penilaian kerja kelompok.

---

## 📌 Catatan Tambahan

- Selalu `git pull origin dev` sebelum mulai kerja agar tidak ketinggalan update teman
- File/folder hasil generate Flutter (`.dart_tool/`, `build/`, `.flutter-plugins`, `.flutter-plugins-dependencies`, `.packages`, folder `android/.gradle`, `ios/Pods`) **tidak perlu di-commit** — Flutter otomatis membuat `.gitignore` yang mencakup ini saat `flutter create` dijalankan, jangan dihapus/diedit isi `.gitignore` tersebut
- Jika `flutter pub get` error setelah `git pull` (biasanya karena `pubspec.yaml` berubah), jalankan ulang `flutter pub get` sebelum `flutter run`
- Jika bingung soal Git, tanyakan di grup sebelum force push atau menghapus branch
- Komunikasi rutin (misal H-3 sebelum deadline) untuk memastikan semua fitur sudah terintegrasi dengan baik dan tidak ada error saat `flutter run` di device siapa pun

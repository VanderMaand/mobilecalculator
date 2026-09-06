import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fungsi utama (entry point) untuk menjalankan aplikasi Flutter.
void main() {
  runApp(const MyApp());
}

/// [MyApp] merupakan Root Widget aplikasi.
/// Berfungsi untuk mengatur konfigurasi tema global dan sistem navigasi (routing).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Utilitas Multifungsi',
      debugShowCheckedModeBanner:
          false, // Menghilangkan banner debug di pojok kanan atas
      // Konfigurasi Tema Aplikasi (Material 3)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7), // Warna dasar/utama aplikasi
          primary: const Color(0xFF6C5CE7),
          secondary: const Color(0xFFA29BFE),
          background: const Color(0xFFF8F9FA),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      // Rute awal saat aplikasi pertama kali dibuka
      initialRoute: '/login',

      // Peta Navigasi Aplikasi (Register semua rute halaman di sini)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/kelompok': (context) => const DataKelompokScreen(),
        '/penjumlahan': (context) =>
            const OperasiAritmatikaScreen(mode: 'Penjumlahan'),
        '/pengurangan': (context) =>
            const OperasiAritmatikaScreen(mode: 'Pengurangan'),
        '/perkalian': (context) =>
            const OperasiAritmatikaScreen(mode: 'Perkalian'),
        '/pembagian': (context) =>
            const OperasiAritmatikaScreen(mode: 'Pembagian'),
        '/ganjil_genap': (context) => const GanjilGenapScreen(),
        '/total_angka': (context) => const TotalAngkaScreen(),
      },
    );
  }
}

// ============================================================================
// 1. HALAMAN LOGIN
// ============================================================================

/// Halaman Login untuk autentikasi pengguna sebelum masuk ke Dashboard Utama.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Pengontrol untuk mengambil nilai dari field input username dan password
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Status untuk menyembunyikan/menampilkan teks password (fitur mata)
  bool _isObscure = true;

  /// Fungsi [ _login ] untuk memvalidasi input username dan password pengguna.
  void _login() {
    // Memeriksa apakah username 'admin' dan password '123'
    if (_usernameController.text.trim() == 'kelompok_cihuy' &&
        _passwordController.text == 'mobileasikbanget123') {
      // Jika benar, navigasi ke halaman Dashboard Utama (/home) dan hapus halaman login dari tumpukan
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika salah, tampilkan notifikasi pesan kesalahan
      _showErrorSnackBar('Username atau Password Salah!');
    }
  }

  /// Helper function untuk menampilkan [SnackBar] merah ketika terjadi kesalahan.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Latar belakang gradient ungu
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Kunci di dalam lingkaran
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 48,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Silakan login ke akun Anda',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Field Input Username
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field Input Password (dengan toggle sakelar mata)
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscure, // Sembunyikan karakter jika true
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Eksekusi Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _login,
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HALAMAN DASHBOARD / MENU UTAMA
// ============================================================================

/// Halaman Dashboard Utama yang menampilkan seluruh daftar pilihan fitur aplikasi.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Utama',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Tombol Logout untuk kembali ke Halaman Login
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Kategori Fitur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Menu 1: Data Kelompok
          _buildMenuCard(
            context,
            'Data Kelompok',
            'Informasi anggota tim',
            Icons.group_outlined,
            Colors.orange,
            '/kelompok',
          ),
          const SizedBox(height: 16),

          const Text(
            'Kalkulator Terpisah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Grid Kartu Operasi Aritmatika (Dibuat berdampingan)
          Row(
            children: [
              Expanded(
                child: _buildGridCard(
                  context,
                  'Penjumlahan',
                  Icons.add_circle_outline,
                  Colors.blue,
                  '/penjumlahan',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridCard(
                  context,
                  'Pengurangan',
                  Icons.remove_circle_outline,
                  Colors.red,
                  '/pengurangan',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGridCard(
                  context,
                  'Perkalian',
                  Icons.cancel_outlined,
                  Colors.purple,
                  '/perkalian',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridCard(
                  context,
                  'Pembagian',
                  Icons.linear_scale_outlined,
                  Colors.teal,
                  '/pembagian',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Fitur Angka',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Menu 3: Cek Ganjil/Genap
          _buildMenuCard(
            context,
            'Cek Ganjil / Genap',
            'Identifikasi jenis bilangan bulat',
            Icons.tag,
            Colors.indigo,
            '/ganjil_genap',
          ),
          const SizedBox(height: 12),

          // Menu 4: Total Angka Input
          _buildMenuCard(
            context,
            'Total Angka Field Input',
            'Hitung akumulasi deretan angka',
            Icons.functions,
            Colors.green,
            '/total_angka',
          ),
        ],
      ),
    );
  }

  /// Helper Widget: Membangun komponen kartu horizontal panjang (ListTile style)
  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: () => Navigator.pushNamed(
          context,
          route,
        ), // Pindah ke halaman sesuai rute
      ),
    );
  }

  /// Helper Widget: Membangun komponen kartu bentuk grid/kotak kecil
  Widget _buildGridCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. HALAMAN OPERASI ARITMATIKA TERPISAH
// ============================================================================

/// Halaman Dinamis Kalkulator Aritmatika.
/// Menangani mode Penjumlahan, Pengurangan, Perkalian, dan Pembagian secara fleksibel.
class OperasiAritmatikaScreen extends StatefulWidget {
  final String
  mode; // Parameter penentu mode (Penjumlahan/Pengurangan/Perkalian/Pembagian)
  const OperasiAritmatikaScreen({super.key, required this.mode});

  @override
  State<OperasiAritmatikaScreen> createState() =>
      _OperasiAritmatikaScreenState();
}

class _OperasiAritmatikaScreenState extends State<OperasiAritmatikaScreen> {
  // Pengontrol teks untuk input angka 1 dan angka 2
  final _num1 = TextEditingController();
  final _num2 = TextEditingController();

  // Penampung teks hasil kalkulasi
  String _hasil = '0';

  /// Helper function untuk menampilkan pesan eror melalui [SnackBar]
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Fungsi [ _hitung ] untuk mengeksekusi perhitungan matematika berdasarkan mode.
  void _hitung() {
    // 1. Validasi: Memastikan input tidak dibiarkan kosong
    if (_num1.text.trim().isEmpty || _num2.text.trim().isEmpty) {
      _showError('Semua input angka wajib diisi!');
      return;
    }

    // 2. Parsing teks ke bentuk tipe data double secara aman
    double? a = double.tryParse(_num1.text);
    double? b = double.tryParse(_num2.text);

    // Memastikan angka yang diparse tidak null/corrupt
    if (a == null || b == null) {
      _showError('Format angka tidak valid!');
      return;
    }

    double res = 0;

    // 3. Logika Aritmatika sesuai mode widget
    setState(() {
      if (widget.mode == 'Penjumlahan') {
        res = a + b;
        _hasil = res.toString();
      } else if (widget.mode == 'Pengurangan') {
        res = a - b;
        _hasil = res.toString();
      } else if (widget.mode == 'Perkalian') {
        res = a * b;
        _hasil = res.toString();
      } else if (widget.mode == 'Pembagian') {
        // Error handling pembagian nol (division by zero)
        if (b != 0) {
          res = a / b;
          _hasil = res.toStringAsFixed(2); // Dibatasi 2 desimal belakang koma
        } else {
          _hasil = 'Error';
          _showError('Pembagian dengan angka nol tidak diperbolehkan!');
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu ${widget.mode}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Kartu Penampil Hasil Kalkulasi Utama
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color(0xFF6C5CE7),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Hasil ${widget.mode}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasil,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Angka Pertama
            TextField(
              controller: _num1,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              // Filter: HANYA MENGIZINKAN angka, minus, dan desimal (Mencegah input huruf)
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Angka Pertama',
                hintText: 'Contoh: 12 atau 5.5',
                prefixIcon: const Icon(Icons.looks_one_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Angka Kedua
            TextField(
              controller: _num2,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              // Filter: HANYA MENGIZINKAN angka, minus, dan desimal (Mencegah input huruf)
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Angka Kedua',
                hintText: 'Contoh: 3 atau -2',
                prefixIcon: const Icon(Icons.looks_two_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Hitung
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _hitung,
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: Text(
                  'Hitung ${widget.mode}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. HALAMAN DATA KELOMPOK
// ============================================================================

/// Halaman statis untuk menampilkan informasi data anggota kelompok.
class DataKelompokScreen extends StatelessWidget {
  const DataKelompokScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List data dummy anggota kelompok
    final List<Map<String, String>> anggota = [
      {'nama': 'Muhammad Shofa Azmy', 'nim': '124240058', 'role': 'President'},
      {'nama': 'Sepi Ananda', 'nim': '124240066', 'role': 'Vice President'},
      {'nama': 'M Dimas Ragil', 'nim': '124240146', 'role': 'Rakyat'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Data Kelompok')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: anggota.length,
        itemBuilder: (context, index) {
          final item = anggota[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6C5CE7),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                item['nama']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('NIM: ${item['nim']}\nPeran: ${item['role']}'),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 5. HALAMAN CEK GANJIL / GENAP
// ============================================================================

/// Halaman untuk memeriksa apakah bilangan yang dimasukkan berjenis GANJIL atau GENAP.
class GanjilGenapScreen extends StatefulWidget {
  const GanjilGenapScreen({super.key});

  @override
  State<GanjilGenapScreen> createState() => _GanjilGenapScreenState();
}

class _GanjilGenapScreenState extends State<GanjilGenapScreen> {
  final _input = TextEditingController();
  String _status = '-'; // Menyimpan status hasil (GENAP/GANJIL)

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Fungsi [ _cek ] untuk menentukan sifat ganjil/genap dari input.
  void _cek() {
    if (_input.text.trim().isEmpty) {
      _showError('Masukkan angka terlebih dahulu!');
      return;
    }

    // Parsing ke tipe data int (bilangan bulat)
    int? val = int.tryParse(_input.text.trim());
    if (val == null) {
      _showError('Input harus berupa bilangan bulat valid!');
      return;
    }

    // Logika modulus % 2 untuk menentukan ganjil/genap
    setState(() {
      _status = (val % 2 == 0) ? 'GENAP' : 'GANJIL';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek Ganjil / Genap')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Kartu Penampil Status (GANJIL / GENAP)
            Card(
              elevation: 4,
              color: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Jenis Bilangan',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Field Input Bilangan Bulat
            TextField(
              controller: _input,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              // Filter: HANYA MENGIZINKAN bilangan bulat dan minus (Mencegah huruf & desimal)
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Masukkan Bilangan Bulat',
                hintText: 'Contoh: 25 atau -8',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Cek
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _cek,
                child: const Text(
                  'CEK ANGKA',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. HALAMAN TOTAL ANGKA INPUT
// ============================================================================

/// Halaman untuk menghitung jumlah total (akumulasi) dari deretan angka yang dipisahkan spasi.
class TotalAngkaScreen extends StatefulWidget {
  const TotalAngkaScreen({super.key});

  @override
  State<TotalAngkaScreen> createState() => _TotalAngkaScreenState();
}

class _TotalAngkaScreenState extends State<TotalAngkaScreen> {
  final _input = TextEditingController();
  double _total = 0; // Penampung nilai akumulasi total

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Fungsi [ _hitung ] untuk memecah teks input dan menjumlahkan setiap angka.
  void _hitung() {
    String textInput = _input.text.trim();
    if (textInput.isEmpty) {
      _showError('Input tidak boleh kosong!');
      return;
    }

    // Memecah (split) teks berdasarkan karakter spasi
    List<String> items = textInput.split(RegExp(r'\s+'));
    double sum = 0;
    bool hasValidNumber = false;

    // Iterasi setiap elemen hasil pecahan string
    for (var item in items) {
      double? val = double.tryParse(item);
      if (val != null) {
        sum += val; // Menjumlahkan nilai jika valid
        hasValidNumber = true;
      }
    }

    if (!hasValidNumber) {
      _showError('Tidak ada format angka yang valid!');
      return;
    }

    // Memperbarui state tampilan dengan nilai total baru
    setState(() => _total = sum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Total Deret Angka')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Kartu Penampil Jumlah Total Angka
            Card(
              elevation: 4,
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Jumlah Total',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Text Area Input Deretan Angka Multi-Baris
            TextField(
              controller: _input,
              maxLines: 3,
              keyboardType: TextInputType.datetime,
              // Filter: HANYA MENGIZINKAN digit angka, spasi, titik, dan minus (Mencegah huruf)
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.\-]')),
              ],
              decoration: InputDecoration(
                labelText: 'Masukkan Angka (Dipisah Spasi)',
                hintText: 'Contoh: 10 20.5 -5 15',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Hitung Total
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _hitung,
                child: const Text(
                  'HITUNG TOTAL',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

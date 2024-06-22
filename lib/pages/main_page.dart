// Impor paket dan modul yang diperlukan.
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uangkoo/models/database.dart';
import 'package:uangkoo/pages/category_page.dart';
import 'package:uangkoo/pages/home_page.dart';
import 'package:uangkoo/pages/transaction_page.dart';

// Definisikan widget stateful untuk halaman utama.
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

// Definisikan state untuk halaman utama.
class _MainPageState extends State<MainPage> {
  // Variabel untuk menyimpan tanggal yang dipilih.
  late DateTime selectedDate;
  // Variabel untuk menyimpan widget yang akan ditampilkan.
  late List<Widget> _children;
  // Variabel untuk menyimpan indeks halaman saat ini.
  late int currentIndex;

  // Inisialisasi database.
  final database = AppDb();

  // Controller untuk nama kategori.
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    // Memperbarui tampilan awal.
    updateView(0, DateTime.now());
    super.initState(); // Memanggil metode initState dari kelas induk.
  }

  // Metode untuk mendapatkan semua kategori dari database.
  Future<List<Category>> getAllCategory() {
    return database.select(database.categories).get();
  }

  // Metode untuk menampilkan semua kategori (debugging).
  void showAwe() async {
    List<Category> al = await getAllCategory();
    print('PANJANG : ' + al.length.toString());
  }

  // Metode untuk menampilkan dialog sukses.
  void showSuccess(BuildContext context) {
    // Membuat tombol OK.
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {},
    );

    // Membuat dialog.
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // Menampilkan dialog.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Metode untuk memperbarui tampilan berdasarkan indeks dan tanggal.
  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        // Mengatur tanggal yang dipilih.
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      // Mengatur indeks halaman saat ini.
      currentIndex = index;
      // Mengatur widget yang akan ditampilkan.
      _children = [HomePage(selectedDate: selectedDate), CategoryPage()];
    });
  }

  // Metode yang dipanggil saat tab ditekan.
  void onTabTapped(int index) {
    setState(() {
      // Mengatur tanggal yang dipilih ke hari ini.
      selectedDate =
          DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      // Mengatur indeks halaman saat ini.
      currentIndex = index;
      // Mengatur widget yang akan ditampilkan.
      _children = [HomePage(selectedDate: selectedDate), CategoryPage()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tombol aksi mengambang untuk menambahkan transaksi baru.
      floatingActionButton: Visibility(
        visible: (currentIndex == 0), // Hanya terlihat di halaman beranda.
        child: FloatingActionButton(
          onPressed: () {
            // Navigasi ke halaman transaksi.
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) =>
                  TransactionPage(transactionsWithCategory: null),
            ))
                .then((value) {
              // Perbarui tampilan setelah kembali dari halaman transaksi.
              setState(() {
                updateView(0, DateTime.now());
              });
            });
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom navigation bar dengan dua tombol.
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                // Perbarui tampilan ke halaman beranda.
                updateView(0, DateTime.now());
              },
              icon: Icon(Icons.home),
            ),
            SizedBox(width: 20), // Spasi antara dua ikon.
            IconButton(
              onPressed: () {
                // Perbarui tampilan ke halaman kategori.
                updateView(1, DateTime.now());
              },
              icon: Icon(Icons.list),
            )
          ],
        ),
      ),
      body: _children[currentIndex], // Tampilkan halaman saat ini.
      appBar: (currentIndex == 1) // Jika di halaman kategori.
          ? PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                  child: Text(
                    "Categories",
                    style: GoogleFonts.montserrat(fontSize: 20),
                  ),
                ),
              ),
            )
          : CalendarAppBar(
              // Jika di halaman beranda, tampilkan CalendarAppBar.
              fullCalendar: true,
              backButton: false,
              accent: Colors.blue,
              locale: 'en',
              onDateChanged: (value) {
                setState(() {
                  selectedDate = value; // Perbarui tanggal yang dipilih.
                  updateView(0,
                      selectedDate); // Perbarui tampilan berdasarkan tanggal.
                });
              },
              lastDate: DateTime.now(),
            ),
    );
  }
}

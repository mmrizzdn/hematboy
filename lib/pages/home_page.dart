// Impor paket dan modul yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uangkoo/models/database.dart';
import 'package:uangkoo/models/transaction_with_category.dart';
import 'package:uangkoo/pages/transaction_page.dart';

// Definisikan widget stateful untuk halaman beranda.
class HomePage extends StatefulWidget {
  // Tanggal yang dipilih.
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// Definisikan state untuk halaman beranda.
class _HomePageState extends State<HomePage> {
  // Inisialisasi database.
  final AppDb database = AppDb();

  @override
  void initState() {
    super.initState(); // Memanggil metode initState dari kelas induk.
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget untuk menampilkan ringkasan pendapatan dan pengeluaran.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Menampilkan pendapatan.
                          Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.download,
                                    color: Colors.greenAccent[400],
                                  )),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pendapatan',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(height: 5),
                                  Text('Rp 3.800.000',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14, color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          // Menampilkan pengeluaran.
                          Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.upload,
                                    color: Colors.redAccent[400],
                                  )),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pengeluaran',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(height: 5),
                                  Text('Rp 1.600.000',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14, color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )),
            ),
            SizedBox(height: 10),
            // Menampilkan judul "Transactions".
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            // StreamBuilder untuk menampilkan daftar transaksi berdasarkan tanggal yang dipilih.
            StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionByDateRepo(widget.selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Tombol untuk menghapus transaksi.
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {},
                                        ),
                                        SizedBox(width: 10),
                                        // Tombol untuk mengedit transaksi.
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionPage(
                                                          transactionsWithCategory:
                                                              snapshot.data![
                                                                  index]),
                                                ))
                                                .then((value) {});
                                          },
                                        )
                                      ],
                                    ),
                                    subtitle: Text(
                                        snapshot.data![index].category.name),
                                    leading: Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: (snapshot.data![index].category
                                                    .type ==
                                                1)
                                            ? Icon(
                                                Icons.download,
                                                color: Colors.greenAccent[400],
                                              )
                                            : Icon(
                                                Icons.upload,
                                                color: Colors.red[400],
                                              )),
                                    title: Text(
                                      snapshot.data![index].transaction.amount
                                          .toString(),
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Center(
                          child: Column(
                            children: [
                              SizedBox(height: 30),
                              Text("Belum ada transaksi",
                                  style: GoogleFonts.montserrat()),
                            ],
                          ),
                        );
                      }
                    } else {
                      return Center(
                        child: Text("Belum ada transaksi"),
                      );
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}

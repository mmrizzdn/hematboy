// Impor paket dan modul yang diperlukan.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uangkoo/models/database.dart';
import 'package:uangkoo/models/transaction.dart';
import 'package:uangkoo/models/transaction_with_category.dart';

// Definisikan widget stateful untuk halaman transaksi.
class TransactionPage extends StatefulWidget {
  // Data transaksi dengan kategori opsional.
  final TransactionWithCategory? transactionsWithCategory;
  // Konstruktor dengan kunci dan data transaksi.
  const TransactionPage({Key? key, required this.transactionsWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

// Definisikan state untuk halaman transaksi.
class _TransactionPageState extends State<TransactionPage> {
  // Boolean untuk mengindikasikan apakah transaksi adalah pengeluaran.
  bool isExpense = true;
  // Variabel untuk menyimpan tipe transaksi.
  late int type;
  // Inisialisasi database.
  final AppDb database = AppDb();
  // Variabel untuk menyimpan kategori yang dipilih.
  Category? selectedCategory;
  // Controller untuk text field.
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Metode untuk menyisipkan transaksi ke dalam database.
  Future insert(
      String description, int categoryId, int amount, DateTime date) async {
    DateTime now = DateTime.now(); // Mendapatkan tanggal dan waktu saat ini.
    // Menyisipkan transaksi dan mendapatkan baris yang disisipkan.
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            description: description,
            category_id: categoryId,
            amount: amount,
            transaction_date: date,
            created_at: now,
            updated_at: now));
  }

  @override
  void initState() {
    // Inisialisasi state dari widget.
    if (widget.transactionsWithCategory != null) {
      // Jika ada data transaksi, perbarui transaksi.
      updateTransaction(widget.transactionsWithCategory!);
    } else {
      // Mengatur tipe transaksi default ke 2 (pengeluaran).
      type = 2;
      // Kosongkan teks pada dateController.
      dateController.text = "";
    }
    super.initState(); // Memanggil metode initState dari kelas induk.
  }

  // Metode untuk mendapatkan semua kategori dari database.
  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  // Metode untuk memperbarui transaksi dengan data awal.
  void updateTransaction(TransactionWithCategory initTransaction) {
    // Mengatur teks pada amountController.
    amountController.text = initTransaction.transaction.amount.toString();
    // Mengatur teks pada descriptionController.
    descriptionController.text = initTransaction.transaction.description;
    // Memformat dan mengatur teks pada dateController.
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(initTransaction.transaction.transaction_date);
    // Mengatur tipe transaksi.
    type = initTransaction.category.type;
    // Mengatur apakah ini pengeluaran berdasarkan tipe.
    isExpense = (type == 2);
    // Mengatur kategori yang dipilih.
    selectedCategory = initTransaction.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // App bar dengan judul.
        appBar: AppBar(title: Text("Add Transaction")),
        // Body yang dapat digulir.
        body: SingleChildScrollView(
            child: SafeArea(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris untuk switch dan teks.
            Row(
              children: [
                // Switch untuk pengeluaran/pemasukan.
                Switch(
                  value: isExpense,
                  inactiveTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.green,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    setState(() {
                      // Mengubah status pengeluaran/pemasukan.
                      isExpense = value;
                      // Mengatur tipe transaksi berdasarkan nilai switch.
                      type = (isExpense) ? 2 : 1;
                      // Reset kategori yang dipilih.
                      selectedCategory = null;
                    });
                  },
                ),
                // Teks untuk pengeluaran/pemasukan.
                Text(
                  isExpense ? "Expense" : "Income",
                  style: GoogleFonts.montserrat(fontSize: 14),
                )
              ],
            ),
            // Padding untuk input jumlah.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount',
                ),
              ),
            ),
            SizedBox(height: 10), // Spasi.
            // Padding untuk label kategori.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Category", style: GoogleFonts.montserrat()),
            ),
            SizedBox(height: 5), // Spasi.
            // FutureBuilder untuk memuat kategori.
            FutureBuilder<List<Category>>(
              future: getAllCategory(type),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Indikator pemuatan.
                } else if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<Category>(
                      isExpanded: true,
                      value: (selectedCategory == null)
                          ? snapshot.data!.first
                          : selectedCategory,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (Category? newValue) {
                        setState(() {
                          selectedCategory =
                              newValue!; // Memperbarui kategori yang dipilih.
                        });
                      },
                      items: snapshot.data!.map((Category value) {
                        return DropdownMenuItem<Category>(
                          value: value,
                          child: Text(value.name), // Menampilkan nama kategori.
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return Text(
                      "Belum ada kategori"); // Pesan jika belum ada kategori.
                }
              },
            ),
            SizedBox(height: 10), // Spasi.
            // Padding untuk input tanggal.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Enter Date"),
                readOnly: true, // Membuat text field hanya baca.
                onTap: () async {
                  // Menampilkan pemilih tanggal.
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));

                  if (pickedDate != null) {
                    // Memformat tanggal yang dipilih.
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      dateController.text =
                          formattedDate; // Mengatur teks pada dateController.
                    });
                  } else {
                    print(
                        "Date is not selected"); // Pesan jika tanggal tidak dipilih.
                  }
                },
              ),
            ),
            // Padding untuk input deskripsi.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            SizedBox(height: 20), // Spasi.
            // Tombol simpan.
            Center(
                child: ElevatedButton(
                    onPressed: () {
                      if (selectedCategory != null) {
                        // Memanggil metode insert untuk menyimpan transaksi.
                        insert(
                            descriptionController.text,
                            selectedCategory!.id,
                            int.parse(amountController.text),
                            DateTime.parse(dateController.text));
                        Navigator.pop(
                            context, true); // Kembali ke halaman sebelumnya.
                      } else {
                        print(
                            "Error: selectedCategory is null"); // Pesan jika kategori belum dipilih.
                      }
                    },
                    child: Text('Save')))
          ],
        ))));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uangkoo/models/database.dart';

// Definisikan widget stateful untuk halaman kategori.
class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

// Definisikan state untuk halaman kategori.
class _CategoryPageState extends State<CategoryPage> {
  bool?
      isExpense; // Variabel untuk menentukan jenis kategori (pengeluaran atau pendapatan).
  int? type; // Variabel untuk menyimpan tipe kategori.
  final AppDb database = AppDb(); // Inisialisasi database.
  List<Category> listCategory = []; // Daftar kategori.
  TextEditingController categoryNameController =
      TextEditingController(); // Controller untuk input nama kategori.

  // Fungsi untuk mendapatkan semua kategori berdasarkan tipe.
  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  // Fungsi untuk menambahkan kategori baru ke database.
  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updatedAt: now));
  }

  // Fungsi untuk memperbarui nama kategori.
  Future update(int categoryId, String newName) async {
    await database.updateCategoryRepo(categoryId, newName);
  }

  @override
  void initState() {
    // Inisialisasi nilai isExpense dan type.
    isExpense = true;
    type = (isExpense!) ? 2 : 1;
    super.initState();
  }

  // Fungsi untuk membuka dialog tambah/edit kategori.
  void openDialog(Category? category) {
    categoryNameController.clear();
    if (category != null) {
      categoryNameController.text = category.name;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Center(
                    child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  ((category != null) ? 'Edit ' : 'Add ') +
                      ((isExpense!) ? "Outcome" : "Income"),
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: (isExpense!) ? Colors.red : Colors.green),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: categoryNameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Name"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      (category == null)
                          ? insert(
                              categoryNameController.text, isExpense! ? 2 : 1)
                          : update(category.id, categoryNameController.text);
                      setState(() {});

                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: Text("Save"))
              ],
            ))),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Switch untuk memilih jenis kategori (pengeluaran atau pendapatan).
                  Switch(
                    value: isExpense!,
                    inactiveTrackColor: Colors.green[200],
                    inactiveThumbColor: Colors.green,
                    activeColor: Colors.red,
                    onChanged: (bool value) {
                      setState(() {
                        isExpense = value;
                        type = (value) ? 2 : 1;
                      });
                    },
                  ),
                  Text(
                    isExpense! ? "Pengeluaran" : "Pemasukan",
                    style: GoogleFonts.montserrat(fontSize: 14),
                  )
                ],
              ),
              IconButton(
                  onPressed: () {
                    openDialog(null);
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ),
        // FutureBuilder untuk menampilkan daftar kategori berdasarkan tipe.
        FutureBuilder<List<Category>>(
            future: getAllCategory(type!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Tombol untuk menghapus kategori.
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          database.deleteCategoryRepo(
                                              snapshot.data![index].id);
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      // Tombol untuk mengedit kategori.
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          openDialog(snapshot.data![index]);
                                        },
                                      )
                                    ],
                                  ),
                                  leading: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: (isExpense!)
                                          ? Icon(Icons.upload,
                                              color: Colors.redAccent[400])
                                          : Icon(Icons.download,
                                              color: Colors.greenAccent[400])),
                                  title: Text(snapshot.data![index].name)),
                            ),
                          );
                        });
                  } else {
                    return Center(
                      child: Text("No data available"),
                    );
                  }
                } else {
                  return Center(
                    child: Text("No data available"),
                  );
                }
              }
            }),
      ])),
    );
  }
}

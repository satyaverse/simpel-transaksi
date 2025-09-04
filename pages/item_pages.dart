import 'package:flutter/material.dart';
import '../db/db_item.dart';
import '../models/item_model.dart';
import '../widgets/item_form.dart';
import 'package:intl/intl.dart';

final formatter = NumberFormat('#,###', 'id_ID');

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final DBItem dbItem = DBItem();
  List<Item> itemList = [];
  List<Item> filteredList = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await dbItem.getItemList();
    setState(() {
      itemList = data;
      filteredList = data; // isi awal langsung semua data
    });
  }

  void addOrUpdate(Item item) async {
    if (item.id == null) {
      await dbItem.insertItem(item);
    } else {
      await dbItem.updateItem(item);
    }
    loadData();
  }

  Future<void> deleteItem(Item item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Yakin hapus ${item.nama}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dbItem.deleteItem(item.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item.nama} dihapus")),
      );
      loadData();
    }
  }

  void filterSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredList = itemList;
      } else {
        filteredList = itemList
            .where((item) =>
                item.nama.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Produk"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: filterSearch,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("Belum ada data produk"))
                : ListView.builder(
                    itemCount: filteredList.length,
                    padding: const EdgeInsets.only(bottom: 70),
                    itemBuilder: (_, index) {
                      final item = filteredList[index];
                      return ListTile(
                        title: Text(
                          item.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Rp ${formatter.format(item.harga)}\n"
                          "Stok: ${formatter.format(item.stok)}\n"
                          "${item.keterangan}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => ItemForm(
                                  item: item,
                                  onSubmit: (updated) => addOrUpdate(updated),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteItem(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: SizedBox(
        width: double.infinity, // full lebar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ItemForm(
                onSubmit: (newItem) => addOrUpdate(newItem),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Tambah Produk"),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

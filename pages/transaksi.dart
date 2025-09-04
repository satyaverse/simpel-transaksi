import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_item.dart';
import '../models/item_model.dart';
import '../models/riwayat_model.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final DBItem dbItem = DBItem();
  List<Item> items = [];
  String searchQuery = '';

  final _currencyFmt = NumberFormat("#,###", "id_ID");

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final list = await dbItem.getItemList();
    setState(() {
      items = list;
    });
  }

  List<Item> get filteredItems {
    if (searchQuery.isEmpty) return items;
    return items
        .where((p) => p.nama.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  int get itemsTotal =>
      items.where((p) => p.isChecked).fold(0, (sum, p) => sum + p.subtotal);

  void _toggleSelect(Item p) {
    setState(() => p.isChecked = !p.isChecked);
  }

  void _incQty(Item p) {
    setState(() => p.qty++);
  }

  void _decQty(Item p) {
    if (p.qty > 1) setState(() => p.qty--);
  }

  void _resetItems() {
  items = items.map((p) {
    return p.copyWith(
      isChecked: false,
      qty: 1,
    );
  }).toList();
}

  Future<void> _simpan() async {
  final selected = items.where((p) => p.isChecked).toList();

  // Validasi kalau belum pilih item
  if (selected.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pilih minimal 1 item sebelum bayar')),
    );
    return;
  }

  // Cek stok
  for (var p in selected) {
    if (p.qty > p.stok) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Stok Tidak Cukup !"),
          //content: Text(
            //"Stok ${p.nama} hanya ${p.stok}, tapi dipesan ${p.qty}."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup"),
            ),
          ],
        ),
      );
      return;
    }
  }

  // Format tanggal
  final now = DateTime.now().toString().substring(0, 19);

  // Gabungkan list item jadi string
  final itemListString = selected
      .map((p) => "${p.nama} (${p.qty}) : Rp ${_fmt(p.subtotal)}")
      .join("\n");

  if (!mounted) return;

  // Tampilkan dialog konfirmasi
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Konfirmasi Transaksi'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...selected.map((p) => Text(
                  '${p.nama} (${p.qty}) : Rp ${_fmt(p.subtotal)}',
                )),
            const Divider(),
            Text(
              'Total : Rp ${_fmt(itemsTotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Proses'),
        ),
      ],
    ),
  );

  // Cek hasil dialog
  if (result == true && mounted) {
    // User menekan Proses → kurangi stok & simpan riwayat
    for (var p in selected) {
      final newStok = p.stok - p.qty;
      await dbItem.updateItem(p.copyWith(stok: newStok));
    }

    // Simpan ke riwayat sekali saja
    final history = TransactionHistory(
      date: now,
      total: itemsTotal,
      items: itemListString,
    );
    await dbItem.insertHistory(history);

    if (!mounted) return;
    // Refresh list dari database (stok baru)
    await _loadItems();

    // Reset checkbox & qty
    setState(_resetItems);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi diproses')),
    );
  } else if (result == false && mounted) {
    // Batal → tidak ubah stok
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi dibatalkan')),
    );
  }
}

  String _fmt(int value) => _currencyFmt.format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Cari ...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...filteredItems.map(_buildProductTile),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: Rp ${_fmt(itemsTotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ElevatedButton(
              onPressed: _simpan,
              child: const Text("Proses"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(Item p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Checkbox(value: p.isChecked, onChanged: (_) => _toggleSelect(p)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Rp ${_fmt(p.harga)}'),
                  const SizedBox(height: 5),
                  Text('Stok : ${_fmt(p.stok)}'),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: p.isChecked ? () => _decQty(p) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${p.qty}'),
                    IconButton(
                      onPressed: p.isChecked ? () => _incQty(p) : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Text(
                  'Rp ${_fmt(p.subtotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

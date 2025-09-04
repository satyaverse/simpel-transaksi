import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemForm extends StatefulWidget {
  final Item? item;
  final Function(Item) onSubmit;

  const ItemForm({super.key, this.item, required this.onSubmit});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _namaController.text = widget.item!.nama;
      _hargaController.text = widget.item!.harga.toString();
      _stokController.text = widget.item!.stok.toString();
      _keteranganController.text = widget.item!.keterangan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? "Tambah Item" : "Edit Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _namaController, decoration: InputDecoration(labelText: "Nama")),
          TextField(controller: _hargaController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Harga")),
          TextField(controller: _stokController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Stok")),
          TextField(controller: _keteranganController, decoration: InputDecoration(labelText: "Keterangan")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
        ElevatedButton(
          onPressed: () {
            if (_namaController.text.isEmpty) {
            // tampilkan SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nama tidak boleh kosong')),
              );
              return; // hentikan eksekusi selanjutnya
            }


            final item = Item(
              id: widget.item?.id,
              nama: _namaController.text,
              harga: int.tryParse(_hargaController.text) ?? 0,
              stok: int.tryParse(_stokController.text) ?? 0,
              keterangan: _keteranganController.text.isEmpty 
                ? "-" 
                : _keteranganController.text,
            );
            widget.onSubmit(item);
            Navigator.pop(context);
          },
          child: Text("Simpan"),
        ),
      ],
    );
  }
}

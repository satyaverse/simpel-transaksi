import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../db/db_item.dart';
import '../models/riwayat_model.dart';

final formatter = NumberFormat.decimalPattern('id');

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final DBItem dbItem = DBItem();
  List<TransactionHistory> history = [];
  List<TransactionHistory> allHistory = []; // simpan semua transaksi
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await dbItem.getHistoryList();
    setState(() {
      allHistory = list;
      history = allHistory.take(100).toList(); // default tampilkan 100 terakhir
    });
  }

//  Future<void> _deleteHistory(int id) async {
//    await dbItem.deleteHistory(id);
//    _loadHistory();
//  }

  void _search(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        // jika kosong, tampilkan 100 terakhir
        history = allHistory.take(1000).toList();
      } else {
        // tampilkan hasil search (tanpa batasan 100)
        history = allHistory.where((h) {
          final text = "${h.date} ${h.items} ${h.total}".toLowerCase();
          return text.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  /// Helper untuk merapikan tampilan item
  Widget _buildItemList(String items) {
    final lines = items.split("\n");
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: IntrinsicColumnWidth(),
      },
      children: lines.map((line) {
        final parts = line.split(":");
        final leftRaw = parts[0].trim();
        final right = parts.length > 1 ? parts[1].trim() : "";

        final left = leftRaw.replaceAllMapped(
          RegExp(r"x(\d+)"),
          (match) => "(${match.group(1)})",
        );

        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(left),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                right,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Cetak struk ukuran A4
  Future<void> _printStrukA4(TransactionHistory h) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 8),
              pw.Text(h.date),
              pw.Text("Total: Rp ${formatter.format(h.total)}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              ...h.items.split("\n").map((line) {
                final parts = line.split(":");
                final leftRaw = parts[0].trim();
                final right = parts.length > 1 ? parts[1].trim() : "";
                final left = leftRaw.replaceAllMapped(
                  RegExp(r"x(\\d+)"),
                  (m) => "(${m.group(1)})",
                );
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(left),
                    pw.Text(right),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Cetak struk ukuran POS 58mm / 80mm
  Future<void> _printStrukPOS(TransactionHistory h, {bool is80mm = false}) async {
    final pdf = pw.Document();

    final pageFormat = is80mm
        ? PdfPageFormat(80 * PdfPageFormat.mm, double.infinity,
            marginAll: 5 * PdfPageFormat.mm)
        : PdfPageFormat(58 * PdfPageFormat.mm, double.infinity,
            marginAll: 5 * PdfPageFormat.mm);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 6),
              pw.Text(h.date, style: pw.TextStyle(fontSize: 10)),
              pw.Text("Total: Rp ${formatter.format(h.total)}",
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              ...h.items.split("\n").map((line) {
                final parts = line.split(":");
                final leftRaw = parts[0].trim();
                final right = parts.length > 1 ? parts[1].trim() : "";
                final left = leftRaw.replaceAllMapped(
                  RegExp(r"x(\\d+)"),
                  (m) => "(${m.group(1)})",
                );
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(left, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(right, style: const pw.TextStyle(fontSize: 10)),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void _showDetailDialog(TransactionHistory h) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(h.date),
            const SizedBox(height: 4),
            Text(
              "Total: Rp ${formatter.format(h.total)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildItemList(h.items),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPrintOptions(h);
            },
            child: const Text("Print"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showPrintOptions(TransactionHistory h) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pilih Ukuran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Printer Biasa (A4)"),
              onTap: () {
                Navigator.pop(context);
                _printStrukA4(h);
              },
            ),
            ListTile(
              title: const Text("Printer POS 58mm"),
              onTap: () {
                Navigator.pop(context);
                _printStrukPOS(h, is80mm: false);
              },
            ),
            ListTile(
              title: const Text("Printer POS 80mm"),
              onTap: () {
                Navigator.pop(context);
                _printStrukPOS(h, is80mm: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Cari transaksi...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _search,
            ),
          ),
        ),
      ),
      body: history.isEmpty
          ? const Center(child: Text("Belum ada Transaksi"))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final h = history[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      h.date,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rp ${formatter.format(h.total)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        _buildItemList(h.items),
                      ],
                    ),
                    onTap: () => _showDetailDialog(h),
                    //trailing: IconButton(
                      //icon: const Icon(Icons.delete, color: Colors.red),
                      //onPressed: () async {
                        //final confirm = await showDialog<bool>(
                          //context: context,
                          //builder: (context) => AlertDialog(
                            //title: const Text("Konfirmasi Hapus"),
                            //content: const Text("Yakin hapus transaksi ini?"),
                           // actions: [
                             // TextButton(
                              //  child: const Text("Batal"),
                              //  onPressed: () =>
                              //      Navigator.pop(context, false),
                            //  ),
                             // ElevatedButton(
                              //  child: const Text("Hapus"),
                              //  onPressed: () =>
                                //    Navigator.pop(context, true),
                              //),
                            //],
                          ),
                        //);
                        //if (confirm == true) {
                        //  _deleteHistory(h.id!);
                        //}
                      //},
                    //),
                  //),
                );
              },
            ),
    );
  }
}

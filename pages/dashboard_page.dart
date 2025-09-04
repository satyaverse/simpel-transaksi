import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/db_item.dart';
import '../models/riwayat_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DBItem dbItem = DBItem();
  List<HourlySales> hourlySales = [];

  @override
  void initState() {
    super.initState();
    _loadHourly();
  }

  Future<void> _loadHourly() async {
    final sales = await _getSalesPerHour();
    setState(() => hourlySales = sales);
  }

  /// Ambil data penjualan per jam untuk hari ini
  Future<List<HourlySales>> _getSalesPerHour() async {
    final db = await dbItem.database;
    final result = await db.query('riwayat');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Inisialisasi jam 0..23 = 0
    final Map<int, int> grouped = {for (var h = 0; h < 24; h++) h: 0};

    for (var row in result) {
      final history = TransactionHistory.fromMap(row);
      final dt = DateTime.parse(history.date);

      // hanya transaksi hari ini
      if (dt.year == today.year && dt.month == today.month && dt.day == today.day) {
        grouped[dt.hour] = (grouped[dt.hour] ?? 0) + history.total;
      }
    }

    return grouped.entries.map((e) => HourlySales(e.key, e.value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Penjualan Harian")),
      body: hourlySales.isEmpty
          ? const Center(child: Text("Belum ada data penjualan hari ini"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: HourlyChart(data: hourlySales),
            ),
    );
  }
}

class HourlyChart extends StatelessWidget {
  final List<HourlySales> data;

  const HourlyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2, // tampilkan tiap 2 jam
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() > 23) return Container();
                return Text("${value.toInt()}h", style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
            spots: data
                .map((e) => FlSpot(e.hour.toDouble(), e.total.toDouble()))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Model untuk penjualan per jam
class HourlySales {
  final int hour; // 0..23
  final int total;

  HourlySales(this.hour, this.total);
}

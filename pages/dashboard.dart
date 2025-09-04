import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/db_item.dart';
import 'help.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin {
  final DBItem dbItem = DBItem();
  int totalHarian = 0;
  int jumlahTransaksi = 0;
  String today = "";
  int totalBulanan = 0;
  int jumlahTransaksiBulanan = 0;

  Map<String, int> dailyIncome = {};
  Map<String, int> monthlyIncome = {};
  Map<String, int> monthlyTransactions = {};

  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final list = await dbItem.getHistoryList();
    final now = DateTime.now();
    today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // --- income per hari (1 minggu terakhir) ---
    dailyIncome.clear();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final todayHistory = list.where((h) => h.date.startsWith(key)).toList();
      final sum = todayHistory.fold<int>(0, (total, h) => total + h.total);
      dailyIncome[key] = sum;
    }

    // --- income per bulan (6 bulan terakhir) ---
    monthlyIncome.clear();
    monthlyTransactions.clear();
    
    for (int i = 5; i >= 0; i--) {
      final monthOffset = i;
      final date = DateTime(now.year, now.month - monthOffset, 1);
      
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      
      final monthHistory = list.where((h) => h.date.startsWith(key)).toList();
      final sum = monthHistory.fold<int>(0, (total, h) => total + h.total);
      final transactionCount = monthHistory.length;
      
      monthlyIncome[key] = sum;
      monthlyTransactions[key] = transactionCount;
    }

    // Data hari ini
    final todayHistory = list.where((h) => h.date.startsWith(today)).toList();
    final sum = todayHistory.fold<int>(0, (total, h) => total + h.total);

    // Data bulan ini
    final bulanIniKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final bulanIniHistory = list.where((h) => h.date.startsWith(bulanIniKey)).toList();
    final totalBulanIni = bulanIniHistory.fold<int>(0, (total, h) => total + h.total);

    setState(() {
      totalHarian = sum;
      jumlahTransaksi = todayHistory.length;
      totalBulanan = totalBulanIni;
      jumlahTransaksiBulanan = bulanIniHistory.length;
    });
  }

  String _fmt(int value) {
    if (value == 0) return "0";
    
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buffer.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  String _formatDateDisplay(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _formatMonthDisplay(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length >= 2) {
        final month = int.tryParse(parts[1]);
        //final year = parts[0];
        if (month != null) {
          final monthNames = [
            'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
            'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
          ];
          return ' ${monthNames[month - 1]}';
        }
      }
      return monthStr;
    } catch (e) {
      return monthStr;
    }
  }

Widget _buildDailyChart() {
  final spots = <FlSpot>[];
  int i = 0;

  final dailyKeys = dailyIncome.keys.toList();
  for (var key in dailyKeys) {
    final value = dailyIncome[key] ?? 0;
    // pastikan tidak negatif
    spots.add(FlSpot(i.toDouble(), value < 0 ? 0 : value.toDouble()));
    i++;
  }

  return LineChart(
    LineChartData(
      minY: 0,
      maxY: spots.isNotEmpty
          ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1
          : 1000,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text("0");
              String label;
              if (value >= 1000000) {
                double juta = value / 1000000;
                label = (juta % 1 == 0)
                    ? "${juta.toInt()}Jt"
                    : "${juta.toStringAsFixed(1)}Jt";
              } else if (value >= 1000) {
                double ribu = value / 1000;
                label = (ribu % 1 == 0)
                    ? "${ribu.toInt()}K"
                    : "${ribu.toStringAsFixed(1)}K";
              } else {
                label = value.toStringAsFixed(0);
              }
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(label, style: const TextStyle(fontSize: 10)),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < dailyKeys.length) {
                final key = dailyKeys[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatDateDisplay(key),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text("");
            },
          ),
        ),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(
  show: true,
  border: const Border(
    left: BorderSide(color: Colors.grey, width: 1),
    bottom: BorderSide(color: Colors.grey, width: 1),
    right: BorderSide.none,
    top: BorderSide.none,
  ),
),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          preventCurveOverShooting: true, // ⬅️ cegah garis overshoot ke bawah
          color: Colors.green,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.green.withValues(alpha: 0.2),
          ),
          dotData: const FlDotData(show: true),
        ),
      ],
    ),
  );
}


  Widget _buildMonthlyChart() {
  final spots = <FlSpot>[];
  int i = 0;

  final monthlyKeys = monthlyIncome.keys.toList();
  for (var key in monthlyKeys) {
    final value = monthlyIncome[key] ?? 0;
    // pastikan tidak negatif
    spots.add(FlSpot(i.toDouble(), value < 0 ? 0 : value.toDouble()));
    i++;
  }

  return LineChart(
    LineChartData(
      minY: 0,
      maxY: spots.isNotEmpty
          ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1
          : 1000,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text("0");
              String label;
              if (value >= 1000000) {
                double juta = value / 1000000;
                label = (juta % 1 == 0)
                    ? "${juta.toInt()}Jt"
                    : "${juta.toStringAsFixed(1)}Jt";
              } else if (value >= 1000) {
                double ribu = value / 1000;
                label = (ribu % 1 == 0)
                    ? "${ribu.toInt()}K"
                    : "${ribu.toStringAsFixed(1)}K";
              } else {
                label = value.toStringAsFixed(0);
              }
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(label, style: const TextStyle(fontSize: 10)),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < monthlyKeys.length) {
                final key = monthlyKeys[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatMonthDisplay(key),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text("");
            },
          ),
        ),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(
  show: true,
  border: const Border(
    left: BorderSide(color: Colors.grey, width: 1),
    bottom: BorderSide(color: Colors.grey, width: 1),
    right: BorderSide.none,
    top: BorderSide.none,
  ),
),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          preventCurveOverShooting: true, //  cegah garis turun ke bawah 0
          color: Colors.teal,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.teal.withValues(alpha: 0.2),
          ),
          dotData: const FlDotData(show: true),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.red),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Help()),
            );
          },
        ),
          
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Harian"),
            Tab(text: "Bulanan"),
            ],
          indicatorColor: Colors.teal,
          labelColor: Colors.black,          // warna teks tab aktif
  unselectedLabelColor: Colors.black,      // warna teks tab non-aktif
         labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Harian
          SingleChildScrollView(
            child: Column(
              children: [
                // Kartu ringkasan harian
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Pendapatan Hari Ini",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text("Rp ${_fmt(totalHarian)}",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green)),
                                const SizedBox(height: 4),
                                Text(today, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Transaksi Hari Ini",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text("$jumlahTransaksi",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.purple)),
                                const SizedBox(height: 4),
                                const Text("Transaksi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chart income 7 hari terakhir
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pendapatan 7 Hari Terakhir",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: _buildDailyChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bulanan
          SingleChildScrollView(
            child: Column(
              children: [
                // Kartu ringkasan bulanan
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Pendapatan Bulan Ini",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text("Rp ${_fmt(totalBulanan)}",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.teal)),
                                const SizedBox(height: 4),
                                Text("${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Transaksi Bulan Ini",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text("$jumlahTransaksiBulanan",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                                const SizedBox(height: 4),
                                const Text("Transaksi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chart income 6 bulan terakhir
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pendapatan 6 Bulan Terakhir",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: _buildMonthlyChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      //floatingActionButton: FloatingActionButton(
        //onPressed: () {
          //setState(() {
            //_isLoading = true;
          //});
          //loadData().then((_) {
            //setState(() {
              //_isLoading = false;
            //});
          //});
        //},
        //child: const Icon(Icons.refresh),
      //),
      //floatingActionButton: FloatingActionButton.extended(
        //onPressed: () {
          //Navigator.push(
            //context,
            //MaterialPageRoute(builder: (context) => Help()),
          //);
        //},
        //icon: const Icon(Icons.help),
        //label: const Text("Bantuan"), 
        
      //),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
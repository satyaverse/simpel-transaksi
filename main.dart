import 'dart:io';
import 'pages/riwayat.dart';
import 'package:flutter/material.dart';
import 'pages/item_pages.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/transaksi.dart';
import 'pages/dashboard.dart';





void main() {
  if (Platform.isAndroid || Platform.isIOS) {
    
  } else {
    
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const Dasar());
}

class Dasar extends StatelessWidget {
  const Dasar({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
    home: NavigationExample());
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.grey,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_outlined),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(                     
            selectedIcon: Icon(Icons.app_registration),
            icon: Icon(Icons.apps),
            label: 'Produk',
          ),
        ],
      ),
      
      body: <Widget>[
        /// Home page
        InfoPage(),

        /// Transaksi
        TransactionPage(),

        ///Riwayat page
        RiwayatPage(),

        /// Item page
        ItemPage()
        
      ][currentPageIndex],
    );
  }
}

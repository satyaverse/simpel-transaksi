import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text("Cara Pakai"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.black),
                children: [
                  TextSpan(text: "Versi Aplikasi transaksi ini sifatnya "),
                  TextSpan(
                    text: "GRATIS !",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  TextSpan(text: ". Bertujuan untuk membantu UMKM di Indonesia."),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.black),
                children: [
                  TextSpan(text: "Aplikasi ini terdiri dari 4 menu utama dibagian bawah : "),
                  TextSpan(
                    text: "Home, Transaksi, Riwayat, dan Produk",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.black),
                children: [
                  TextSpan(text: "Sebelum memulai transaksi, tambahkan Produk di menu "),
                  TextSpan(
                    text: "Produk",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(text: " agar terdaftar di menu "),
                  TextSpan(
                    text: "Transaksi",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(text: ". Stok jangan dikosongkan."),
                ],
              ),
            ),
            SizedBox(height: 16.0),
 
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.black),
                children: [
                  TextSpan(text: "Pada menu "),
                  TextSpan(
                    text: "Transaksi",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(text: ", Produk harus dicentang dulu untuk bisa memilih jumlahnya. "),
                  TextSpan(text: "periksa kembali pilihan produk yang sudah dicentang, akan ada peringatan jika stok kurang. "),
                  TextSpan(text: "Konfirmasi kembali transaksi sebelum proses. "),
                  TextSpan(text: "Untuk print struk bisa lanjut ke menu "),
                  TextSpan(
                    text: "Riwayat ",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),          
            SizedBox(height: 16.0),
            
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.black),
                children: [
                  TextSpan(text: "Transaksi yang sudah diproses bisa dilihat di menu "),
                  TextSpan(
                    text: "Riwayat",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(text: ". untuk print struk bisa dengan langsung menekan pada daftar transaksi di menu ini. "),
                  TextSpan(text: "struk bisa juga disimpan dengan format pdf. "),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.black),
                children: [
                  TextSpan(text: "Jumlah penjualan dan banyaknya transaksi bisa langsung dilihat di menu "),
                  TextSpan(
                    text: "Home",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  
                ],
              ),
            ),
            
            SizedBox(height: 16.0),
            Text("Selamat menjalankan usaha, semoga Tuhan melimpahi kita dengan rejeki dan kesehatan.", style: TextStyle(fontSize: 16.0, height: 1.5),)
          ],
        ),
      ),
    );
  }
}

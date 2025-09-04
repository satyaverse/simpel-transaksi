class Item {
  final int? id;
  final String nama;
  final int harga;
  final int stok;
  final String keterangan;
  bool isChecked;
  int qty;

  Item({
    this.id,
    required this.nama,
    required this.harga,
    this.stok = 0,
    this.keterangan = '',
    this.isChecked = false,
    this.qty = 1,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      harga: map['harga'] as int,
      stok: map['stok'] as int,
      keterangan: map['keterangan'] ?? '',
      isChecked: false,
      qty: 1, // default qty
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'keterangan': keterangan,
      //'isChecked': isChecked ? 1 : 0,
    };
  }

  Item copyWith({
  int? id,
  String? nama,
  int? harga,
  int? stok,
  String? keterangan,
  bool? isChecked,
  int? qty,
}) {
  return Item(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    harga: harga ?? this.harga,
    stok: stok ?? this.stok,
    keterangan: keterangan ?? this.keterangan,
    isChecked: isChecked ?? this.isChecked,
    qty: qty ?? this.qty,
  );
}

  
  int get subtotal => harga * qty;
}


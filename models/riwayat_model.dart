class TransactionHistory {
  final int? id;
  final String date;
  final int total;
  final String items; // simpan list item dalam bentuk string JSON

  TransactionHistory({
    this.id,
    required this.date,
    required this.total,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'total': total,
      'items': items,
    };
  }

  factory TransactionHistory.fromMap(Map<String, dynamic> map) {
    return TransactionHistory(
      id: map['id'],
      date: map['date'],
      total: map['total'],
      items: map['items'],
    );
  }
}


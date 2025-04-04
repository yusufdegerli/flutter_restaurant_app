class Ticket {
  final int id;
  final String name;
  final String ticketNumber;
  final String? customerName;
  final double remainingAmount;
  final double totalAmount;
  final String? note;
  final String? tag;

  Ticket({
    required this.id,
    required this.name,
    required this.ticketNumber,
    this.customerName,
    required this.remainingAmount,
    required this.totalAmount,
    this.note,
    this.tag,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      name: json['name'] ?? 'No Name',
      ticketNumber: json['ticketNumber'] ?? 'No Number',
      customerName: json['customerName'],
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      note: json['note'],
      tag: json['tag'],
    );
  }
}

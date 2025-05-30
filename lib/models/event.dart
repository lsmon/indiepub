class Event {
  final int id;
  final String name;
  final DateTime date;
  final String location;
  final double price;
  final int capacity;
  final String creatorId;
  final int sold;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.price,
    required this.capacity,
    required this.creatorId,
    required this.sold,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      price: json['price'].toDouble(),
      capacity: json['capacity'],
      creatorId: json['creator_id'],
      sold: json['sold'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'price': price,
      'capacity': capacity,
      'creator_id': creatorId,
      'sold': sold,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
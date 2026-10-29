class OutletModel {
  final int id;
  final String name;
  final String restaurantName;
  final String? address;
  final String? phone;
  final String activeShift;
  final DateTime date;

  const OutletModel({
    required this.id,
    required this.name,
    this.restaurantName = 'Seafood Restaurant',
    this.address = 'Jl. Pantai Indah No. 88',
    this.phone = '021-5558899',
    this.activeShift = 'Shift Aktif',
    required this.date,
  });

  factory OutletModel.defaultOutlet() {
    return OutletModel(
      id: 1,
      name: 'Cabang Utama',
      restaurantName: 'Seafood Restaurant',
      address: 'Jl. Pantai Indah No. 88, Jakarta',
      phone: '021-5558899',
      activeShift: 'Shift Pagi / Siang',
      date: DateTime.now(),
    );
  }

  factory OutletModel.fromJson(Map<String, dynamic> json) {
    return OutletModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? 'Cabang Utama',
      restaurantName: json['restaurant_name']?.toString() ?? 'Seafood Restaurant',
      address: json['address']?.toString() ?? 'Jl. Pantai Indah No. 88',
      phone: json['phone']?.toString() ?? '021-5558899',
      activeShift: json['shift']?.toString() ?? 'Shift Aktif',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'restaurant_name': restaurantName,
      'address': address,
      'phone': phone,
      'shift': activeShift,
      'date': date.toIso8601String(),
    };
  }
}


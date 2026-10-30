class ReceiptConfigModel {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String footerMessage;

  const ReceiptConfigModel({
    this.id,
    this.name = 'SEAFOOD RESTO POS',
    this.address = 'Jl. Pelabuhan Ikan No. 88',
    this.phone = '0812-3456-7890',
    this.footerMessage = '*** TERIMA KASIH ***\nSelamat Menikmati Hidangan Kami',
  });

  factory ReceiptConfigModel.fromJson(Map<String, dynamic> json) {
    return ReceiptConfigModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'SEAFOOD RESTO POS',
      address: json['address']?.toString() ?? 'Jl. Pelabuhan Ikan No. 88',
      phone: json['phone']?.toString() ?? '0812-3456-7890',
      footerMessage: json['footer_message']?.toString() ?? '*** TERIMA KASIH ***\nSelamat Menikmati Hidangan Kami',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'footer_message': footerMessage,
    };
  }

  ReceiptConfigModel copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? footerMessage,
  }) {
    return ReceiptConfigModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      footerMessage: footerMessage ?? this.footerMessage,
    );
  }
}


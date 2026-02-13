class PaymentModel {
  final String? id;
  final String userId;
  final double amount;
  final String cardLast4;
  final String cardHolder;
  final String transactionId;
  final DateTime timestamp;
  final String status; // pending, completed, failed
  final String? recipientCard;

  PaymentModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.cardLast4,
    required this.cardHolder,
    required this.transactionId,
    DateTime? timestamp,
    this.status = 'pending',
    this.recipientCard,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for MongoDB
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'amount': amount,
      'cardLast4': cardLast4,
      'cardHolder': cardHolder,
      'transactionId': transactionId,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      if (recipientCard != null) 'recipientCard': recipientCard,
    };
  }

  // Create from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id']?.toString(),
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      cardLast4: json['cardLast4'] as String,
      cardHolder: json['cardHolder'] as String,
      transactionId: json['transactionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'pending',
      recipientCard: json['recipientCard'] as String?,
    );
  }

  // Create a copy with updated fields
  PaymentModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? cardLast4,
    String? cardHolder,
    String? transactionId,
    DateTime? timestamp,
    String? status,
    String? recipientCard,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardHolder: cardHolder ?? this.cardHolder,
      transactionId: transactionId ?? this.transactionId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      recipientCard: recipientCard ?? this.recipientCard,
    );
  }
}

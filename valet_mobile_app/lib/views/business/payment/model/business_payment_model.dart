class BusinessPaymentModel {
  final int? paymentId;
  final DateTime? paymentDate;
  final double amount;
  final String paymentMethod;
  final String ticketId;

  BusinessPaymentModel({
    this.paymentId,
    this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    required this.ticketId,
  });

  // JSON'dan model oluşturma
  factory BusinessPaymentModel.fromJson(Map<String, dynamic> json) {
    return BusinessPaymentModel(
      paymentId: json['payment_id'],
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      ticketId: json['ticket_id'] ?? '',
    );
  }

  // Model'den JSON oluşturma
  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'payment_date': paymentDate?.toIso8601String(),
      'amount': amount,
      'payment_method': paymentMethod,
      'ticket_id': ticketId,
    };
  }
}

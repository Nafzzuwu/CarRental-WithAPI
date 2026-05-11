
class PaymentModel {
  final String? id;
  final String? paymentCode;
  final dynamic booking; // Can be a String ID or a BookingModel map
  final dynamic user; // Can be a String ID or a UserModel map
  final double amount;
  final String method;
  final String status;
  final String? proofOfPayment;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? transactionId;
  final String? notes;
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final double? refundAmount;
  final String? refundReason;
  final dynamic verifiedBy;
  final DateTime? verifiedAt;
  final DateTime? createdAt;

  String? get bookingId {
    if (booking == null) return null;
    if (booking is String) return booking as String;
    if (booking is Map) {
      final map = booking as Map;
      return (map['_id'] ?? map['id'])?.toString();
    }
    return null;
  }

  PaymentModel({
    this.id,
    this.paymentCode,
    this.booking,
    this.user,
    required this.amount,
    required this.method,
    this.status = 'pending',
    this.proofOfPayment,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.transactionId,
    this.notes,
    this.paidAt,
    this.refundedAt,
    this.refundAmount,
    this.refundReason,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Safely parse amount - could be int or double
    double safeAmount = 0.0;
    if (json['amount'] != null) {
      safeAmount = (json['amount'] as num).toDouble();
    }

    // Safely parse dates
    DateTime? safeParse(String? val) {
      if (val == null) return null;
      try { return DateTime.parse(val); } catch (_) { return null; }
    }

    return PaymentModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      paymentCode: json['paymentCode']?.toString(),
      booking: json['booking'],
      user: json['user'],
      amount: safeAmount,
      method: json['method']?.toString() ?? 'transfer_bank',
      status: json['status']?.toString() ?? 'pending',
      proofOfPayment: json['proofOfPayment']?.toString(),
      bankName: json['bankName']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      accountName: json['accountName']?.toString(),
      transactionId: json['transactionId']?.toString(),
      notes: json['notes']?.toString(),
      paidAt: safeParse(json['paidAt']?.toString()),
      refundedAt: safeParse(json['refundedAt']?.toString()),
      refundAmount: json['refundAmount'] != null ? (json['refundAmount'] as num).toDouble() : null,
      refundReason: json['refundReason']?.toString(),
      verifiedBy: json['verifiedBy'],
      verifiedAt: safeParse(json['verifiedAt']?.toString()),
      createdAt: safeParse(json['createdAt']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (paymentCode != null) 'paymentCode': paymentCode,
      'amount': amount,
      'method': method,
      'status': status,
      if (proofOfPayment != null) 'proofOfPayment': proofOfPayment,
      if (bankName != null) 'bankName': bankName,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (accountName != null) 'accountName': accountName,
      if (transactionId != null) 'transactionId': transactionId,
      if (notes != null) 'notes': notes,
    };
  }
}

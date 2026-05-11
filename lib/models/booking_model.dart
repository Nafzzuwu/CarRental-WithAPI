import 'car_model.dart';
import 'user_model.dart';

class BookingModel {
  final String? id;
  final String? bookingCode;
  final UserModel? user;
  final CarModel? car;
  final DateTime startDate;
  final DateTime endDate;
  final int? duration;
  final double? pricePerDay;
  final double totalPrice;
  final String status;
  final String? pickupLocation;
  final String? returnLocation;
  final String? notes;
  final String? paymentStatus;
  final DateTime? createdAt;

  BookingModel({
    this.id,
    this.bookingCode,
    this.user,
    this.car,
    required this.startDate,
    required this.endDate,
    this.duration,
    this.pricePerDay,
    required this.totalPrice,
    this.status = 'pending',
    this.pickupLocation,
    this.returnLocation,
    this.notes,
    this.paymentStatus,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] as String?,
      bookingCode: json['bookingCode'] as String?,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
      car: json['car'] != null && json['car'] is Map<String, dynamic>
          ? CarModel.fromJson(json['car'])
          : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      duration: json['duration'] as int?,
      pricePerDay: json['pricePerDay'] != null
          ? (json['pricePerDay'] as num).toDouble()
          : null,
      totalPrice: json['totalPrice'] != null
          ? (json['totalPrice'] as num).toDouble()
          : 0.0,
      status: json['status'] as String? ?? 'pending',
      pickupLocation: json['pickupLocation'] as String?,
      returnLocation: json['returnLocation'] as String?,
      notes: json['notes'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (bookingCode != null) 'bookingCode': bookingCode,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      if (pickupLocation != null) 'pickupLocation': pickupLocation,
      if (returnLocation != null) 'returnLocation': returnLocation,
      if (notes != null) 'notes': notes,
    };
  }
}

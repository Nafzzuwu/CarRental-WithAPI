import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/booking_model.dart';
import 'auth_service.dart';

class BookingService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<BookingModel>> getUserBookings() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> bookingsJson = body['data']['bookings'] ?? [];
      return bookingsJson.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data booking');
    }
  }
  
  static Future<List<BookingModel>> getAllBookings() async {
    return getUserBookings();
  }

  static Future<BookingModel> createBooking({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    required String returnLocation,
    String? notes,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}');
    final headers = await _authHeaders();

    final requestBody = {
      'car': carId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'pickupLocation': pickupLocation,
      'returnLocation': returnLocation,
    };
    if (notes != null && notes.isNotEmpty) {
      requestBody['notes'] = notes;
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      String errMsg = body['message'] ?? 'Gagal membuat booking';
      if (body['errors'] != null && body['errors'] is List) {
        final List errors = body['errors'];
        if (errors.isNotEmpty) {
          errMsg += '\n${errors.map((e) => '- ${e['message']}').join('\n')}';
        }
      }
      throw Exception(errMsg);
    }
  }

  /// Cancel booking: PUT /api/bookings/:id/cancel
  static Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$bookingId/cancel');
    final headers = await _authHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'reason': reason ?? 'Dibatalkan oleh pengguna'}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membatalkan booking');
    }
  }

  /// Confirm booking (Admin): PUT /api/bookings/:id/confirm
  static Future<BookingModel> confirmBooking(String bookingId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$bookingId/confirm');
    final headers = await _authHeaders();

    final response = await http.put(url, headers: headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal mengkonfirmasi booking');
    }
  }

  /// Complete booking (Admin): PUT /api/bookings/:id/complete
  static Future<BookingModel> completeBooking(String bookingId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$bookingId/complete');
    final headers = await _authHeaders();

    final response = await http.put(url, headers: headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal menyelesaikan booking');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/payment_model.dart';
import 'auth_service.dart';

class PaymentService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<PaymentModel>> getAllPayments() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> paymentsJson = body['data']['payments'] ?? [];
      final List<PaymentModel> result = [];
      for (final json in paymentsJson) {
        try {
          result.add(PaymentModel.fromJson(json as Map<String, dynamic>));
        } catch (_) {
          // skip malformed items
        }
      }
      return result;
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data pembayaran');
    }
  }

  static Future<PaymentModel> createPayment({
    required String bookingId,
    required String method,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? transactionId,
    String? notes,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}');
    final headers = await _authHeaders();

    final payload = <String, dynamic>{
      'bookingId': bookingId,
      'method': method,
    };
    
    if (bankName != null) payload['bankName'] = bankName;
    if (accountNumber != null) payload['accountNumber'] = accountNumber;
    if (accountName != null) payload['accountName'] = accountName;
    if (transactionId != null) payload['transactionId'] = transactionId;
    if (notes != null) payload['notes'] = notes;

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      String errMsg = body['message'] ?? 'Gagal membuat pembayaran';
      if (body['errors'] != null && body['errors'] is List) {
        final List errors = body['errors'];
        if (errors.isNotEmpty) {
          errMsg += '\n${errors.map((e) => '- ${e['message']}').join('\n')}';
        }
      }
      throw Exception(errMsg);
    }
  }

  static Future<PaymentModel> verifyPayment(String paymentId, String status, {String? notes}) async {
    // Status must be 'success' or 'failed' based on the API
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}/$paymentId/verify');
    final headers = await _authHeaders();

    final payload = <String, dynamic>{'status': status};
    if (notes != null) payload['notes'] = notes;

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      String errMsg = body['message'] ?? 'Gagal memverifikasi pembayaran';
      if (body['errors'] != null && body['errors'] is List) {
        final List errors = body['errors'];
        if (errors.isNotEmpty) {
          errMsg += '\n${errors.map((e) => '- ${e['message']}').join('\n')}';
        }
      }
      throw Exception(errMsg);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:modul6apiflutter/config/app_colors.dart';
import 'package:modul6apiflutter/models/payment_model.dart';
import 'package:modul6apiflutter/services/payment_service.dart';
import 'package:modul6apiflutter/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

class PaymentVerificationScreen extends StatefulWidget {
  final String bookingId;
  const PaymentVerificationScreen({super.key, required this.bookingId});

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  List<PaymentModel> _payments = [];
  List<PaymentModel> _allPaymentsDebug = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final all = await PaymentService.getAllPayments();
      if (mounted) {
        setState(() {
          _allPaymentsDebug = all;
          _payments = all.where((p) => p.bookingId == widget.bookingId).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _verify(String id, String status) async {
    try {
      await PaymentService.verifyPayment(id, status);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status pembayaran diperbarui'), backgroundColor: AppColors.success)); Navigator.pop(context, true); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
    }
  }

  String _fmt(double p) { String s = p.toStringAsFixed(0); String r = ''; int c = 0; for (int i = s.length - 1; i >= 0; i--) { c++; r = s[i] + r; if (c % 3 == 0 && i != 0) r = '.$r'; } return r; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verifikasi Pembayaran'), backgroundColor: AppColors.background, elevation: 0),
      body: _isLoading ? const LoadingIndicator(message: 'Memuat data pembayaran...')
          : _errorMessage.isNotEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error), const SizedBox(height: 16),
              Text(_errorMessage, style: const TextStyle(color: AppColors.error)), const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetch, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Coba Lagi', style: TextStyle(color: Colors.white))),
            ]))
          : _payments.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.payment, size: 64, color: AppColors.textHint), const SizedBox(height: 16),
              const Text('Belum ada data pembayaran', style: TextStyle(color: AppColors.textSecondary)),
              // DEBUG INFO to help see if the ID matched anything
              const SizedBox(height: 16),
              Text('Booking ID: ${widget.bookingId}', style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
              Text('Total Payments In DB: ${_allPaymentsDebug.length}', style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
            ]))
          : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _payments.length, itemBuilder: (_, i) => _card(_payments[i])),
    );
  }

  Widget _card(PaymentModel p) {
    final df = DateFormat('dd MMM yyyy, HH:mm');
    final sc = p.status == 'success' ? AppColors.success : p.status == 'failed' ? AppColors.error : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(p.method.toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: sc.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(p.status.toUpperCase(), style: TextStyle(color: sc, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Jumlah Dibayar', style: TextStyle(color: AppColors.textSecondary)),
          Text('Rp ${_fmt(p.amount)}', style: const TextStyle(color: AppColors.secondary, fontSize: 17, fontWeight: FontWeight.bold)),
        ]),
        if (p.paidAt != null) ...[
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Waktu Bayar', style: TextStyle(color: AppColors.textSecondary)),
            Text(df.format(p.paidAt!), style: const TextStyle(color: AppColors.textSecondary)),
          ]),
        ],
        if (p.proofOfPayment != null && p.proofOfPayment!.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text('Bukti Pembayaran:', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8)),
            child: Text(p.proofOfPayment!, style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline)),
          ),
        ],
        if (p.notes != null && p.notes!.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text('Catatan:', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(p.notes!, style: const TextStyle(color: AppColors.textPrimary)),
        ],
        if (p.status == 'pending') ...[
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _verify(p.id!, 'failed'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Tolak'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () => _verify(p.id!, 'success'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Verifikasi', style: TextStyle(color: Colors.white)))),
          ]),
        ],
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:modul6apiflutter/config/app_colors.dart';
import 'package:modul6apiflutter/models/booking_model.dart';
import 'package:modul6apiflutter/services/payment_service.dart';
import 'package:modul6apiflutter/widgets/custom_text_field.dart';
import 'package:modul6apiflutter/widgets/loading_indicator.dart';

class PaymentFormScreen extends StatefulWidget {
  final BookingModel booking;
  const PaymentFormScreen({super.key, required this.booking});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _proofController = TextEditingController();
  String _selectedMethod = 'transfer_bank';
  bool _isLoading = false;
  final List<String> _methods = ['transfer_bank', 'kartu_kredit', 'kartu_debit', 'e_wallet', 'tunai'];

  @override
  void initState() { super.initState(); _amountController.text = widget.booking.totalPrice.toStringAsFixed(0); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await PaymentService.createPayment(bookingId: widget.booking.id!, method: _selectedMethod, notes: _proofController.text.isNotEmpty ? _proofController.text.trim() : null);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran dikirim! Menunggu verifikasi.'), backgroundColor: AppColors.success)); Navigator.pop(context, true); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  void dispose() { _amountController.dispose(); _proofController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pembayaran'), backgroundColor: AppColors.background, elevation: 0),
      body: _isLoading ? const LoadingIndicator(message: 'Memproses pembayaran...') : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              const Text('Total Tagihan', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 8),
              Text('Rp ${_amountController.text}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            ]),
          ),
          const SizedBox(height: 28),
          const Text('Metode Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedMethod, dropdownColor: AppColors.surface, style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              filled: true, fillColor: AppColors.surface,
            ),
            items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m.toUpperCase()))).toList(),
            onChanged: (v) => setState(() => _selectedMethod = v!),
          ),
          const SizedBox(height: 20),
          CustomTextField(label: 'Jumlah Transfer (Rp)', controller: _amountController, keyboardType: TextInputType.number, readOnly: true),
          CustomTextField(label: 'Catatan Pembayaran (Opsional)', hintText: 'Misal: Link bukti transfer', controller: _proofController),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Kirim Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ])),
      ),
    );
  }
}

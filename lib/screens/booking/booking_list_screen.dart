import 'package:flutter/material.dart';
import 'package:modul6apiflutter/config/app_colors.dart';
import 'package:modul6apiflutter/models/booking_model.dart';
import 'package:modul6apiflutter/services/booking_service.dart';
import 'package:modul6apiflutter/services/auth_service.dart';
import 'package:modul6apiflutter/widgets/loading_indicator.dart';
import 'package:modul6apiflutter/screens/payment/payment_form_screen.dart';
import 'package:modul6apiflutter/screens/payment/payment_verification_screen.dart';
import 'package:intl/intl.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _role = 'user';

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final role = await AuthService.getRole();
    if (mounted) { setState(() => _role = role ?? 'user'); _fetchBookings(); }
  }

  Future<void> _fetchBookings() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final bookings = _role == 'admin' ? await BookingService.getAllBookings() : await BookingService.getUserBookings();
      if (mounted) setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(String id) async {
    try {
      await BookingService.cancelBooking(id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibatalkan'), backgroundColor: AppColors.success)); _fetchBookings(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
    }
  }

  Future<void> _confirmBooking(String id) async {
    try {
      await BookingService.confirmBooking(id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dikonfirmasi'), backgroundColor: AppColors.success)); _fetchBookings(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
    }
  }

  String _fmt(double p) { String s = p.toStringAsFixed(0); String r = ''; int c = 0; for (int i = s.length - 1; i >= 0; i--) { c++; r = s[i] + r; if (c % 3 == 0 && i != 0) r = '.$r'; } return r; }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending': return AppColors.warning;
      case 'confirmed': return AppColors.primary;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Daftar Pesanan'), backgroundColor: AppColors.background, elevation: 0),
      body: _isLoading ? const LoadingIndicator(message: 'Memuat data pesanan...')
          : _errorMessage.isNotEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error), const SizedBox(height: 16),
              Text(_errorMessage, style: const TextStyle(color: AppColors.error)), const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchBookings, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Coba Lagi', style: TextStyle(color: Colors.white))),
            ]))
          : _bookings.isEmpty ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.receipt_long, size: 64, color: AppColors.textHint), SizedBox(height: 16),
              Text('Belum ada pesanan', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            ]))
          : RefreshIndicator(
              onRefresh: _fetchBookings, color: AppColors.primary, backgroundColor: AppColors.surface,
              child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _bookings.length, itemBuilder: (ctx, i) => _card(_bookings[i])),
            ),
    );
  }

  Widget _card(BookingModel b) {
    final sc = _statusColor(b.status);
    final df = DateFormat('dd MMM yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(b.car?.name ?? 'Mobil Dihapus', style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: sc.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(b.status.toUpperCase(), style: TextStyle(color: sc, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 10),
        if (_role == 'admin' && b.user != null) ...[
          Row(children: [const Icon(Icons.person, color: AppColors.textSecondary, size: 16), const SizedBox(width: 6), Text(b.user!.name, style: const TextStyle(color: AppColors.textSecondary))]),
          const SizedBox(height: 4),
        ],
        Row(children: [const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 16), const SizedBox(width: 6),
          Text('${df.format(b.startDate)} – ${df.format(b.endDate)}', style: const TextStyle(color: AppColors.textSecondary))]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(color: AppColors.textSecondary)),
          Text('Rp ${_fmt(b.totalPrice)}', style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 14),
        if (_role == 'user' && b.status == 'pending')
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentFormScreen(booking: b))); if (r == true) _fetchBookings(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white)),
          )),
        if (_role == 'admin') ...[
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentVerificationScreen(bookingId: b.id!))); if (r == true) _fetchBookings(); },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Verifikasi Pembayaran'),
          )),
          if (b.status == 'pending') Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _cancelBooking(b.id!), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Tolak'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () => _confirmBooking(b.id!), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)))),
          ])),
        ],
      ]),
    );
  }
}

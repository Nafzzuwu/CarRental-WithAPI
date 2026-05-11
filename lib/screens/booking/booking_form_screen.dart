import 'package:flutter/material.dart';
import 'package:modul6apiflutter/config/app_colors.dart';
import 'package:modul6apiflutter/models/car_model.dart';
import 'package:modul6apiflutter/services/booking_service.dart';
import 'package:modul6apiflutter/widgets/custom_text_field.dart';
import 'package:modul6apiflutter/widgets/loading_indicator.dart';

class BookingFormScreen extends StatefulWidget {
  final CarModel car;
  const BookingFormScreen({super.key, required this.car});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _returnController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.surface,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    final diff = _endDate!.difference(_startDate!).inDays;
    return diff == 0 ? 1 : diff;
  }

  double get _totalPrice => _rentalDays * widget.car.pricePerDay;

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal sewa'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    DateTime start = _startDate!;
    if (start.year == DateTime.now().year &&
        start.month == DateTime.now().month &&
        start.day == DateTime.now().day) {
      start = DateTime.now().add(const Duration(minutes: 5));
    }

    setState(() => _isLoading = true);
    try {
      await BookingService.createBooking(
        carId: widget.car.id!,
        startDate: start,
        endDate: _endDate!,
        pickupLocation: _pickupController.text.trim(),
        returnLocation: _returnController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemesanan berhasil dibuat!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fmt(double p) {
    String s = p.toStringAsFixed(0);
    String r = '';
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      c++;
      r = s[i] + r;
      if (c % 3 == 0 && i != 0) r = '.$r';
    }
    return r;
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _returnController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Pesanan'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memproses pesanan...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Car Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.car.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.car.brand} · ${widget.car.type.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Harga Per Hari',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Rp ${_fmt(widget.car.pricePerDay)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Date Picker
                    const Text(
                      'Jadwal Sewa',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectDateRange,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pilih Tanggal',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _startDate != null && _endDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} – ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Belum dipilih',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Location Fields
                    const Text(
                      'Lokasi',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Lokasi Pengambilan *',
                      controller: _pickupController,
                      prefixIcon: Icons.location_on_outlined,
                      hintText: 'Contoh: Kantor Jakarta Selatan',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi pengambilan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      label: 'Lokasi Pengembalian *',
                      controller: _returnController,
                      prefixIcon: Icons.flag_outlined,
                      hintText: 'Contoh: Kantor Jakarta Selatan',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi pengembalian wajib diisi';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      label: 'Catatan (Opsional)',
                      controller: _notesController,
                      prefixIcon: Icons.notes_outlined,
                      hintText: 'Tambahan informasi...',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 28),

                    // Order Summary
                    if (_startDate != null && _endDate != null) ...[
                      const Text(
                        'Ringkasan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Durasi Sewa',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '$_rentalDays Hari',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Estimasi Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Rp ${_fmt(_totalPrice)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Buat Pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

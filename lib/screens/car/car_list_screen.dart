import 'package:flutter/material.dart';
import 'dart:async';
import 'package:modul6apiflutter/config/app_colors.dart';
import 'package:modul6apiflutter/models/car_model.dart';
import 'package:modul6apiflutter/services/car_service.dart';
import 'package:modul6apiflutter/widgets/car_card.dart';
import 'package:modul6apiflutter/widgets/loading_indicator.dart';
import 'package:modul6apiflutter/screens/car/car_form_screen.dart';
import 'package:modul6apiflutter/screens/booking/booking_form_screen.dart';
import 'package:modul6apiflutter/services/auth_service.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<CarModel> _cars = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _role = 'user';
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchCars();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) {
      setState(() {
        _role = role ?? 'user';
      });
    }
  }

  Future<void> _fetchCars([String? searchQuery]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await CarService.getCars(search: searchQuery);
      if (mounted) {
        setState(() {
          _cars = result['cars'] as List<CarModel>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCar(CarModel car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Hapus Mobil',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${car.name}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CarService.deleteCar(car.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mobil berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
          _fetchCars();
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
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Car Rental',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              _role.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari mobil...',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                            _fetchCars();
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _fetchCars(value);
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Mencari mobil terbaik...')
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _fetchCars(_searchController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _cars.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.car_rental,
                                  size: 64,
                                  color: AppColors.textHint,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada data mobil',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                _fetchCars(_searchController.text),
                            color: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _cars.length,
                              itemBuilder: (context, index) {
                                final car = _cars[index];
                                return CarCard(
                                  car: car,
                                  onTap: _role == 'user'
                                      ? () async {
                                          final result =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BookingFormScreen(car: car),
                                            ),
                                          );
                                          if (result == true && context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Silakan cek tab Pesanan.',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  onEdit: _role == 'admin'
                                      ? () async {
                                          final result =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CarFormScreen(car: car),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchCars(
                                              _searchController.text,
                                            );
                                          }
                                        }
                                      : null,
                                  onDelete: _role == 'admin'
                                      ? () => _deleteCar(car)
                                      : null,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarFormScreen(),
                  ),
                );
                if (result == true) {
                  _fetchCars(_searchController.text);
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

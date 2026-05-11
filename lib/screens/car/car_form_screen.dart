import 'package:flutter/material.dart';
import 'package:modul6apiflutter/config/app_colors.dart';
import 'package:modul6apiflutter/models/car_model.dart';
import 'package:modul6apiflutter/services/car_service.dart';
import 'package:modul6apiflutter/widgets/custom_text_field.dart';
import 'package:modul6apiflutter/widgets/loading_indicator.dart';

class CarFormScreen extends StatefulWidget {
  final CarModel? car;
  const CarFormScreen({super.key, this.car});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController, _brandController, _modelController, _yearController, _licensePlateController, _colorController, _priceController, _seatsController, _mileageController, _locationController, _descController;

  String _selectedType = 'sedan';
  String _selectedTransmission = 'manual';
  String _selectedFuel = 'bensin';
  bool _isAvailable = true;
  bool _isLoading = false;

  final _types = ['sedan', 'suv', 'mpv', 'hatchback', 'pickup', 'van'];
  final _transmissions = ['manual', 'automatic'];
  final _fuels = ['bensin', 'diesel', 'hybrid', 'electric'];

  @override
  void initState() {
    super.initState();
    final c = widget.car;
    _nameController = TextEditingController(text: c?.name ?? '');
    _brandController = TextEditingController(text: c?.brand ?? '');
    _modelController = TextEditingController(text: c?.model ?? '');
    _yearController = TextEditingController(text: c?.year.toString() ?? '');
    _licensePlateController = TextEditingController(text: c?.licensePlate ?? '');
    _colorController = TextEditingController(text: c?.color ?? '');
    _priceController = TextEditingController(text: c?.pricePerDay.toStringAsFixed(0) ?? '');
    _seatsController = TextEditingController(text: c?.seats.toString() ?? '');
    _mileageController = TextEditingController(text: c?.mileage?.toStringAsFixed(0) ?? '');
    _locationController = TextEditingController(text: c?.location ?? '');
    _descController = TextEditingController(text: c?.description ?? '');
    if (c != null) {
      if (_types.contains(c.type)) _selectedType = c.type;
      if (_transmissions.contains(c.transmission)) _selectedTransmission = c.transmission;
      if (_fuels.contains(c.fuel)) _selectedFuel = c.fuel;
      _isAvailable = c.isAvailable;
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final d = CarModel(
        id: widget.car?.id, name: _nameController.text.trim(), brand: _brandController.text.trim(),
        model: _modelController.text.isEmpty ? null : _modelController.text.trim(),
        type: _selectedType, year: int.parse(_yearController.text.trim()),
        licensePlate: _licensePlateController.text.trim(),
        color: _colorController.text.isEmpty ? null : _colorController.text.trim(),
        pricePerDay: double.parse(_priceController.text.trim()),
        seats: int.parse(_seatsController.text.trim()), transmission: _selectedTransmission, fuel: _selectedFuel,
        mileage: _mileageController.text.isEmpty ? null : double.parse(_mileageController.text.trim()),
        location: _locationController.text.isEmpty ? null : _locationController.text.trim(),
        description: _descController.text.isEmpty ? null : _descController.text.trim(),
        isAvailable: _isAvailable, images: widget.car?.images ?? [], features: widget.car?.features ?? [],
      );
      if (widget.car == null) { await CarService.createCar(d); } else { await CarService.updateCar(widget.car!.id!, d); }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.car == null ? 'Mobil berhasil ditambahkan' : 'Mobil berhasil diperbarui'), backgroundColor: AppColors.success));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  void dispose() {
    for (final c in [_nameController, _brandController, _modelController, _yearController, _licensePlateController, _colorController, _priceController, _seatsController, _mileageController, _locationController, _descController]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.car == null ? 'Tambah Mobil' : 'Edit Mobil'), backgroundColor: AppColors.background, elevation: 0),
      body: _isLoading ? const LoadingIndicator(message: 'Menyimpan data...') : Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            CustomTextField(label: 'Nama Mobil *', controller: _nameController, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            Row(children: [Expanded(child: CustomTextField(label: 'Merek *', controller: _brandController, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)), const SizedBox(width: 16), Expanded(child: CustomTextField(label: 'Model', controller: _modelController))]),
            Row(children: [Expanded(child: CustomTextField(label: 'Tahun *', controller: _yearController, keyboardType: TextInputType.number, validator: (v) { if (v!.isEmpty) return 'Wajib'; if (int.tryParse(v) == null) return 'Angka'; return null; })), const SizedBox(width: 16), Expanded(child: CustomTextField(label: 'Plat Nomor *', controller: _licensePlateController, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null))]),
            Row(children: [Expanded(child: CustomTextField(label: 'Harga/Hari (Rp) *', controller: _priceController, keyboardType: TextInputType.number, validator: (v) { if (v!.isEmpty) return 'Wajib'; if (double.tryParse(v) == null) return 'Angka'; return null; })), const SizedBox(width: 16), Expanded(child: CustomTextField(label: 'Kursi *', controller: _seatsController, keyboardType: TextInputType.number, validator: (v) { if (v!.isEmpty) return 'Wajib'; if (int.tryParse(v) == null) return 'Angka'; return null; }))]),
            const SizedBox(height: 8),
            _dd('Tipe', _types, _selectedType, (v) => setState(() => _selectedType = v!)),
            _dd('Transmisi', _transmissions, _selectedTransmission, (v) => setState(() => _selectedTransmission = v!)),
            _dd('Bahan Bakar', _fuels, _selectedFuel, (v) => setState(() => _selectedFuel = v!)),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(title: const Text('Ketersediaan', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(_isAvailable ? 'Tersedia disewa' : 'Tidak tersedia', style: const TextStyle(color: AppColors.textSecondary)),
                value: _isAvailable, activeThumbColor: AppColors.primary, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => _isAvailable = v))),
            const SizedBox(height: 24),
            CustomTextField(label: 'Lokasi', controller: _locationController),
            CustomTextField(label: 'Deskripsi', controller: _descController, maxLines: 4),
          ]),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _saveCar, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Simpan Data Mobil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        const SizedBox(height: 24),
      ])),
    );
  }

  Widget _dd(String label, List<String> items, String val, Function(String?) onChanged) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: DropdownButtonFormField<String>(
      initialValue: items.contains(val) ? val : null, dropdownColor: AppColors.surface, style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        filled: true, fillColor: AppColors.surface),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i.toUpperCase()))).toList(), onChanged: onChanged,
    ));
  }
}

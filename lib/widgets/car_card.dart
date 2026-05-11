import 'package:flutter/material.dart';
import 'package:modul6apiflutter/models/car_model.dart';
import 'package:modul6apiflutter/config/app_colors.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.brand} · ${car.type.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${_formatPrice(car.pricePerDay)}/hari',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildChip(car.transmission, Icons.settings),
                        const SizedBox(width: 8),
                        _buildChip(
                          '${car.seats} Kursi',
                          Icons.airline_seat_recline_normal,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: car.isAvailable
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            car.isAvailable ? 'Tersedia' : 'Disewa',
                            style: TextStyle(
                              fontSize: 11,
                              color: car.isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                Column(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: onEdit,
                        iconSize: 20,
                        splashRadius: 20,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: onDelete,
                        iconSize: 20,
                        splashRadius: 20,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    String priceStr = price.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      count++;
      result = priceStr[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return result;
  }
}

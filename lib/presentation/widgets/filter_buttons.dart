import 'package:flutter/material.dart';

class FilterButtons extends StatelessWidget {
  final bool showAssets;
  final ValueChanged<bool> onChanged;

  const FilterButtons({
    super.key,
    required this.showAssets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF4F959D);
    final inactiveColor = Colors.grey[300]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Activos'),
            selected: showAssets,
            selectedColor: activeColor,
            backgroundColor: inactiveColor,
            onSelected: (_) => onChanged(true),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Inactivos'),
            selected: !showAssets,
            selectedColor: activeColor,
            backgroundColor: inactiveColor,
            onSelected: (_) => onChanged(false),
          ),
        ],
      ),
    );
  }
}

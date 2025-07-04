import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[300],
          prefixIcon: const Icon(Icons.search),
          hintText: 'DNI o Nombre',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

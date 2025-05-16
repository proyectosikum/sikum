// lib/presentation/widgets/user_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  String _capitalize(String s) =>
      s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

  @override
  Widget build(BuildContext context) {
    final fullName = '${_capitalize(user.firstName)} ${_capitalize(user.lastName)}';

    return Card(
      color: const Color(0xFFFFF8E1),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('DNI: ${user.dni}'),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye),
          onPressed: () {
            context.push('/usuario/detalle/${user.id}');
          },
        ),
      ),
    );
  }
}

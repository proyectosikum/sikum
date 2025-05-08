import 'package:flutter/material.dart';
import '../../entities/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF8E1),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text('DNI: ${user.dni}'),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye),
          onPressed: () {
            // Lógica para ver detalles del usuario
          },
        ),
      ),
    );
  }
}

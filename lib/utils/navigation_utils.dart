import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';

Future<void> handleExit({
  required BuildContext context,
  required bool isDataSaved,
  required String patientId,
  required WidgetRef ref,
}) async {
  if (isDataSaved) {
    // Verificar si podemos hacer pop antes de intentarlo
    if (context.canPop()) {
      context.pop();
    } else {
      // Si no podemos hacer pop, navegar directamente al detalle del paciente
      context.go('/paciente/detalle/$patientId');
    }
  } else {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: AppColors.green,
            title: const Text(
              '¿Salir sin guardar?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '¿Seguro que querés salir sin guardar los cambios?',
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text(
                  'Salir',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (shouldLeave == true && context.mounted) {
      // Descartar cambios y restaurar
      final formNotifier = ref.read(maternalDataFormProvider(patientId).notifier);
      formNotifier.discardChangesAndRestore(patientId);

      context.pop();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';
import 'package:sikum/utils/navigation_utils.dart';

class MaternalHeader extends ConsumerWidget {
  final String patientId;

  const MaternalHeader({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(maternalDataFormProvider(patientId));

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => handleExit(
                context: context,
                isDataSaved: form.isDataSaved,
                patientId: patientId,
                ref: ref,
              ),
        ),
        const Expanded(
          child: Center(child: ScreenSubtitle(text: 'Datos maternos')),
        ),

        const SizedBox(width: 48),
      ],
    );
  }
}

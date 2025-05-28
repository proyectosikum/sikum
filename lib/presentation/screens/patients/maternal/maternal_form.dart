import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';
import 'maternal_step1.dart';
import 'maternal_step2.dart';
import 'maternal_step3.dart';
import 'maternal_step4.dart';

class MaternalForm extends ConsumerStatefulWidget {
  final String patientId;
  const MaternalForm({super.key, required this.patientId});

  @override
  ConsumerState<MaternalForm> createState() => _MaternalFormState();
}

class _MaternalFormState extends ConsumerState<MaternalForm> {
  final PageController _controller = PageController();

  void _nextPage() => _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  void _previousPage() => _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));
    final form = ref.read(maternalDataFormProvider);

    return Scaffold(
      body: patientAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4F959D)),
        ),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (patient) {
          Future.microtask(() {
            final maternalData = patient?.maternalData;
            final notifier = ref.read(maternalDataFormProvider.notifier);
            if (maternalData != null) {
              notifier.loadMaternalData(maternalData);
              notifier.markDataAsSaved();
            } else {
              notifier.reset();
            }
          });

          if (patient == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }

          return PageView(
            key: ValueKey(form.isDataSaved),
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MaternalStep1(
                key: ValueKey('step1-${form.isDataSaved}'),
                onNext: _nextPage,
                patient: patient,
              ),
              MaternalStep2(
                key: ValueKey('step2-${form.isDataSaved}'),
                onNext: _nextPage,
                onBack: _previousPage,
                patient: patient,
              ),
              MaternalStep3(
                key: ValueKey('step3-${form.isDataSaved}'),
                onNext: _nextPage,
                onBack: _previousPage,
                patient: patient,
              ),
              MaternalStep4(
                key: ValueKey('step4-${form.isDataSaved}'),
                onBack: _previousPage,
                patient: patient,
              ),
            ],
          );
        },
      ),
    );
  }
}

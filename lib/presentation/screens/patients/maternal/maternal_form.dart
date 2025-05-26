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

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
}

  void _previousPage() { 
  _controller.previousPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));

    return Scaffold(

      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4F959D))),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (patient) {
          if (patient == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }

          final maternalData = patient.maternalData;
          
          if (maternalData != null) {
            ref.read(maternalDataFormProvider.notifier).loadMaternalData(maternalData);
            ref.read(maternalDataFormProvider.notifier).markDataAsSaved();
          } else {
            ref.read(maternalDataFormProvider.notifier).reset();
          }

          return PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MaternalStep1(
                onNext: _nextPage,
                patient: patient,
              ),
              MaternalStep2( 
                onNext: _nextPage,
                onBack: _previousPage, 
                patient: patient,
              ),
              MaternalStep3( 
                onNext: _nextPage,
                onBack: _previousPage, 
                patient: patient,
              ),
              MaternalStep4(
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

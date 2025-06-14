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
  bool _isInitialized = false; // Flag para controlar la inicialización

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
    
    return Scaffold(
      body: patientAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4F959D)),
        ),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (patient) {
          if (patient == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }

          // Inicializar datos solo una vez
          if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeMaternalData(patient);
            });
            _isInitialized = true;
          }

          // Usar Consumer para escuchar cambios en el form
          return Consumer(
            builder: (context, ref, child) {
              final form = ref.watch(maternalDataFormProvider(widget.patientId));
              
              return PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  MaternalStep1(
                    key: ValueKey('step1-${form.isDataSaved}-$_isInitialized'),
                    onNext: _nextPage,
                    patient: patient,
                  ),
                  MaternalStep2(
                    key: ValueKey('step2-${form.isDataSaved}-$_isInitialized'),
                    onNext: _nextPage,
                    onBack: _previousPage,
                    patient: patient,
                  ),
                  MaternalStep3(
                    key: ValueKey('step3-${form.isDataSaved}-$_isInitialized'),
                    onNext: _nextPage,
                    onBack: _previousPage,
                    patient: patient,
                  ),
                  MaternalStep4(
                    key: ValueKey('step4-${form.isDataSaved}-$_isInitialized'),
                    onBack: _previousPage,
                    patient: patient,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _initializeMaternalData(patient) {
    final notifier = ref.read(maternalDataFormProvider(widget.patientId).notifier);
    final form = ref.read(maternalDataFormProvider(widget.patientId));
    
    // Si ya estamos editando, no sobreescribas el estado actual
    if (form.isLoadedForCurrentPatient) return;

    final maternalData = patient?.maternalData;
    
    if (maternalData != null) {
      notifier.loadMaternalData(maternalData, widget.patientId);
    } else {
      notifier.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

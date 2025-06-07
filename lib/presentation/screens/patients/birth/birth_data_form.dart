
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/birth_data_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/screens/patients/birth/birth_data_enums.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/custom_text_field.dart';
import 'package:sikum/presentation/widgets/patient_summary.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

// ignore: must_be_immutable
class BirthDataForm extends ConsumerWidget {
  final String patientId;
  
  BirthDataForm({super.key, required this.patientId});

  @override  
  Widget build(BuildContext context, ref) {
      final detailAsync = ref.watch(patientDetailsStreamProvider(patientId));
      const green = Color(0xFF4F959D);

      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: const CustomAppBar(),
        endDrawer: const SideMenu(),
        body: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: green)),
          error: (_, __) => const Center(child: Text('Error al cargar paciente')),
          data: (p) {
            if (p == null) {
              return const Center(child: Text('Paciente no encontrado'));
            }
            return _completeFormView(context, p, ref);
          },
        ),
      );
    }

    Widget _completeFormView(BuildContext context, Patient p, ref) {
      return Scaffold(
          backgroundColor: const Color(0xFFFFF8E1),
          body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PatientSummary(patient: p),
                    _form(context, p, ref)
                  ],
                )
              ),
            ),
        );
    }

    String birthType ="";
    String presentation=""; 
    String ruptureOfMembrane="";
    String amnioticFluid="";
    String sex="";

    Widget _form(BuildContext context, Patient p, ref) {
      String typeSelectedOption= ref.watch(birthDataProvider).birthType;
      String presentationSelectedOption= ref.watch(birthDataProvider).presentation;
      String ruptureOfMembraneSelectedOption= ref.watch(birthDataProvider).ruptureOfMembrane;
      String amnioticFluidSelectedOption= ref.watch(birthDataProvider).amnioticFluid;
      String sexSelectedOption= ref.watch(birthDataProvider).sex;
      String? twinSelectedOption= ref.watch(birthDataProvider).twin;
      String? fisrtApgarSelectedOption= ref.watch(birthDataProvider).firstApgarScore;
      String? secondApgarSelectedOption= ref.watch(birthDataProvider).secondApgarScore;
      String? thirdApgarSelectedOption= ref.watch(birthDataProvider).thirdApgarScore;


      return ListView(   
          shrinkWrap: true,   
          children: [
            ExpansionTile(
                title: Text('Tipo de Nacimiento'),
                subtitle: Text(typeSelectedOption),
                children: [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      children: 
                         BirthTypeEnum.values.map((option) {
                          return RadioListTile<BirthTypeEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: BirthTypeEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).birthType,orElse: () => BirthTypeEnum.unknown),
                            onChanged: (option) =>ref.read(birthDataProvider.notifier).updateBirthType(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
            ExpansionTile(
              title: Text('Presentacion'),
              subtitle: Text(presentationSelectedOption),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        PresentationEnum.values.map((option) {
                        return RadioListTile<PresentationEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: PresentationEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).presentation,orElse: () => PresentationEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updatePresentation(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            ExpansionTile(
              title: Text('Ruptura de membrana'),
              subtitle: Text(ruptureOfMembraneSelectedOption),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        RuptureOfMembraneEnum.values.map((option) {
                        return RadioListTile<RuptureOfMembraneEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: RuptureOfMembraneEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).ruptureOfMembrane,orElse: () => RuptureOfMembraneEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateRuptureOfMembrane(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
             ExpansionTile(
              title: Text('Liquido amniotico'),
              subtitle: Text(amnioticFluidSelectedOption),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        AmnioticFluidEnum.values.map((option) {
                        return RadioListTile<AmnioticFluidEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: AmnioticFluidEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).amnioticFluid,orElse: () => AmnioticFluidEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateAmnioticFluid(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            ExpansionTile(
              title: Text('Sexo'),
              subtitle: Text(sexSelectedOption),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        SexEnum.values.map((option) {
                        return RadioListTile<SexEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: SexEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).sex,orElse: () => SexEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateSex(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            ExpansionTile(
              title: Text('Gemelar'),
              subtitle: Text(twinSelectedOption?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        TwinEnum.values.map((option) {
                        return RadioListTile<TwinEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: TwinEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).twin,
                                      orElse: () => TwinEnum.no),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateTwin(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            ExpansionTile(
              title: Text('Apgar 1`'),
              subtitle: Text(fisrtApgarSelectedOption?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        ApgarScoreEnum.values.map((option) {
                        return RadioListTile<ApgarScoreEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: ApgarScoreEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).firstApgarScore,
                                      orElse: () => ApgarScoreEnum.one),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateFirstApgar(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
                        ExpansionTile(
              title: Text('Apgar 5`'),
              subtitle: Text(secondApgarSelectedOption?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        ApgarScoreEnum.values.map((option) {
                        return RadioListTile<ApgarScoreEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: ApgarScoreEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).secondApgarScore,
                                      orElse: () => ApgarScoreEnum.one),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateSecondApgar(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
                        ExpansionTile(
              title: Text('Apgar 10`'),
              subtitle: Text(thirdApgarSelectedOption?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        ApgarScoreEnum.values.map((option) {
                        return RadioListTile<ApgarScoreEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: ApgarScoreEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider).thirdApgarScore,
                                      orElse: () => ApgarScoreEnum.one),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updatethirdApgar(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
           //Input: edad gestacional
           CustomTextField(
            label: 'Edad gestacional',
           ),
            ElevatedButton(
              onPressed: () async { try {
                              // Submit para grabar en Firebase (en provider)
                              await ref.read(birthDataProvider.notifier).submitBirthData(p.id);
                            } catch (e) {
                                print('ERROR:$e');
                            }}, 
              child: Text('Guardar'))
            //Date Picker fecha de nacimiento
            //Hora de nacimiento
            //Gemelar - Radio button
            //APGAR - Desplegable
            // Input> Peso
            //Input Talla
            //Input Perimetro encefalico
            //Texto libre - Examen fisico
            // Checkbox -  Vacuna Hep B
            // Checkbox / Vit K
            // Checkbox / Colirio 
            // Dropdown  / Destino
          ]
      );

    }
  
}

   
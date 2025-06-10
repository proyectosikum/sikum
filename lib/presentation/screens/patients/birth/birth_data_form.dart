
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/birth_data.dart';
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
  
  const BirthDataForm({super.key, required this.patientId});

  @override  
  Widget build(BuildContext context, ref) {
      final detailAsync = ref.watch(patientDetailsStreamProvider(patientId));
      const green = Color(0xFF4F959D);

      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        appBar: const CustomAppBar(),
        endDrawer: const SideMenu(),
        body: 
          detailAsync.when(
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

    Widget _form(BuildContext context, Patient p, ref) {

      ref.read(birthDataProvider.notifier).setPatient(p);

      BirthData data = BirthData(
        birthType: ref.watch(birthDataProvider)?.birthType,
        presentation: ref.watch(birthDataProvider)?.presentation, 
        ruptureOfMembrane: ref.watch(birthDataProvider)?.ruptureOfMembrane, 
        amnioticFluid: ref.watch(birthDataProvider)?.amnioticFluid , 
        sex: ref.watch(birthDataProvider)?.sex, 
        twin: ref.watch(birthDataProvider)?.twin,
        firstApgarScore: ref.watch(birthDataProvider)?.firstApgarScore,
        secondApgarScore: ref.watch(birthDataProvider)?.secondApgarScore,
        thirdApgarScore: ref.watch(birthDataProvider)?.thirdApgarScore,
        hasHepatitisBVaccine: ref.watch(birthDataProvider)?.hasHepatitisBVaccine, 
        hasVitaminK: ref.watch(birthDataProvider)?.hasVitaminK ?? p.birthData?.hasVitaminK , 
        hasOphthalmicDrops: ref.watch(birthDataProvider)?.hasOphthalmicDrops,
        disposition: ref.watch(birthDataProvider)?.disposition,
        gestationalAge: ref.watch(birthDataProvider)?.gestationalAge
      );

/*
    BirthData data = BirthData(
        birthType: p.birthData?.birthType,
        presentation: p.birthData?.presentation, 
        ruptureOfMembrane: p.birthData?.ruptureOfMembrane, 
        amnioticFluid: p.birthData?.amnioticFluid, 
        sex: p.birthData?.sex, 
        twin: p.birthData?.twin,
        firstApgarScore: p.birthData?.firstApgarScore,
        secondApgarScore: p.birthData?.secondApgarScore,
        thirdApgarScore: p.birthData?.thirdApgarScore,
        hasHepatitisBVaccine: p.birthData?.hasHepatitisBVaccine ?? false, 
        hasVitaminK: p.birthData?.hasVitaminK ?? false  , 
        hasOphthalmicDrops: p.birthData?.hasOphthalmicDrops ?? false,
        disposition: p.birthData?.disposition,
        gestationalAge: p.birthData?.gestationalAge
      );

*/

      TextEditingController ageController = TextEditingController(text: data.gestationalAge.toString());

      return ListView(   
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ExpansionTile(
                title: Text('Tipo de Nacimiento'),
                subtitle: Text(data.birthType ?? 'No asignado'),
                children: [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      children: 
                         BirthTypeEnum.values.map((option) {
                          return RadioListTile<BirthTypeEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: BirthTypeEnum.values.firstWhere((e) => e.getValue() == ref.watch(birthDataProvider)?.birthType ,orElse: () => BirthTypeEnum.unknown),
                            onChanged: (option) => ref.read(birthDataProvider.notifier).updateBirthType(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
            ExpansionTile(
              title: Text('Presentacion'),
              subtitle: Text(data.presentation ?? 'No asignado'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        PresentationEnum.values.map((option) {
                        return RadioListTile<PresentationEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: PresentationEnum.values.firstWhere((e) => e.getValue() == data.presentation,orElse: () => PresentationEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updatePresentation(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            ExpansionTile(
              title: Text('Ruptura de membrana'),
              subtitle: Text(data.ruptureOfMembrane ?? 'No asignado'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        RuptureOfMembraneEnum.values.map((option) {
                        return RadioListTile<RuptureOfMembraneEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: RuptureOfMembraneEnum.values.firstWhere((e) => e.getValue() == data.ruptureOfMembrane,orElse: () => RuptureOfMembraneEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateRuptureOfMembrane(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
             ExpansionTile(
              title: Text('Liquido amniotico'),
              subtitle: Text(data.amnioticFluid ?? 'No asignado'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        AmnioticFluidEnum.values.map((option) {
                        return RadioListTile<AmnioticFluidEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: AmnioticFluidEnum.values.firstWhere((e) => e.getValue() == data.amnioticFluid,orElse: () => AmnioticFluidEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateAmnioticFluid(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            ExpansionTile(
              title: Text('Sexo'),
              subtitle: Text(data.sex ?? 'No asignado'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        SexEnum.values.map((option) {
                        return RadioListTile<SexEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: SexEnum.values.firstWhere((e) => e.getValue() == data.sex,orElse: () => SexEnum.unknown),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateSex(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number, // Solo permite números
              decoration: InputDecoration(
                labelText: "Edad gestacional",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  //int? age = int.tryParse(value);
                  ref.read(birthDataProvider.notifier).updateGestationalAge(value);
                }
              },
            ),
            ExpansionTile(
              title: Text('Gemelar'),
              subtitle: Text(data.twin?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        TwinEnum.values.map((option) {
                        return RadioListTile<TwinEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: TwinEnum.values.firstWhere((e) => e.getValue() == data.twin,
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
              subtitle: Text(data.firstApgarScore?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        ApgarScoreEnum.values.map((option) {
                        return RadioListTile<ApgarScoreEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: ApgarScoreEnum.values.firstWhere((e) => e.getValue() == data.firstApgarScore,
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
              subtitle: Text(data.secondApgarScore?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        ApgarScoreEnum.values.map((option) {
                        return RadioListTile<ApgarScoreEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: ApgarScoreEnum.values.firstWhere((e) => e.getValue() == data.secondApgarScore,
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
              subtitle: Text(data.thirdApgarScore?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        ApgarScoreEnum.values.map((option) {
                        return RadioListTile<ApgarScoreEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: ApgarScoreEnum.values.firstWhere((e) => e.getValue() == data.thirdApgarScore,
                                      orElse: () => ApgarScoreEnum.one),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateThirdApgar(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
            CheckboxListTile(
              title: Text('Vacuna de Hepatitis B'),
              value: (data.hasHepatitisBVaccine), 
              onChanged: (value) => ref.read(birthDataProvider.notifier).updateHasHepatitisBVaccine(value),
            ),
            CheckboxListTile(
              title: Text('Vitamina K'),
              value: (data.hasVitaminK), 
              onChanged: (value) => ref.read(birthDataProvider.notifier).updateHasVitaminK(value?? false),
            ),
            CheckboxListTile(
              title: Text('Colirio oftalmologico'),
              value: (data.hasOphthalmicDrops), 
              onChanged: (value) => ref.read(birthDataProvider.notifier).updateHasOphthalmicDrops(value??false),
            ),
            ExpansionTile(
              title: Text('Destino'),
              subtitle: Text(data.disposition?? 'Sin eleccion'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        DispositionEnum.values.map((option) {
                        return RadioListTile<DispositionEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: DispositionEnum.values.firstWhere((e) => e.getValue() == data.disposition,
                                      orElse: () => DispositionEnum.roomingInHospitalization),
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
                              ref.read(patientActionsProvider).submitBirthData(p.id, data);
                              ref.read(birthDataProvider.notifier).reset();
                            } catch (e) {
                                print('ERROR:$e');
                            }}, 
              child: Text('Guardar'))
          ]
      );

    }
  
}

   
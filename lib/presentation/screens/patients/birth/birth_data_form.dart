
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/birth_data_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/screens/patients/birth/birth_data_enums.dart';
import 'package:sikum/presentation/screens/patients/data/patient_details.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/custom_date_picker.dart';
import 'package:sikum/presentation/widgets/custom_time_picker.dart';
import 'package:sikum/presentation/widgets/patient_summary.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

// ignore: must_be_immutable
class BirthDataForm extends ConsumerStatefulWidget {

  final String patientId;
  
  const BirthDataForm({super.key, required this.patientId});

  @override
  ConsumerState<BirthDataForm> createState() => _BirthDataFormState();
}

class _BirthDataFormState extends ConsumerState<BirthDataForm> {
  bool _isInitialized = false;

  @override  
  Widget build(BuildContext context) {
      final detailAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));
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
             if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeBirthData(p);
            });
            _isInitialized = true;
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
                    SizedBox(height: 20),
                    _form(context, p, ref)
                  ],
                )
              ),
            ),
        );
    }

      void _initializeBirthData(Patient p) {
        final notifier = ref.read(birthDataProvider.notifier);
        
        // Evita recargar si es el mismo paciente
        if (notifier.patient?.id == p.id) return;

        notifier.reset();      // limpia estado anterior
        notifier.setPatient(p); // carga datos del paciente actual
      }

    Widget _form(BuildContext context, Patient p, ref) {

      var data = ref.watch(birthDataProvider);
      final notifier = ref.read(birthDataProvider.notifier);
      final isUpdateView = data.isDataSaved;
      final hasBirthTypeError = notifier.errorTextFor('birthType') != null;
      final hasPresentationError = notifier.errorTextFor('presentation') != null;
      final hasRuptureOfMembraneError = notifier.errorTextFor('ruptureOfMembrane') != null;
      final hasAmnioticFluidError = notifier.errorTextFor('amnioticFluid') != null;
      final hasSexError = notifier.errorTextFor('sex') != null;
      final hasTwinError = notifier.errorTextFor('twin') != null;
      final hasFirstApgarScoreError = notifier.errorTextFor('firstApgarScore') != null;
      final hasSecondApgarScoreError = notifier.errorTextFor('secondApgarScore') != null;
      final hasThirdApgarScoreError = notifier.errorTextFor('thirdApgarScore') != null;
      final hasDispositionError = notifier.errorTextFor('disposition') != null;
      final hasBirthDateError = notifier.errorTextFor('birthDate') != null;
      final hasBirthPlaceError = notifier.errorTextFor('birthPlace') != null;
      final hasBirthPlaceDetailsError = notifier.errorTextFor('birthPlaceDetails') != null;
      final hasPhysicalError = notifier.errorTextFor('physicalExamination') != null;
      final hasDetailsError = notifier.errorTextFor('physicalExaminationDetails') != null;

      return ListView(   
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              decoration: hasBirthPlaceError || hasBirthPlaceDetailsError
                ? BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
              child: ExpansionTile(
                title: Text('Lugar de nacimiento'),
                subtitle: Text(data.birthPlace == "Otro" && (data.birthPlaceDetails?.isNotEmpty ?? false)
                        ? "Otro: ${data.birthPlaceDetails}"
                        : data.birthPlace ?? "No asignado",
                ),
                trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                children: isUpdateView ? [] :[
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209), 
                    child: Column(
                      children: PlacesEnum.values.map((option) {
                        return RadioListTile<PlacesEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          activeColor: Color(0xFF4F959D),
                          groupValue: PlacesEnum.values.firstWhereOrNull(
                            (e) => e.getValue() == data.birthPlace
                          ),
                          onChanged: (option) {
                            ref.read(birthDataProvider.notifier).updateBirthPlace(option!.getValue());
                            if (option.getValue() != "Otro") {
                              ref.read(birthDataProvider.notifier).updateBirthPlaceDetails("");
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  if (data.birthPlace == "Otro") ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextFormField(
                        enabled: !isUpdateView,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Especificar otro lugar",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4F959D)), 
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                          ),
                          errorText: notifier.errorTextFor('birthPlaceDetails'),
                        ),
                        initialValue: data.birthPlaceDetails, 
                        onChanged: (value) {
                          ref.read(birthDataProvider.notifier).updateBirthPlaceDetails(value);
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (hasBirthPlaceError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          notifier.errorTextFor('birthPlace')!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                    ),

      
            Container(
              decoration: hasBirthTypeError
                ? BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
              child: ExpansionTile(
                title: Text('Tipo de Nacimiento'),
                subtitle: Text(data.birthType ?? 'No asignado'),
                trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                children: isUpdateView ? [] : [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         ...BirthTypeEnum.values.map((option) {
                          return RadioListTile<BirthTypeEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: BirthTypeEnum.values.firstWhereOrNull((e) => e.getValue() == ref.watch(birthDataProvider)),
                            onChanged: (option) => ref.read(birthDataProvider.notifier).updateBirthType(option!.getValue()),
                          );
                        }),
                      ],
                    )
                  )
                ]
              ),
            ),
              if (hasBirthTypeError)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    notifier.errorTextFor('birthType')!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
              Container(
                decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
                 child:ExpansionTile(
                  title: Text('Presentacion'),
                  subtitle: Text(data.presentation ?? 'No asignado'),
                  trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                  children: isUpdateView ? [] : [
                    Container(
                      color: const Color.fromARGB(255, 179, 207, 209),
                      child: Column(
                        children: 
                            PresentationEnum.values.map((option) {
                            return RadioListTile<PresentationEnum>(
                              title: Text(option.getValue()),
                              value: option,
                              groupValue: PresentationEnum.values.firstWhereOrNull((e) => e.getValue() == data.presentation),
                              onChanged: (option) =>ref.read(birthDataProvider.notifier).updatePresentation(option!.getValue()),
                            );
                          }).toList(),
                      )
                    )
                  ]
                ),
              ),
               if (hasPresentationError)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    notifier.errorTextFor('presentation')!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
              Container(
                decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
                 child: ExpansionTile(
              title: Text('Ruptura de membrana'),
              subtitle: Text(data.ruptureOfMembrane ?? 'No asignado'),
              trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
              children: isUpdateView ? [] : [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209),
                  child: Column(
                    children: 
                        RuptureOfMembraneEnum.values.map((option) {
                        return RadioListTile<RuptureOfMembraneEnum>(
                          title: Text(option.getValue()),
                          value: option,
                          groupValue: RuptureOfMembraneEnum.values.firstWhereOrNull((e) => e.getValue() == data.ruptureOfMembrane),
                          onChanged: (option) =>ref.read(birthDataProvider.notifier).updateRuptureOfMembrane(option!.getValue()),
                        );
                      }).toList(),
                  )
                )
              ]
            ),
              ),
            if (hasRuptureOfMembraneError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('ruptureOfMembrane')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Container(
              decoration: hasBirthTypeError
                ? BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
                child: ExpansionTile(
                title: Text('Liquido amniotico'),
                subtitle: Text(data.amnioticFluid ?? 'No asignado'),
                trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                children: isUpdateView ? [] : [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      children: 
                          AmnioticFluidEnum.values.map((option) {
                          return RadioListTile<AmnioticFluidEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: AmnioticFluidEnum.values.firstWhereOrNull((e) => e.getValue() == data.amnioticFluid),
                            onChanged: (option) =>ref.read(birthDataProvider.notifier).updateAmnioticFluid(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
            ),
            if (hasAmnioticFluidError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('amnioticFluid')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Container(
              decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: ExpansionTile(
                title: Text('Sexo'),
                subtitle: Text(data.sex ?? 'No asignado'),
                trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                children: isUpdateView ? [] : [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      children: 
                          SexEnum.values.map((option) {
                          return RadioListTile<SexEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: SexEnum.values.firstWhereOrNull((e) => e.getValue() == data.sex),
                            onChanged: (option) =>ref.read(birthDataProvider.notifier).updateSex(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
            ),
            if (hasSexError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('sex')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity, // Hace que ocupe todo el ancho disponible de la columna
                  child: CustomDatePicker(
                    label: "Seleccionar fecha de nacimiento",
                    initialDate: data.birthDate != null 
                        ? DateFormat('dd/MM/yyyy').format(data.birthDate!) 
                        : null,
                    isDataSaved: isUpdateView,
                    onDateChanged: (formattedDate) {
                      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
                      ref.read(birthDataProvider.notifier).updateBirthDate(parsedDate);
                    },
                ),
                  
                ),
                if (hasBirthDateError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      notifier.errorTextFor('birthDate')!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                CustomTimePicker(
                  label: "Seleccionar hora de nacimiento",
                  initialTime: data.birthTime,
                  isDataSaved: isUpdateView,
                  onTimeChanged: (formattedTime) {
                    ref.read(birthDataProvider.notifier).updateBirthTime(formattedTime);
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("Edad gestacional", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: data?.gestationalAge?.toString(),
              keyboardType: TextInputType.number,
              enabled: !isUpdateView,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4F959D)),
                ),
                errorText: notifier.errorTextFor('gestationalAge'),
              ),
              onChanged: (value) {
                int? parsedValue = int.tryParse(value);
                if (parsedValue != null) {
                  ref.read(birthDataProvider.notifier).updateGestationalAge(parsedValue);
                }
              },
            ),
            SizedBox(height: 16),
            Container(
              decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: ExpansionTile(
                title: Text('Gemelar'),
                subtitle: Text(data.twin?? 'Sin eleccion'),
                trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                children: isUpdateView ? [] : [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      children: 
                          TwinEnum.values.map((option) {
                          return RadioListTile<TwinEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: TwinEnum.values.firstWhereOrNull((e) => e.getValue() == data.twin),
                            onChanged: (option) =>ref.read(birthDataProvider.notifier).updateTwin(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
            ),
            if (hasTwinError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('twin')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Container(
              decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
                 child: ExpansionTile(
                  title: Text('Apgar 1`'),
                  subtitle: Text(data.firstApgarScore?? 'Sin eleccion'),
                  trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                  children: isUpdateView ? [] : [
                    Container(
                      color: const Color.fromARGB(255, 179, 207, 209),
                      child: Column(
                        children: 
                            ApgarScoreEnum.values.map((option) {
                            return RadioListTile<ApgarScoreEnum>(
                              title: Text(option.getValue()),
                              value: option,
                              groupValue: ApgarScoreEnum.values.firstWhereOrNull((e) => e.getValue() == data.firstApgarScore),
                              onChanged: (option) =>ref.read(birthDataProvider.notifier).updateFirstApgar(option!.getValue()),
                            );
                          }).toList(),
                      )
                    )
                  ]
                ),
            ), 
            if (hasFirstApgarScoreError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('firstApgarScore')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Container(
              decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: ExpansionTile(
                title: Text('Apgar 5`'),
                subtitle: Text(data.secondApgarScore?? 'Sin eleccion'),
                trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                children: isUpdateView ? [] : [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      children: 
                          ApgarScoreEnum.values.map((option) {
                          return RadioListTile<ApgarScoreEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: ApgarScoreEnum.values.firstWhereOrNull((e) => e.getValue() == data.secondApgarScore),
                            onChanged: (option) =>ref.read(birthDataProvider.notifier).updateSecondApgar(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
            ),
            if (hasSecondApgarScoreError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('secondApgarScore')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Container(
              decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: ExpansionTile(
                title: Text('Apgar 10`'),
                subtitle: Text(data.thirdApgarScore?? 'Sin eleccion'),
                trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                children: isUpdateView ? [] : [
                  Container(
                    color: const Color.fromARGB(255, 179, 207, 209),
                    child: Column(
                      children: 
                          ApgarScoreEnum.values.map((option) {
                          return RadioListTile<ApgarScoreEnum>(
                            title: Text(option.getValue()),
                            value: option,
                            groupValue: ApgarScoreEnum.values.firstWhereOrNull((e) => e.getValue() == data.thirdApgarScore),
                            onChanged: (option) =>ref.read(birthDataProvider.notifier).updateThirdApgar(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
            ),
            if (hasThirdApgarScoreError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('thirdApgarScore')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          
            
            
            Text("Peso (grs)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 8),
              TextFormField(
                initialValue: data?.weight?.toString(),
                enabled: !isUpdateView,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4F959D)),
                  ),
                  errorText: notifier.errorTextFor('weight'),
                ),
                onChanged: (value) {
                  int? parsedValue = int.tryParse(value);
                  if (parsedValue != null) {
                    ref.read(birthDataProvider.notifier).updateWeight(parsedValue);
                  }
                },
              ),
              SizedBox(height: 16),
              Text("Talla (cm)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 8),
              TextFormField(
                initialValue: data?.length?.toString(),
                enabled: !isUpdateView,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4F959D)),
                  ),
                  errorText: notifier.errorTextFor('length'),
                ),
                onChanged: (value) {
                  int? parsedValue = int.tryParse(value);
                  if (parsedValue != null) {
                    ref.read(birthDataProvider.notifier).updateLength(parsedValue);
                  }
                },
              ),
              SizedBox(height: 16),
              Text("Perímetro Cefálico (cm)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 8),
              TextFormField(
                initialValue: data?.headCircumference?.toString(),
                enabled: !isUpdateView,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4F959D)),
                  ),
                  errorText: notifier.errorTextFor('headCircumference'),
                ),
                onChanged: (value) {
                  int? parsedValue = int.tryParse(value);
                  if (parsedValue != null) {
                    ref.read(birthDataProvider.notifier).updateHeadCircumference(parsedValue);
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<BloodTypeEnum>(
                value: BloodTypeEnum.values.firstWhereOrNull(  (e) => e.getValue() == data.bloodType,),
                decoration: InputDecoration(
                  labelText: "Grupo y factor sanguineo",
                  border: const OutlineInputBorder(),
                  suffixIcon: isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
                  errorText: notifier.errorTextFor('bloodType'),
                ),
                dropdownColor: Color(0xFFB3CFD1),
                icon: const SizedBox.shrink(), // 🔹 Esto quita la flecha
                items: BloodTypeEnum.values.map((option) {
                  return DropdownMenuItem<BloodTypeEnum>(
                    value: option,
                    child: Text(option.getValue()),
                  );
                }).toList(),
                onChanged: isUpdateView ? null : (newValue) {
                    if (newValue != null) {
                      ref.read(birthDataProvider.notifier).updateBloodType(newValue.getValue());
                    }
                  },

              ),
              SizedBox(height: 16),
              Container(
                decoration: hasPhysicalError || hasDetailsError
                    ? BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                padding: const EdgeInsets.all(12),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Examen físico",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        // Opción "Normal"
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text("Normal"),
                            value: "Normal",
                            groupValue: data.physicalExamination,
                            onChanged: isUpdateView
                              ? null
                              :(value) {
                              ref.read(birthDataProvider.notifier).updatePhysicalExamination(value!);
                              ref.read(birthDataProvider.notifier).updatePhysicalExaminationDetails(""); // Borra texto si cambia a "Normal"
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text("Anormal"),
                            value: "Anormal",
                            groupValue: data.physicalExamination,
                            onChanged: isUpdateView
                              ? null
                              : (value) {
                              ref.read(birthDataProvider.notifier).updatePhysicalExamination(value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (hasPhysicalError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          notifier.errorTextFor('physicalExamination')!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    // Campo de texto solo cuando se selecciona "Otros"
                    if (data.physicalExamination == "Anormal") ...[
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: data?.physicalExaminationDetails,
                        enabled: !isUpdateView,
                        maxLines: 5, // o la cantidad que quieras mostrar visiblemente
                        minLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Detalles del examen físico",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4F959D)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          errorText: notifier.errorTextFor('physicalExaminationDetails'),
                        ),
                        onChanged: isUpdateView
                          ? null
                          : (value) {
                          ref.read(birthDataProvider.notifier).updatePhysicalExaminationDetails(value);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recibió...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8), 
                  CheckboxListTile(
                    title: Text('Vacuna de Hepatitis B'),
                    value: (data.hasHepatitisBVaccine), 
                    onChanged: isUpdateView ? null : (value) => ref.read(birthDataProvider.notifier).updateHasHepatitisBVaccine(value),
                  ),

                  CheckboxListTile(
                    title: Text('Vitamina K'),
                    value: (data.hasVitaminK), 
                    onChanged: isUpdateView ? null : (value) => ref.read(birthDataProvider.notifier).updateHasVitaminK(value ?? false),
                  ),

                  CheckboxListTile(
                    title: Text('Colirio oftalmológico'),
                    value: (data.hasOphthalmicDrops), 
                    onChanged: isUpdateView ? null : (value) => ref.read(birthDataProvider.notifier).updateHasOphthalmicDrops(value ?? false),
                  ),
                ],
              ),
              
              Text("Número de pulsera", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: data?.braceletNumber?.toString(),
                    enabled: !isUpdateView,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4F959D)),
                      ),
                      errorText: notifier.errorTextFor('braceletNumber'),
                    ),
                    onChanged: (value) {
                      int? parsedValue = int.tryParse(value);
                      if (parsedValue != null) {
                        ref.read(birthDataProvider.notifier).updateBraceletNumber(parsedValue);
                      }
                    },
                  ),
              SizedBox(height: 16),
              Container(
                decoration: hasBirthTypeError
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
                child: ExpansionTile(
                  title: Text('Destino'),
                  subtitle: Text(data.disposition?? 'Sin eleccion'),
                  trailing: isUpdateView ?  Icon(Icons.lock, color: Colors.grey) : const Icon(Icons.expand_more),
                  children: isUpdateView ? [] : [
                    Container(
                      color: const Color.fromARGB(255, 179, 207, 209),
                      child: Column(
                        children: 
                            DispositionEnum.values.map((option) {
                            return RadioListTile<DispositionEnum>(
                              title: Text(option.getValue()),
                              value: option,
                              groupValue: DispositionEnum.values.firstWhereOrNull((e) => e.getValue() == data.disposition),
                              onChanged: (option) =>ref.read(birthDataProvider.notifier).updateDisposition(option!.getValue()),
                            );
                          }).toList(),
                      )
                    )
                  ]
                ),
              ),
              if (hasDispositionError)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  notifier.errorTextFor('disposition')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
              
              SizedBox(height: 16),
            //BOTONES DE ACCION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye los botones equitativamente
              children:  isUpdateView
                ? [ //MODO EDICION
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: Color(0xFF4F959D)),
                      label: Text("Volver", style: TextStyle(color: Color(0xFF4F959D))),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Color(0xFF4F959D)),
                      tooltip: "Editar",
                      onPressed: () {
                        ref.read(birthDataProvider.notifier).updateIsDataSaved(false);
                      },
                    ),
                  ]
                :[
                OutlinedButton(
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      title: 'Confirmar cancelación',
                      content: 'Si continúas, perderás los cambios realizados. ¿Deseas continuar?',
                      onConfirm: () {
                        Navigator.pop(context); // Vuelve a la pantalla anterior
                        notifier.reset();
                       // ref.read(birthDataProvider.notifier).setPatient(p); // Restaura los datos originales
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PatientDetailsScreen(patientId: p.id)), // Reemplazar con la pantalla destino
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF4F959D),
                    side: BorderSide(color: Color(0xFF4F959D)), 
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
                  ),
                  child: Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final isValid = ref.read(birthDataProvider.notifier).validateAll();
                    if (!isValid) {
                      // Mostramos errores y evitamos continuar
                      setState(() {}); // Asegura redibujar los campos con errorText
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Por favor, corregí los errores antes de guardar."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    showConfirmationDialog(
                      context: context,
                      title: 'Confirmar guardado',
                      content: '¿Estás seguro de que quieres guardar estos cambios?',
                      onConfirm: () async {
                        try {
                         final notifier = ref.read(birthDataProvider.notifier);
                          notifier.updateIsDataSaved(true);
                          data = notifier.state;
                          await ref.read(patientActionsProvider).submitBirthData(p.id, data);
                          if (!context.mounted) return; // Asegura que el contexto sigue existiendo
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Datos guardados correctamente'),
                              backgroundColor: Color(0xFF4F959D),
                            ),
                          );
                          //Redirigir a la pantalla después de guardar
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PatientDetailsScreen(patientId: p.id)),
                          );

                        } catch (e) {
                          if (!context.mounted) return; //Asegura que el contexto sigue existiendo
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar los datos: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4F959D),
                    foregroundColor: Color(0xFFFFF8E1), 
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
                  ),
                  child: Text("Guardar", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ]
        );

    }
 ///Funciones aux
    void showConfirmationDialog({
      required BuildContext context,
      required String title,
      required String content,
      required VoidCallback onConfirm,
    }) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cierra el modal sin hacer cambios
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal antes de ejecutar la acción
                  onConfirm();
                },
                child: Text('Confirmar'),
              ),
            ],
          );
        },
      );
    }

  
}

   
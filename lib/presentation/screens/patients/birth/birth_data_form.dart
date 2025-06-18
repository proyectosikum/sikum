// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/birth_data_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/screens/patients/birth/birth_data_enums.dart';
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
  void didUpdateWidget(covariant BirthDataForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      _isInitialized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      patientDetailsStreamProvider(widget.patientId),
    );
    const green = Color(0xFF4F959D);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: detailAsync.when(
        loading:
            () => const Center(child: CircularProgressIndicator(color: green)),
        error: (_, __) => const Center(child: Text('Error al cargar paciente')),
        data: (p) {
          if (p == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }
          if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeBirthData(p);
              setState(() {
                _isInitialized = true;
              });
            });
            return const Center(child: CircularProgressIndicator(color: green));
          }
          return _completeFormView(context, p, ref);
        },
      ),
    );
  }

  Widget _completeFormView(BuildContext context, Patient p, ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PatientSummary(patient: p),
            const SizedBox(height: 20),
            _form(context, p, ref),
          ],
        ),
      ),
    );
  }

  void _initializeBirthData(Patient p) {
    final notifier = ref.read(birthDataProvider.notifier);
    if (notifier.patient?.id == p.id) return;
    notifier.reset();
    notifier.setPatient(p);
  }

  Widget _form(BuildContext context, Patient p, ref) {
    var data = ref.watch(birthDataProvider);
    final notifier = ref.read(birthDataProvider.notifier);
    final isUpdateView = data.isDataSaved;
    final hasBirthDateError = notifier.errorTextFor('birthDate') != null;
    final hasBirthTimeError = notifier.errorTextFor('birthTime') != null;
    final hasBirthPlaceError = notifier.errorTextFor('birthPlace') != null;
    final hasBirthPlaceDetailsError =
        notifier.errorTextFor('birthPlaceDetails') != null;
    final hasPhysicalError =
        notifier.errorTextFor('physicalExamination') != null;
    final hasDetailsError =
        notifier.errorTextFor('physicalExaminationDetails') != null;

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          decoration:
              hasBirthPlaceError || hasBirthPlaceDetailsError
                  ? BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  )
                  : null,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lugar de nacimiento",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      activeColor: Color(0xFF4F959D),
                      title: Text(PlacesEnum.thisHospital.getValue()),
                      value: PlacesEnum.thisHospital.getValue(),
                      groupValue: data.birthPlace,
                      onChanged:
                          isUpdateView
                              ? null
                              : (value) {
                                ref
                                    .read(birthDataProvider.notifier)
                                    .updateBirthPlace(value!);
                                ref
                                    .read(birthDataProvider.notifier)
                                    .updateBirthPlaceDetails("");
                              },
                    ),

                    RadioListTile<String>(
                      activeColor: Color(0xFF4F959D),
                      title: Text(PlacesEnum.outpatient.getValue()),
                      value: PlacesEnum.outpatient.getValue(),
                      groupValue: data.birthPlace,
                      onChanged:
                          isUpdateView
                              ? null
                              : (value) {
                                ref
                                    .read(birthDataProvider.notifier)
                                    .updateBirthPlace(value!);
                              },
                    ),
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

              if (data.birthPlace == PlacesEnum.outpatient.getValue()) ...[
                SizedBox(height: 8),
                TextFormField(
                  key: ValueKey('birthPlaceDetails_${p.id}'),
                  initialValue: data.birthPlaceDetails ?? '',
                  enabled: !isUpdateView,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                    labelText: "Especificar lugar de nacimiento",
                    floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4F959D)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    errorText: notifier.errorTextFor('birthPlaceDetails'),
                  ),
                  onChanged: (value) {
                    ref
                        .read(birthDataProvider.notifier)
                        .updateBirthPlaceDetails(value);
                  },
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 16),
        DropdownButtonFormField<BirthTypeEnum>(
          key: ValueKey('birthType_${p.id}'),
          value: BirthTypeEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.birthType,
          ),
          decoration: InputDecoration(
            labelText: "Tipo de Nacimiento",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('birthType'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              BirthTypeEnum.values.map((option) {
                return DropdownMenuItem<BirthTypeEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateBirthType(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<PresentationEnum>(
          key: ValueKey('presentation_${p.id}'),
          value: PresentationEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.presentation,
          ),
          decoration: InputDecoration(
            labelText: "Presentación",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('presentation'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              PresentationEnum.values.map((option) {
                return DropdownMenuItem<PresentationEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updatePresentation(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<RuptureOfMembraneEnum>(
          key: ValueKey('ruptureOfMembrane_${p.id}'),
          value: RuptureOfMembraneEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.ruptureOfMembrane,
          ),
          decoration: InputDecoration(
            labelText: "Ruptura de membrana",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('ruptureOfMembrane'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              RuptureOfMembraneEnum.values.map((option) {
                return DropdownMenuItem<RuptureOfMembraneEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateRuptureOfMembrane(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<AmnioticFluidEnum>(
          key: ValueKey('amnioticFluid_${p.id}'),
          value: AmnioticFluidEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.amnioticFluid,
          ),
          decoration: InputDecoration(
            labelText: "Líquido amniótico",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('amnioticFluid'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              AmnioticFluidEnum.values.map((option) {
                return DropdownMenuItem<AmnioticFluidEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateAmnioticFluid(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<SexEnum>(
          key: ValueKey('sex_${p.id}'),
          value: SexEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.sex,
          ),
          decoration: InputDecoration(
            labelText: "Sexo",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('sex'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              SexEnum.values.map((option) {
                return DropdownMenuItem<SexEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateSex(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width:
                  double
                      .infinity, // Hace que ocupe todo el ancho disponible de la columna
              child: CustomDatePicker(
                label: "Seleccionar fecha de nacimiento",
                initialDate:
                    data.birthDate != null
                        ? DateFormat('dd/MM/yyyy').format(data.birthDate!)
                        : null,
                isDataSaved: isUpdateView,
                onDateChanged: (formattedDate) {
                  DateTime parsedDate = DateFormat(
                    'dd/MM/yyyy',
                  ).parse(formattedDate);
                  ref
                      .read(birthDataProvider.notifier)
                      .updateBirthDate(parsedDate);
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
                ref
                    .read(birthDataProvider.notifier)
                    .updateBirthTime(formattedTime);
              },
            ),
             if (hasBirthTimeError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  notifier.errorTextFor('birthTime')!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          "Edad gestacional",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          key: ValueKey('gestationalAge_${p.id}'),
          initialValue: data.gestationalAge?.toString() ?? '',
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
              ref
                  .read(birthDataProvider.notifier)
                  .updateGestationalAge(parsedValue);
            }
          },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<TwinEnum>(
          key: ValueKey('twin_${p.id}'),
          value: TwinEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.twin,
          ),
          decoration: InputDecoration(
            labelText: "Gestación gemelar",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('twin'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              TwinEnum.values.map((option) {
                return DropdownMenuItem<TwinEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateTwin(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<ApgarScoreEnum>(
          key: ValueKey('firstApgarScore_${p.id}'),
          value: ApgarScoreEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.firstApgarScore,
          ),
          decoration: InputDecoration(
            labelText: "Apgar al minuto",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('firstApgarScore'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              ApgarScoreEnum.values.map((option) {
                return DropdownMenuItem<ApgarScoreEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateFirstApgar(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<ApgarScoreEnum>(
          key: ValueKey('secondApgarScore_${p.id}'),
          value: ApgarScoreEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.secondApgarScore,
          ),
          decoration: InputDecoration(
            labelText: "Apgar a los 5 minutos",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('secondApgarScore'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              ApgarScoreEnum.values.map((option) {
                return DropdownMenuItem<ApgarScoreEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateSecondApgar(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<ApgarScoreEnum>(
          key: ValueKey('thirdApgarScore_${p.id}'),
          value: ApgarScoreEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.thirdApgarScore,
          ),
          decoration: InputDecoration(
            labelText: "Apgar a los 10 minutos",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('thirdApgarScore'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              ApgarScoreEnum.values.map((option) {
                return DropdownMenuItem<ApgarScoreEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateThirdApgar(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        Text(
          "Peso (grs)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          key: ValueKey('weight_${p.id}'),
          initialValue: data.weight?.toString() ?? '',
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
        Text(
          "Talla (cm)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          key: ValueKey('length_${p.id}'),
          initialValue: data.length?.toString() ?? '',
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
        Text(
          "Perímetro Cefálico (cm)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          key: ValueKey('headCircumference_${p.id}'),
          initialValue: data.headCircumference?.toString() ?? '',
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
              ref
                  .read(birthDataProvider.notifier)
                  .updateHeadCircumference(parsedValue);
            }
          },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<BloodTypeEnum>(
          key: ValueKey('bloodType_${p.id}'),
          value: BloodTypeEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.bloodType,
          ),
          decoration: InputDecoration(
            labelText: "Grupo y factor sanguineo",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('bloodType'),
          ),
          dropdownColor: Color(0xFFB3CFD1),
          icon: const SizedBox.shrink(), // 🔹 Esto quita la flecha
          items:
              BloodTypeEnum.values.map((option) {
                return DropdownMenuItem<BloodTypeEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateBloodType(newValue.getValue());
                    }
                  },
        ),
        SizedBox(height: 16),
        Container(
          decoration:
              hasPhysicalError || hasDetailsError
                  ? BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  )
                  : null,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Examen físico",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  // Opción "Normal"
                  Expanded(
                    child: RadioListTile<String>(
                      activeColor: Color(0xFF4F959D),
                      title: Text("Normal"),
                      value: "Normal",
                      groupValue: data.physicalExamination,
                      onChanged:
                          isUpdateView
                              ? null
                              : (value) {
                                ref
                                    .read(birthDataProvider.notifier)
                                    .updatePhysicalExamination(value!);
                                ref
                                    .read(birthDataProvider.notifier)
                                    .updatePhysicalExaminationDetails(
                                      "",
                                    ); // Borra texto si cambia a "Normal"
                              },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      activeColor: Color(0xFF4F959D),
                      title: Text("Anormal"),
                      value: "Anormal",
                      groupValue: data.physicalExamination,
                      onChanged:
                          isUpdateView
                              ? null
                              : (value) {
                                ref
                                    .read(birthDataProvider.notifier)
                                    .updatePhysicalExamination(value!);
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
                  key: ValueKey('physicalExaminationDetails_${p.id}'),
                  initialValue: data.physicalExaminationDetails ?? '',
                  enabled: !isUpdateView,
                  maxLines: 5, // o la cantidad que quieras mostrar visiblemente
                  minLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Detalles del examen físico",
                    floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4F959D)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    errorText: notifier.errorTextFor(
                      'physicalExaminationDetails',
                    ),
                  ),
                  onChanged:
                      isUpdateView
                          ? null
                          : (value) {
                            ref
                                .read(birthDataProvider.notifier)
                                .updatePhysicalExaminationDetails(value);
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
              activeColor: Color(0xFF4F959D),
              onChanged:
                  isUpdateView
                      ? null
                      : (value) => ref
                          .read(birthDataProvider.notifier)
                          .updateHasHepatitisBVaccine(value),
            ),

            CheckboxListTile(
              title: Text('Vitamina K'),
              value: (data.hasVitaminK),
              activeColor: Color(0xFF4F959D),
              onChanged:
                  isUpdateView
                      ? null
                      : (value) => ref
                          .read(birthDataProvider.notifier)
                          .updateHasVitaminK(value ?? false),
            ),

            CheckboxListTile(
              title: Text('Colirio oftalmológico'),
              value: (data.hasOphthalmicDrops),
              activeColor: Color(0xFF4F959D),
              onChanged:
                  isUpdateView
                      ? null
                      : (value) => ref
                          .read(birthDataProvider.notifier)
                          .updateHasOphthalmicDrops(value ?? false),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          "Número de pulsera",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          key: ValueKey('braceletNumber_${p.id}'),
          initialValue: data.braceletNumber?.toString() ?? '',
          enabled: !isUpdateView && p.birthData?.braceletNumber == null,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D)),
            ),
            errorText: notifier.errorTextFor('braceletNumber'),
          ),
          onChanged: (value) {
            if (!isUpdateView && p.birthData?.braceletNumber == null) {
              int? parsedValue = int.tryParse(value);
              ref
                  .read(birthDataProvider.notifier)
                  .updateBraceletNumber(parsedValue);
            }
          },
        ),
        SizedBox(height: 16),
        SizedBox(height: 8),
        DropdownButtonFormField<DispositionEnum>(
          key: ValueKey('disposition_${p.id}'),
          value: DispositionEnum.values.firstWhereOrNull(
            (e) => e.getValue() == data.disposition,
          ),
          decoration: InputDecoration(
            labelText: "Destino",
            floatingLabelStyle: TextStyle(color: Color(0xFF4F959D)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F959D), width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    data.disposition != null ? Color(0xFF4F959D) : Colors.grey,
              ),
            ),
            suffixIcon:
                isUpdateView ? Icon(Icons.lock, color: Colors.grey) : null,
            errorText: notifier.errorTextFor('disposition'),
          ),
          dropdownColor: const Color(0xFFB3CFD1),
          icon: const Icon(Icons.arrow_drop_down),
          items:
              DispositionEnum.values.map((option) {
                return DropdownMenuItem<DispositionEnum>(
                  value: option,
                  child: Text(option.getValue()),
                );
              }).toList(),
          onChanged:
              isUpdateView
                  ? null
                  : (newValue) {
                    if (newValue != null) {
                      ref
                          .read(birthDataProvider.notifier)
                          .updateDisposition(newValue.getValue());
                    }
                  },
        ),

        SizedBox(height: 16),
        //BOTONES DE ACCION
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceEvenly,
          children:
              isUpdateView
                  ? [
                    TextButton.icon(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(Icons.arrow_back, color: Color(0xFF4F959D)),
                      label: Text(
                        "Volver",
                        style: TextStyle(color: Color(0xFF4F959D)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Color(0xFF4F959D)),
                      tooltip: "Editar",
                      onPressed: () {
                        ref
                            .read(birthDataProvider.notifier)
                            .updateIsDataSaved(false);
                      },
                    ),
                  ]
                  : [
                    OutlinedButton(
                      onPressed: () async {
                        if (isUpdateView) {
                          context.pop(); // salir directo en modo vista
                          return;
                        }

                        final discard = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Confirmar cancelación'),
                                content: const Text(
                                  'Si sales, perderás los cambios no guardados. ¿Continuar?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(false),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        color: Color(0xFF4F959D),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(true),
                                    child: const Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        color: Color(0xFF4F959D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (discard == true) {
                          ref.read(birthDataProvider.notifier).reset();
                          Navigator.of(context).pop();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF4F959D),
                        side: BorderSide(color: Color(0xFF4F959D)),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final isValid =
                            ref.read(birthDataProvider.notifier).validateAll();
                        if (!isValid) {
                          // Mostramos errores y evitamos continuar
                          setState(
                            () {},
                          ); // Asegura redibujar los campos con errorText
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Por favor, corregí los errores antes de guardar.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        showConfirmationDialog(
                          context: context,
                          title: 'Confirmar guardado',
                          content:
                              '¿Estás seguro de que quieres guardar estos cambios?',
                          onConfirm: () async {
                            try {
                              final notifier = ref.read(
                                birthDataProvider.notifier,
                              );
                              notifier.updateIsDataSaved(true);
                              data = notifier.state;
                              await ref
                                  .read(patientActionsProvider)
                                  .submitBirthData(p.id, data);
                              if (!context.mounted)
                                return; // Asegura que el contexto sigue existiendo
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Datos guardados correctamente',
                                  ),
                                  backgroundColor: Color(0xFF4F959D),
                                ),
                              );
                              //Redirigir a la pantalla después de guardar
                              context.pop();
                            } catch (e) {
                              if (!context.mounted)
                                return; //Asegura que el contexto sigue existiendo
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al guardar los datos: $e',
                                  ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Guardar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
        ),
      ],
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
              onPressed:
                  () => Navigator.pop(
                    context,
                  ), 
              child: Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF4F959D)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
                onConfirm();
              },
              child: Text(
                'Confirmar',
                style: TextStyle(color: Color(0xFF4F959D)),
              ),
            ),
          ],
        );
      },
    );
  }
}

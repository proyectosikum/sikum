
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/birth_data.dart';
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
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(birthDataProvider.notifier).setPatient(p);
              });
            return _completeFormView(context, p, ref);
            }
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

      final data = ref.watch(birthDataProvider);

/*
      BirthData data = BirthData(
        birthType: birthData?.birthType,
        presentation: birthData?.presentation, 
        ruptureOfMembrane: birthData?.ruptureOfMembrane, 
        amnioticFluid: birthData?.amnioticFluid , 
        sex: birthData?.sex, 
        birthDate: birthData?.birthDate,
        birthTime: birthData?.birthTime,
        twin: birthData?.twin,
        firstApgarScore: birthData?.firstApgarScore,
        secondApgarScore: birthData?.secondApgarScore,
        thirdApgarScore: birthData?.thirdApgarScore,
        hasHepatitisBVaccine: birthData?.hasHepatitisBVaccine, 
        hasVitaminK: birthData?.hasVitaminK ?? p.birthData?.hasVitaminK , 
        hasOphthalmicDrops: birthData?.hasOphthalmicDrops,
        disposition: birthData?.disposition,
        gestationalAge: birthData?.gestationalAge,
        length: birthData?.length,
        headCircumference: birthData?.headCircumference,
        physicalExamination:  birthData?.physicalExamination,
        physicalExaminationDetails: birthData?.physicalExaminationDetails,
        birthPlace : birthData?.birthPlace,
        birthPlaceDetails: birthData?.birthPlaceDetails,
        braceletNumber: birthData?.braceletNumber,
      );
    */

      return ListView(   
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ExpansionTile(
              title: Text('Lugar de nacimiento'),
              subtitle: Text(data.birthPlace ?? 'No asignado'),
              children: [
                Container(
                  color: const Color.fromARGB(255, 179, 207, 209), 
                  child: Column(
                    children: PlacesEnum.values.map((option) {
                      return RadioListTile<PlacesEnum>(
                        title: Text(option.getValue()),
                        value: option,
                        activeColor: Color(0xFF4F959D),
                        groupValue: PlacesEnum.values.firstWhere(
                          (e) => e.getValue() == data.birthPlace,
                          orElse: () => PlacesEnum.hospTigre,
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Especificar otro lugar",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4F959D)), 
                      ),
                    ),
                    enabled: data.birthPlace == "Otro", 
                    onChanged: (value) {
                      ref.read(birthDataProvider.notifier).updateBirthPlaceDetails(value);
                    },
                  ),
                ),
              ],
            ),
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
                    isDataSaved: false,
                    onDateChanged: (formattedDate) {
                      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);
                      ref.read(birthDataProvider.notifier).updateBirthDate(parsedDate);
                    },
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
                  initialTime: data.birthTime, // Si hay una hora guardada, se muestra
                  isDataSaved: false, // Puedes cambiar esto para bloquearlo
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4F959D)), // ✅ Borde verde al seleccionar
                    ),
                  ),
                  onChanged: (value) {
                    int? parsedValue = int.tryParse(value);
                    if (parsedValue != null) {
                      ref.read(birthDataProvider.notifier).updateGestationalAge(parsedValue);
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
            Text("Peso (grs)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  int? parsedValue = int.tryParse(value);
                  if (parsedValue != null) {
                    ref.read(birthDataProvider.notifier).updateHeadCircumference(parsedValue);
                  }
                },
              ),
              SizedBox(height: 16),
              Column(
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
                          onChanged: (value) {
                            ref.read(birthDataProvider.notifier).updatePhysicalExamination(value!);
                            ref.read(birthDataProvider.notifier).updatePhysicalExaminationDetails(""); // Borra texto si cambia a "Normal"
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text("Otros"),
                          value: "Otros",
                          groupValue: data.physicalExamination,
                          onChanged: (value) {
                            ref.read(birthDataProvider.notifier).updatePhysicalExamination(value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  // Campo de texto solo cuando se selecciona "Otros"
                  if (data.physicalExamination == "Otros") ...[
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Detalles del examen físico",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4F959D)),
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(birthDataProvider.notifier).updatePhysicalExaminationDetails(value);
                      },
                    ),
                  ],
                ],
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
                    onChanged: (value) => ref.read(birthDataProvider.notifier).updateHasHepatitisBVaccine(value),
                  ),

                  CheckboxListTile(
                    title: Text('Vitamina K'),
                    value: (data.hasVitaminK), 
                    onChanged: (value) => ref.read(birthDataProvider.notifier).updateHasVitaminK(value ?? false),
                  ),

                  CheckboxListTile(
                    title: Text('Colirio oftalmológico'),
                    value: (data.hasOphthalmicDrops), 
                    onChanged: (value) => ref.read(birthDataProvider.notifier).updateHasOphthalmicDrops(value ?? false),
                  ),
                ],
              ),
              
              Text("Número de pulsera", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    //initialValue: data?.braceletNumber?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4F959D)),
                      ),
                    ),
                    onChanged: (value) {
                      int? parsedValue = int.tryParse(value);
                      if (parsedValue != null) {
                        ref.read(birthDataProvider.notifier).updateBraceletNumber(parsedValue);
                      }
                    },
                  ),
              SizedBox(height: 16),
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
                            onChanged: (option) =>ref.read(birthDataProvider.notifier).updateDisposition(option!.getValue()),
                          );
                        }).toList(),
                    )
                  )
                ]
              ),
              SizedBox(height: 16),
            //BOTONES DE ACCION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye los botones equitativamente
              children: [
                // Botón "Cancelar" - Fondo claro con bordes y letras en verde
                OutlinedButton(
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      title: 'Confirmar cancelación',
                      content: 'Si continúas, perderás los cambios realizados. ¿Deseas continuar?',
                      onConfirm: () {
                        Navigator.pop(context); // Vuelve a la pantalla anterior
                        ref.read(birthDataProvider.notifier).setPatient(p); // Restaura los datos originales
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
                    showConfirmationDialog(
                      context: context,
                      title: 'Confirmar guardado',
                      content: '¿Estás seguro de que quieres guardar estos cambios?',
                      onConfirm: () async {
                        try {

                          await ref.read(patientActionsProvider).submitBirthData(p.id, data);
                          //ref.read(birthDataProvider.notifier).reset();
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
                  child: Text("Aceptar", style: TextStyle(fontWeight: FontWeight.bold)),
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
/*
    Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.green, // Color del encabezado
              hintColor: Colors.green, // Color de selección
              colorScheme: ColorScheme.light(primary: Colors.green), // Gama verde
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );

     if (pickedDate != null) {
        ref.read(birthDataProvider.notifier).updateBirthDate(pickedDate);
      }
    }

    Future<void> _selectTime(BuildContext context, WidgetRef ref) async {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Color(0xFF4F959D), // ✅ Gama verde
              hintColor: Color(0xFF4F959D),
              colorScheme: ColorScheme.light(primary: Color(0xFF4F959D)),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
        ref.read(birthDataProvider.notifier).updateBirthTime(formattedTime);
      }
    }
*/
  
}

   
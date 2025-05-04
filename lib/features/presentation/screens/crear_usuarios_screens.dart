import 'package:flutter/material.dart';

class CrearUsuariosScreens extends StatelessWidget{

  const CrearUsuariosScreens({  super.key  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text('Sikum'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Lógica de salida.
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            SizedBox(height: 30),
            Center(
              child: Text(
                'Nuevo Usuario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'DNI',
                border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Telefono',
                border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Matricula Provincial',
                border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Especialidad',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'Neonatología',
                  child: Text('Neonatologia')
                ),
                DropdownMenuItem(
                  value: 'Enfermería',
                  child: Text('Enfermería')
                ),
                DropdownMenuItem(
                  value: 'Fonoudiología',
                  child: Text('Fonoudiología')
                ),
                DropdownMenuItem(
                  value: 'Interconsultor',
                  child: Text('Interconsultor')
                ),
              ],
              onChanged: (value) {
                // Lógica de seleccion
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Lógica crear
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                padding: EdgeInsets.symmetric(vertical: 16)
              ),
              child: Text('Crear')
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // Lógica cancelar
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                padding: EdgeInsets.symmetric(vertical: 16)
              ),
              child: Text('Cancelar')
            )
          ],
        ),
      ),
    );
  }
}
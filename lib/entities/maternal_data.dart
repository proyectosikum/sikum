class MaternalData {
  String firstName;
  String lastName;
  String idType;
  String idNumber;
  String age;
  String locality;
  String address;
  String email;
  String phoneNumber;
  String gravidity;
  String parity;
  String cesareans;
  String abortions;
  Map<String, bool> complications;
  Map<String, String?> testResults;
  Map<String, String?> testDates;
  String serologies;
  String bloodType;

  MaternalData({
    required this.firstName,
    required this.lastName,
    required this.idType,
    required this.idNumber,
    required this.age,
    required this.locality,
    required this.address,
    required this.email,
    required this.phoneNumber,
    required this.gravidity,
    required this.parity,
    required this.cesareans,
    required this.abortions,
    required this.complications,
    required this.testResults,
    required this.testDates,
    required this.serologies,
    required this.bloodType,
  });

  // Método para crear un objeto MaternalData a partir de un mapa (por ejemplo, de Firestore)
  factory MaternalData.fromMap(Map<String, dynamic> map) {
    return MaternalData(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      idType: map['idType'] ?? '',
      idNumber: map['idNumber'] ?? '',
      age: map['age'] ?? '',
      locality: map['locality'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      gravidity: map['gravidity'] ?? '',
      parity: map['parity'] ?? '',
      cesareans: map['cesareans'] ?? '',
      abortions: map['abortions'] ?? '',
      complications: Map<String, bool>.from(map['complications'] ?? {}),
      testResults: Map<String, String?>.from(map['testResults'] ?? {}),
      testDates: Map<String, String?>.from(map['testDates'] ?? {}),
      serologies: map['serologies'] ?? '',
      bloodType: map['bloodType'] ?? '',
    );
  }

  // Método para convertir a un mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'idType': idType,
      'idNumber': idNumber,
      'age': age,
      'locality': locality,
      'address': address,
      'email': email,
      'phoneNumber': phoneNumber,
      'gravidity': gravidity,
      'parity': parity,
      'cesareans': cesareans,
      'abortions': abortions,
      'complications': complications,
      'testResults': testResults,
      'testDates': testDates,
      'serologies': serologies,
      'bloodType': bloodType,
    };
  }
}

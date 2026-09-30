class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String bedId;
  final String zone;

  Patient ({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.bedId,
    required this.zone,
  });
  factory Patient.fromMap(Map<String, dynamic>map){
    return Patient(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map ['gender'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      bedId: map['bedId'] as String,
      zone: map['zone'] as String,
    );
  }
  Map<String,dynamic>toMap(){
    return{
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'bedId': bedId,
      'zone': zone,
    };
  }
}
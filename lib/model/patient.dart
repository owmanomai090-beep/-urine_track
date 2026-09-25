class Patient {
  final String id;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String bedId;
  final String zone;

  Patient ({
    required this.id,
    required this.name,
    required this.age,
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
      'age':age,
      'weight': weight,
      'height': height,
      'bedID': bedId,
      'zone':zone,
    };
  }
}
class Zone{
  final String name;
  final List<String> bedIds;
  Zone({
    required this.name,
    required this.bedIds,
  });
}
  final List<Zone> allZones =[
    Zone(name: 'A', bedIds:['a','b','c','d','e']),
  ];
enum DiagramType {
  postgresql('PostgreSQL'),
  firestore('Firestore'),
  custom('Custom');

  const DiagramType(this.name);

  factory DiagramType.fromString(String type) => DiagramType.values.firstWhere(
    (e) => e.name.toLowerCase() == type.toLowerCase(),
  );

  final String name;
}

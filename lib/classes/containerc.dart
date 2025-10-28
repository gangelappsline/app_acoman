class ContainerC {
  final int id;
  final String code;
  final String license_plate;

  ContainerC({
    required this.id,
    required this.code,
    required this.license_plate,
  });

  static List<ContainerC> listFromJson(List list) {
    List<ContainerC> containers = [];
    for (var value in list) {
      containers.add(ContainerC.fromJson(value));
    }
    return containers;
  }

  static ContainerC fromJson(Map parsedJson) {
    return ContainerC(
      id: parsedJson['id'],
      code: parsedJson['code'],
      license_plate: parsedJson['license_plate'],
    );
  }

}

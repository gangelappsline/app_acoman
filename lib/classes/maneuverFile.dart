class ManeuverFile {
  final int id;
  final String type;
  final String path;

  ManeuverFile({required this.id, required this.type, required this.path});

  static List<ManeuverFile> listFromJson(List list) {
        List<ManeuverFile> departments = [];
        for (var value in list) {
          departments.add(ManeuverFile.fromJson(value));
        }
        return departments;
      }

  static ManeuverFile fromJson(Map parsedJson) {
        return ManeuverFile(
          id: parsedJson['id'],
          type: parsedJson['type'],
          path: parsedJson['path'],
        );
      }
}
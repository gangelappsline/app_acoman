class Client {
  final int id;
  final String name;

  Client({required this.id, required this.name});

  static Client fromJson(Map parsedJson) {
        return Client(
          id: parsedJson['id'],
          name: parsedJson['name'],
        );
      }
}

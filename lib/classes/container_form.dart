class ContainerForm {
  final String type; // 'Pallet' o 'Granel'
  final String arrivelSeal;
  final String finishSeal;
  final String container; // '40' o '20'
  final int arrivalTemperature;
  final int platformNumber;
  final String supervisorSign;
  final String notes;
  final String agencySign;
  final String maneuverPersonnelSign;

  ContainerForm({
    required this.type,
    required this.arrivelSeal,
    required this.finishSeal,
    required this.container,
    required this.arrivalTemperature,
    required this.platformNumber,
    required this.supervisorSign,
    required this.notes,
    required this.agencySign,
    required this.maneuverPersonnelSign,
  });

  static ContainerForm fromJson(Map<String, dynamic> json) {
    return ContainerForm(
      type: json['type'] ?? '',
      arrivelSeal: json['arrivel_seal'] ?? '',
      finishSeal: json['finish_seal'] ?? '',
      container: json['container'] ?? '',
      arrivalTemperature: json['arrival_temperature'] ?? 0,
      platformNumber: json['platform_number'] ?? 0,
      supervisorSign: json['supervisor_sign'] ?? '',
      notes: json['notes'] ?? '',
      agencySign: json['agency_sign'] ?? '',
      maneuverPersonnelSign: json['maneuver_personnel_sign'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'arrivel_seal': arrivelSeal,
      'finish_seal': finishSeal,
      'container': container,
      'arrival_temperature': arrivalTemperature,
      'platform_number': platformNumber,
      'supervisor_sign': supervisorSign,
      'notes': notes,
      'agency_sign': agencySign,
      'maneuver_personnel_sign': maneuverPersonnelSign,
    };
  }
}

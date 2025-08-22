import 'package:acoman/classes/maneuver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ManeuversHistorySupervisorPage extends StatefulWidget {
  const ManeuversHistorySupervisorPage({super.key});

  @override
  State<ManeuversHistorySupervisorPage> createState() =>
      _ManeuversHistorySupervisorPageState();
}

class _ManeuversHistorySupervisorPageState
    extends State<ManeuversHistorySupervisorPage> {
  final List<Maneuver> maneuvers = [];
  List<Maneuver> _filteredHistory = [];
   DateTime? _startDate;
  DateTime? _endDate;

  Widget _buildHeaderSection(BuildContext context, Maneuver maneuver) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      maneuver.id.toString(),
                      style: Theme.of(context).textTheme.bodyLarge ,
                    ),
                    Chip(
                      label: Text('ID: ${maneuver.id}'),
                      backgroundColor: Colors.blue[50],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(maneuver.status),
                      backgroundColor: _getDifficultyColor(maneuver.status)),
                     SizedBox(width: 8),
                    Chip(
                      label: Text(maneuver.company),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  maneuver.status,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildNumberedSteps(String stepsText) {
    final steps = stepsText.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  steps[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBulletPoints(String text) {
    final points = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(points.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '•',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  points[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIndicationsSection(Maneuver maneuver ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Indicaciones y Contraindicaciones'),
        const SizedBox(height: 8),
        Text(
          'Indicaciones:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        _buildBulletPoints(maneuver.status),
        const SizedBox(height: 12),
        Text(
          'Contraindicaciones:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        _buildBulletPoints(maneuver.client.name),
      ],
    );
  }

  Widget _buildVideoSection() {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Video Demostrativo'),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_fill, size: 60, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Ver demostración en video',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _shareManeuver(BuildContext context) {
    // Implementar lógica para compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartiendo información de la maniobra...')),
    );
  }

  void _markAsFavorite(BuildContext context) {
    // Implementar lógica para favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Añadido a favoritos')),
    );
  }


Color? _getDifficultyColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'baja':
      return Colors.green[100];
    case 'media':
      return Colors.orange[100];
    case 'alta':
      return Colors.red[100];
    default:
      return Colors.grey[200];
  }
}


Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      // Mostrar el loader mientras se filtra
      EasyLoading.show(status: 'Filtrando...');
      
      // Simular una operación asíncrona
      await Future.delayed(const Duration(seconds: 1));
      
      _filterHistory();
      
      EasyLoading.dismiss();
    }
  }

  void _filterHistory() {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _filteredHistory = maneuvers;
      });
      return;
    }

    setState(() {
      _filteredHistory = maneuvers.where((item) {
        final itemDate = item.created_at as DateTime;
        return itemDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _filteredHistory = maneuvers;
    });
  }

@override
  void initState() {
    super.initState();
    _filteredHistory = maneuvers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, // Change your color here
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Historial de Maniobras',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showDateRangePicker,
          ),
            Visibility(
                visible: maneuvers.isNotEmpty,
                child: IconButton(
                  icon: Icon(
                    Icons.cleaning_services,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManeuversHistorySupervisorPage(),
                      ),
                    );
                  },
                ))
          ],
        ),
        body: Padding(padding: EdgeInsets.all(10.0)));
  }
}

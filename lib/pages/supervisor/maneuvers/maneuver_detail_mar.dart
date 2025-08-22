import 'package:acoman/classes/maneuver.dart';
import 'package:flutter/material.dart';

class ManeuverDetailMarSupervisorPage extends StatelessWidget {
  final Maneuver maneuver;

  const ManeuverDetailMarSupervisorPage({super.key, required this.maneuver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change your color here
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Maniobra #${maneuver.id.toString().padLeft(6, '0')}',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareManeuver(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen e información básica
            _buildHeaderSection(context),
            const SizedBox(height: 24),

            // Descripción detallada
            _buildSectionTitle('Descripción'),
            Text(
              maneuver.status,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Pasos en formato numerado
            _buildSectionTitle('Pasos a seguir'),
            _buildNumberedSteps("steps"),
            const SizedBox(height: 24),

            // Precauciones
            _buildSectionTitle('Precauciones importantes'),
            _buildBulletPoints("precautions"),
            const SizedBox(height: 24),

            // Indicaciones y contraindicaciones
            _buildIndicationsSection(),
            const SizedBox(height: 24),

            // Video demostrativo (opcional)
            _buildVideoSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _markAsFavorite(context),
        child: const Icon(Icons.favorite_border),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              'https://via.placeholder.com/400x200?text=Maniobra',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.medical_services,
                    size: 60, color: Colors.blue),
              ),
            ),
          ),
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
                    Chip(
                      label: Text(maneuver.company),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  maneuver.bulks.toString(),
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

  Widget _buildIndicationsSection() {
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
        _buildBulletPoints("Indications" ?? 'No hay indicaciones específicas'),
        const SizedBox(height: 12),
        Text(
          'Contraindicaciones:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        _buildBulletPoints(
            "contraindications" ?? 'No hay contraindicaciones específicas'),
      ],
    );
  }

  Widget _buildVideoSection() {
    return const SizedBox();

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
      const SnackBar(
          content: Text('Compartiendo información de la maniobra...')),
    );
  }

  void _markAsFavorite(BuildContext context) {
    // Implementar lógica para favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Añadido a favoritos')),
    );
  }
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

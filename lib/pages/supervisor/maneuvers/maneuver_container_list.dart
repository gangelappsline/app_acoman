import 'package:acoman/classes/maneuver.dart';
import 'package:acoman/classes/containerc.dart';
import 'package:acoman/pages/supervisor/maneuvers/container_form_page.dart';
import 'package:flutter/material.dart';

class ManeuverContainerList extends StatefulWidget {
  final Maneuver maneuver;
  const ManeuverContainerList({super.key, required this.maneuver});

  @override
  State<ManeuverContainerList> createState() => _ManeuverContainerListState();
}

class _ManeuverContainerListState extends State<ManeuverContainerList> {
  void _navigateToContainerForm(ContainerC container) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContainerFormPage(
          maneuver: widget.maneuver,
          container: container,
        ),
      ),
    );
  }

  Widget _buildContainerCard(ContainerC container) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToContainerForm(container),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del contenedor
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E9C8B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  size: 30,
                  color: Color(0xFF3E9C8B),
                ),
              ),
              const SizedBox(width: 16),

              // Información del contenedor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenedor ${container.code}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placa: ${container.license_plate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${container.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha para indicar navegación
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF3E9C8B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Contenedores - Maniobra ${widget.maneuver.id}',
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.maneuver.containers == null ||
              widget.maneuver.containers!.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay contenedores disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.maneuver.containers!.length,
              itemBuilder: (context, index) {
                final container = widget.maneuver.containers![index];
                return _buildContainerCard(container);
              },
            ),
    );
  }
}

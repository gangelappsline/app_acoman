import 'package:flutter/material.dart';
import 'package:acoman/classes/container_form.dart';
import 'package:acoman/classes/maneuver.dart';
import 'package:acoman/classes/containerc.dart';
import 'package:acoman/services/http_service.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class ContainerFormPage extends StatefulWidget {
  final Maneuver maneuver;
  final ContainerC container;

  const ContainerFormPage({
    super.key,
    required this.maneuver,
    required this.container,
  });

  @override
  State<ContainerFormPage> createState() => _ContainerFormPageState();
}

class _ContainerFormPageState extends State<ContainerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final HttpService _httpService = HttpService();
  bool _isLoading = false;

  // Controllers para los campos de texto
  final TextEditingController _arrivelSealController = TextEditingController();
  final TextEditingController _finishSealController = TextEditingController();
  final TextEditingController _arrivalTemperatureController =
      TextEditingController();
  final TextEditingController _platformNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Variables para radio buttons
  String _selectedType = 'Pallet';
  String _selectedContainer = '20';

  // Variables para firmas
  bool _supervisorSigned = false;
  bool _agencySigned = false;
  bool _maneuverPersonnelSigned = false;

  @override
  void dispose() {
    _arrivelSealController.dispose();
    _finishSealController.dispose();
    _arrivalTemperatureController.dispose();
    _platformNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      // Validar que todas las firmas estén completadas
      if (!_supervisorSigned || !_agencySigned || !_maneuverPersonnelSigned) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las firmas son requeridas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Crear objeto ContainerForm con los datos del formulario
        final containerForm = ContainerForm(
          type: _selectedType,
          arrivelSeal: _arrivelSealController.text,
          finishSeal: _finishSealController.text,
          container: _selectedContainer,
          arrivalTemperature:
              int.tryParse(_arrivalTemperatureController.text) ?? 0,
          platformNumber: int.tryParse(_platformNumberController.text) ?? 0,
          supervisorSign: _supervisorSigned ? 'Firmado' : '',
          notes: _notesController.text,
          agencySign: _agencySigned ? 'Firmado' : '',
          maneuverPersonnelSign: _maneuverPersonnelSigned ? 'Firmado' : '',
        );

        // Enviar datos al servidor
        final response = await _httpService.putDataHttp(
          '/containers',
          containerForm.toJson(),
        );

        //Simular espera de respuesta
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Información del contenedor guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);

        /*if (response.statusCode == 200 || response.statusCode == 201) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Información del contenedor guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar de regreso
          Navigator.pop(context);
        } else {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }*/
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSignatureDialog({
    required String title,
    required Function(bool) onSigned,
  }) async {
    final GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SfSignaturePad(
              key: signatureKey,
              backgroundColor: Colors.white,
              strokeColor: Colors.black,
              minimumStrokeWidth: 1.0,
              maximumStrokeWidth: 4.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                signatureKey.currentState!.clear();
              },
              child: const Text('Limpiar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Verificar si hay una firma
                if (signatureKey.currentState != null) {
                  onSigned(true);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, agregue su firma'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E9C8B),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioGroup({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E9C8B),
          ),
        ),
        const SizedBox(height: 8),
        //Colocar los RadioListTile horizontalmente
        ...options
            .map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF3E9C8B),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildSignatureButton({
    required String label,
    required bool isSigned,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E9C8B),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(
              isSigned ? Icons.check_circle : Icons.edit,
              color: Colors.white,
            ),
            label: Text(
              isSigned ? 'Firmado' : 'Toque para firmar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSigned ? Colors.green : const Color(0xFF3E9C8B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Contenedor ${widget.container.code}',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo (Radio buttons)
              _buildRadioGroup(
                title: 'Tipo',
                value: _selectedType,
                options: ['Pallet', 'Granel'],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Sello de llegada
              const Text(
                'Sello de Llegada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E9C8B),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _arrivelSealController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el sello de llegada',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF3E9C8B), width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sello de salida
              const Text(
                'Sello de Salida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E9C8B),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _finishSealController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el sello de salida',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF3E9C8B), width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Contenedor (Radio buttons)
              _buildRadioGroup(
                title: 'Contenedor',
                value: _selectedContainer,
                options: ['20', '40'],
                onChanged: (value) {
                  setState(() {
                    _selectedContainer = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Temperatura de llegada
              const Text(
                'Temperatura de Llegada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E9C8B),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _arrivalTemperatureController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ingrese la temperatura',
                  suffixText: '°C',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF3E9C8B), width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // No de Andén
              const Text(
                'No. de Andén',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E9C8B),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _platformNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ingrese el número de andén',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF3E9C8B), width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Firma de Supervisor
              _buildSignatureButton(
                label: 'Firma de Supervisor',
                isSigned: _supervisorSigned,
                onPressed: () {
                  _showSignatureDialog(
                    title: 'Firma de Supervisor',
                    onSigned: (signed) {
                      setState(() {
                        _supervisorSigned = signed;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Observaciones
              const Text(
                'Observaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E9C8B),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ingrese observaciones adicionales',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF3E9C8B), width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Firma de representante de agencia
              _buildSignatureButton(
                label: 'Firma de Representante de Agencia',
                isSigned: _agencySigned,
                onPressed: () {
                  _showSignatureDialog(
                    title: 'Firma de Representante de Agencia',
                    onSigned: (signed) {
                      setState(() {
                        _agencySigned = signed;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Firma de personal de maniobras
              _buildSignatureButton(
                label: 'Firma de Personal de Maniobras',
                isSigned: _maneuverPersonnelSigned,
                onPressed: () {
                  _showSignatureDialog(
                    title: 'Firma de Personal de Maniobras',
                    onSigned: (signed) {
                      setState(() {
                        _maneuverPersonnelSigned = signed;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 30),

              // Botón para guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E9C8B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Información',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

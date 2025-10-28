import 'package:acoman/classes/maneuver.dart';
import 'package:acoman/classes/containerc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class ManeuverContainerFilesPage extends StatefulWidget {
  final Maneuver maneuver;
  final ContainerC container;

  const ManeuverContainerFilesPage({
    super.key,
    required this.maneuver,
    required this.container,
  });

  @override
  State<ManeuverContainerFilesPage> createState() =>
      _ManeuverContainerFilesPageState();
}

class _ManeuverContainerFilesPageState
    extends State<ManeuverContainerFilesPage> {
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  List<File> _selectedImages = [];
  List<File> _damageImages = [];
  bool _isUploading = false;
  String _currentSection = 'general'; // 'general' o 'damage'

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          if (_currentSection == 'general') {
            _selectedImages.add(File(image.path));
          } else {
            _damageImages.add(File(image.path));
          }
        });
      }
    } catch (e) {
      _logger.e('Error al tomar foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al acceder a la cámara'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanDocument() async {
    try {
      dynamic scannedDocuments =
          await FlutterDocScanner().getScannedDocumentAsImages();

      if (scannedDocuments != null && scannedDocuments["Uri"] != null) {
        String uriString = scannedDocuments["Uri"].toString();
        uriString =
            uriString.replaceAll('[Page{imageUri=', '').replaceAll('}]', '');

        File file = File.fromUri(Uri.parse(uriString));

        if (await file.exists()) {
          setState(() {
            if (_currentSection == 'general') {
              _selectedImages.add(file);
            } else {
              _damageImages.add(file);
            }
          });
        }
      }
    } on PlatformException catch (e) {
      _logger.e('Error al escanear documento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al escanear documento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty && _damageImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Agregue al menos una foto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    EasyLoading.show(status: 'Subiendo fotos...');

    try {
      final String baseUrl = dotenv.env["ACOMAN_API_URL"].toString();
      final token = await storage.read(key: "acoman-jwt");

      int uploadedCount = 0;
      int totalImages = _selectedImages.length + _damageImages.length;

      // Subir fotos generales
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        String uploadUrl = '$baseUrl/maneuvers/${widget.maneuver.id}/files';

        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
          ..headers.addAll({
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token'
          })
          ..files.add(await http.MultipartFile.fromPath('file', file.path))
          ..fields['type'] = 'Foto de cama ${widget.container.code}'
          ..fields['container_id'] = widget.container.id.toString();

        var response = await request.send();

        if (response.statusCode == 200) {
          uploadedCount++;
        } else {
          _logger.e(
              'Error al subir imagen general ${i + 1}: ${response.statusCode}');
        }
      }

      // Subir fotos de daños
      for (int i = 0; i < _damageImages.length; i++) {
        final file = _damageImages[i];
        String uploadUrl = '$baseUrl/maneuvers/${widget.maneuver.id}/files';

        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
          ..headers.addAll({
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token'
          })
          ..files.add(await http.MultipartFile.fromPath('file', file.path))
          ..fields['type'] = 'Daño contenedor ${widget.container.code}'
          ..fields['container_id'] = widget.container.id.toString();

        var response = await request.send();

        if (response.statusCode == 200) {
          uploadedCount++;
        } else {
          _logger.e(
              'Error al subir imagen de daño ${i + 1}: ${response.statusCode}');
        }
      }

      EasyLoading.dismiss();

      if (uploadedCount == totalImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todas las fotos se subieron correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedImages.clear();
          _damageImages.clear();
        });

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se subieron $uploadedCount de $totalImages fotos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      _logger.e('Error al subir imágenes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir las fotos'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  void _removeImage(int index, String section) {
    setState(() {
      if (section == 'general') {
        _selectedImages.removeAt(index);
      } else {
        _damageImages.removeAt(index);
      }
    });
  }

  Widget _buildImageCard(File imageFile, int index, String section) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeImage(index, section),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                section == 'general'
                    ? 'Foto ${index + 1}'
                    : 'Daño ${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Fotos - Contenedor ${widget.container.code}',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            onTap: (index) {
              setState(() {
                _currentSection = index == 0 ? 'general' : 'damage';
              });
            },
            tabs: [
              Tab(
                icon: Icon(Icons.photo_camera),
                text: 'Fotos Generales',
              ),
              Tab(
                icon: Icon(Icons.warning),
                text: 'Daños',
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del contenedor
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: Theme.of(context).colorScheme.primary,
                        size: 40,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contenedor ${widget.container.code}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Placa: ${widget.container.license_plate}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Maniobra: ${widget.maneuver.id}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botones para agregar fotos
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImageFromCamera,
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label:
                          Text('Cámara', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentSection == 'general'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.orange[700],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scanDocument,
                      icon: Icon(Icons.document_scanner, color: Colors.white),
                      label: Text('Escanear',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentSection == 'general'
                            ? Colors.orange
                            : Colors.red[600],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // TabBarView con contenido
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab de fotos generales
                    _buildPhotoSection(
                        _selectedImages, 'general', 'fotos generales'),
                    // Tab de fotos de daños
                    _buildPhotoSection(
                        _damageImages, 'damage', 'fotos de daños'),
                  ],
                ),
              ),

              // Botón para subir fotos
              if (_selectedImages.isNotEmpty || _damageImages.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Subir ${_selectedImages.length + _damageImages.length} foto(s)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildPhotoSection(
      List<File> images, String section, String sectionName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contador de fotos y botón limpiar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${sectionName.capitalize()}: ${images.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (images.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    images.clear();
                  });
                },
                child: Text('Limpiar ${sectionName}'),
              ),
          ],
        ),

        SizedBox(height: 8),

        // Lista de fotos o estado vacío
        Expanded(
          child: images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        section == 'general'
                            ? Icons.photo_camera
                            : Icons.warning,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay ${sectionName}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        section == 'general'
                            ? 'Toque "Cámara" o "Escanear" para agregar fotos generales'
                            : 'Toque "Cámara" o "Escanear" para documentar daños',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return _buildImageCard(images[index], index, section);
                  },
                ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

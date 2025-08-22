import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:acoman/services/http_service.dart';
import 'package:http/http.dart' as http;

class ScanDocummentsPage extends StatefulWidget {
  const ScanDocummentsPage({super.key});

  @override
  State<ScanDocummentsPage> createState() => _ScanDocummentsPageState();
}

class _ScanDocummentsPageState extends State<ScanDocummentsPage> {
  dynamic _scannedDocuments;
  var logger = Logger();
  bool isScanned = false;
  File? imageFile;

  Future<void> processData(String data) async {
    // This method is used to process the scanned documents
    // You can implement your logic here
    print("Processing data...");
    Map<String, dynamic> jsonData = jsonDecode(data);

    // Extraer la parte de la URI
    String uriPart = jsonData['Uri']; // "[Page{imageUri=file:///...jpg}]"

    // Usar expresión regular para extraer la URI del archivo
    RegExp exp = RegExp(r'file://[^"]+');
    Match? match = exp.firstMatch(uriPart);

    if (match != null) {
      String fileUri = match.group(0)!;
      File imageFile = File.fromUri(Uri.parse(fileUri));

      // Verificar existencia
      if (await imageFile.exists()) {
        print('Archivo válido: ${imageFile.path}');
        // Usar el archivo aquí
      } else {
        print('El archivo no existe: ${imageFile.path}');
      }
    } else {
      print('No se encontró URI de archivo en el JSON');
    }
  }

  Future<void> scanDocument() async {
    dynamic scannedDocuments;
    try {
      scannedDocuments = await FlutterDocScanner().getScanDocuments(page: 4) ??
          'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    print(scannedDocuments.toString());
    if (!mounted) return;
    setState(() {
      _scannedDocuments = scannedDocuments;
    });
  }

  Future<File?> uriToFile(String uriString) async {
    try {
      // Limpiar la URI si viene con formato extraño
      uriString =
          uriString.replaceAll('[Page{imageUri=', '').replaceAll('}]', '');

      // Crear el objeto File
      File file = File.fromUri(Uri.parse(uriString));

      // Verificar existencia
      if (await file.exists()) {
        _uploadImage("ine", file);
        setState(() {
          imageFile = file;
        });
        return file;
      } else {
        print('El archivo no existe en la ruta: ${file.path}');
        return null;
      }
    } catch (e) {
      print('Error al convertir URI a File: $e');
      return null;
    }
  }

  Future<void> scanDocumentAsImages() async {
    dynamic scannedDocuments;
    try {
      scannedDocuments =
          await FlutterDocScanner().getScannedDocumentAsImages() ??
              'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    //print(scannedDocuments.toString());
    logger.d(scannedDocuments.toString());
    //processData(scannedDocuments.toString());
    uriToFile(scannedDocuments["Uri"].toString());
    /*String uriString = scannedDocuments["Uri"];
    uriString = uriString.replaceAll('[Page{imageUri=file://', '');
    uriString = uriString.replaceAll('}]', '');
    File imageFile = File(uriString);

    logger.d("Image File Path: ${imageFile.path}");*/

    if (!mounted) return;
    // _uploadImage("ine", scannedDocuments);
    setState(() {
      _scannedDocuments = scannedDocuments;
    });
  }

  Future<void> scanDocumentAsPdf() async {
    dynamic scannedDocuments;
    try {
      scannedDocuments =
          await FlutterDocScanner().getScannedDocumentAsPdf(page: 4) ??
              'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    print(scannedDocuments.toString());
    if (!mounted) return;
    setState(() {
      _scannedDocuments = scannedDocuments;
    });
  }

  Future<void> _uploadImage(String type, File imageFile) async {
    final String baseUrl = dotenv.env["ACOMAN_API_URL"].toString();
    EasyLoading.show(status: 'Guardando imagenes');
    final token = await storage.read(key: "acoman-jwt");

    String addimageUrl = '$baseUrl/test-upload';
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token'
    };

    var request = http.MultipartRequest('POST', Uri.parse(addimageUrl))
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path))
      ..fields['type'] = type; // O "Reverso"
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Imagen subida correctamente");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imagen subida con éxito")),
        );
      } else {
        print("❌ Error al subir imagen: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al subir la imagen")),
        );
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
    }
    EasyLoading.dismiss();
  }

  Future<void> scanDocumentUri() async {
    //This Feature only supported for Android.
    dynamic scannedDocuments;
    try {
      scannedDocuments =
          await FlutterDocScanner().getScanDocumentsUri(page: 4) ??
              'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    print(scannedDocuments.toString());
    if (!mounted) return;
    setState(() {
      _scannedDocuments = scannedDocuments;
    });
  }

  Future requestCameraPermission() async {
    await Permission.camera.request();
    await Permission.storage.request();
    await Permission.photos.request();
  }

  @override
  void initState() {
    super.initState();
    // Request camera permission
    requestCameraPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner example app'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageFile != null
                  ? Image.file(
                      imageFile!,
                      width: 200,
                      height: 200,
                    )
                  : Text("No Image Selected"),
              _scannedDocuments != null
                  ? Text(_scannedDocuments.toString())
                  : const Text("No Documents Scanned"),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  scanDocument();
                },
                child: const Text("Scan Documents"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  scanDocumentAsImages();
                },
                child: const Text("Scan Documents As Images"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  scanDocument();
                },
                child: const Text("Scan Documents As PDF"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  scanDocumentUri();
                },
                child: const Text("Get Scan Documents URI"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

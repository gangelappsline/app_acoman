import 'package:acoman/classes/maneuver.dart';
import 'package:acoman/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:logger/web.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:acoman/services/http_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ManeuverDetailFreezeSupervisorPage extends StatefulWidget {
  final Maneuver maneuver;

  const ManeuverDetailFreezeSupervisorPage({super.key, required this.maneuver});

  @override
  State<ManeuverDetailFreezeSupervisorPage> createState() =>
      _ManeuverDetailFreezeSupervisorPageState();
}

class _ManeuverDetailFreezeSupervisorPageState
    extends State<ManeuverDetailFreezeSupervisorPage> {
  String dropdownValue = '1';
  final ImagePicker _picker = ImagePicker();

  dynamic firstSeal;
  dynamic secondSeal;
  TextEditingController quantityCtrl = TextEditingController();
  dynamic _cameraImage;
  var logger = Logger();

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

    uriToFile(scannedDocuments["Uri"].toString());

    if (!mounted) return;
  }

  Future<void> _uploadImage(String type, File imageFile) async {
    final String baseUrl = dotenv.env["ACOMAN_API_URL"].toString();
    EasyLoading.show(status: 'Guardando imagenes');
    final token = await storage.read(key: "acoman-jwt");

    String addimageUrl = '$baseUrl/maneuvers/${widget.maneuver.id}/files';
    logger.d(addimageUrl);
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
        //final respStr = await response.stream.bytesToString();
        //final j = json.decode(respStr);
        //logger.d(j);
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

  Future _getCameraImage() async {
    var image =
        await _picker.pickImage(source: ImageSource.camera); // using the camera

    setState(() {
      firstSeal = image;
      //_uploadPic(_cameraImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change your color here
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Maniobras #${widget.maneuver.id.toString().padLeft(6, "0")}',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Agencia aduanal"),
                                SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  controller: TextEditingController(
                                      text: widget.maneuver.product),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("Número de contenedor"),
                                SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  controller: TextEditingController(
                                      text: widget.maneuver.product),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ]))),
                  Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Inspección",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Cantidad de muestra"),
                                  Container(
                                      width: size.width * 0.15,
                                      child: TextFormField(
                                        controller: quantityCtrl,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.all(4),
                                        ),
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [Text("Dictamen de autotidad")],
                              )
                            ],
                          ))),
                  Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Inspección",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Divider(),
                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        _getCameraImage();
                                      },
                                      child: Text("Primer sello")),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        scanDocumentAsImages();
                                      },
                                      child: Text("Licencia de conducir")),
                                ],
                              )
                            ],
                          ))),
                  Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Contanedor",
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Divider(),
                                Row(children: [
                                  Text("40"),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Checkbox(
                                      value: true,
                                      onChanged: (value) {
                                        print(value);
                                      }),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text("20"),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Checkbox(
                                      value: true,
                                      onChanged: (value) {
                                        print(value);
                                      })
                                ])
                              ]))),
                  Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Observaciones",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  IconButton(
                                      onPressed: () {}, icon: Icon(Icons.add))
                                ],
                              ),
                              Divider(),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [Text("Dictamen de autotidad")],
                              )
                            ],
                          ))),
                ],
              ))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstants.kPrimaryColorBlueLight,
        onPressed: () {},
        child: const Icon(
          Icons.save_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'package:acoman/classes/maneuver.dart';
import 'package:acoman/components/custom_progress_indicator.dart';
import 'package:acoman/pages/fullScreenImage.dart';
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
import 'package:http/http.dart';

class ManeuverDertailsTollPage extends StatefulWidget {
  final Maneuver maneuver;
  const ManeuverDertailsTollPage({super.key, required this.maneuver});

  @override
  State<ManeuverDertailsTollPage> createState() =>
      _ManeuverDertailsTollPageState();
}

class _ManeuverDertailsTollPageState extends State<ManeuverDertailsTollPage> {
  String dropdownValue = '1';
  final ImagePicker _picker = ImagePicker();
  HttpService httpService = HttpService();

  dynamic firstSeal;
  dynamic secondSeal;
  TextEditingController quantityCtrl = TextEditingController();
  dynamic _cameraImage;
  var logger = Logger();
  bool isLoading = true;
  String? ineFile;
  String? licenseFile;
  bool checkIn = false;
  bool checkOut = false;

  Future<File?> uriToFile(String uriString, String type) async {
    try {
      // Limpiar la URI si viene con formato extraño
      uriString =
          uriString.replaceAll('[Page{imageUri=', '').replaceAll('}]', '');

      // Crear el objeto File
      File file = File.fromUri(Uri.parse(uriString));

      // Verificar existencia
      if (await file.exists()) {
        _uploadImage(type, file);
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

  Future<void> scanDocumentAsImages(String type) async {
    dynamic scannedDocuments;
    try {
      scannedDocuments =
          await FlutterDocScanner().getScannedDocumentAsImages() ??
              'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }

    uriToFile(scannedDocuments["Uri"].toString(), type);

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
        logger.d(response);
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

  Future<void> _getManeuverFiles() async {
    Response response =
        await httpService.getDataHttp("/maneuvers/${widget.maneuver.id}/files");

    final j = json.decode(response.body);
    logger.d(j);
    switch (response.statusCode) {
      case 200:
        j["data"].forEach((file) {
          logger.d(file);
          if (file["type"] == "INE") {
            setState(() {
              ineFile = file["path"];
            });
          }

          if (file["type"] == "Licencia de conducir") {
            setState(() {
              licenseFile = file["path"];
            });
          }
        });
        break;
      case 422:
        break;
      default:
    }
  }

  Future<void> _updateCheckIn() async {
    EasyLoading.show(status: 'Registrando entrada');

    Map<String, dynamic> data = {
      'check_in': DateTime.now().toIso8601String(),
    };

    Response response =
        await httpService.putDataHttp("/maneuvers/${widget.maneuver.id}", data);

    final j = json.decode(response.body);
    logger.d(response.body);
    logger.d(j);
    EasyLoading.dismiss();
    switch (response.statusCode) {
      case 200:
        setState(() {
          checkIn = true;
        });
        EasyLoading.showToast("Registro de entrada exitoso",
            duration: const Duration(seconds: 2),
            toastPosition: EasyLoadingToastPosition.bottom);
        break;
      case 422:
        EasyLoading.showToast("Debe completar el formulario",
            duration: const Duration(seconds: 2),
            toastPosition: EasyLoadingToastPosition.bottom);
        break;
      default:
    }
  }

  Future<void> _updateCheckOut() async {
    EasyLoading.show(status: 'Registrando entrada');

    Map<String, dynamic> data = {
      'check_out': DateTime.now().toIso8601String(),
    };

    Response response =
        await httpService.putDataHttp("/maneuvers/${widget.maneuver.id}", data);

    final j = json.decode(response.body);
    EasyLoading.dismiss();
    switch (response.statusCode) {
      case 200:
        setState(() {
          checkOut = true;
        });
        EasyLoading.showToast("Registro de salida exitoso",
            duration: const Duration(seconds: 2),
            toastPosition: EasyLoadingToastPosition.bottom);
        break;
      case 422:
        EasyLoading.showToast("Debe completar el formulario",
            duration: const Duration(seconds: 2),
            toastPosition: EasyLoadingToastPosition.bottom);
        break;
      default:
    }
  }

  void _init() async {
    // Check for camera permission
    logger.d(widget.maneuver);
    await _getManeuverFiles();
    setState(() {
      isLoading = false;
      checkIn = widget.maneuver.check_in != null;
      checkOut = widget.maneuver.check_out != null;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
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
      body: isLoading
          ? Center(child: CustomProgressIndicator())
          : SingleChildScrollView(
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
                                    Text("Contenedor",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      controller: TextEditingController(
                                          text: widget.maneuver.container),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Agencia"),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      controller:
                                          TextEditingController(text: ""),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Importadpor"),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      controller: TextEditingController(
                                          text: widget.maneuver.importer),
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
                                    "Documentación de conductor",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: ineFile == null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    scanDocumentAsImages("ine");
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      spacing: 10,
                                                      children: [
                                                        Icon(Icons.add_a_photo),
                                                        Text(
                                                          "INE",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        )
                                                      ],
                                                    ),
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            style: BorderStyle
                                                                .solid)),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 120,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder: (_) {
                                                          return FullScreenImagePage(
                                                            imageUrl: ineFile!,
                                                            tag: 'INEImage',
                                                          );
                                                        }));
                                                      },
                                                      child: Image.network(
                                                        ineFile!,
                                                      )))),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: licenseFile == null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    scanDocumentAsImages(
                                                        "license");
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      spacing: 10,
                                                      children: [
                                                        Icon(Icons.add_a_photo),
                                                        Text(
                                                          "Licencia",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        )
                                                      ],
                                                    ),
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            style: BorderStyle
                                                                .solid)),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 120,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder: (_) {
                                                          return FullScreenImagePage(
                                                            imageUrl:
                                                                licenseFile!,
                                                            tag: 'LicenseImage',
                                                          );
                                                        }));
                                                      },
                                                      child: Image.network(
                                                        licenseFile!,
                                                      )))),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {},
                                          child: Text("Licencia de conducir")),
                                    ],
                                  )
                                ],
                              ))),
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
                                        "Contenedores",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.add))
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ))),
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                          visible: !checkIn,
                          child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                ),
                                onPressed: () {
                                  _updateCheckIn();
                                },
                                child: Text(
                                  "Registrar entrada",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                          visible: !checkOut && checkIn,
                          child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                ),
                                onPressed: () {
                                  _updateCheckOut();
                                },
                                child: Text("Registrar salida",
                                    style: TextStyle(color: Colors.white)),
                              )))
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

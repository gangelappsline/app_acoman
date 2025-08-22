import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

const storage = FlutterSecureStorage();

class HttpService {
  final String baseUrl = dotenv.env["ACOMAN_API_URL"].toString();
  //final String baseUrl = "https://acoman-api.herokuapp.com/api/v1";

  Future<Response> postDataHttp(String urlString, Map body) async {
    final token = await storage.read(key: "acoman-jwt");
    Uri url = Uri.parse(baseUrl + urlString);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.post(url, body: jsonEncode(body), headers: headers).timeout(
  const Duration(seconds: 10),
  onTimeout: () {
    // Time has run out, do what you wanted to do.
    return http.Response('Error', 408); // Request Timeout response status code
  },
);

    return response;
  }

  Future<Response> putDataHttp(String urlString, Map body) async {
    final token = await storage.read(key: "acoman-jwt");
    Uri url = Uri.parse(baseUrl + urlString);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response =
        await http.put(url, body: jsonEncode(body), headers: headers);
    return response;
  }

  Future<Response> deleteDataHttp(String urlString, Map body) async {
    final token = await storage.read(key: "acoman-jwt");
    Uri url = Uri.parse(baseUrl + urlString);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response =
        await http.delete(url, body: jsonEncode(body), headers: headers);
    return response;
  }

  Future<Response> postImageDataHttp(String urlString, File image) async {
    final token = await storage.read(key: "acoman-jwt");
    //Uri url = Uri.parse(baseUrl + urlString);
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token'
    };

    final request =
        http.MultipartRequest('POST', Uri.parse(baseUrl + urlString))
          ..headers.addAll(headers)
          ..files.add(await http.MultipartFile.fromPath('image', image.path));
    var response = await http.Response.fromStream(await request.send());
    return response;
  }

  Future<Response> getDataHttp(String urlString) async {
    final token = await storage.read(key: 'acoman-jwt');
    Uri url = Uri.parse(baseUrl + urlString);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.get(url, headers: headers);
    return response;
  }
}

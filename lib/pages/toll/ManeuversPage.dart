import 'dart:convert';
import 'dart:io';

import 'package:acoman/classes/maneuver.dart';
import 'package:acoman/components/custom_progress_indicator.dart';
import 'package:acoman/components/maneuver_card.dart';
import 'package:acoman/pages/supervisor/maneuvers/history.dart';
import 'package:acoman/pages/toll/ManeuverDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:acoman/services/http_service.dart';
import 'package:logger/logger.dart';

class ManeuversTollPage extends StatefulWidget {
  const ManeuversTollPage({super.key});

  @override
  State<ManeuversTollPage> createState() => _ManeuversTollPageState();
}

class _ManeuversTollPageState extends State<ManeuversTollPage> {
  HttpService httpService = HttpService();
  List<Maneuver> _allManeuvers = [];
  List<Maneuver> _filteredManeuvers = [];
  bool isLoading = true;

  

  final TextEditingController _searchController = TextEditingController();

  var logger = Logger();

  Widget _buildManeuverCard(Maneuver maneuver) {
    return ManeuverCard(maneuver: maneuver);
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

  Future getManeuvers() async {
    Response response = await httpService.getDataHttp("/maneuvers");

    final j = json.decode(response.body);
    logger.d(j);
    switch (response.statusCode) {
      case 200:
        setState(() {
          _allManeuvers = Maneuver.listFromJson(j["data"]);
          _filteredManeuvers = _allManeuvers;
          
        });
        break;
      case 422:
        break;
      default:
    }
  }

  void _init() async {
    await Future.any([getManeuvers()]);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
    //_filteredManeuvers = _allManeuvers;
    _searchController.addListener(_filterManeuvers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterManeuvers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredManeuvers = _allManeuvers.where((maneuver) {
        return maneuver.id.toString().toLowerCase().contains(query) ||
            maneuver.status.toLowerCase().contains(query) ||
            maneuver.pediment.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToDetail(Maneuver maneuver) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManeuverDertailsTollPage(maneuver: maneuver),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Programación de Maniobras',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.history_rounded,
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
            )
          ],
        ),
        body: isLoading
            ? Center(
                child: CustomProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    return getManeuvers();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar maniobra por ID o nombre...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Lista de maniobras
                      Expanded(
                        child: _filteredManeuvers.isEmpty
                            ? const Center(
                                child: Column(children: [
                                  Text(
                                    'No se encontraron maniobras',
                                    style: TextStyle(fontSize: 20.0),
                                  )
                                ]),
                              )
                            : ListView.builder(
                                itemCount: _filteredManeuvers.length,
                                itemBuilder: (context, index) {
                                  final maneuver = _filteredManeuvers[index];
                                  return GestureDetector(
                                    onTap: () => _navigateToDetail(maneuver),
                                    child: ManeuverCard(maneuver: maneuver),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}

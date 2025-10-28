import 'package:acoman/classes/client.dart';
import 'package:acoman/classes/maneuverFile.dart';
import 'package:acoman/classes/containerc.dart';
import 'package:flutter/material.dart';

class Maneuver {
  final int id;
  final String status;
  final String pediment;
  final String patent;
  final String? container;
  final List<ContainerC>? containers;
  final String product;
  final String? type;
  final int bulks;
  final String country;
  final String presentation;
  final String importer;
  final String folio_200;
  final String folio_500;
  final String created_at;
  final String? check_in;
  final String? check_out;
  final Client client;
  

  Maneuver(
      {required this.id,
      required this.status,
      required this.pediment,
      required this.patent,
      this.container,
      this.containers,
      required this.product,
      this.type,
      required this.country,
      required this.bulks,
      required this.presentation,
      required this.importer,
      required this.folio_200,
      required this.folio_500,
      required this.created_at,
      this.check_in,
      this.check_out,
      required this.client,});

      static List<Maneuver> listFromJson(List list) {
        List<Maneuver> departments = [];
        for (var value in list) {
          departments.add(Maneuver.fromJson(value));
        }
        return departments;
      }

      static Maneuver fromJson(Map parsedJson) {
        return Maneuver(
          id: parsedJson['id'],
          status: parsedJson['status'],
          pediment: parsedJson['pediment'],
          patent: parsedJson['patent'],
          container: parsedJson['container'],
          containers: ContainerC.listFromJson(parsedJson['containers']),
          product: parsedJson['product'],
          type: parsedJson['type'],
          country: parsedJson['country'],
          bulks: parsedJson['bulks'],
          presentation: parsedJson['presentation'],
          importer: parsedJson['importer'],
          folio_200: parsedJson['folio_200'],
          folio_500: parsedJson['folio_500'],
          created_at: parsedJson['created_at'],
          check_in: parsedJson['check_in'],
          check_out: parsedJson['check_out'],
          client: Client.fromJson(parsedJson['client']),
        );
      }
}

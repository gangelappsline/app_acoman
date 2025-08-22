import 'package:acoman/classes/maneuver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ManeuverCard extends StatefulWidget {
  final Maneuver maneuver;
  const ManeuverCard({super.key, required this.maneuver});

  @override
  State<ManeuverCard> createState() => _ManeuverCardState();
}

class _ManeuverCardState extends State<ManeuverCard> {
  @override
  Widget build(BuildContext context) {
    var typeIcon = "";
    switch (widget.maneuver.type) {
      case 'frio':
        typeIcon = "assets/images/acoman-freeze.svg";
        break;
      case 'seco':
        typeIcon = "assets/images/acoman-dry.svg";
        break;
      case 'marindustria':
        typeIcon = "assets/images/acoman-marindustrias.svg";
        break;
      default:
        typeIcon = "assets/images/acoman-empty.svg";
        break;
    }

    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${widget.maneuver.id.toString().padLeft(6, '0')}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SvgPicture.asset(
                  typeIcon,
                  width: 40,
                  height: 40,
                  semanticsLabel: 'Dart Logo',
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
                '${widget.maneuver.product} - ${widget.maneuver.bulks.toString()} ${widget.maneuver.presentation}'),
            const SizedBox(height: 8),
            Text(widget.maneuver.company),
          ],
        ),
      ),
    );
  }
}

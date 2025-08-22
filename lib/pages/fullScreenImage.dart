import 'package:flutter/material.dart';

class FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImagePage({super.key,required this.imageUrl,required this.tag});

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: widget.tag,
            child: Image.network(widget.imageUrl),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
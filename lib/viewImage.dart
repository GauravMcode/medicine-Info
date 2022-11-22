import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  String medImage;
  String medName;
  ViewImage(this.medImage, this.medName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medName),
      ),
      body: Container(
        height: 400,
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(medImage), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

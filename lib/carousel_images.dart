import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:carousel_pro/carousel_pro.dart';

class CarouselHome extends StatelessWidget {
  const CarouselHome({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.1, 1, 0.1, 0.1),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.40,
        width: MediaQuery.of(context).size.width * 1.05,
        child: Carousel(dotSize: 4, dotBgColor: Colors.transparent, images: [
          Image.asset(
            "assets/image01.jpeg",
            height: 200,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/image02.jpeg",
            height: 200.0,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/image03.jpeg",
            height: 200.0,
            fit: BoxFit.cover,
          ),
        ]),
      ),
    );
  }
}

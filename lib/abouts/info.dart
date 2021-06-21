import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class Info extends StatelessWidget {
  const Info({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan[600],
          toolbarHeight: 60,
          title: AutoSizeText('About Carp Kenya'),
          centerTitle: true,
        ),
        backgroundColor: Colors.black87,
        body: Container(
            padding: EdgeInsets.all(7),
            child: Column(children: [
              SizedBox(
                height: 30,
              ),
              AutoSizeText(
                'Collegiate Association for the Research of Prinples(C.A.R.P). A campus based organisation that strives to raise young leaders who have mature character and strong moral values.For students by students Motto "Love God,Love People,Love your Nation!"',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                maxLines: 6,
                softWrap: true,
              ),
              SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/carp.png',
                width: MediaQuery.of(context).size.width,
              ),
              SizedBox(
                height: 5,
              ),
              AutoSizeText(
                'Official Logo',
                style: TextStyle(color: Colors.white70),
              ),
            ])));
  }
}

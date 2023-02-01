import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class Notifications extends StatelessWidget {
  const Notifications({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic data = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan[600],
          elevation: 4.0,
          toolbarHeight: 70,
          title: Text('Notifications'),
          centerTitle: true,
        ),
        body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 3.0),
            width: MediaQuery.of(context).size.width,
            child: Card(
                color: Colors.grey[300],
                margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 0.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: AutoSizeText(
                            data[index]['name'],
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17.0),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: AutoSizeText(
                            data[index]['description'],
                            overflow: TextOverflow.clip,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 2.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: new RichText(
                              text: new TextSpan(
                                children: [
                                  new TextSpan(
                                    text: 'Click for more or go to Page',
                                    style: new TextStyle(
                                        color: Colors.blue, fontSize: 16),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunch(
                                            data[index]['Link'])) {
                                          await launch(data[index]['Link']);
                                        } else {
                                          throw "Cannot Load URL";
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                )),
          ),
        ));
  }

  getNots() {}
}

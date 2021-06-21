import 'package:auto_size_text/auto_size_text.dart';
import 'package:carpkenya/eventDetails.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert' as convert;
import 'dart:async';

class EventList extends StatefulWidget {
  EventList({
    Key key,
    this.cardings,
    this.controller,
  }) : super(key: key);

  final List cardings;
  final ScrollController controller;

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  List data;
  bool isThere = true;
  var check;

  @override
  void initState() {
    super.initState();
    this.getBooks();
  }

  var url = 'http://carp.pythonanywhere.com/activity_json_format/?format=json';

  Future<String> getBooks() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    check = connectivityResult;
    if (check == ConnectivityResult.mobile ||
        check == ConnectivityResult.wifi) {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          var convertData = convert.jsonDecode(response.body);
          data = convertData;
          isThere = true;
        });
        return "Success";
      } else {
        isThere = false;
        return 'Failure';
      }
    }
    return 'success';
  }

  @override
  Widget build(BuildContext context) {
    return Events(data: data, choice: isThere, check: check);
  }
}

class Events extends StatefulWidget {
  const Events({
    Key key,
    @required this.data,
    @required this.choice,
    @required this.check,
  }) : super(key: key);

  final List data;
  final bool choice;
  final check;

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.42,
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.fromLTRB(1, 5, 1, 1),
      child: getEvents(widget.choice, widget.check),
    );
  }

  getEvents(choice, check) {
    if (check == ConnectivityResult.mobile ||
        check == ConnectivityResult.wifi) {
      return GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.data == null ? 0 : widget.data.length,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 3.0),
          width: MediaQuery.of(context).size.width * 0.40,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventDetails(),
                    settings: RouteSettings(arguments: widget.data[index])),
              );
            },
            child: Card(
              child: Hero(
                tag: widget.data[index]['event'],
                child: Material(
                  child: InkWell(
                    child: GridTile(
                      footer: Container(
                        height: MediaQuery.of(context).size.height * 0.10,
                        color: Colors.cyan[600],
                        child: Center(
                          child: AutoSizeText(
                            widget.data[index]['event'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                        ),
                      ),
                      child: Image.network(
                        'http://carp.pythonanywhere.com' +
                            widget.data[index]['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getLoader(),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Icon(
                  Icons.signal_cellular_connected_no_internet_4_bar,
                  size: 50,
                  color: Colors.black54,
                ),
                AutoSizeText('No internet Connection'),
              ],
            ),
          )
        ],
      );
    }
  }

  getLoader() {
    return Center(
      child: SpinKitFadingCircle(
        color: Colors.cyan[600],
        size: 50,
      ),
    );
  }
}

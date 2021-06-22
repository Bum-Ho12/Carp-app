import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carpkenya/book_details.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert' as convert;
import 'dart:async';
import 'package:toast/toast.dart';

class CardList extends StatefulWidget {
  CardList({Key key, this.cardings}) : super(key: key);

  final List cardings;

  @override
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList>
    with AutomaticKeepAliveClientMixin {
  dynamic data = [];
  bool isThere = true;
  var check;
  bool _connection = true;
  Box box2;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //this.getBooks();
  }

  var url = 'http://carp.pythonanywhere.com/book_json_format/?format=json';
  Future openBox() async {
    //Hive.init(dir.path);
    box2 = await Hive.openBox('books');
    return;
  }

  Future<bool> getAll() async {
    await openBox();
    try {
      var response = await http.get(url);
      var convertData = convert.jsonDecode(response.body);
      await putData(convertData);
    } catch (e) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      check = connectivityResult;
      _connection = !_connection;
      print('error');
    }

    var myData = box2.toMap().values.toList();

    if (myData.isEmpty) {
      data.add('empty');
    } else {
      data = myData;
    }
    return Future.value(true);
  }

  Future putData(fetched) async {
    await box2.clear();
    for (var d in fetched) {
      box2.add(d);
    }
  }

  Future<void> updateData() async {
    try {
      var response = await http.get(url);
      var convertData = convert.jsonDecode(response.body);
      await putData(convertData);
      setState(() {});
    } catch (SocketException) {
      Toast.show("No internet", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  getImage(index) {
    if (index['imageFile'] != null) {
      return _connection
          ? CachedNetworkImage(
              imageUrl: 'http://carp.pythonanywhere.com' + index['imageFile'],
              fit: BoxFit.contain,
            )
          : Icon(
              Icons.image,
              size: 120,
              color: Colors.black12,
            );
    } else {
      return Icon(
        Icons.image,
        size: 120,
        color: Colors.black12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: RefreshIndicator(
        color: Colors.cyan[600],
        onRefresh: updateData,
        child: getNet(),
      ),
    );
  }

  getNet() {
    return data.contains('empty')
        ? AnimatedSwitcher(
            reverseDuration: Duration(milliseconds: 200),
            key: Key('1'),
            duration: Duration(milliseconds: 2000),
            child: _connection
                ? Container(
                    key: Key('1'),
                    child: getLoader(),
                  )
                : Container(
                    key: Key('2'),
                    child: getNt(),
                  ),
          )
        : FutureBuilder(
            future: getAll(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (data.contains('empty')) {
                  return Center(
                      child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(8.0),
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.signal_cellular_off_sharp)),
                      Text('No internet'),
                    ],
                  ));
                } else {
                  return GridView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: data == null ? 0 : data.length,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.2),
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Card(
                        child: Hero(
                          tag: data[index]['Title'],
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookDetails(),
                                      settings: RouteSettings(
                                          arguments: data[index])),
                                );
                              },
                              child: GridTile(
                                footer: Container(
                                  color: Colors.white70,
                                  child: ListTile(
                                    title: AutoSizeText(
                                      data[index]['Title'],
                                      style: TextStyle(
                                        color: Colors.brown,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                ),
                                child: getImage(data[index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
              return Text('');
            });
  }

  getLoader() {
    return Center(
      child: SpinKitFadingCircle(
        color: Colors.cyan[600],
        size: 40,
      ),
    );
  }

  getNt() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 150),
        child: Column(
          children: [
            Icon(
              Icons.signal_cellular_connected_no_internet_4_bar,
              size: 30,
              color: Colors.black54,
            ),
            AutoSizeText(
              'No internet Connection',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carpkenya/abouts/album.dart';
import 'package:carpkenya/abouts/info.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toast/toast.dart';
import 'carousel_images.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'eventDetails.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Box box;
  List data = [];
  bool isThere = true;
  var check;
  bool _connection = true;
  ScrollController controller = ScrollController();
  bool closeCarousel = false;
  @override
  void initState() {
    super.initState();
    //this.getBooks();
    controller.addListener(() {
      setState(() {
        closeCarousel = controller.offset > 50;
      });
    });
  }

  var url = 'http://carp.pythonanywhere.com/activity_json_format/?format=json';
  Future openBox() async {
    //Hive.init(dir.path);
    box = await Hive.openBox('data');
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

    var myData = box.toMap().values.toList();

    if (myData.isEmpty) {
      data.add('empty');
    } else {
      data = myData;
    }
    return Future.value(true);
  }

  Future putData(fetched) async {
    await box.clear();
    for (var d in fetched) {
      box.add(d);
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
    if (index['image'] != null) {
      return Container(
          width: 190,
          child: CachedNetworkImage(
            imageUrl: 'http://carp.pythonanywhere.com' + index['image'],
            fit: BoxFit.contain,
          ));
    } else {
      return Icon(
        Icons.image,
        color: Colors.black45,
        size: 190,
      );
    }
  }

  getEvents() {
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
                    child: getNet(),
                  ),
          )
        : FutureBuilder(
            future: getAll(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (data.contains('empty')) {
                  return Text('no Data');
                } else {
                  return ListView.builder(
                      controller: controller,
                      itemCount: data == null ? 0 : data.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.30,
                          padding: EdgeInsets.symmetric(vertical: 2),
                          color: Colors.white70,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            height: MediaQuery.of(context).size.height * 0.27,
                            margin: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 2),
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 2),
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EventDetails(),
                                        settings: RouteSettings(
                                            arguments: data[index])),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    getImage(data[index]),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            padding: EdgeInsets.only(
                                                right: 10, top: 30),
                                            margin: EdgeInsets.only(right: 10),
                                            child: AutoSizeText(
                                              data[index]['event'],
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15.0),
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            margin: EdgeInsets.only(
                                                right: 10, bottom: 37),
                                            child: AutoSizeText(
                                              data[index]['description'],
                                              textAlign: TextAlign.left,
                                              style: TextStyle(fontSize: 10),
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 80),
                                          child: Icon(
                                            Icons.read_more,
                                            color: Colors.black54,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                }
              }
              return Text('');
            },
          );
  }

  getLoader() {
    return Center(
      child: SpinKitFadingCircle(
        color: Colors.cyan[600],
        size: 40,
      ),
    );
  }

  getNet() {
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

  double _iconSize = 27;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: Container(
            margin: EdgeInsets.only(left: 10),
            height: 50,
            width: 50,
            child: Image.asset('assets/leading.png')),
        toolbarHeight: 70,
        title: AutoSizeText(
          'Carp Kenya',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.cyan[600],
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Info()),
              );
            },
            icon: Icon(Icons.info),
            color: Colors.white,
            iconSize: _iconSize,
          )
        ],
      ),
      body: Container(
        child: RefreshIndicator(
          color: Colors.cyan[600],
          onRefresh: updateData,
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).size.width,
                      height: closeCarousel
                          ? 0
                          : MediaQuery.of(context).size.height * 0.3,
                      duration: Duration(microseconds: 100),
                      child: CarouselHome()),
                ],
              ),
              Expanded(
                child: getEvents(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _floatingButton(),
    );
  }

  _floatingButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      height: 45,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2.0, // soften the shadow
              //spreadRadius: 5.0, //extend the shadow
              offset: Offset(
                0.5, // Move to right 10  horizontally
                0.5, // Move to bottom 10 Vertically
              ),
            )
          ],
          border: Border.all(width: 1, color: Colors.transparent),
          borderRadius: BorderRadius.circular(40),
          color: Colors.cyan[600]),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Album()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.perm_media,
              color: Colors.white,
              size: 23,
            ),
            AutoSizeText(
              'Album',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

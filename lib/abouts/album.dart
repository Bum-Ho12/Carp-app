//import 'dart:html';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';

class Album extends StatefulWidget {
  Album({Key key, this.cardings}) : super(key: key);

  final List cardings;

  @override
  _AlbumState createState() => _AlbumState();
}

class _AlbumState extends State<Album>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  dynamic data = [];
  bool isThere = true;
  var check;
  bool _connection = true;
  AnimationController _animationController;
  Animation<Offset> _animate;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    this.getBooks();
  }

  var url = 'http://carp.pythonanywhere.com/album_json_format/?format=json';
  Future<String> getBooks() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    check = connectivityResult;
    if (check == ConnectivityResult.none) {
      setState(() {
        _connection = !_connection;
      });
    }
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

  getImage(index) {
    if (index['image'] != null) {
      return CachedNetworkImage(
        imageUrl: 'http://carp.pythonanywhere.com' + index['image'],
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        Icons.image,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[600],
        toolbarHeight: 60,
        title: AutoSizeText(
          'Carp Kenya collections',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black87,
      body: getIt(),
    );
  }

  getIt() {
    return data.isEmpty
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
        : GridView.builder(
            scrollDirection: Axis.vertical,
            itemCount: data == null ? 0 : data.length,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.2),
              width: 180.0,
              child: GestureDetector(
                onTap: () {
                  _imagePop(context, data[index]);
                },
                child: Card(
                  child: Hero(
                    tag: data[index]['description'],
                    child: GridTile(
                      child: getImage(data[index]),
                    ),
                  ),
                ),
              ),
            ),
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

  getNt() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 150),
        child: Column(
          children: [
            Icon(
              Icons.signal_cellular_connected_no_internet_4_bar,
              size: 30,
              color: Colors.white70,
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

  getImg(index) {
    if (index['image'] != null) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: CachedNetworkImage(
          imageUrl: 'http://carp.pythonanywhere.com' + index['image'],
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Icon(
        Icons.image,
      );
    }
  }

  void _imagePop(context, data) {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _animate = Tween<Offset>(begin: Offset.zero, end: Offset(0, 0.2))
        .animate(_animationController);
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return Center(
            child: Material(
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  padding: EdgeInsets.only(bottom: 1, top: 15),
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Center(
                      child: SizedBox(
                    width: double.infinity,
                    child: InteractiveViewer(
                      child: Column(children: [
                        getImg(data),
                        ListTile(
                          title: Container(
                            child: AutoSizeText(
                              'Occasion: ${data['description']}',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _animate,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed))
                                    return Colors.cyan;
                                  return Colors.cyan[
                                      400]; // Use the component's default.
                                },
                              ),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25))),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: AutoSizeText(
                              'Go back',
                              key: Key('1'),
                            ),
                          ),
                        )
                      ]),
                    ),
                  )),
                )),
          );
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

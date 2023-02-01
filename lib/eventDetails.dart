import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({
    Key key,
  }) : super(key: key);

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    connect();
  }

  var check;
  bool _connection = true;

  Future<void> connect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    check = connectivityResult;
    if (check == ConnectivityResult.mobile ||
        check == ConnectivityResult.wifi) {
      setState(() {
        _connection = true;
      });
    } else {
      setState(() {
        _connection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Map data = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[600],
        elevation: 4.0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.084,
        title: AutoSizeText(data['event']),
        centerTitle: true,
      ),
      body: SizedBox(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _connection
                    ? CachedNetworkImage(
                        imageUrl:
                            'http://carp.pythonanywhere.com' + data['image'],
                        height: MediaQuery.of(context).size.height * 0.35,
                        fit: BoxFit.contain,
                        //excludeFromSemantics: true,
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: Center(
                            child: Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.black45),
                        ))),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(width: 0, color: Colors.white)),
                  child: Center(
                    child: AutoSizeText(
                      'About This Event',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: AutoSizeText(
                    data['description'],
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

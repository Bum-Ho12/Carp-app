import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';
import '../book_details.dart';

class Drama extends StatefulWidget {
  @override
  _DramaState createState() => _DramaState();
}

class _DramaState extends State<Drama> with AutomaticKeepAliveClientMixin {
  var data;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    this.getBooks();
  }

  var url = 'http://carp.pythonanywhere.com/book_json_format/?format=json';
  var filteredList;
  var category;

  Future<dynamic> getBooks() async {
    var response = await http.get(url);
    setState(() {
      String decodedData = response.body;
      var convertData = convert.jsonDecode(decodedData);
      data = convertData;
      var rest = data as List;
      filteredList = rest.where((val) => val["category"] == "others");
      category = filteredList.toList();
    });
    return filteredList.toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (category != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan[600],
          title: AutoSizeText(
            'Other Books',
            style: TextStyle(fontSize: 17),
          ),
        ),
        body: Container(
          child: GridView.builder(
            scrollDirection: Axis.vertical,
            itemCount: category == null ? 0 : category.length,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.2),
              width: 180.0,
              child: Card(
                child: Hero(
                  tag: category[index]['Title'],
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookDetails(),
                              settings:
                                  RouteSettings(arguments: category[index])),
                        );
                      },
                      child: GridTile(
                        footer: Container(
                          color: Colors.white70,
                          child: ListTile(
                            title: AutoSizeText(
                              category[index]['Title'],
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                        child: Image.network(
                          'http://carp.pythonanywhere.com' +
                              category[index]['imageFile'],
                          fit: BoxFit.cover,
                        ),
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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan[600],
          title: AutoSizeText(
            'Other Books',
            style: TextStyle(fontSize: 17),
          ),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SpinKitFadingCircle(
                    color: Colors.cyan[600],
                    size: 40,
                  ),
                ),
                AutoSizeText("Loading, Please wait!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      );
    }
  }
}

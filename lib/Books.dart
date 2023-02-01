import 'package:auto_size_text/auto_size_text.dart';
import 'package:carpkenya/category/drama.dart';
import 'package:carpkenya/category/educational.dart';
import 'package:carpkenya/category/inpirational.dart';
import 'package:flutter/material.dart';
import 'List.dart';
import 'category/Unification.dart';

class Books extends StatefulWidget {
  const Books({Key key}) : super(key: key);

  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[600],
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }),
        elevation: 4.0,
        toolbarHeight: 60,
        title: AutoSizeText('Books', style: TextStyle(fontSize: 17)),
        centerTitle: true,
      ),
      body: SizedBox(child: CardList()),
      drawerEdgeDragWidth: 0,
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.cyan,
            ),
            child: AutoSizeText(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
          ListTile(
            title: AutoSizeText('Founder\'s Books'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Unification(),
                  ));
            },
          ),
          ListTile(
            title: AutoSizeText('Educational Books'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Educational(),
                  ));
            },
          ),
          ListTile(
            title: AutoSizeText('Inspirational Books'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Inspirational(),
                  ));
            },
          ),
          ListTile(
            title: AutoSizeText('Others'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Drama(),
                  ));
            },
          ),
        ],
      )),
    );
  }
}

//import 'dart:html';
import 'package:carpkenya/downloads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'Books.dart';
import 'Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      home: Tabs(),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
    );
  }
}

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  @override
  bool get wantKeepAlive => true;

  final tabs = [
    Center(child: Home()),
    Center(child: Books()),
    Center(child: Downloads()),
  ];
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: tabs[_currentIndex],
        bottomNavigationBar: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.08,
          //margin: EdgeInsets.only(bottom: 3),
          //padding: EdgeInsets.only(top: 0, bottom: 5),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 4,
            unselectedItemColor: Colors.black45,
            selectedItemColor: Colors.cyan[600],
            currentIndex: _currentIndex,
            //selectedFontSize: 10,
            //unselectedFontSize: 10,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_filled,
                  size: 27,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.local_library_rounded,
                  size: 27,
                ),
                label: 'Books',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.folder_rounded,
                  size: 27,
                ),
                label: 'Downloads',
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

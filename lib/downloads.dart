import 'dart:io' as io;
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_2/pdfviewer.dart';
import 'package:pdf_viewer_2/pdfviewer_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloads extends StatefulWidget {
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  String directory;
  List file = [];

  //gets the list of all files downloaded
  void listofFiles() async {
    String pdfPath = '/storage/emulated/0/CarpDoc';
    Directory directory;
    file = io.Directory("$pdfPath").listSync();

    if (file == null) {
      if (await _requestPermission(Permission.storage)) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        print(directory);
        List<String> paths = directory.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/CarpDoc";
        directory = Directory(newPath);
        print('------newDIR $directory');
        setState(() {
          file = directory.listSync();
        });
      } else {
        setState(() {
          file = io.Directory("$pdfPath").listSync();
        });
        Container(
          child: Column(
            children: [
              AutoSizeText(
                'Ooops no downloads',
                style: TextStyle(fontSize: 15),
              ),
              CircularProgressIndicator(),
            ],
          ),
        );
      }
    } else {
      if (await _requestPermission(Permission.photos)) {
        directory = await getTemporaryDirectory();
      }
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<void> deleteFile(File dfile) async {
    try {
      final file = dfile;
      await file.delete();
    } catch (e) {
      return 0;
    }
  }

  _backGround() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  showSnackBar(context, _file) {
    final snackBar = SnackBar(
      duration: Duration(milliseconds: 500),
      content: AutoSizeText(
        '$_file has been deleted',
        style: TextStyle(
          fontSize: 13,
        ),
      ),
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    listofFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[600],
        elevation: 4.0,
        toolbarHeight: 60,
        title: AutoSizeText(
          'Downloads',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: file.length > 0
          ? Container(
              margin: EdgeInsets.only(top: 5),
              child: ListView.builder(
                itemCount: file.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(file[index].path.split('/').last),
                    onDismissed: (direction) {
                      var _file = file[index].path.split('/').last;
                      deleteFile(file[index]);
                      showSnackBar(context, _file);
                    },
                    background: _backGround(),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ViewPDF(
                              pathPDF: file[index].path,
                              namePDF: file[index].path.split('/').last,
                            );
                          }));
                        },
                        title: AutoSizeText(
                          file[index].path.split('/').last,
                          style: TextStyle(fontSize: 15),
                        ),
                        leading: Icon(
                          Icons.auto_stories_sharp,
                          color: Colors.orange[300],
                          size: 30,
                        ),
                        subtitle: AutoSizeText(
                          'swipe left/right to delete this file',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : Container(
              child: Center(
                child: AutoSizeText(
                  'No Books',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ),
    );
  }
}

class ViewPDF extends StatelessWidget {
  //final io. File pathPDF;
  final String pathPDF;
  final String namePDF;
  ViewPDF({this.pathPDF, this.namePDF});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PDFViewerScaffold(
            appBar: AppBar(
              backgroundColor: Colors.cyan[600],
              title: AutoSizeText(
                "$namePDF",
                style: TextStyle(fontSize: 17),
              ),
            ),
            path: pathPDF),
      ),
    );
  }
}

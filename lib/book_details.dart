import 'dart:io';
import 'dart:io' as io;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:carpkenya/book_read.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_2/pdfviewer_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf_viewer_2/pdfviewer.dart';

class BookDetails extends StatefulWidget {
  const BookDetails({
    Key key,
  }) : super(key: key);

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _animationControlled;
  Animation<Offset> _animated;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    // downloadFile();
    listofFiles();
    connect();
  }

  Dio dio = Dio();
  var check;
  //int _total;
  //int _rec;
  bool _connection = true;
  String progressString = '';
  bool downloading = false;
  double progress = 0;
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

  Future<bool> downloadFile(pdfUrl, pdfname) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
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
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/$pdfname.pdf");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(pdfUrl, saveFile.path,
            onReceiveProgress: (rec, total) {
          setState(() {
            progress = rec / total;
            //_rec = rec;
            //_total = total;
            progressString = "Downloading File";
          });
        });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      setState(() {
        downloading = false;
      });
      return false;
    } catch (e) {
      return false;
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

  List file = [];
  //gets the list of all files downloaded
  void listofFiles() async {
    String pdfPath = '/storage/emulated/0/CarpDoc';
    Directory directory;
    //directory =(await getExternalStorageDirectory()).path;
    file = io.Directory("$pdfPath").listSync();

    if (file == null) {
      if (await _requestPermission(Permission.storage)) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
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
      }
    } else {
      if (await _requestPermission(Permission.photos)) {
        directory = await getTemporaryDirectory();
      }
    }
  }

  getImage(data) {
    if (data['imageFile'] != null) {
      return _connection
          ? CachedNetworkImage(
              imageUrl: 'http://carp.pythonanywhere.com' + data['imageFile'],
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
              )));
    } else {
      return Icon(
        Icons.image,
        size: 300,
      );
    }
  }

  String filename;

  getAll(data, pdfUrl) {
    _animationControlled =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _animated = Tween<Offset>(begin: Offset.zero, end: Offset(0.2, 0))
        .animate(_animationControlled);
    if (pdfUrl != null) {
      return SizedBox(
        child: Padding(
            padding: const EdgeInsets.only(left: 3, right: 3, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                getImage(data),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 0, color: Colors.white)),
                  child: Center(
                    child: AutoSizeText(
                      'Overview of the Book',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.cyan;
                                return Colors
                                    .cyan[400]; // Use the component's default.
                              },
                            ),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25))),
                          ),
                          child: Icon(Icons.auto_stories_sharp),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookRead(),
                                  settings: RouteSettings(arguments: data)),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.cyan;
                                return Colors
                                    .cyan[400]; // Use the component's default.
                              },
                            ),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                          ),
                          child: Icon(Icons.file_download),
                          onPressed: () async {
                            downloading = true;
                            progress = 0;
                            downloadFile(pdfUrl, data['Title']);
                            setState(() {
                              progressString = "Download complete";
                            });
                          }),
                    ),
                  ],
                ),
                downloading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          color: Colors.brown[400],
                          minHeight: 8.0,
                          value: progress,
                        ),
                      )
                    : AutoSizeText(''),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black38),
                      child: AutoSizeText(
                        progressString.isEmpty
                            ? 'You can read or download this book'
                            : 'this book has been Downloaded',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            )),
      );
    } else {
      return SizedBox(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  getImage(data),
                  ListTile(
                    title: AutoSizeText(
                      data['description'],
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Map data = ModalRoute.of(context).settings.arguments;
    filename = data['Title'] + '.pdf';
    String pdfUrl = 'http://carp.pythonanywhere.com' + data['File'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan[600],
        elevation: 4.0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.084,
        title: AutoSizeText(
          data['Title'],
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: getAll(data, pdfUrl),
      floatingActionButton: _floatButton(),
    );
  }

  _floatButton() {
    String fil;
    if (progress > 0) {
      return;
    } else {
      for (int x = 0; x <= file.length; x++) {
        if (x == file.length) {
          break;
        } else {
          fil = file[x].path.split('/').last;
          String _doc = file[x].path;
          _animationControlled = AnimationController(
              vsync: this, duration: const Duration(milliseconds: 800))
            ..repeat(reverse: true);
          _animated = Tween<Offset>(begin: Offset.zero, end: Offset(0, 0.1))
              .animate(_animationControlled);
          if ('$fil' == '$filename') {
            setState(() {
              progressString = 'Downloaded';
            });
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ViewPDF(
                    pathPDF: _doc,
                    namePDF: fil,
                  );
                }));
              },
              child: SlideTransition(
                position: _animated,
                child: Icon(
                  Icons.folder_special,
                  color: Colors.orange[300],
                  size: 38,
                ),
              ),
              backgroundColor: Colors.black26,
            );
          }
        }
      }
    }
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

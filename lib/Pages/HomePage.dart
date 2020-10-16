import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import '../Pages/ResultPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../JsonDecode.dart';

Future<bool> setThemeData(bool local) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var res = await prefs.setBool("theme", local);
  return res;
}

// Drawer
Widget homePageDrawer({bool isDark, setTheme}) {
  final drawerTextStyle = TextStyle(fontSize: 18);

  return Builder(
    builder: (context) => Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              child: Center(
                  child: Text(
            "Settings",
            style: TextStyle(fontSize: 26.0),
          ))),
          ListTile(
            title: Text(
              "Dark mode",
              style: drawerTextStyle,
            ),
            trailing: Switch(
                value: isDark,
                onChanged: (value) async {
                  setTheme(value);
                  await setThemeData(value);
                }),
          ),
          ListTile(
              title: Text(
                "Developer",
                style: drawerTextStyle,
              ),
              trailing: IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () async {
                  String baseURL =
                      "https://www.instagram.com/vishva_photography1/";
                  if (await canLaunch(baseURL)) {
                    await launch(baseURL);
                  } else {
                    final snackBar =
                        SnackBar(content: Text('Could not launch URL'));
                    Scaffold.of(context).showSnackBar(snackBar);
                    throw "Could not launch URL";
                  }
                },
              ))
        ],
      ),
    ),
  );
}

// App Bar
Widget homePageAppBar(context, {bool isDark}) {
  return AppBar(
    leading: Builder(
      builder: (context) => IconButton(
          icon: Icon(
            Icons.dehaze,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          }),
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: Text(
      "Tomato Disease Detector",
      style: TextStyle(fontSize: 24.0),
    ),
    // backgroundColor: Colors.transparent,
    elevation: 8.0,
  );
}

// ignore: must_be_immutable
class MainContent extends StatefulWidget {
  bool isLoading;
  File imgFile;
  String imgPath;
  bool isDark;
  Function loadingIndicator;

  MainContent(
      {this.imgFile,
      this.imgPath,
      this.isLoading,
      this.isDark,
      this.loadingIndicator});

  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  String lable;
  double confidence;

  final _picker = ImagePicker();

  // Loading TF model
  loadModel(context, String model, String label, String errorMessage) async {
    try {
      String res =
          await Tflite.loadModel(model: model, labels: label, numThreads: 4);
      print("Model Loaded : " + res);
    } catch (e) {
      print(e);
      final snackBar = SnackBar(content: Text(errorMessage));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> runOnImage(String path) async {
    // Image recognition using tfLite
    print("RunOnImage :" + path);

    try {
      loadModel(context, "assets/mobile.tflite", "assets/Lable.txt",
          'Image is not clear to detect!');

      var recognitions = await Tflite.runModelOnImage(
          path: path, numResults: 1, imageMean: 0.0, imageStd: 255);
      print(recognitions);

      // Decoding
      if (recognitions != null) {
        ResponseList resList = ResponseList.fromJson(recognitions);
        print(resList.listOfResponse[0].label);

        int confi = (resList.listOfResponse[0].confidence * 100).toInt();

        if (confi < 85) {
          print("Image is not clear to detect!'");

          final snackBar =
              SnackBar(content: Text('Image is not clear to detect!'));
          Scaffold.of(context).showSnackBar(snackBar);
          return;
        }

        setState(() {
          lable = resList.listOfResponse[0].label;
          confidence = resList.listOfResponse[0].confidence;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultPage(
                    isDark: widget.isDark,
                    imgFile: widget.imgFile,
                    imgPath: widget.imgPath,
                    lable: lable,
                    confidence: confidence,
                  )),
        );
      }
    } catch (e) {
      print(e);
      final snackBar = SnackBar(content: Text('Something went wrong!'));
      Scaffold.of(context).showSnackBar(snackBar);
      print('Something went wrong in running ML!');
    }
  }

  // Click
  onClick(ImageSource source) async {
    widget.loadingIndicator(true);
    print(widget.isLoading);

    try {
      print(widget.isLoading);
      PickedFile pickedFile = await _picker.getImage(source: source);
      final File image = File(pickedFile.path);
      print(image.path);

      // Setting Image
      if (image != null) {
        setState(() {
          widget.imgFile = image;
          widget.imgPath = image.path;
        });

        try {
          loadModel(context, "assets/tomatoOrother.tflite",
              "assets/TomatoOrotherlabels.txt", 'Select a leaf image!');
          var firstModel = await Tflite.runModelOnImage(
              path: widget.imgPath,
              numResults: 1,
              imageMean: 0.001,
              imageStd: 255);

          if (firstModel != null) {
            ResponseList resList = ResponseList.fromJson(firstModel);
            print(resList.listOfResponse[0].label);

            int confi = (resList.listOfResponse[0].confidence * 100).toInt();

            print(confi.toString() + "%");

            if (resList.listOfResponse[0].label == "Other") {
              print("It is not a tomato leaf.");
              final snackBar = SnackBar(content: Text('Select a leaf image!'));
              Scaffold.of(context).showSnackBar(snackBar);
              widget.loadingIndicator(false);
              print(widget.isLoading);
              return;
            } else {
              await runOnImage(widget.imgPath);
              await Tflite.close();
            }
          }
        } catch (e) {
          print("Loading Model" + e);
        }
      } else {
        final snackBar = SnackBar(content: Text('No image selected!'));
        Scaffold.of(context).showSnackBar(snackBar);
        print('No image selected.');
      }

      widget.loadingIndicator(false);
      print(widget.isLoading);
    } catch (e) {
      print(e);
      final snackBar = SnackBar(content: Text('No image selected!'));
      Scaffold.of(context).showSnackBar(snackBar);
      print('Something went wrong in image picking!');
    }
    widget.loadingIndicator(false);
    print(widget.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
              flex: 2,
              child: Text(
                "Take a picture from camera \nor\n Open gallery and select a picture ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28.0),
              )),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 1,
                      child: RaisedButton.icon(
                        onPressed: () async {
                          onClick(ImageSource.camera);
                          widget.loadingIndicator(false);
                          print(widget.isLoading);
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 26.0,
                        ),
                        label: Text("Camera",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                        color: Colors.blue,
                      )),
                  Flexible(
                      flex: 1,
                      child: RaisedButton.icon(
                        onPressed: () async {
                          onClick(ImageSource.gallery);
                        },
                        icon: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 26.0,
                        ),
                        label: Text(
                          "Gallery",
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                        color: Colors.blue,
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({this.isDark});
  bool isDark;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  File imgFile;
  String imgPath;

  setTheme(value) {
    setState(() {
      widget.isDark = value;
    });
  }

  // Initial state
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadingIndicator(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Theme(
        data: ThemeData(
            brightness: widget.isDark ? Brightness.dark : Brightness.light),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: homePageAppBar(context, isDark: widget.isDark),
            body: Builder(
              builder: (context) => Stack(
                children: [
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                  Column(
                    children: [
                      Flexible(flex: 2, child: Container()),
                      Flexible(
                          flex: 3,
                          child: MainContent(
                            imgFile: imgFile,
                            imgPath: imgPath,
                            isLoading: isLoading,
                            isDark: widget.isDark,
                            loadingIndicator: loadingIndicator,
                          )),
                      Flexible(flex: 2, child: Container()),
                    ],
                  )
                ],
              ),
            ),
            drawer: homePageDrawer(isDark: widget.isDark, setTheme: setTheme),
          ),
        ),
      ),
    );
  }
}

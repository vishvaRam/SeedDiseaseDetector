import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import '../Pages/ResultPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import '../JsonDecode.dart';

Future<bool> setThemeData(bool local) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var res = await prefs.setBool("theme", local);
  return res;
}

// Drawer
Widget homePageDrawer({bool isDark, setTheme}) {
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
            title: Text("Dark mode"),
            trailing: Switch(
                value: isDark,
                onChanged: (value) async {
                  setTheme(value);
                  await setThemeData(value);
                }),
          )
        ],
      ),
    ),
  );
}

// App Bar
Widget homePageAppBar(context, {bool isDark}) {
  return AppBar(
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: Text(
      "Detector",
      style:
          TextStyle(color: isDark ? Colors.white : Colors.blue, fontSize: 24.0),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    actions: [
      Builder(
          builder: (context) => IconButton(
              icon: Icon(
                Icons.settings,
                color: isDark ? Colors.white : Colors.blue,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              }))
    ],
  );
}

// ignore: must_be_immutable
class MainContent extends StatefulWidget {

  bool isLoading;
  File imgFile;
  String imgPath;
  bool isDark;

  MainContent({this.imgFile, this.imgPath, this.isLoading, this.isDark});

  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  final _picker = ImagePicker();

  // Loading TF model
  loadModel() async {
    String res = await Tflite.loadModel(
      model: "assets/mobile.tflite",
      labels: "assets/Lable.txt",
    );
    print("Model Loaded : " + res);
  }

  Future<void> runOnImage(String path) async {
    // Image recognition using tfLite
    print("RunOnImage :" + path);

    setState(() {
      widget.isLoading = true;
    });

    try {
      var recognitions = await Tflite.runModelOnImage(
          path: path, numResults: 1, imageMean: 0.0, imageStd: 255);
      print(recognitions);


      if( recognitions != null ){

        ResponseList resList = ResponseList.fromJson(recognitions);
        print(resList.listOfResponse[0].index);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultPage(
                isDark: widget.isDark,
                imgFile: widget.imgFile,
              )),
        );
      }

    } catch (e) {
      print(e);
      final snackBar = SnackBar(content: Text('Something went wrong!'));
      Scaffold.of(context).showSnackBar(snackBar);
      print('Something went wrong in running ML!');
    }

    setState(() {
      widget.isLoading = false;
    });
  }

  // Click
  onClick(ImageSource source) async {
    try {
      PickedFile pickedFile =
          await _picker.getImage(source: source, maxWidth: 256, maxHeight: 256);
      final File image = File(pickedFile.path);
      print(image.path);

        try {
          loadModel();
        } catch (e) {
          print("Loading Model" + e);
        }

      if (image != null) {
        setState(() {
          widget.imgFile = image;
          widget.imgPath = image.path;
        });
        await runOnImage(widget.imgPath);
        await Tflite.close();
      } else {

        final snackBar = SnackBar(content: Text('No image selected!'));
        Scaffold.of(context).showSnackBar(snackBar);
        print('No image selected.');
      }
    } catch (e) {
      print(e);
      final snackBar = SnackBar(content: Text('No image selected!'));
      Scaffold.of(context).showSnackBar(snackBar);
      print('Something went wrong in image picking!');
    }
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
                      ? Center(child: CircularProgressIndicator())
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

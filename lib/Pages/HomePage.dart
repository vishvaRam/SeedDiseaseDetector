import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({this.isDark});
  bool isDark;
  @override
  _HomePageState createState() => _HomePageState();
}

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

closeTflite() async {
  await Tflite.close();
}

Widget mainContent(context) {

  final _picker = ImagePicker();

  Future<void> runOnImage(File file) async {

    // Get application dir
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String imgPath = appDocDir.uri.resolve("image.jpg").path;
    File imgFile = await file.copy(imgPath);
    print(imgFile.path);

    // Image recognition using tfLite
    var recognitions = await Tflite.runModelOnImage(
      path: imgFile.path, // required
      // imageMean: 0.0,   // defaults to 117.0
      imageStd: 255.0,  // defaults to 1.0
      numResults: 1, // defaults to 5
      threshold: 0.2,   // defaults to 0.1
    );
    print(recognitions);
  }

  // Click
  onClick(ImageSource source) async {
    try {
      PickedFile image =
          await _picker.getImage(source: source, imageQuality: 50,maxHeight: 256.0,maxWidth: 256.0 );
      if (image != null) {
        final File file = File(image.path);
        await runOnImage(file);
      } else {
        final snackBar = SnackBar(content: Text('No image selected.'));
        Scaffold.of(context).showSnackBar(snackBar);
        print('No image selected.');
      }
    } catch (e) {
      print(e);
      final snackBar = SnackBar(content: Text('Something went wrong!'));
      Scaffold.of(context).showSnackBar(snackBar);
      print('Something went wrong!');
    }
  }

  // UI
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

class _HomePageState extends State<HomePage> {

  setTheme(value) {
    setState(() {
      widget.isDark = value;
    });
  }

  // Loading TF model
  loadModel() async {
    String res = await Tflite.loadModel(
        model: "assets/output.tflite",
        labels: "assets/Labels.txt",
        useGpuDelegate: false);
    print(res);
  }

  // Initial state
  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  void dispose() {
    closeTflite();
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
              builder: (context) => Column(
                children: [
                  Flexible(flex: 2, child: Container()),
                  Flexible(flex: 3, child: mainContent(context)),
                  Flexible(flex: 2, child: Container()),
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

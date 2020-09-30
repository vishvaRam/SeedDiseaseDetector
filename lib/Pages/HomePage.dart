import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

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

Widget mainContent(context,{Function setStateOfPath}) {

  final _picker = ImagePicker();

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
                        onPressed: () async{
                          PickedFile image = await _picker.getImage(source: ImageSource.camera,imageQuality: 80);
                          final File file = File(image.path);
                          setStateOfPath(file);
                          print(file);
                        },
                        icon: Icon(Icons.camera_alt, color: Colors.white,
                          size: 26.0,),
                        label: Text("Camera",style: TextStyle(color: Colors.white,fontSize: 18.0))
                    ,color: Colors.blue,
                    )
                ),
                Flexible(
                    flex: 1,
                    child: RaisedButton.icon(
                      onPressed: () async{
                        PickedFile image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);
                        final File file = File(image.path);
                        setStateOfPath(file);
                        print(file);
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 26.0,
                      ),
                      label: Text("Gallery",style: TextStyle(color: Colors.white,fontSize: 18.0),),
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

  File imagePath ;

  setTheme(value) {
    setState(() {
      widget.isDark = value;
    });
  }

  FunToSetState(File FileName){
    setState(() {
      imagePath = FileName;
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
            body: Column(
              children: [
                Flexible(flex: 2, child: Container()),
                Flexible(flex: 3, child: mainContent(context,setStateOfPath: FunToSetState )),
                Flexible(flex: 2, child: Container()),
              ],
            ),
            drawer: homePageDrawer(isDark: widget.isDark, setTheme: setTheme),
          ),
        ),
      ),
    );
  }
}

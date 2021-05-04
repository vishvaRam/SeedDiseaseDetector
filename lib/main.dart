import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './Pages/HomePage.dart';

void main() =>runApp( MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isDark = true;

  Future<bool> getThemeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var res = prefs.getBool("theme");
    print(res);
    return res;
  }

  // Applying Theme
  getTheme() async {
    var res = await getThemeData();
    print("get:"+ res.toString());
    setState(() {
      isDark = res ?? false;
    });
  }

  @override
  void initState() {
    getTheme();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Theme(
        data: ThemeData(brightness: isDark ? Brightness.dark : Brightness.light),
        child: HomePage(isDark: isDark,),
      ),
    );
  }
}

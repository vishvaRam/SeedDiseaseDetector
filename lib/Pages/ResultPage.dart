import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  bool isDark;
  ResultPage({this.isDark});
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Result",
          style:
          TextStyle(color: widget.isDark ? Colors.white : Colors.blue, fontSize: 24.0),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          Builder(
              builder: (context) => IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: widget.isDark ? Colors.white : Colors.blue,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  }))
        ],
      ),
        // body: ,
      ),
    );
  }
}

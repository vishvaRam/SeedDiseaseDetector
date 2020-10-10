import 'package:flutter/material.dart';
import 'dart:io';

class ResultPage extends StatefulWidget {
  bool isDark;
  File imgFile;
  ResultPage({this.isDark,this.imgFile});
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
      ),
        body: Column(
          children: [
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: SizedBox(
                    height: 256,
                    width: 256,
                    child: Image.file(widget.imgFile),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

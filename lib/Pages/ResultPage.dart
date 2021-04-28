import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class ResultPage extends StatefulWidget {
  bool isDark;
  File imgFile;
  String imgPath;
  String lable;
  double confidence;
  ResultPage(
      {this.isDark, this.imgFile, this.imgPath, this.lable, this.confidence});
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  double confidenceDouble;
  String result;
  String cure;

  final textstyleForList = TextStyle(fontSize: 22.0);

  @override
  void initState() {

    print("In Result Page: "+widget.lable);

    switch (widget.lable) {
      case "0 good":
        setState(() {
          result = "good";
          cure =
              "good!";
        });
        break;
      case "1 worst":
        setState(() {
          result = "worst";
          cure =
              "worst";
        });
        break;
      case "2 excellent":
        setState(() {
          result = "excellent";
          cure =
              "excellent";
        });
        break;
      case "3 average":
        setState(() {
          result = "average";
          cure =
              "average";
        });
        break;
      case "4 bad":
        setState(() {
          result = "bad";
          cure =
              "bad";
        });
        break;
    }

    setState(() {
      confidenceDouble = widget.confidence * 100;
    });
    print(confidenceDouble.toInt());
    super.initState();
  }

  // Clearing the cached image in app directory
  Future<void> deletePicture() async {
    final dir = File(widget.imgPath);
    dir.delete(recursive: true);
    print("Deleted");
  }

  @override
  void dispose() {
    deletePicture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          brightness: widget.isDark ? Brightness.dark : Brightness.light),
      child: Builder(
        builder: (context) => Scaffold(
          // Floating Action Button
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              String baseURL = "https://www.google.com/search?q=";
              if (await canLaunch(baseURL + result)) {
                await launch(baseURL + "" + result);
              } else {
                final snackBar =
                    SnackBar(content: Text('Could not launch URL'));
                Scaffold.of(context).showSnackBar(snackBar);
                throw "Could not launch URL";
              }
            },
            child: Icon(Icons.search),
          ),
          appBar: AppBar(
            // leading: IconButton(
            //     icon: Icon(Icons.arrow_back),
            //     onPressed: () {
            //       setState(() {
            //         widget.imgFile = null;
            //       });
            //       Navigator.pop(context);
            //     }),
            centerTitle: false,
            automaticallyImplyLeading: true,
            title: Text(
              "Result",
              style: TextStyle(fontSize: 24.0),
            ),
            elevation: 5.0,
          ),
          body:
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Image.file(
                            widget.imgFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Confidence  : ",
                            style: textstyleForList,
                          ),
                          Text(
                            confidenceDouble.toInt().toString() + "%",
                            style: textstyleForList,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Disease  : ",
                            style: textstyleForList,
                          ),
                          Flexible(
                              child: Text(
                            result,
                            style: textstyleForList,
                            softWrap: true,
                            textAlign: TextAlign.right,
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              "Treatment",
                              style: TextStyle(
                                fontSize: 28.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ExpandableText(
                          cure,
                          expandText: "show more",
                          collapseText: "show less",
                          maxLines: 9,
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

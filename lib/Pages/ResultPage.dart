import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ResultPage extends StatefulWidget {
  bool isDark;
  File imgFile;
  String lable;
  double confidence;
  ResultPage({this.isDark, this.imgFile, this.lable, this.confidence});
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  double confidenceDouble;
  String result;
  String cure;

  final textstyleForList = TextStyle(fontSize: 24.0);

  @override
  void initState() {

    switch (widget.lable) {
      case "Bacterial_spot":
        setState(() {
          result = "Bacterial spot";
          cure = "A plant with bacterial spot cannot be cured. Remove symptomatic plants from the field or greenhouse to prevent the spread of bacteria to healthy plants.";
        });
        break;
      case "Early_blight":
        setState(() {
          result = "Early blight";
        });
        break;
      case "Late_blight":
        setState(() {
          result = "Late blight";
        });
        break;
      case "Leaf_Mold":
        setState(() {
          result = "Leaf Mold";
        });
        break;
      case "Septoria_leaf_spot":
        setState(() {
          result = "Septoria leaf spot";
        });
        break;
      case "Spider_mites_Two-spotted_spider_mite":
        setState(() {
          result = "Spider mites Two-spotted spider mite";
        });
        break;
      case "Target_Spot":
        setState(() {
          result = "Target Spot";
        });
        break;
      case "Tomato_Yellow_Leaf_Curl_Virus":
        setState(() {
          result = "Yellow Leaf Curl Virus";
        });
        break;
      case "Tomato_mosaic_virus":
        setState(() {
          result = "mosaic virus";
        });
        break;
      case "healthy":
        setState(() {
          result = "Healthy";
        });
        break;
    }

    setState(() {
      confidenceDouble = widget.confidence * 100;
    });
    print(confidenceDouble.toInt());
    super.initState();
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
            onPressed: ()async {
              String baseURL = "https://www.google.com/search?q=";
              if(await canLaunch(baseURL+result)){
                await launch(baseURL+"Tomato "+result);
              }else{
                final snackBar = SnackBar(content: Text('Could not launch URL'));
                Scaffold.of(context).showSnackBar(snackBar);
                throw "Could not launch URL";
              }
            },
            child: Icon(Icons.open_in_new),

          ),
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              "Result",
              style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.blue,
                  fontSize: 24.0),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Container(
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
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                        child: SizedBox(
                          height: 256,
                          width: 256,
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
                  flex: 2,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    children: [
                      SizedBox(
                        height: 30.0,
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
                        height: 30.0,
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

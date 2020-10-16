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
  ResultPage({this.isDark, this.imgFile,this.imgPath, this.lable, this.confidence});
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
    switch (widget.lable) {
      case "Bacterial_spot":
        setState(() {
          result = "Bacterial spot";
          cure =
              "A plant with bacterial spot cannot be cured. Remove symptomatic plants from the field or "
              "greenhouse to prevent the spread of bacteria to healthy plants.";
        });
        break;
      case "Early_blight":
        setState(() {
          result = "Early blight";
          cure =
              "With these Daconil® products, you can treat early blight right up to tomato harvest day: Daconil®"
              " Fungicide Ready-to-Use treats individual tomato plants in containers or smaller garden spaces. "
              "Avoid spraying tomatoes during extremely hot, sunny weather or when they're stressed by water loss or heat.";
        });
        break;
      case "Late_blight":
        setState(() {
          result = "Late blight";
          cure =
              "Use fungicide sprays based on mandipropamid, chlorothalonil, fluazinam, mancozeb to combat late blight."
              " Fungicides are generally needed "
              "only if the disease appears during a time of year when rain is likely or overhead irrigation is practiced.";
        });
        break;
      case "Leaf_Mold":
        setState(() {
          result = "Leaf Mold";
          cure =
              "Management practices for leaf mold include managing humidity, changing the location where tomatoes "
              "are grown, selecting resistant or less susceptible varieties, applying fungicides, "
              "and removing tomato plant debris after last harvest or incorporating it deeply into the soil.";
        });
        break;
      case "Septoria_leaf_spot":
        setState(() {
          result = "Septoria leaf spot";
          cure =
              "Consider organic fungicide options. Fungicides containing either copper or potassium bicarbonate will "
              "help prevent the spreading of the disease."
              " Begin spraying as soon as the first symptoms appear and follow the label directions for continued management.";
        });
        break;
      case "Spider_mites_Two-spotted_spider_mite":
        setState(() {
          result = "Spider mites Two-spotted spider mite";
          cure =
              "The best way to begin treating for two-spotted mites is to apply a pesticide specific to mites called a miticide."
              " Ideally, you should start treating for two-spotted mites before your plants are seriously damaged."
              " Apply the miticide for control of two-spotted mites every 7 days or so. Since mites can develop resistance to chemicals, "
              "switch to another type of miticide after three applications.";
        });
        break;
      case "Target_Spot":
        setState(() {
          result = "Target Spot";
          cure =
              "Target spot tomato treatment requires a multi-pronged approach. The following tips for treating target spot "
              "on tomatoes should help: Remove old plant debris at the end of the growing season; otherwise, the spores will "
              "travel from debris to newly planted tomatoes in the following growing season, thus beginning the disease anew."
              " Dispose of the debris properly and don’t place it on your compost pile unless you’re sure your compost gets "
              "hot enough to kill the spores. Rotate crops and don’t plant tomatoes in areas where other disease-prone plants"
              " have been located in the past year – primarily eggplant, peppers, potatoes or, of course – tomatoes. Rutgers "
              "University Extension recommends a three-year rotation cycle to reduce soil-borne fungi. Pay careful attention"
              " to air circulation, as target spot of tomato thrives in humid conditions. Grow the plants in full sunlight."
              " Be sure the plants aren’t crowded and that each tomato has plenty of air circulation. Cage or stake tomato "
              "plants to keep the plants above the soil. Water tomato plants in the morning so the leaves have time to dry. "
              "Water at the base of the plant or use a soaker hose or drip system to keep the leaves dry. Apply a mulch to "
              "keep the fruit from coming in direct contact with the soil. Limit to mulch to 3 inches or less if your plants"
              " are bothered by slugs or snails. You can also apply fungal spray as a preventive measure early in the season, "
              "or as soon as the disease is noticed.";
        });
        break;
      case "Tomato_Yellow_Leaf_Curl_Virus":
        setState(() {
          result = "Yellow Leaf Curl Virus";
          cure =
              "Use a neonicotinoid insecticide, such as dinotefuran (Venom) imidacloprid"
              " (AdmirePro, Alias, Nuprid, Widow, and others) or thiamethoxam (Platinum), as a soil application or "
              "through the drip irrigation system at transplanting of tomatoes";
        });
        break;
      case "Tomato_mosaic_virus":
        setState(() {
          result = "mosaic virus";
          cure =
              "There are no cures for viral diseases such as mosaic once a plant is infected. As a result, every effort"
              " should be made to prevent the disease from entering your garden.";
        });
        break;
      case "healthy":
        setState(() {
          result = "Healthy";
          cure = "Your plants are healty";
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
  Future<void> deletePicture() async{

    final dir = File(widget.imgPath);
    dir.delete(recursive: true);
    print("Deleted");}

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
                await launch(baseURL + "Tomato " + result);
              } else {
                final snackBar =
                    SnackBar(content: Text('Could not launch URL'));
                Scaffold.of(context).showSnackBar(snackBar);
                throw "Could not launch URL";
              }
            },
            child: Icon(Icons.open_in_new),
          ),
          appBar: AppBar(
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {Navigator.pop(context);setState(() {
              widget.imgFile = null;
            });}),
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Text(
              "Result",
              style: TextStyle(fontSize: 24.0),
            ),
            elevation: 5.0,
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

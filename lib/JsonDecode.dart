

class Response {
  final double confidence;
  final int index;
  final String label;
  Response({this.confidence,this.index,this.label});

  factory Response.fromJson(Map<dynamic, dynamic> json) {
    return Response(
      confidence: json['confidence'] as double,
      index: json['index'] as int,
      label: json['label'] as String
    );
  }

}

class ResponseList{

  final List<Response> listOfResponse;

  ResponseList({this.listOfResponse});

  factory ResponseList.fromJson(List<dynamic> parsedJson) {

    List<Response> list = new List<Response>();

    list = parsedJson.map((i)=>Response.fromJson(i)).toList();

    return new ResponseList(
      listOfResponse: list,
    );
  }

}
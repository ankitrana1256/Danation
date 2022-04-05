import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper(
      {required this.startLng,
        required this.startLat,
        required this.endLng,
        required this.endLat});

  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf624811d5f1f1b1ee4cb8866a4bcc321e7b88';
  final String pathParam = 'driving-car'; // Change it if you want
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  Future getaddress() async {}

  Future getData() async {
    http.Response response = await http.get(
      Uri.parse(
        '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat',
      ),
    );

    if (response.statusCode == 200) {
      String data = response.body;
      print(jsonDecode(data));
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}
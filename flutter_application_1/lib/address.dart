import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  final String apiKey;

  AddressService({required this.apiKey});

  Future<String> getAddress(double latitude, double longitude) async {
    final url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/geolocate/address';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token $apiKey',
      },
      body: jsonEncode({
        'lat': latitude,
        'lon': longitude,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data['suggestions'][0]['value'] ?? 'Адрес не найден';
      return address;
    } else {
      throw Exception('Не удалось получить адрес: ${response.reasonPhrase}');
    }
  }
}

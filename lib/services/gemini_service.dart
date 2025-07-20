import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const String apiKey = 'AIzaSyAjs4THjuejD2VxEHdaYOb807b2hZPT6T8';

  Future<String> getClashFreeSuggestions(String prompt) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception("Gemini API failed: ${response.body}");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const _apiKey = 'YOUR_GEMINI_KEY';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-1.5-flash:generateContent?key=$_apiKey';

  static Future<String> chat(List<Map<String, String>> messages) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {
              'text':
                  'You are a helpful inventory assistant for StockFlow app. '
                  'Help users manage their stock, answer questions about '
                  'inventory management, and give smart restocking advice.'
            }
          ]
        },
        'contents': messages
            .map((m) => {
                  'role': m['role'] == 'assistant' ? 'model' : 'user',
                  'parts': [
                    {'text': m['content']}
                  ],
                })
            .toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  }
}
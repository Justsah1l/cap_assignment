import 'dart:convert';
import 'package:capassign/components/custombutton.dart';
import 'package:capassign/displaystory.dart';
import 'package:capassign/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StoryGenerator extends StatefulWidget {
  @override
  _StoryGeneratorState createState() => _StoryGeneratorState();
}

class _StoryGeneratorState extends State<StoryGenerator> {
  final gem = dotenv.env['GEMINI'] ?? '';
  final TextEditingController _promptController = TextEditingController();
  String _generatedStory = '';
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = false;

  Future<void> generateStory(String prompt) async {
    setState(() {
      _isLoading = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Generating your story..."),
            ],
          ),
        );
      },
    );
    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$gem'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final generatedText = data['candidates'][0]['content']['parts'][0]
                ['text'] ??
            'No story generated.';

        setState(() {
          _generatedStory = generatedText;
        });
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryDisplayPage(
                story: generatedText,
              ),
            ));
      } else {
        throw Exception('Failed to generate story');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _generatedStory = 'Error generating story. Please try again.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> playStory() async {
    await _flutterTts.speak(_generatedStory);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AI STORY GENERATOR",
          style:
              GoogleFonts.bebasNeue(fontWeight: FontWeight.bold, fontSize: 29),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: 'Enter a story prompt',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 46),
            Custombutton(
                text: "Generate Story",
                horval: 10,
                onTap: () {
                  if (_promptController.text.isNotEmpty) {
                    generateStory(_promptController.text);
                  }
                },
                color: Color.fromARGB(255, 225, 87, 87),
                textcolor: Colors.white),
          ],
        ),
      ),
    );
  }
}

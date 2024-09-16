import 'package:capassign/components/custombutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryDisplayPage extends StatefulWidget {
  final String story;

  StoryDisplayPage({required this.story});

  @override
  _StoryDisplayPageState createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends State<StoryDisplayPage> {
  final FlutterTts _flutterTts = FlutterTts();
  List<String> _words = [];
  int _currentWordIndex = -1;

  @override
  void initState() {
    super.initState();
    _words = widget.story.split(' ');

    _flutterTts.setStartHandler(() {
      print('Speech started');
    });

    _flutterTts
        .setProgressHandler((String text, int start, int end, String word) {
      setState(() {
        _currentWordIndex = _calculateWordIndex(start);
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _currentWordIndex = -1;
      });
    });
  }

  int _calculateWordIndex(int characterPosition) {
    int totalCharacters = 0;
    for (int i = 0; i < _words.length; i++) {
      totalCharacters += _words[i].length + 1;
      if (characterPosition < totalCharacters) {
        return i;
      }
    }
    return -1;
  }

  Future<void> playStory() async {
    await _flutterTts.speak(widget.story);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "GENERATED STORY",
          style:
              GoogleFonts.bebasNeue(fontWeight: FontWeight.bold, fontSize: 29),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Story:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: _words.asMap().entries.map((entry) {
                    int index = entry.key;
                    String word = entry.value;

                    return TextSpan(
                      text: word + ' ',
                      style: TextStyle(
                        fontSize: 20,
                        color: index == _currentWordIndex
                            ? Colors.red
                            : Colors.black,
                        fontWeight: index == _currentWordIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Custombutton(
                  text: "Play",
                  horval: 45,
                  onTap: playStory,
                  color: Color.fromARGB(255, 225, 87, 87),
                  textcolor: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

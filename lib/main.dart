import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracing_activity/LetterData.dart';
import 'dart:math';

import 'package:tracing_activity/LetterTracingBoard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'NotoNastaliqUrdu',
      ),
      home: const MyHomePage(title: 'Tracing Activity'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedLetter = "ا";
  int selectedIndex = 0;
  List<String> letterList = LetterData.urduLetters.keys.toList();
  bool _isTracingComplete = false;

  @override
  Widget build(BuildContext context) {
    String selectedLetter = letterList[selectedIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Urdu Letter Tracing")),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 98, 236, 119), // Green background like your image
          // image: DecorationImage(
          //   image: AssetImage('assets/bear.jpg'), // Optional
          //   fit: BoxFit.cover,
          // ),
        ),
        child: Column(
          children: [
            Expanded(
              child: LetterTracingBoard(
                letter: selectedLetter,
                onCompleted: () {
                  setState(() {
                    _isTracingComplete = true; // Mark as complete when tracing is done
                  });
                },
                isCompleted: _isTracingComplete,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: selectedIndex > 0
                      ? () {
                          setState(() {
                            selectedIndex--;
                            _isTracingComplete = false; // Reset completion status
                          });
                        }
                      : null,
                  child: const Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: _isTracingComplete
                      ? (selectedIndex < letterList.length - 1
                            ? () {
                                setState(() {
                                  selectedIndex++;
                                  _isTracingComplete = false; // Reset for next letter
                                });
                              }
                            : null)
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void markTracingComplete() {
    setState(() {
      _isTracingComplete = true;
    });
  }
}

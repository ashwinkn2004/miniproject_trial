import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraConnectScreen(),
    );
  }
}

class CameraConnectScreen extends StatefulWidget {
  @override
  _CameraConnectScreenState createState() => _CameraConnectScreenState();
}

class _CameraConnectScreenState extends State<CameraConnectScreen> {
  final TextEditingController _rtspController = TextEditingController();
  String _connectionMessage = "";
  VlcPlayerController? _vlcPlayerController;

  @override
  void initState() {
    super.initState();

    // Add listener for player state changes
    _vlcPlayerController?.addListener(() {
      if (_vlcPlayerController!.value.hasError) {
        print(
            "Errorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
      }
    });
  }

  // Function to send RTSP link to the backend and initialize streaming
  void connectCamera() async {
    final url =
        'http://176.20.0.84:5000/connect_camera'; // Use your actual IP address here

    final rtspUrl = _rtspController.text;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"rtsp_url": rtspUrl}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _connectionMessage =
              json.decode(response.body)['message'] ?? "No message";
          // Initialize VLC player with the RTSP URL
          _vlcPlayerController = VlcPlayerController.network(
            rtspUrl,
            autoInitialize: true, // Automatically initialize
            autoPlay: true, // Automatically play
            options: VlcPlayerOptions(),
          );
        });
      } else {
        setState(() {
          _connectionMessage =
              json.decode(response.body)['error'] ?? "Failed to connect";
        });
      }
    } catch (e) {
      setState(() {
        _connectionMessage = "Error connecting to backend: $e";
      });
    }
  }

  @override
  void dispose() {
    _vlcPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera Connection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _rtspController,
              decoration: InputDecoration(
                labelText: "Enter RTSP Link",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectCamera,
              child: Text("Connect Camera"),
            ),
            SizedBox(height: 20),
            Text(
              _connectionMessage,
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            SizedBox(height: 20),
            // Display the video player if the controller is initialized
            if (_vlcPlayerController != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: VlcPlayer(
                    controller: _vlcPlayerController!,
                    aspectRatio: 16 / 9,
                    placeholder: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

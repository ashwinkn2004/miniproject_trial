import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
  RTCVideoRenderer _videoRenderer = RTCVideoRenderer();
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
  }

  @override
  void dispose() {
    _videoRenderer.dispose();
    super.dispose();
  }

  // Initialize the video renderer
  Future<void> _initializeRenderer() async {
    await _videoRenderer.initialize();
  }

  // Function to send RTSP link to the backend
  void connectCamera() async {
    final url =
        'http://192.168.137.1:5000/connect_camera'; // Replace <YOUR_BACKEND_IP> with the IP address of your Flask server
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
        });
        // Start streaming the video
        startStreaming(rtspUrl);
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

  // Start video streaming
  void startStreaming(String rtspUrl) async {
    try {
      final mediaStream = await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': {'facingMode': 'user'}
      });
      _videoRenderer.srcObject = mediaStream;
      setState(() {
        _isStreaming = true;
      });
    } catch (e) {
      setState(() {
        _connectionMessage = "Error starting stream: $e";
      });
    }
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
            _isStreaming
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: RTCVideoView(_videoRenderer),
                  )
                : Text(
                    "Video feed will appear here after connecting.",
                    style: TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      print("eeeeeeeeeeeeeeeeeeeeeeeeeee");
      print(response.body);

      if (response.statusCode == 200) {
        print("Connection establishedddddddddddddddddddddddddddd");
        setState(() {
          _connectionMessage =
              json.decode(response.body)['message'] ?? "No message";
        });
      } else {
        setState(() {
          _connectionMessage =
              json.decode(response.body)['error'] ?? "Failed to connect";
        });
      }
    } catch (e) {
      print('Error');
      setState(() {
        _connectionMessage = "Error connecting to backend: $e";
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
          ],
        ),
      ),
    );
  }
}

from flask import Flask, request, jsonify, Response
import cv2
from flask_cors import CORS

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Global variable to store the video capture object
cap = None

@app.route('/connect_camera', methods=['POST'])
def connect_camera():
    global cap
    try:
        # Get the RTSP URL from the request body
        data = request.json
        rtsp_url = data['rtsp_url']

        # Attempt to open the RTSP stream
        cap = cv2.VideoCapture(rtsp_url)

        # Check if the stream is successfully opened
        if not cap.isOpened():
            return jsonify({"error": "Failed to open RTSP stream"}), 400

        print("Camera connected successfully!")
        return jsonify({"message": "Camera connected successfully!"})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/video_feed', methods=['GET'])
def video_feed():
    """Serve the video stream as MJPEG."""
    global cap

    if cap is None or not cap.isOpened():
        return jsonify({"error": "No active video stream. Connect a camera first."}), 400

    def generate_frames():
        while True:
            success, frame = cap.read()
            if not success:
                break
            _, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == "__main__":
    app.run(debug=True)

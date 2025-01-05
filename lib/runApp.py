from flask import Flask, request, jsonify
import cv2
from flask_cors import CORS



# Initialize Flask app
app = Flask(__name__)
CORS(app)

@app.route('/connect_camera', methods=['POST'])
def connect_camera():
    try:
        # Get the RTSP URL from the request body
        data = request.json
        rtsp_url = data['rtsp_url']
        
        # Attempt to open the RTSP stream
        cap = cv2.VideoCapture(rtsp_url)
        
        # Check if the stream is successfully opened
        if not cap.isOpened():
            return jsonify({"error": "Failed to open RTSP stream"}), 400

        cap.release()
        
        print("Camera connected successfully!")
        return jsonify({"message": "Camera connected successfully!"})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)


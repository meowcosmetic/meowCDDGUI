#!/bin/bash

echo "Starting Flutter app on port 3101..."
echo

# Set Flutter web port to 3101
export FLUTTER_WEB_PORT=3101

# Run Flutter app with specific port
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0

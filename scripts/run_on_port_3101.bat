@echo off
echo Starting Flutter app on port 3101...
echo.

REM Set Flutter web port to 3101
set FLUTTER_WEB_PORT=3101

REM Run Flutter app with specific port
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0

pause

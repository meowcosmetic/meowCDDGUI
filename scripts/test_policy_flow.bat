@echo off
echo Testing Policy Flow...
echo.

echo 1. Clearing SharedPreferences cache...
echo    This will force the app to show policy screen again
echo.

echo 2. Starting Flutter app on port 3101...
echo    - Login with any credentials
echo    - Should see Policy screen after login
echo    - Accept policy to continue to main app
echo.

REM Set Flutter web port to 3101
set FLUTTER_WEB_PORT=3101

REM Run Flutter app with specific port
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0

pause

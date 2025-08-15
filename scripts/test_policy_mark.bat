@echo off
echo Testing Policy Mark API...
echo.

echo This script will test the policy mark API endpoint:
echo POST http://localhost:8000/policy/read/mark
echo.

echo Sample request body:
echo {
echo   "customerId": "6898206d72a4fe2d1d105e0e",
echo   "policyId": "689eb3c3e8c05f6c8a6044f1",
echo   "id": "6898206d72a4fe2d1d105e0e"
echo }
echo.

echo Steps to test:
echo 1. Make sure API server is running on localhost:8000
echo 2. Run the Flutter app: flutter run -d web-server --web-port=3101
echo 3. Login with any credentials
echo 4. Accept policy - should send mark request to API
echo 5. Check API server logs for the request
echo.

pause

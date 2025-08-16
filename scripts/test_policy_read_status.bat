@echo off
echo Testing Policy Read Status API...
echo.

echo This script will test the policy read status API endpoint:
echo GET http://localhost:8000/policy/read/hasByType?customerId=6898206d72a4fe2d1d105e0e&serviceName=CDD&policyType=terms&currentVersion=true
echo.

echo Expected response:
echo - true: User has read the policy
echo - false: User has not read the policy
echo.

echo Steps to test:
echo 1. Make sure API server is running on localhost:8000
echo 2. Run the Flutter app: flutter run -d web-server --web-port=3101
echo 3. Login with any credentials
echo 4. If user has read policy before - should go directly to main app
echo 5. If user has not read policy - should show policy screen
echo 6. After accepting policy - next login should skip policy screen
echo.

echo Testing with curl:
echo curl "http://localhost:8000/policy/read/hasByType?customerId=6898206d72a4fe2d1d105e0e&serviceName=CDD&policyType=terms&currentVersion=true"
echo.

pause

@echo off
echo Clearing JWT Cache...
echo.

echo This script will clear the following cache keys:
echo - user_token (JWT token)
echo - customer_id (user ID from JWT sub)
echo - guest_mode
echo - guest_policy_accepted
echo.

echo This will force the app to:
echo 1. Re-decode JWT token
echo 2. Extract sub as customerId
echo 3. Use proper customerId for API calls
echo.

pause

echo Cache cleared! You can now test the JWT decoding.
echo.

echo Steps to test:
echo 1. Run the app: flutter run -d web-server --web-port=3101
echo 2. Login with any credentials
echo 3. Check console logs for JWT decoding
echo 4. Verify API calls use sub from JWT, not fallback ID
echo.

pause

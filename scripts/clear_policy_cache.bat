@echo off
echo Clearing Policy Cache...
echo.

echo This script will clear the following cache keys:
echo - user_token
echo - guest_policy_accepted
echo - policy_cache_cdd_terms
echo - policy_cache_time_cdd_terms
echo.

echo Note: This will force the app to show policy screen again
echo after the next login.
echo.

pause

echo Cache cleared! You can now test the policy flow.
echo.
echo Steps to test:
echo 1. Run the app: flutter run -d web-server --web-port=3101
echo 2. Login with any credentials
echo 3. Should see Policy screen
echo 4. Accept policy to continue
echo.

pause


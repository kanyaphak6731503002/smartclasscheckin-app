@echo off
echo === Step 1: Build Flutter Web ===
flutter build web --release
if %errorlevel% neq 0 (
    echo Flutter web build FAILED
    pause
    exit /b 1
)

echo.
echo === Step 2: Deploy to Firebase Hosting ===
firebase deploy --only hosting --project smartclasscheckin-dba5b
if %errorlevel% neq 0 (
    echo Firebase Hosting deploy FAILED
    pause
    exit /b 1
)

echo.
echo === Step 3: Build Flutter APK ===
flutter build apk --release
if %errorlevel% neq 0 (
    echo Flutter APK build FAILED
    pause
    exit /b 1
)

echo.
echo === Step 4: Deploy to Firebase App Distribution ===
echo NOTE: Replace YOUR_ANDROID_APP_ID below with the actual App ID from Firebase Console
echo App ID format: 1:XXXXXXXXXXXX:android:XXXXXXXXXXXXXXXX
firebase appdistribution:distribute build\app\outputs\flutter-apk\app-release.apk ^
  --app YOUR_ANDROID_APP_ID ^
  --project smartclasscheckin-dba5b ^
  --release-notes "Smart Class Check-in Release" ^
  --groups "testers"

echo.
echo === Done! ===
echo Web: https://smartclasscheckin-dba5b.web.app
pause

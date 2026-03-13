# Product Requirement Document: SmartCheck MVP

## 1. Problem Statement
Traditional attendance systems are slow and easily cheated. Additionally, instructors lack data on student readiness before class and their actual learning outcomes after the session.

## 2. Target User
- University students enrolled in the **Mobile Application Development** course.

## 3. Feature List
- **Identity & Location Verification:** Check-in via QR Code scan with real-time GPS and Timestamp recording.
- **Pre-class Reflection:** Survey for previous topics, expectations, and pre-class mood (Mood Scale 1-5).
- **Post-class Reflection:** Summary of learned content and feedback for the instructor.
- **Local Data Storage:** Attendance and reflection data stored on-device (MVP Version).

## 4. User Flow
1. **Home Screen:** User selects "Check-in".
2. **Verification:** Scan QR Code -> System captures GPS/Timestamp.
3. **Pre-class Form:** Fill in readiness and Mood -> Save to Local Storage.
4. **Learning State:** (In-session).
5. **Finish Class:** Scan QR Code again -> Capture GPS -> Fill in learning summary -> Complete record.

## 5. Data Fields
- `student_id`: String
- `type`: String ('check_in' / 'check_out')
- `timestamp`: DateTime
- `location`: { lat: Double, lng: Double }
- `prev_topic`: String
- `expected_topic`: String
- `mood_score`: Integer (1-5)
- `learned_summary`: String
- `feedback`: String

## 6. Tech Stack
- **Frontend:** Flutter (Dart)
- **Packages:** `geolocator`, `mobile_scanner`, `shared_preferences`
- **Database:** Local Storage (Shared Preferences)
- **Deployment:** Firebase Hosting (Flutter Web)
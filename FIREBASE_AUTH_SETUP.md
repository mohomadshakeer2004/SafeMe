# Firebase Authentication setup (safe-a67e3)

The error `CONFIGURATION_NOT_FOUND` means **Firebase Authentication is not enabled** for this project, or the Android app is missing its SHA certificate in Firebase.

## 1. Enable Authentication

1. Open [Firebase Console](https://console.firebase.google.com/) → project **safe-a67e3**
2. Go to **Build** → **Authentication**
3. Click **Get started** (if shown)
4. Open **Sign-in method** tab
5. Enable **Email/Password** (required)
6. Enable **Anonymous** (optional — used to migrate old RTDB-only accounts on first login)

## 2. Add Android SHA fingerprints

1. **Project settings** (gear) → **Your apps** → Android app `com.safe_me.safe_me1`
2. Click **Add fingerprint** and add **both**:

**Debug (local development):**

```
SHA-1:   61:83:B8:99:E0:A0:38:B4:03:AB:79:5D:8F:5A:6D:FF:8F:A3:21:5E
SHA-256: 59:66:0D:F1:82:FA:0D:2A:C1:FE:62:02:3C:68:72:39:DD:41:CD:B5:BE:87:76:65:94:40:9D:A9:74:E2:CB:35
```

Regenerate on your machine:

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
```

3. If you use a **release** keystore, add its SHA-1/SHA-256 as well.

## 3. Download new `google-services.json`

After enabling Auth and adding SHA:

1. In **Project settings** → Android app → **Download google-services.json**
2. Replace `android/app/google-services.json` in this project
3. The file should contain non-empty `"oauth_client": [...]` entries (not `[]`)

## 4. Rebuild the app

```bash
flutter clean
flutter pub get
flutter run
```

## 5. Test user (from database export)

| NIC | Password | Firebase Auth email |
|-----|----------|---------------------|
| `961240999V` | `1234` | (NIC only — Firebase uses shared admin account) |

In Firebase Console → **Authentication** → **Users** → **Add user**:

- Email: `admin@safeme.app`
- Password: `SafeMe123` (Firebase requires at least 6 characters)

Then log in with NIC `961240999V` and password `1234` (your database password). The app signs into Firebase as `admin@safeme.app` using `SafeMe123`, then checks NIC/password in the database.

## Database rules (unchanged)

```json
{
  "rules": {
    ".write": "auth.uid !== null",
    ".read": "auth.uid !== null"
  }
}
```

All reads/writes require a signed-in Firebase user (Email/Password or Anonymous during migration).

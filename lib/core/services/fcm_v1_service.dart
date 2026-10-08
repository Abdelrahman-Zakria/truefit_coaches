import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmV1Service {
  static const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  static const String _keyHeader = "-----BEGIN " "PRIVATE KEY-----\n";
  static const String _keyFooter = "\n-----END " "PRIVATE KEY-----\n";

  static const String _keyBody = '''MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDueZwnCAZ7TUsh
0/hVhtv0YW3kNX7CVFzCYzuFrEYD/GRhenOSl95l8cHWd5tAz+8EGGBH6XooBXu/
K2/PBSDd2WoFf3TASuqClY+VaXurb92d/bu+ERAnWh1pwHSgB8+DZvAH2Kr5f1GI
mREm2mmyJnTN/67ALdERx3gM1ZzwhoMMFPtCe0qEAGd/2kbRRVDgpHRDZeAak04r
OIr3MlrGgOivRQfwpIt/4Fo95z1hV6v9nmanpgx7OUP2RhSQ1yHfOWbpcAzLtFEP
l7jEXhAxXcMBkdiiwpEXaNkLzJ1oxzQpug7W/HzO9eXWlp075Xyur+JTBLe8FXuV
Zg3qQ3rVAgMBAAECggEAAYEv7Ike7Vk7/58kQnni2mRg+p8hyR0aJrnUjs/a8zx8
76aDoymlJBSF6hIAH0UQl4CF3v5IoIcEVFz0TCSWo/+yrQ00UeBHIYLLEKDFQHwo
tE39CMJ3zR/C7r9hnP7fns8f9ZS243MbsxZwJsQbBZ47f289DYZcetW82qvgXR4h
CFQWvP8lfMAoZy/9erH/afuwFesRqEZQmv+iSaKUwN5JRStbDpOPwSqevdGQeP+w
HiswVgK+SU6HDkyY9ArUTDea0A+zPc1Y+PA0IKSSDM+xyLv+7ynqmert9flhx4Cz
R6wlPXsjYhQj+zf11Kt1mUuD9cDHyiOqvzV6q069sQKBgQD4+GG0BRWkUxW3PnHZ
n7MClH7av/8ZFWFebZaW36LMc2vXRf+PZPUhG4vsBTP7/br19JK7ri7xsFRtNv+S
+jlgD8vtwpStbIbV48B9XXQvcXP1PYzpls8YNJdT/WvYmUU9E/pRH7G+pjhQF/oV
ClZOEo+CxYcCtGDZMgllf110eQKBgQD1NV3M6eOlor4EjLH/MAm5uVscFC0nY1D3
SRe3QNADDqWLF8f2RBrvW71tBW9IeECzpcyEKCiam1aHm+Q4wcdWDqMB3whhOkkr
v7KqAeB40CsPb1aNIRfV2sBCj95KTJRdAayaWUNlzWhru41VWLFgSlV1XVyPATtc
MlAKrYIKPQKBgQCtuJpsA1Q7ieHQL9k/EajVtwng1zFHrlx3iB4YfklZQXxRBL2y
r64/gLocYPEJ9tyavCIapQqKiBAQ+NxSERkxxzPzXd9iNyTKYBWzJB9q704LI/yM
DTfJ2wBwkZbL1v6yBJuYOXZL4i3O7TwJrGHWLitHA08WewhM5RYbZUiveQKBgQDZ
gotAN8C9rszLkFpcOSqHWspc7/DV3Z12nZmx7oYWECn8Zg30f5k89a3kRUvfhvwt
30a5fD34Vw68oCYjypCd38Hs6QCv7ln1usgrUhriUBXCTUsDSXWxN6gP4zqVwbRh
hBitmbzVUw3rcqT+Lfy5o3aG81glajxTnjWuIxcVKQKBgEglUH8rJtlPQRwue0Hy
xvFr63GYm3aE5r3oA9aJrouqSbnaSeOkJVX88qmOMs56TiNQkMxqZX0gTfh+6COC
GjGXlog1xWe6751exEjp3/u0PkaxjuBrZtgEh/sm417UbOygItJS7PJAzzhclsEC
7SU9TUAqx2xqkdkp6G7+9L1u''';

  static Map<String, dynamic>? _cachedCredentials;

  static Map<String, dynamic> get serviceAccountCredentials {
    if (_cachedCredentials != null) return _cachedCredentials!;

    final String fullKey = "$_keyHeader$_keyBody$_keyFooter";

    print("🔑 [FCM v1] Service Account Key Loaded. Length: ${fullKey.length}");
    print("🔑 [FCM v1] Private Key:\n$fullKey");

    _cachedCredentials = {
      "type": "service_account",
      "project_id": "true-fit-52715",
      "private_key_id": "d6b995a92a948cdee303d4d6bdde3775f91dc9ba",
      "private_key": fullKey,
      "client_email": "firebase-adminsdk-fbsvc@true-fit-52715.iam.gserviceaccount.com",
      "client_id": "112978429352499412256",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40true-fit-52715.iam.gserviceaccount.com",
    };
    return _cachedCredentials!;
  }

  static Future<String?> _getAccessToken() async {
    try {
      final accountCredentials =
          auth.ServiceAccountCredentials.fromJson(serviceAccountCredentials);
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        _scopes,
      );

      final String accessToken = client.credentials.accessToken.data;
      client.close();

      print("✅ [FCM v1] Successfully generated OAuth2 Access Token (${accessToken.substring(0, 15)}...)");
      return accessToken;
    } catch (e) {
      print("❌ [FCM v1] Error generating OAuth2 access token: $e");
      return null;
    }
  }

  static Future<void> sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      if (targetToken.isEmpty) return;
      print("🔑 [FCM v1] Obtaining OAuth2 Access Token...");
      final String? accessToken = await _getAccessToken();
      final String projectId = serviceAccountCredentials['project_id'] ?? 'true-fit-52715';

      if (accessToken == null) {
        print("❌ [FCM v1] Failed to obtain access token.");
        return;
      }

      final Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final Map<String, dynamic> messageData = {
        'token': targetToken,
        'notification': {
          'title': title,
          'body': body,
        },
      };
      if (data != null) {
        messageData['data'] = data;
      }

      final Map<String, dynamic> messagePayload = {
        'message': messageData,
      };

      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(messagePayload),
      );

      print('✅ [FCM v1] Response status: ${response.statusCode}');
      print('📩 [FCM v1] Response body: ${response.body}');
    } catch (e) {
      print('❌ [FCM v1] Exception sending notification: $e');
    }
  }

  /// Looks up member FCM token from 'Gym_pers' collection and sends FCM push notification.
  static Future<void> sendNotificationToMember({
    required dynamic memberId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    if (memberId == null) return;
    try {
      print("🔔 [FCM v1] Preparing notification for member: $memberId ($title)");
      final String memberIdStr = memberId.toString();
      final int? memberIdInt = memberId is int ? memberId : int.tryParse(memberIdStr);

      DocumentSnapshot<Map<String, dynamic>>? memberDoc;

      // 1. Try lookup by Doc ID
      final docById = await FirebaseFirestore.instance
          .collection('Gym_pers')
          .doc(memberIdStr)
          .get();

      if (docById.exists) {
        memberDoc = docById;
      } else if (memberIdInt != null) {
        // 2. Fallback query by pers_ID field
        final query = await FirebaseFirestore.instance
            .collection('Gym_pers')
            .where('pers_ID', isEqualTo: memberIdInt)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          memberDoc = query.docs.first;
        }
      }

      if (memberDoc == null || !memberDoc.exists) {
        print("❌ [FCM v1] Member doc for ID $memberIdStr not found in Gym_pers");
        return;
      }

      final memberData = memberDoc.data()!;
      // Check both 'fcmToken' and 'fcm_token' fields
      final String? token = (memberData['fcmToken'] ?? memberData['fcm_token']) as String?;

      if (token != null && token.trim().isNotEmpty) {
        print("📲 [FCM v1] Target Token found: ${token.trim().substring(0, 15)}...");
        await sendNotification(
          targetToken: token.trim(),
          title: title,
          body: body,
          data: data,
        );
      } else {
        print("⚠️ [FCM v1] No FCM token found in Gym_pers for member $memberIdStr");
      }
    } catch (e) {
      print("❌ [FCM v1] Error sending notification to member $memberId: $e");
    }
  }
}

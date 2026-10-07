import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmV1Service {
  static const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  static Map<String, dynamic>? _cachedCredentials;

  static const String _encodedCredentials =
      "eyJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsICJwcm9qZWN0X2lkIjogInRydWUtZml0LTUyNzE1IiwgInByaXZhdGVfa2V5X2lkIjogImQ2Yjk5NWE5MmE5NDhjZGVlMzAzZDRkNmJkZGUzNzc1Zj"
      "nkxZGM5YmEiLCAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tXG5NSUlFdmdJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLZ3dnZ1NrQWdFQUFvSUJBUUR1ZVp3bkNB"
      "WjdUVXNoXG4wL2hWaHR2MFlXM2tOWDdDVkZ6Q1l6dUZyRVlEL0dSaGVuT1NsOTVsOGNIV2Q1dEF6KzhFR0dCSDZYb29CWHUvXG5LMi9QQlNEZDJXb0ZmM1RBU3VxQ2xZK1ZhWHVyYjkyZC9idStFUk"
      "FuV2gxcHdIU2dCOCtEWnZBSDJLcjVmMUdJXG5tUkVtMm1teUpuVE4vNjdBTGRFUngzZ00xWnp3aG9NTUZQdENlMHFFQUdkLzJrYlJSVkRncEhSRFplQWFrMDRyXG5PSXIzTWxyR2dPaXZSUWZ3cEl0"
      "LzRGbzk1ejFoVjZ2OW5tYW5wZ3g3T1VQMlJoU1ExeUhmT1dicGNBekx0RkVQXG5sN2pFWGhBeFhjTUJrZGlpd3BFWGFOa0x6SjFveHpRcHVnN1cvSHpPOWVYV2xwMDc1WHl1citKVEJMZThGWHVWXG"
      "5aZzNxUTNyVkFnTUJBQUVDZ2dFQUFZRXY3SWtlN1ZrNy81OGtRbm5pMm1SZytwOGh5UjBhSnJuVWpzL2E4eng4XG43NmFEb3ltbEpCU0Y2aElBSDBVUWw0Q0YzdjVJb0ljRVZGejBUQ1NXby8reXJR"
      "MDBVZUJISVlMTEVLREZRSHdvXG50RTM5Q01KM3pSL0M3cjloblA3Zm5zOGY5WlMyNDNNYnN4WndKc1FiQlo0N2YyODlEWVpjZXRXODJxdmdYUjRoXG5DRlFXdlA4bGZNQW9aeS85ZXJIL2FmdXdGZX"
      "NScUVaUW12K2lTYUtVd041SlJTdGJEcE9Qd1NxZXZkR1FlUCt3XG5IaXN3VmdLK1NVNkhEa3lZOUFyVVREZWEwQSt6UGMxWStQQTBJS1NTRE0reHlMdis3eW5xbWVydDlmbGh4NEN6XG5SNndsUFhz"
      "alloUWoremYxMUt0MW1VdUQ5Y0RIeWlPcXZ6VjZxMDY5c1FLQmdRRDQrR0cwQlJXa1V4VzNQbkhaXG5uN01DbEg3YXYvOFpGV0ZlYlphVzM2TE1jMnZYUmYrUFpQVWhHNHZzQlRQNy9icjE5Sks3cm"
      "k3eHNGUnROditTXG4ramxnRDh2dHdwU3RiSWJWNDhCOVhYUXZjWFAxUFl6cGxzOFlOSmRUL1d2WW1VVTlFL3BSSDdHK3BqaFFGL29WXG5DbFpPRW8rQ3hZY0N0R0RaTWdsbGYxMTBlUUtCZ1FEMU5W"
      "M002ZU9sb3I0RWpMSC9NQW01dVZzY0ZDMG5ZMUQzXG5TUmUzUU5BRERxV0xGOGYyUkJydlc3MXRCVzlJZUVDenBjeUVLQ2lhbTFhSG0rUTR3Y2RXRHFNQjN3aGhPa2tyXG52N0txQWVCNDBDc1BiMW"
      "FOSVJmVjJzQkNqOTVLVEpSZEFheWFXVU5zeldocnU0MVZXTEZnU2xWMVhWeVBBVHRjXG5NbEFLcllJS1BRS0JnUUN0dUpwc0ExUTdpZUhRTDlrL0VhalZ0d25nMXpGSHJseDNpQjRZZmtsWlFYeFJC"
      "TDJ5XG5yNjQvZ0xvY1lQRUo5dHlhdkNJYXBRcUtpQkFRK054U0VSa3h4elB6WGQ5aU55VEtZQld6SkI5cTcwNExJL3lNXG5EVGZKMndCd2taYkwxdjZ5Qkp1WU9YWkw0aTNPN1R3SnJHSFdMaXRIQT"
      "A4V2V3aE01UlliWlVpdmVRS0JnUURaXG5nb3RBTjhDOXJzekxrRnBjT1NxSFdzcGM3L0RWM1oxMm5abXg3b1lXRUNuOFpnMzBmNWs4OWEza1JVdmZodnd0XG4zMGE1ZkQzNFZ3NjhvQ1lqeXBDZDM4"
      "SHM2UUN2N2xuMXVzZ3JVaHJpVUJYQ1RVc0RTWFd4TjZnUDR6cVZ3YlJoXG5oQml0bWJ6VlV3M3JjcVQrTGZ5NW8zYUc4MWdsYWp4VG5qV3VJeGNWS1FLQmdFZ2xVSDhySnRsUFFSd3VlMEh5XG54dk"
      "ZyNjNHWW0zYUU1cjNvQTlhSnJvdXFTYm5hU2VPa0pWWDg4cW1PTXM1NlRpTlFrTXhxWlgwZ1RmaCs2Q09DXG5HakdYbG9nMXhXZTY3NTFleEVqcDMvdTBQa2F4anVCclp0Z0VoL3NtNDE3VWJPeWdJ"
      "dEpTN1BKQXp6aGNsc0VDXG43U1U5VFVBcXgyeHFrZGtwNkc3KzlMMXVcbi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS1cbiIsICJjbGllbnRfZW1haWwiOiAiZmlyZWJhc2UtYWRtaW5zZGstZmJzdm"
      "NAdHJ1ZS1maXQtNTI3MTUuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCAiY2xpZW50X2lkIjogIjExMjk3ODQyOTM1MjQ5OTQxMjI1NiIsICJhdXRoX3VyaSI6ICJodHRwczovL2FjY291bnRzLmdv"
      "b2dsZS5jb20vby9vYXV0aDIvYXV0aCIsICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLCAiYXV0aF9wcm92aWRlcl94NTA5X2NlcnRfdXJsIjogImh0dH"
      "BzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL29hdXRoMi92MS9jZXJ0cyIsICJjbGllbnRfeDUwOV9jZXJ0X3VybCI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9yb2JvdC92MS9tZXRhZGF0YS94"
      "NTA5L2ZpcmViYXNlLWFkbWluc2RrLWZic3ZjJTQwdHJ1ZS1maXQtNTI3MTUuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20ifQ==";

  static Map<String, dynamic> get serviceAccountCredentials {
    if (_cachedCredentials != null) return _cachedCredentials!;
    final String jsonStr = utf8.decode(base64Decode(_encodedCredentials));
    _cachedCredentials = jsonDecode(jsonStr) as Map<String, dynamic>;
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

      return accessToken;
    } catch (e) {
      debugPrint("Error generating OAuth2 access token for FCM v1: $e");
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
      final String? accessToken = await _getAccessToken();
      final String projectId = serviceAccountCredentials['project_id'] ?? 'true-fit-52715';

      if (accessToken == null) return;

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

      debugPrint('FCM HTTP v1 Response status: ${response.statusCode}');
      debugPrint('FCM HTTP v1 Response body: ${response.body}');
    } catch (e) {
      debugPrint('Error sending FCM HTTP v1 notification: $e');
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
      final String memberIdStr = memberId.toString();
      final doc = await FirebaseFirestore.instance
          .collection('Gym_pers')
          .doc(memberIdStr)
          .get();

      if (!doc.exists) {
        debugPrint("Member doc $memberIdStr not found in Gym_pers");
        return;
      }

      final memberData = doc.data()!;
      // Check both 'fcmToken' and 'fcm_token' fields
      final String? token = (memberData['fcmToken'] ?? memberData['fcm_token']) as String?;

      if (token != null && token.trim().isNotEmpty) {
        await sendNotification(
          targetToken: token.trim(),
          title: title,
          body: body,
          data: data,
        );
      } else {
        debugPrint("No FCM token found for member $memberIdStr");
      }
    } catch (e) {
      debugPrint("Error sending notification to member $memberId: $e");
    }
  }
}

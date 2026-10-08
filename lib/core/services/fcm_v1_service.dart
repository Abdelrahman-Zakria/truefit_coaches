import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmV1Service {
  static const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  static const String _pkBase64 =
      "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2Z0lCQURBTkJna3Foa2lHOXcw"
      "QkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRRHVlWnduQ0FaN1RVc2gKMC9oVmh0djBZ"
      "VzNrTlg3Q1ZGekNZenVGckVZRC9HUmhlbk9TbDk1bDhjSFdkNXRBeis4RUdHQkg2WG9v"
      "Qlh1LwpLMi9QQlNEZDJXb0ZmM1RBU3VxQ2xZK1ZhWHVyYjkyZC9idStFUkFuV2gxcHdI"
      "U2dCOCtEWnZBSDJLcjVmMUdJCm1SRW0ybW15Sm5UTi82N0FMZEVSeDNnTTFaendob01N"
      "RlB0Q2UwcUVBR2QvMmtiUlJWRGdwSFJEWmVBYWswNHIKT0lyM01sckdnT2l2UlFmd3BJ"
      "dC80Rm85NXoxaFY2djlubWFucGd4N09VUDJSaFNRMXlIZk9XYnBjQXpMdEZFUApsN2pF"
      "WGhBeFhjTUJrZGlpd3JhcEVYYU5rTHpKMW94elFwdWc3Vy9Iek85ZVhXbHAwNzVYeXVy"
      "K0pUQkxlOEZYdVYKWmczcVEzclZBZ01CQUFFQ2dnRUFBWUV2N0lrZTdWazcvNThrUW5u"
      "aTJtUmcrcDhoeVIwYUpyblVqcy9hOHp4OAo3NmFEb3ltbEpCU0Y2aElBSDBVUWw0Q0Yz"
      "djVJb0ljRVZGejBUQ1NXby8reXJRQDBVZUJISVlMTEVLREZRSHdvCnRFMzlDTUozelIv"
      "QzdyOWhuUDdmbnM4ZjlaUzI0M01ic3had0pzUWJCWjQ3ZjI4OURZWmNldFc4MnF2Z1hS"
      "NGhKQ0ZRV3ZQOGxmTUFvWnkvOWVySC9hZnV3RmVzUnFFWlFtditpU2FLVXdONUpSU3Ri"
      "RHBPUHdTcWV2ZEdRZVArdwpIaXN3VmdLK1NVNkhEa3lZOUFyVVREZWEwQSt6UGMxWStQ"
      "QTBJS1NTRE0reHlMdis3eW5xbWVydDlmbGh4NEN6ClI2d2xQWHNqWWhRait6ZjExS3Qx"
      "bVV1RDljREh5aU9xdnpWNnEwNjlzUUtCZ1FEK0dHMEJSUldrVXhXM1BuSFptbk1DbEg3"
      "YXZvOFpGV0ZlYlphVzM2TE1jMnZYUmYrUFpQVWhHNHZzQlRQNy9icjE5Sks3cmk3eHNG"
      "UnROditTK2psZ0Q4dnR3cFN0YkliVjQ4QjlYWFF2Y1hQMVBZenBsczhZTkpkVC9Xdllt"
      "VVU5RS9wUkg3RytwamhRRi9vVkNsWk9FbytDeFljQ3RHRFpNZ2xsZjExMGVRS0JnUUQx"
      "TlYzTTZlT2xvcjRFakxIL01BbTV1VnNjRkMwblkxRDMKU1JlM1FOQUREcVdMRjhmMlJC"
      "cnZXNzF0Qlc5SWVFQ3pwY3lFS0NpYW0xYUhtK1E0d2NkV0RxTUIzd2hoT2trcgp2N0tx"
      "QWVCNDBDc1BiMWFOSVJmVjJzQkNqOTVLVEpSZEFheWFXVU5zbHpXaHJ1NDFWV0xGZ1Ns"
      "VjFYVnlQQVR0Y01sQUtyWUlLUFFLQmdRQ3R1SnBzQTFRN2llSFFMOWsvRWFqVnR3bmcx"
      "ekZIcmx4M2lCNFlma2xaUVh4UkJMMnkKcjY0L2dMb2NZUEVKOXR5YXZDSWFwUXFLaUJB"
      "UUUrTnhTRVJreHh6UHpYZDlpTnlUS1lCV3pKQjlxNzA0TEkveU0KRFRmSjJ3QndrWmJM"
      "MXY2eUJKdVlPWFpMNGkzTzdUd0pyR0hXTGl0SEEwOFdld2hNNVJZYlpVaXZlUUtCZ1FE"
      "Wgpnb3RBTjhDOXJzekxrRnBjT1NxSFdzcGM3L0RWM3oxMm5abXg3b1lXRUNuOFpnMzBm"
      "NWs4OWEza1JVdmZodnd0CjMwYTVmRDM0Vnc2OG9DWWp5cENkMzhIczZRQ3Y3bG4xdXNn"
      "clVocmlVQlhDVFVzRFNYV3hONmdQNHpxVndiUmgKaEJpdG1ielZVdzNyY3FUK0xmeTVv"
      "M2FHODFnbGFqeFRuald1SXhjVktRS0JnRWdsVUg4ckp0bFBRUVd2RlMwSHl4dkZyNjNH"
      "WW0zYUU1cjNvQTlhSnJvdXFTYm5hU2VPa0pWWDg4cW1PTXM1NlRpTlFrTXhxWlgwZ1Rm"
      "aCs2Q09DQkdqR1hsT2cxeFdlNjc1MWV4RWpwMy91MFBrYXhqdUJyWnRnRWgvc200MTdV"
      "Yk95Z2l0SlM3UEpBenpoY2xzRUM3U1U5VFVBcXgyeHFrZGtwNkc3KzlMMXVDCi0tLS0t"
      "RU5EIFBSSVZBVEUgS0VZLS0tLS0K";

  static Map<String, dynamic>? _cachedCredentials;

  static Map<String, dynamic> get serviceAccountCredentials {
    if (_cachedCredentials != null) return _cachedCredentials!;
    final String cleanB64 = _pkBase64.replaceAll(RegExp(r'\s+'), '');
    final String normalized = base64.normalize(cleanB64);
    final String privateKey = utf8.decode(base64Decode(normalized));

    _cachedCredentials = {
      "type": "service_account",
      "project_id": "true-fit-52715",
      "private_key_id": "d6b995a92a948cdee303d4d6bdde3775f91dc9ba",
      "private_key": privateKey,
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

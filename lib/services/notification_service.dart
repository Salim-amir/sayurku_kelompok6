import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  // Kunci Rahasia Firebase Admin SDK (Khusus untuk PBL/Tugas)
  static const _serviceAccountJson = {
    "type": "service_account",
    "project_id": "sayurku-firebase",
    "private_key_id": "b8ccf473f2fd502b00b7377c600d71f039bdc175",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC+Y6b+QakrebBz\n90vfW12RPlQDbughLbeu/R5ERtGg0Bwi5DiPSm/X+OCdmXrLcxOo/p9yvONo7EnY\nV9EPyucrKKvm7rixSrxqnm5wuIrCPIR5jmcI1NvQM5D77PowBCGm3wNWGO7fQq3R\nlnvKMWj1znw1i2w+SYJlNEx1JlfXaDIv5fDjLmfjFTsu/7YmfGORLK2/MAjqNN+e\nebI8HrPP4fbxtqlJFy2tsCxfC3jfvCluK6FywZoHkj/Du7gxrmVKumbbChhIVYxj\nl5lyD4S7Rl4GJEQlm+z8aEeCCNY6w2scLDJ84rqTXqEwUWsDThXQkLRYtUlLd4IU\nu8tgtVjdAgMBAAECggEAAmZq3awB5XCTHGB4M43JIq0YowhxYwWwBJk1RKK96XCQ\n15HCnW/QnsuI4q5jdrrHJdYROCw7E6tdjPLNHw1YQlowvJMIKgKpWGYR5K2MNkGh\nYTo91fB/quK+MlF89UEAFESdxqaUJaVctUEtOKchzcN3cQyxEHdIbl0tP5F8Vv9N\nfadmSG6LajDJqCAo7u7pHRPSCrJWELaM5ZMkejTM4o7/nyBo0+90GAtrA9+oWgMJ\n91dhC7SyDqHKeo62vwOdPR49LsXQX8PS6zipoUsULr6HfyJ8+PE0p14b0HFuTuKn\nVEEfZbIXjaO0b8T6LOd0SKp/6J1XKjlAsJG23ue4gwKBgQD5kpDR4TDklgohxTlL\nHvP8gJT1mU+YAYa9W7qYG1KLLBxpJdFZMdL+bBZ/YN6+0vrju+bWOxheLovoCbXc\nEkCoUXMziW+vqDTsclFIR/Zq4NABX1fbbLr4l+/IG5dJLUkQI1m9vKFm3K97rcVt\n8wf/oSlZwI7baZMG/zeoDABUjwKBgQDDSuQKP1hnB8cHKHNN7McivkrV/jM/rUDs\nkE3HVnkWMeF9O0hUKs3OoXK3sjRM34xydREU1e1fyzsxJNCfu1V9iM3YyG/2n1fT\nuj+ZA95JKZ5qLuKvprJKTjvqFLfdNas/XvAATFFCccM2Z9JlhlgAJcL/xL6+lRJQ\n5PLhtK9p0wKBgHIq1gzs0wz+hgwEyLzQoBR2Ta48P+jtadHd0HIcrZn0x9ph7m67\nGCZDE9eZXMw2f4cGQgbmabNL37x6FLNjtihJekWtLWZRsEQp130VTmh+BylZkDtU\ndgOanZoQ5RgYmz/CrB7b14nSkoQlbhdqAdKyytO//pnopdWhkrhRJSWJAoGBAJUm\n7HVbHeRKj1pLLY0VSp2hYjx/kZqPcud56r1UsNQfsozXqw0FR/wJWDkt9D3F+lks\nSah1Hn8sE4AcEu37wHZI9pYbt09PMV+2fn4Z8zpDfAay2lS25rJTf/Tub+KV671R\nf9FqeCFcC3DQ6GK7sRgjvwNiux+JcNyxj0KMofAbAoGABtJu3SqixH5j16ErjBFK\nSrf52Y+QBUAIW4i/llS4o0f4rgVfC2wQr7ieKawgNF1hmtuyK5846cOIuIPt4b5+\n4OBRoZDh7UKcIGeTv085J7KOZSQh2J4tlVwjTA/Ep12neMnvybUEk8BOEzliFTe8\nvTsoPbjLvaGs2eaO8GhXoDU=\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@sayurku-firebase.iam.gserviceaccount.com",
    "client_id": "105818680715129664517",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
  };

  // Fungsi untuk mendapatkan Token Akses Server Google
  static Future<String> _getAccessToken() async {
    final accountCredentials = auth.ServiceAccountCredentials.fromJson(_serviceAccountJson);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient = await auth.clientViaServiceAccount(accountCredentials, scopes);
    final token = authClient.credentials.accessToken.data;
    authClient.close();
    return token;
  }

  // Pelatuk untuk menembak Notifikasi ke HP Customer
  static Future<void> sendPushNotification(String fcmToken, String title, String body) async {
    try {
      final serverToken = await _getAccessToken();
      final endpoint = "https://fcm.googleapis.com/v1/projects/sayurku-firebase/messages:send";

      final Map<String, dynamic> message = {
        "message": {
          "token": fcmToken,
          "notification": {
            "title": title,
            "body": body,
          }
        }
      };

      await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken',
        },
        body: jsonEncode(message),
      );
      print("🎯 Sukses menembak notifikasi FCM ke Customer!");
    } catch (e) {
      print("❌ Gagal menembak notifikasi: $e");
    }
  }
}
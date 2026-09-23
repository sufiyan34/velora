import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> testCloudflareAuth() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('❌ No Firebase user is currently signed in.');
    return;
  }

  try {
    final idToken = await user.getIdToken(true);

    final response = await Dio().post(
      'http://127.0.0.1:8788/api/test-auth',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    print('✅ Worker response: ${response.data}');
  } on DioException catch (e) {
    print('❌ Worker error: ${e.response?.data ?? e.message}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
Future<void> testCloudflareDatabase({
  required String orderId,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('❌ No Firebase user.');
    return;
  }

  try {
    final idToken = await user.getIdToken(true);

    final response = await Dio().post(
      'http://127.0.0.1:8788/api/test-database',
      data: {
        'orderId': orderId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    print('✅ Database response: ${response.data}');
  } on DioException catch (e) {
    print(
      '❌ Database error: '
      '${e.response?.data ?? e.message}',
    );
  } catch (e) {
    print('❌ Error: $e');
  }
}
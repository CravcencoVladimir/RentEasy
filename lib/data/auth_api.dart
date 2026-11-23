import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/result.dart';
import 'token_store.dart';

class AuthApi {
  final String baseUrl;
  final TokenStore tokenStore;

  AuthApi(this.baseUrl, this.tokenStore);

  Future<Result<String>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String;
        await tokenStore.saveToken(token);
        return Ok(token);
      } else {
        final data = jsonDecode(response.body);
        final msg = (data is Map && data.containsKey('message'))
            ? data['message'].toString()
            : 'Ошибка авторизации (${response.statusCode})';
        return Err(msg);
      }
    } on SocketException catch (e) {
      return Err('Сервер недоступен на $baseUrl ($e)');
    } on TimeoutException {
      return const Err('Превышено время ожидания ответа при входе');
    } catch (e) {
      return Err('Ошибка при входе: $e');
    }
  }

  Future<Result<String>> register(String name, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String;
        await tokenStore.saveToken(token);
        return Ok(token);
      } else {
        final data = jsonDecode(response.body);
        final msg = (data is Map && data.containsKey('message'))
            ? data['message'].toString()
            : 'Ошибка регистрации (${response.statusCode})';
        return Err(msg);
      }
    } on SocketException catch (e) {
      return Err('Сервер недоступен на $baseUrl ($e)');
    } on TimeoutException {
      return const Err('Превышено время ожидания ответа при регистрации');
    } catch (e) {
      return Err('Ошибка при регистрации: $e');
    }
  }

  Future<void> logout() async {
    await tokenStore.deleteToken();
  }
}

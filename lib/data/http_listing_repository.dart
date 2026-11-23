import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/result.dart';
import '../models/listing.dart';
import 'listing_repository.dart';
import 'token_store.dart';

class HttpListingRepository implements ListingRepository {
  final String baseUrl;
  final TokenStore tokenStore;
  final VoidCallback? onUnauthorized;

  HttpListingRepository(
    this.baseUrl,
    this.tokenStore, {
    this.onUnauthorized,
  });

  Future<Map<String, String>> _headers() async {
    final token = await tokenStore.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) {
      tokenStore.deleteToken();
      onUnauthorized?.call();
    }
  }

  @override
  Future<Result<List<Listing>>> getListings({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/listings').replace(queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));

      _checkUnauthorized(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        final listings = list.map((json) => _fromJson(json)).toList();
        return Ok(listings);
      } else {
        return Err('Ошибка сервера (${response.statusCode})');
      }
    } on SocketException catch (e) {
      return Err('Сервер недоступен на $baseUrl ($e)');
    } on TimeoutException {
      return const Err('Превышено время ожидания ответа от сервера (Таймаут)');
    } catch (e) {
      return Err('Сбой загрузки данных: $e');
    }
  }

  @override
  Future<Result<Listing>> getListingById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/listings/$id');
      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));

      _checkUnauthorized(response.statusCode);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Ok(_fromJson(json));
      } else {
        return const Err('Объявление не найдено');
      }
    } on SocketException catch (e) {
      return Err('Сервер недоступен ($e)');
    } on TimeoutException {
      return const Err('Превышено время ожидания ответа от сервера');
    } catch (e) {
      return Err('Ошибка получения деталей: $e');
    }
  }

  @override
  Future<Result<Listing>> createListing(Listing listing) async {
    try {
      final uri = Uri.parse('$baseUrl/listings');
      final response = await http
          .post(
            uri,
            headers: await _headers(),
            body: jsonEncode(_toJson(listing)),
          )
          .timeout(const Duration(seconds: 15));

      _checkUnauthorized(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return Ok(_fromJson(json));
      } else {
        final data = jsonDecode(response.body);
        final msg = (data is Map && data.containsKey('message'))
            ? data['message'].toString()
            : 'Ошибка сохранения (${response.statusCode})';
        return Err(msg);
      }
    } on SocketException catch (e) {
      return Err('Сервер недоступен ($e)');
    } on TimeoutException {
      return const Err('Превышено время ожидания сохранения');
    } catch (e) {
      return Err('Ошибка при создании: $e');
    }
  }

  @override
  Future<Result<void>> deleteListing(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/listings/$id');
      final response = await http
          .delete(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));

      _checkUnauthorized(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Ok(null);
      } else {
        return Err('Не удалось удалить объявление (${response.statusCode})');
      }
    } on SocketException catch (e) {
      return Err('Сервер недоступен ($e)');
    } on TimeoutException {
      return const Err('Превышено время ожидания удаления');
    } catch (e) {
      return Err('Ошибка удаления: $e');
    }
  }

  @override
  Future<Result<Listing>> updateListing(Listing listing) async {
    try {
      final uri = Uri.parse('$baseUrl/listings/${listing.id}');
      final response = await http
          .put(
            uri,
            headers: await _headers(),
            body: jsonEncode(_toJson(listing)),
          )
          .timeout(const Duration(seconds: 15));

      _checkUnauthorized(response.statusCode);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Ok(_fromJson(json));
      } else {
        return Err('Ошибка обновления (${response.statusCode})');
      }
    } on SocketException catch (e) {
      return Err('Сервер недоступен ($e)');
    } on TimeoutException {
      return const Err('Превышено время ожидания обновления');
    } catch (e) {
      return Err('Ошибка обновления: $e');
    }
  }

  Listing _fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'].toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      price: (json['price'] as num).toDouble(),
      rooms: (json['rooms'] as num).toInt(),
      imageUrls: (json['imageUrls'] is List)
          ? (json['imageUrls'] as List).map((e) => e.toString()).toList()
          : [],
      district: (json['district'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isFavorite: json['isFavorite'] == true,
    );
  }

  Map<String, dynamic> _toJson(Listing listing) {
    return {
      'id': listing.id,
      'ownerId': listing.ownerId,
      'title': listing.title,
      'address': listing.address,
      'price': listing.price,
      'rooms': listing.rooms,
      'imageUrls': listing.imageUrls,
      'district': listing.district,
      'description': listing.description,
      'isFavorite': listing.isFavorite,
    };
  }
}

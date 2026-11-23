import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('=== RentEasy Backend Server listening on http://localhost:$port ===');

  final List<Map<String, dynamic>> listings = [
    {
      'id': '1',
      'ownerId': 'owner_1',
      'title': 'Уютная однокомнатная квартира возле Университета',
      'address': 'ул. Университетская, д. 12, кв. 45',
      'price': 250.0,
      'rooms': 1,
      'imageUrls': [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=800&q=80',
      ],
      'district': 'Центр',
      'description': 'Отличная квартира для студентов. Есть вся необходимая мебель, скоростной интернет, стиральная машина и микроволновка. В пешей доступности от главного корпуса университета, метро и остановок общественного транспорта. Низкие коммунальные платежи.',
      'isFavorite': true,
    },
    {
      'id': '2',
      'ownerId': 'owner_2',
      'title': 'Светлая двухкомнатная квартира для двух студентов',
      'address': 'пр. Студенческий, д. 5, кв. 11',
      'price': 400.0,
      'rooms': 2,
      'imageUrls': [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=800&q=80',
      ],
      'district': 'Рышкановка',
      'description': 'Просторная квартира с раздельными комнатами. Идеально подходит для совместной аренды двумя студентами. Полностью оборудованная кухня, раздельный санузел, балкон. Рядом большой парк, магазины и недорогие кафе.',
      'isFavorite': false,
    },
    {
      'id': '3',
      'ownerId': 'owner_3',
      'title': 'Современная студия в новом доме',
      'address': 'ул. Молодежная, д. 24, кв. 89',
      'price': 320.0,
      'rooms': 1,
      'imageUrls': [
        'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?auto=format&fit=crop&w=800&q=80',
      ],
      'district': 'Ботаника',
      'description': 'Студия с дизайнерским ремонтом в новом жилом комплексе. Автономное отопление, кондиционер, охраняемая территория. Отличный вариант для комфортного проживания и учебы.',
      'isFavorite': true,
    },
    {
      'id': '4',
      'ownerId': 'owner_4',
      'title': 'Трёхкомнатная квартира для компании',
      'address': 'ул. Академическая, д. 8',
      'price': 550.0,
      'rooms': 3,
      'imageUrls': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
      ],
      'district': 'Буюканы',
      'description': 'Большая квартира с тремя изолированными комнатами. Полный комплект бытовой техники, включая посудомоечную машину. Подходит для группы из 3-4 студентов. Удобная транспортная развязка в любой конец города.',
      'isFavorite': false,
    },
    {
      'id': '5',
      'ownerId': 'owner_5',
      'title': 'Недорогая комната в общежитии квартирного типа',
      'address': 'ул. Рассветная, д. 15',
      'price': 150.0,
      'rooms': 1,
      'imageUrls': [
        'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=800&q=80',
      ],
      'district': 'Чеканы',
      'description': 'Бюджетный вариант проживания для одного студента. Комната закрывается на ключ. Общая кухня и санузел на две комнаты. Чисто, аккуратно, дружелюбные соседи-студенты.',
      'isFavorite': false,
    },
  ];

  server.listen((HttpRequest request) async {
    // Add CORS headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type, Authorization');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    var path = request.uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    final method = request.method;

    print('$method $path');

    try {
      // Root / health
      if (method == 'GET' && (path == '' || path == '/' || path == '/health')) {
        _sendJson(request, {'status': 'ok', 'message': 'RentEasy API Backend Running'});
        return;
      }

      // 2. POST /auth/login
      if (method == 'POST' && path == '/auth/login') {
        final body = await _readJsonBody(request);
        final email = body['email'] ?? '';
        final password = body['password'] ?? '';

        if (email.toString().isEmpty || password.toString().isEmpty) {
          _sendJson(request, {'message': 'Заполните email и пароль'}, status: HttpStatus.badRequest);
          return;
        }

        if (password.toString().length < 6) {
          _sendJson(request, {'message': 'Пароль должен состоять минимум из 6 символов'}, status: HttpStatus.unauthorized);
          return;
        }

        final token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        _sendJson(request, {
          'token': token,
          'user': {'id': 'u1', 'name': 'Иван Иванов', 'email': email}
        });
        return;
      }

      // 3. POST /auth/register
      if (method == 'POST' && path == '/auth/register') {
        final body = await _readJsonBody(request);
        final email = body['email'] ?? '';
        final password = body['password'] ?? '';
        final name = body['name'] ?? 'Пользователь';

        if (email.toString().isEmpty || password.toString().isEmpty) {
          _sendJson(request, {'message': 'Заполните email и пароль'}, status: HttpStatus.badRequest);
          return;
        }

        final token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        _sendJson(request, {
          'token': token,
          'user': {'id': 'u2', 'name': name, 'email': email}
        });
        return;
      }

      // Check auth for protected routes if token invalid
      final authHeader = request.headers.value('Authorization');
      final isAuthRequired = method == 'POST' || method == 'DELETE' || method == 'PUT';
      if (isAuthRequired && (authHeader == null || !authHeader.startsWith('Bearer '))) {
        _sendJson(request, {'message': 'Необходима авторизация (401)'}, status: HttpStatus.unauthorized);
        return;
      }

      // 4. GET /listings
      if (method == 'GET' && path == '/listings') {
        final queryParams = request.uri.queryParameters;
        final search = queryParams['search']?.toLowerCase();
        final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
        final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;

        var result = listings;
        if (search != null && search.isNotEmpty) {
          result = result.where((item) {
            final title = (item['title'] ?? '').toString().toLowerCase();
            final address = (item['address'] ?? '').toString().toLowerCase();
            final description = (item['description'] ?? '').toString().toLowerCase();
            return title.contains(search) || address.contains(search) || description.contains(search);
          }).toList();
        }

        final startIndex = (page - 1) * limit;
        if (startIndex >= result.length) {
          _sendJson(request, []);
        } else {
          final endIndex = (startIndex + limit < result.length) ? startIndex + limit : result.length;
          _sendJson(request, result.sublist(startIndex, endIndex));
        }
        return;
      }

      // 5. GET /listings/:id
      if (method == 'GET' && path.startsWith('/listings/')) {
        final id = path.substring('/listings/'.length);
        final item = listings.firstWhere((element) => element['id'] == id, orElse: () => {});
        if (item.isEmpty) {
          _sendJson(request, {'message': 'Объявление не найдено'}, status: HttpStatus.notFound);
        } else {
          _sendJson(request, item);
        }
        return;
      }

      // 6. POST /listings
      if (method == 'POST' && path == '/listings') {
        final body = await _readJsonBody(request);
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        final newItem = {
          'id': newId,
          'ownerId': body['ownerId'] ?? 'user_owner',
          'title': body['title'] ?? 'Без названия',
          'address': body['address'] ?? '',
          'price': (body['price'] is num) ? (body['price'] as num).toDouble() : 0.0,
          'rooms': (body['rooms'] is num) ? (body['rooms'] as num).toInt() : 1,
          'imageUrls': (body['imageUrls'] is List) ? body['imageUrls'] : ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80'],
          'district': body['district'] ?? 'Центр',
          'description': body['description'] ?? '',
          'isFavorite': body['isFavorite'] ?? false,
        };
        listings.add(newItem);
        _sendJson(request, newItem, status: HttpStatus.created);
        return;
      }

      // 7. DELETE /listings/:id
      if (method == 'DELETE' && path.startsWith('/listings/')) {
        final id = path.substring('/listings/'.length);
        listings.removeWhere((element) => element['id'] == id);
        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
        return;
      }

      // 8. PUT /listings/:id
      if (method == 'PUT' && path.startsWith('/listings/')) {
        final id = path.substring('/listings/'.length);
        final body = await _readJsonBody(request);
        final index = listings.indexWhere((element) => element['id'] == id);
        if (index != -1) {
          listings[index] = {...listings[index], ...body};
          _sendJson(request, listings[index]);
        } else {
          _sendJson(request, {'message': 'Объявление не найдено'}, status: HttpStatus.notFound);
        }
        return;
      }

      // 9. POST /files (Multipart Upload)
      if (method == 'POST' && path == '/files') {
        _sendJson(request, {'url': '/files/sample_uploaded_image.jpg'}, status: HttpStatus.created);
        return;
      }

      _sendJson(request, {'message': 'Маршрут не найден: $path'}, status: HttpStatus.notFound);
    } catch (e) {
      _sendJson(request, {'message': 'Внутренняя ошибка сервера: $e'}, status: HttpStatus.internalServerError);
    }
  });

  // Keep process alive indefinitely
  await Completer().future;
}

void _sendJson(HttpRequest request, dynamic data, {int status = HttpStatus.ok}) {
  request.response.statusCode = status;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(data));
  request.response.close();
}

Future<Map<String, dynamic>> _readJsonBody(HttpRequest request) async {
  final content = await utf8.decoder.bind(request).join();
  if (content.isEmpty) return {};
  return jsonDecode(content) as Map<String, dynamic>;
}

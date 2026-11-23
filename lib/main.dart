import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/http_listing_repository.dart';
import 'data/token_store.dart';
import 'models/listings_model.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // API Base URL pointing to your local IP 172.18.6.71
  final String apiBaseUrl = kIsWeb
      ? 'http://localhost:8080'
      : 'http://172.18.6.71:8080';

  final tokenStore = TokenStore();
  final savedToken = await tokenStore.readToken();

  // Configure initial location based on saved JWT token
  if (savedToken != null && savedToken.isNotEmpty) {
    appRouter.go('/listings');
  }

  final repository = HttpListingRepository(
    apiBaseUrl,
    tokenStore,
    onUnauthorized: () {
      appRouter.go('/login');
    },
  );

  final authApi = AuthApi(apiBaseUrl, tokenStore);

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStore>.value(value: tokenStore),
        Provider<AuthApi>.value(value: authApi),
        Provider<HttpListingRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => ListingsModel(repository)..loadListings(),
        ),
      ],
      child: const RentEasyApp(),
    ),
  );
}

class RentEasyApp extends StatelessWidget {
  const RentEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RentEasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}

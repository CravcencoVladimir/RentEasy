import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_listing_repository.dart';
import 'models/listings_model.dart';
import 'router.dart';

void main() {
  final repository = MockListingRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<MockListingRepository>.value(value: repository),
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

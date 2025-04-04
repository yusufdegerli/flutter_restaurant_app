import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // EKLENDİ
import 'package:sambapos_app_restorant/providers/auth_provider.dart';
import 'package:sambapos_app_restorant/providers/order_provider.dart';
import 'package:sambapos_app_restorant/screens/login_screen.dart';
import 'screens/table_selection_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Restaurant POS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/tables': (context) => const TableSelectionScreen(),
        },
        home: const LoginScreen(),
      ),
    );
  }
}

// CommonScreen kodu aynı kalacak...
class CommonScreen extends StatelessWidget {
  final String tableNumber;

  const CommonScreen({Key? key, required this.tableNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$tableNumber Masası')),
      body: Center(child: Text('$tableNumber Masası İçerik Alanı')),
    );
  }
}

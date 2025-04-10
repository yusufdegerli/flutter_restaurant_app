import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sambapos_app_restorant/providers/auth_provider.dart';
import 'package:sambapos_app_restorant/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'table_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch user data from API
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/User?name=${_usernameController.text}',
        ),
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        final matchedUser = users.firstWhere(
          (user) =>
              user['name'].toString().trim() ==
                  _usernameController.text.trim() &&
              user['pinCode'].toString().trim() == _pinController.text.trim(),
          orElse: () => null,
        );
        print(
          "Aranan Kullanıcı: ${_usernameController.text}, Pin: ${_pinController.text}",
        );
        print(
          "API'den Gelen İlk Kullanıcı: ${users[0]['name']}, Pin: ${users[0]['pinCode']}",
        );
        print("MATCHED USER: ${matchedUser}");
        if (matchedUser != null) {
          print("matchedUser: $matchedUser");
          final userId = int.parse(
            matchedUser['id'].toString(),
          ); // Convert to int
          final roleId = int.parse(
            matchedUser['userRole_Id'].toString(),
          ); // Convert to int
          final userName = matchedUser['name'] as String;
          print("OOOOOOOOOOOOOOOOOOOOOOO: ${matchedUser}");
          authProvider.login(userId, roleId, userName); // Pass all 3 arguments
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print("ALSDFHASKLJDFALŞJGHFASKLDFHASKLHJF");
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => TableSelectionScreen()),
                (Route<dynamic> route) => false,
              );
            }
          });
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text("Kullanıcı adı veya pin kodu yanlış."),
            ),
          );
        }
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Sunucu hatası: ${response.statusCode}")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Hata oluştu: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giriş Yap")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'İsim',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen isminizi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pin Kodu',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sadece sayı içeren pin girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text("Giriş Yap"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

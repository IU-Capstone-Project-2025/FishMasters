import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final response = await http.post(
        // Uri.parse('http://localhost:8080/auth/login'), // Uncomment this line for local testing
        Uri.parse(
          'https://capstone.aquaf1na.fun/auth/login',
        ), // Use this line for production
        headers: {'Content-Type': 'application/json'},
        body: '{"email": "$email", "password": "$password"}',
      );

      if (response.statusCode != 200) {
        debugPrint('Login failed: ${response.statusCode}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${response.reasonPhrase}'),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }

      debugPrint('Logged in: $email, $password');

      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }
      final settingsBox = Hive.box('settings');
      settingsBox.put('email', email);

      final responseJson = jsonDecode(response.body);
      final fullName = '${responseJson['name']} ${responseJson['surname']}';
      settingsBox.put('fullName', fullName);
      settingsBox.put('photo', responseJson['photo']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged in: $email'),
          duration: const Duration(seconds: 1),
        ),
      );
      await setLoggedIn(true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.loginText),
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  localizations.loginTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: localizations.emailLabel,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter email';
                              }
                              final emailPattern = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailPattern.hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: localizations.passwordLabel,
                            ),
                            obscureText: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                value != null && value.length >= 6
                                ? null
                                : 'Min 6 characters',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(localizations.loginButton),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/register'),
                  child: Text(localizations.needRegister),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (!Hive.isBoxOpen('settings')) {
                      await Hive.openBox('settings');
                    }
                    final settingsBox = Hive.box('settings');
                    settingsBox.put('email', 'dev@local.test');
                    settingsBox.put('fullName', 'Developer Mode');

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged in as developer'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    await setLoggedIn(true);
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                  ),
                  child: const Text('Developer Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

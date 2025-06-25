import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final response = await http.post(
        // Uri.parse(
        //   'http://localhost:8080/auth/register',
        // ), // Uncomment this line for local testing
        Uri.parse(
          'https://capstone.aquaf1na.fun/auth/register',
        ), // Use this line for production
        headers: {'Content-Type': 'application/json'},
        body:
            '{"name": "$firstName", "surname": "$lastName", "email": "$email", "password": "$password"}',
      );

      if (response.statusCode != 200) {
        debugPrint('Registration failed: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${response.reasonPhrase}'),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }

      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }
      final settingsBox = Hive.box('settings');
      settingsBox.put('email', email);

      final responseJson = jsonDecode(response.body);
      final fullName = '${responseJson['name']} ${responseJson['surname']}';
      settingsBox.put('fullName', fullName);
      settingsBox.put('score', responseJson['score'] ?? 0);

      debugPrint('Registered: $firstName $lastName, $email, $password');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registered: $firstName $lastName, $email'),
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
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter first name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter last name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) =>
                                value != null && value.length >= 6
                                ? null
                                : 'Min 6 characters',
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

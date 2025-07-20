import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

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
      settingsBox.put('photo', responseJson['photo']);

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
    var textScheme = Theme.of(context).textTheme;
    var localizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.secondary,
          automaticallyImplyLeading: true,
          title: Text(
            localizations!.registerText,
            style: textScheme.displayMedium,
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                  child: Text(
                    localizations.registerTitle,
                    style: textScheme.headlineLarge,
                  ),
                ),
                Form(key: _formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _firstNameController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              focusNode: FocusNode(),
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: textScheme.labelMedium,
                                hintText: localizations.firstNameLabel,
                                hintStyle: textScheme.headlineMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorStyle: textScheme.bodyMedium,
                                filled: true,
                                fillColor: colorScheme.surfaceBright,
                              ),
                              style: textScheme.headlineMedium,
                              cursorColor: colorScheme.onPrimary,
                              validator: (value) => value == null || value.isEmpty
                                ? 'Enter first name'
                                : null,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _lastNameController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              focusNode: FocusNode(),
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: textScheme.labelMedium,
                                hintText: localizations.lastNameLabel,
                                hintStyle: textScheme.headlineMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorStyle: textScheme.bodyMedium,
                                filled: true,
                                fillColor: colorScheme.surfaceBright,
                              ),
                              style: textScheme.headlineMedium,
                              cursorColor: colorScheme.onPrimary,
                              validator: (value) => value == null || value.isEmpty
                                ? 'Enter last name'
                                : null,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _emailController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              focusNode: FocusNode(),
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: textScheme.labelMedium,
                                hintText: localizations.emailLabel,
                                hintStyle: textScheme.headlineMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorStyle: textScheme.bodyMedium,
                                filled: true,
                                fillColor: colorScheme.surfaceBright,
                              ),
                              style: textScheme.headlineMedium,
                              cursorColor: colorScheme.onPrimary,
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
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _passwordController,
                              focusNode: FocusNode(),
                              autofocus: false,
                              obscureText: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: textScheme.labelMedium,
                                hintText: localizations.passwordLabel,
                                hintStyle: textScheme.headlineMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.surfaceBright,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                errorStyle: textScheme.bodyMedium,
                                filled: true,
                                fillColor: colorScheme.surfaceBright,
                              ),
                              style: textScheme.headlineMedium,
                              cursorColor: colorScheme.onPrimary,
                              validator: (value) =>
                                  value != null && value.length >= 6
                                  ? null
                                  : 'Min 6 characters',
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _submit,
                        style: TextButton.styleFrom(
                          backgroundColor: colorScheme.surfaceBright,
                          foregroundColor: colorScheme.tertiary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(localizations.registerButton, style: textScheme.titleSmall),
                        ),
                      ]
                      ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.tertiary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(localizations.needLogin, style: textScheme.titleMedium,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   var localizations = AppLocalizations.of(context);
  //   var colorScheme = Theme.of(context).colorScheme;
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(localizations!.registerText),
  //       backgroundColor: colorScheme.tertiary,
  //       foregroundColor: colorScheme.onTertiary,
  //     ),
  //     body: Center(
  //       child: SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             children: [
  //               Text(
  //                 localizations.registerTitle,
  //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 16),
  //               Card(
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Form(
  //                     key: _formKey,
  //                     child: Column(
  //                       children: [
  //                         TextFormField(
  //                           controller: _firstNameController,
  //                           decoration: InputDecoration(
  //                             labelText: localizations.firstNameLabel,
  //                           ),
  //                           validator: (value) => value == null || value.isEmpty
  //                               ? 'Enter first name'
  //                               : null,
  //                         ),
  //                         const SizedBox(height: 12),
  //                         TextFormField(
  //                           controller: _lastNameController,
  //                           decoration: InputDecoration(
  //                             labelText: localizations.lastNameLabel,
  //                           ),
  //                           validator: (value) => value == null || value.isEmpty
  //                               ? 'Enter last name'
  //                               : null,
  //                         ),
  //                         const SizedBox(height: 12),
  //                         TextFormField(
  //                           controller: _emailController,
  //                           autovalidateMode:
  //                               AutovalidateMode.onUserInteraction,
  //                           decoration: InputDecoration(
  //                             labelText: localizations.emailLabel,
  //                           ),
  //                           keyboardType: TextInputType.emailAddress,
  //                           validator: (value) {
  //                             if (value == null || value.isEmpty) {
  //                               return 'Enter email';
  //                             }
  //                             final emailPattern = RegExp(
  //                               r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  //                             );
  //                             if (!emailPattern.hasMatch(value)) {
  //                               return 'Enter a valid email';
  //                             }
  //                             return null;
  //                           },
  //                         ),
  //                         const SizedBox(height: 12),
  //                         TextFormField(
  //                           controller: _passwordController,
  //                           autovalidateMode:
  //                               AutovalidateMode.onUserInteraction,
  //                           decoration: InputDecoration(
  //                             labelText: localizations.passwordLabel,
  //                           ),
  //                           obscureText: true,
  //                           validator: (value) =>
  //                               value != null && value.length >= 6
  //                               ? null
  //                               : 'Min 6 characters',
  //                         ),
  //                         const SizedBox(height: 24),
  //                         ElevatedButton(
  //                           onPressed: _submit,
  //                           child: Text(localizations.registerButton),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               TextButton(
  //                 onPressed: () =>
  //                     Navigator.pushReplacementNamed(context, '/login'),
  //                 child: Text(localizations.needLogin),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
// }

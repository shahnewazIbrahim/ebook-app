import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showTopSnackBar(String title, String message, {Color bgColor = Colors.red, IconData? icon, Color iconColor = Colors.white}) {

    Get.snackbar(
        title,
        message,
        backgroundColor: bgColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: icon != null
            ? Icon(
          icon,
          color: iconColor,
          size: 26,
        )
            : null,
    );
    // final messenger = ScaffoldMessenger.of(context);
    // messenger.clearSnackBars();
    // messenger.showSnackBar(
    //   SnackBar(
    //     content: Row(
    //       children: [
    //         if (icon != null)
    //           Icon(icon, color: Colors.white),
    //         if (icon != null)
    //           const SizedBox(width: 10),
    //         Expanded(child: Text(message)),
    //       ],
    //     ),
    //     backgroundColor: bgColor,
    //     behavior: SnackBarBehavior.floating,
    //     margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(12),
    //     ),
    //     duration: const Duration(seconds: 3),
    //   ),
    // );
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    ApiService apiService = ApiService();

    if (!_formKey.currentState!.validate()) {
      _showTopSnackBar('Invalid input', "Check Again", bgColor: Colors.orange, icon: Icons.warning);
      return;
    }

    final loginData = await apiService.postData('/login', {
      'username': username,
      'password': password,
    });

    if (loginData == null || loginData is! Map || !loginData.containsKey('error')) {
      _showTopSnackBar('Unexpected server error', 'Try Again', bgColor: Colors.red, icon: Icons.error);
      return;
    }

    if (loginData['error'] > 0) {
      _showTopSnackBar(loginData['message'] ?? 'Login error', 'Try again', bgColor: Colors.red, icon: Icons.error);
      return;
    }

    if (loginData['token'] != null && loginData['error'] == 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginData['token']);
      await prefs.setString('userName', loginData['name']);

      _showTopSnackBar('Login successful!', 'Enjoy your learning..' ,bgColor: Colors.green, icon: Icons.check_circle);

      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: "My Ebooks")),
      );
    } else {
      _showTopSnackBar('Login failed', 'Something Error', bgColor: Colors.red, icon: Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Login",
      showDrawer: false,
      showNavBar: false,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/app-icon.png',
                    height: 100,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter username' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text("Forgot Password?"),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign-up');
                        },
                        child: const Text("Sign Up"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final messenger = ScaffoldMessenger.of(context); // ✅ important!

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    ApiService apiService = ApiService();

    if (_formKey.currentState!.validate()) {
      final loginData = await apiService.postData('/login', {
        'username': username,
        'password': password,
      });

      print("Login response: $loginData"); // debug log

      // ✅ Error response
      if (loginData['error'] > 0) {
        messenger.showSnackBar(
          SnackBar(content: Text(loginData['message'] ?? 'Login error')),
        );
        return;
      }

      // ✅ Success
      if (loginData['token'] != null && loginData['error'] == 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginData['token']);
        await prefs.setString('userName', loginData['name']);

        messenger.showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        await Future.delayed(const Duration(milliseconds: 500)); // wait before redirect

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: "My Ebooks")),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid input')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Login",
      showDrawer: false,  // 🚫 Drawer off
      showNavBar: false,  // 🚫 Bottom nav off
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Ebook App",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
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
    );
  }
}

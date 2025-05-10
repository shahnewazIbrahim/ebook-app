import 'package:ebook_project/api/api_service.dart';
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

  // Validate input fields and handle login
  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    ApiService apiService = ApiService();
    if (_formKey.currentState!.validate()) {
      final loginData = await apiService.postData('/login', {
        'username' : username,
        'password' : password,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logging in...')),
      );
      print(loginData['token']);
      if(loginData['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        print(loginData['token']);
        prefs.setString('auth_token', loginData['token']); // Save the token
        print(prefs.getString('auth_token'));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Problem...')),
        );
      }
      // Navigator.pushReplacementNamed(context, '/home');

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Problem...')),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo or Title
                Text(
                  "Ebook App",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 30),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      // Login Button
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Forgot Password and Sign Up Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigate to Forgot Password Page (Implement this page)
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: Text("Forgot Password?"),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        // Navigate to Sign Up Page (Implement this page)
                        Navigator.pushNamed(context, '/sign-up');
                      },
                      child: Text("Sign Up"),
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

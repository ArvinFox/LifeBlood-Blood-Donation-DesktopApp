import 'package:blood_donation_app/components/custom_auth_button.dart';
import 'package:blood_donation_app/providers/auth_provider.dart';
import 'package:blood_donation_app/screens/auth/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/authentication_background.jpg",
              fit: BoxFit.fill,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.pinkAccent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 6),
                            const Text(
                              "USER LOGIN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                  
                        Divider(color: Colors.grey[600]),
                        const SizedBox(height: 18),
                  
                        TextField(
                          controller: _emailController,  
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                  
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())
                              );
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (authProvider.errorMessage != null)
                          Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),

                        authProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomAuthButton(
                              label: "Login",
                              onPressed: () {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  // Empty fields
                                  return;
                                }

                                authProvider.login(email, password);
                              },
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

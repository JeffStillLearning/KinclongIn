import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kinclongin/Views/LoginRegister/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? selectedRole;
  bool _obscurePassword = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    // Validasi username (hanya huruf)
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Username tidak boleh kosong';
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(username)) {
      setState(() {
        _errorMessage = 'Username hanya boleh berisi huruf (tanpa spasi atau karakter lain)';
        _isLoading = false;
      });
      return;
    }

    // Validasi email (harus @gmail.com)
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email tidak boleh kosong';
        _isLoading = false;
      });
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      setState(() {
        _errorMessage = 'Email harus menggunakan @gmail.com';
        _isLoading = false;
      });
      return;
    }

    // Validasi password
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Password tidak boleh kosong';
        _isLoading = false;
      });
      return;
    }

    // Validasi role
    if (selectedRole == null) {
      setState(() {
        _errorMessage = 'Silakan pilih role';
        _isLoading = false;
      });
      return;
    }

    try {
      // Create Firebase Auth user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Create user profile in Firestore
      final userModel = await UserService.createUserProfile(userCredential.user!);

      if (userModel != null) {
        print('✅ User profile created successfully with UID: ${userModel.uid}');

        // Update user profile with custom username and role
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).update({
          'role': selectedRole ?? 'Customer',
          'username': username,
          'displayName': username,
        });

        print('✅ Username and role updated: $username');

        if (mounted) {
          // Navigate to login page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        setState(() { _errorMessage = 'Failed to create user profile'; });
      }
    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = e.message; });
    } catch (e) {
      setState(() { _errorMessage = 'Registration failed: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg_login.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Username Field
                    Container(
                      width: 312,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.person,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _usernameController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Username',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email Field
                    Container(
                      width: 312,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.email,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                // Auto-complete dengan @gmail.com jika user mengetik tanpa @
                                if (!value.contains('@') && value.isNotEmpty) {
                                  // Tidak melakukan apa-apa, biarkan user mengetik
                                } else if (value.contains('@') && !value.endsWith('@gmail.com')) {
                                  // Jika user mengetik @ tapi bukan gmail.com, beri hint
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    Container(
                      width: 312,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.lock,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 20),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Role Dropdown
                    Container(
                      width: 312,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text(
                                'Pilih Role',
                                style: TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                              value: selectedRole,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedRole = newValue;
                                });
                              },
                              items: const [
                                DropdownMenuItem<String>(
                                  value: 'Customer',
                                  child: Text('Customer'),
                                ),
                              ],
                              buttonStyleData: const ButtonStyleData(
                                height: 65,
                                padding: EdgeInsets.only(right: 20),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.blue,
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                              ),
                              underline: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                          shadowColor: Colors.blue.withOpacity(0.18),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

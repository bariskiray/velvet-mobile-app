import 'package:flutter/material.dart';
import 'package:valet_mobile_app/components/custom_password_field.dart';
import 'package:valet_mobile_app/components/custom_text_field.dart';
import 'package:valet_mobile_app/components/error_message.dart';
import 'package:valet_mobile_app/views/business/business_login/business_register_view.dart';

class BusinessLoginView extends StatefulWidget {
  const BusinessLoginView({Key? key}) : super(key: key);

  @override
  _BusinessLoginViewState createState() => _BusinessLoginViewState();
}

class _BusinessLoginViewState extends State<BusinessLoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Business Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20.0),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 20.0),
                ErrorMessage(message: _errorMessage, color: Colors.red),
              ],
              const SizedBox(height: 10.0),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 20.0),
              CustomPasswordField(
                controller: _passwordController,
                label: 'Password',
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Giriş işlemi burada yapılacak
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[900],
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18.0)),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BusinessRegisterView()),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("Don't have an account? Register here"),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Geri butonu
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

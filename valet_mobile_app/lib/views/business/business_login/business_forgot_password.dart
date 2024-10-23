import 'package:flutter/material.dart';
import 'package:valet_mobile_app/components/custom_text_field.dart';
import 'package:valet_mobile_app/components/error_message.dart';
import 'package:valet_mobile_app/views/business/business_login/business_login_view.dart';

class BusinessForgotPasswordView extends StatefulWidget {
  const BusinessForgotPasswordView({Key? key}) : super(key: key);

  @override
  _BusinessForgotPasswordViewState createState() => _BusinessForgotPasswordViewState();
}

class _BusinessForgotPasswordViewState extends State<BusinessForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
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
                'Forgot Password',
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
              ElevatedButton(
                onPressed: () {
                  // Şifre sıfırlama işlemi burada yapılacak
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[900],
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Reset Password', style: TextStyle(fontSize: 18.0)),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BusinessLoginView()),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("Remembered your password? Login here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

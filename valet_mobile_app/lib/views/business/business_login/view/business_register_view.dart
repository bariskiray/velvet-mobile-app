import 'package:flutter/material.dart';
import 'package:valet_mobile_app/components/custom_password_field.dart';
import 'package:valet_mobile_app/components/custom_text_field.dart';
import 'package:valet_mobile_app/components/error_message.dart';
import 'package:valet_mobile_app/views/business/business_login/view/business_login_view.dart';
import 'package:valet_mobile_app/views/business/business_login/controller/business_register_controller.dart';

class BusinessRegisterView extends StatefulWidget {
  const BusinessRegisterView({Key? key}) : super(key: key);

  @override
  _BusinessRegisterViewState createState() => _BusinessRegisterViewState();
}

class _BusinessRegisterViewState extends State<BusinessRegisterView> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  final BusinessRegisterController _controller = BusinessRegisterController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_businessNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _controller.register(
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        businessName: _businessNameController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BusinessLoginView()),
          );
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: $e';
        });
      }
    }
  }

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
                'Business Register',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20.0),
              CustomTextField(
                controller: _businessNameController,
                labelText: 'Business Name',
                hintText: 'Enter your business name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20.0),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20.0),
              CustomTextField(
                controller: _phoneNumberController,
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20.0),
              CustomPasswordField(
                controller: _passwordController,
                label: 'Password',
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[900],
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Get Started', style: TextStyle(fontSize: 18.0)),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 20.0),
                ErrorMessage(message: _errorMessage, color: Colors.red),
              ],
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BusinessLoginView()),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("Already have an account? Login here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

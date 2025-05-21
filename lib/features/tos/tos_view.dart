import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed(RouterConstants.settings),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Jasper HomeAI!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'By using this app, you agree to the following terms and conditions. '
                'Please read them carefully.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                '1. Usage Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'You agree to use this app only for lawful purposes and in a way that does not infringe the rights of others.',
              ),
              SizedBox(height: 12),
              Text(
                '2. Intellectual Property',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'All content and assets in this app are the property of Jasper HomeAI and its creators unless stated otherwise.',
              ),
              SizedBox(height: 12),
              Text(
                '3. Limitation of Liability',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'We are not liable for any damages that may arise from the use of this app.',
              ),
              SizedBox(height: 12),
              Text('4. Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'We respect your privacy. Please refer to our Privacy Policy to understand how we handle your data.',
              ),
              SizedBox(height: 12),
              Text(
                '5. Changes to Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'We may update these terms from time to time. Continued use of the app means you accept the updated terms.',
              ),
              SizedBox(height: 20),
              Text(
                'If you have any questions about our Terms of Service, feel free to contact us.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

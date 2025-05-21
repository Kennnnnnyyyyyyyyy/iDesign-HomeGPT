import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
                'Your Privacy Matters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Jasper HomeAI is committed to protecting your personal information. '
                'This Privacy Policy explains how we collect, use, and safeguard your data.',
              ),
              SizedBox(height: 20),
              Text(
                '1. Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'We collect data such as photos uploaded, preferences selected, and anonymous usage analytics to improve our service.',
              ),
              SizedBox(height: 12),
              Text(
                '2. Data Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Your data is used solely for the functionality of the app — including AI generation, personalization, and performance monitoring.',
              ),
              SizedBox(height: 12),
              Text(
                '3. Third-Party Services',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'We may use third-party services like Supabase, analytics, and crash reporting tools. These services may collect limited data.',
              ),
              SizedBox(height: 12),
              Text(
                '4. Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'We use standard security measures to protect your data. However, no system is completely secure, so use the app at your discretion.',
              ),
              SizedBox(height: 12),
              Text(
                '5. User Control',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'You can contact us to delete your data or inquire about what is stored.',
              ),
              SizedBox(height: 20),
              Text(
                'If you have any questions regarding our privacy practices, please contact us directly.',
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

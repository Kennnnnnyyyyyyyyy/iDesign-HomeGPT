import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'sales@yiinternational.org',
      query: Uri.encodeFull('subject=Privacy Inquiry - HomeGPT'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // fallback if no mail app
      throw 'Could not launch email client.';
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Privacy Matters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'HomeGPT - AI Home Interior is committed to protecting your personal information. '
                'This Privacy Policy explains how we collect, use, and safeguard your data.',
              ),
              const SizedBox(height: 20),
              const Text(
                '1. Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'We collect data such as photos uploaded, preferences selected, and anonymous usage analytics to improve our service.',
              ),
              const SizedBox(height: 12),
              const Text(
                '2. Data Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Your data is used solely for the functionality of the app — including AI generation, personalization, and performance monitoring.',
              ),
              const SizedBox(height: 12),
              const Text(
                '3. Third-Party Services',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'We may use third-party services like Supabase, analytics, and crash reporting tools. These services may collect limited data.',
              ),
              const SizedBox(height: 12),
              const Text(
                '4. Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'We use standard security measures to protect your data. However, no system is completely secure, so use the app at your discretion.',
              ),
              const SizedBox(height: 12),
              const Text(
                '5. User Control',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'You can contact us to delete your data or inquire about what is stored.',
              ),
              const SizedBox(height: 20),
              const Text(
                'If you have any questions regarding our privacy practices, feel free to contact us at:',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _launchEmail,
                child: const Text(
                  '📧 sales@yiinternational.org',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Last updated: June 10, 2025',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

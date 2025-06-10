import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How does HomeGPT - AI Home Interior work?',
        'answer':
            'HomeGPT uses AI to redesign interiors and exteriors based on your preferences, styles, and the photos you upload.',
      },
      {
        'question': 'Is my data stored or shared?',
        'answer':
            'No, your data and images remain private. We do not store or share any personal information.',
      },
      {
        'question': 'Can I try different styles before applying?',
        'answer':
            'Yes! You can preview multiple styles and palettes before choosing your final design.',
      },
      {
        'question': 'What formats of images are supported?',
        'answer': 'We currently support JPG, PNG, and HEIC formats.',
      },
      {
        'question': 'Does it work offline?',
        'answer':
            'No, an internet connection is required to process images using our AI engine hosted on secure cloud servers.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed(RouterConstants.settings),
        ),
        title: const Text('FAQs', style: TextStyle(color: Colors.black)),
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            title: Text(
              faq['question']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

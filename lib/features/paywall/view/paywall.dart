import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final List<String> images = [
    'assets/create/br1.jpeg',
    'assets/create/br2.jpeg',
    'assets/create/br3.jpeg',
  ];

  late Timer _timer;
  int _currentPage = 0;

  bool _isTrialEnabled = true;
  String _selectedPlan = 'yearly';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// Top bar with close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 50),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.goNamed(RouterConstants.home),
                ),
              ],
            ),

            /// Image carousel with auto-scroll
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(images[index], fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// Feature bullets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: const [
                  _FeatureItem("Faster Rendering"),
                  _FeatureItem("Ad-free Experience"),
                  _FeatureItem("Unlimited Design Renders"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Free trial toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Enable free trial",
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    value: _isTrialEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isTrialEnabled = value;
                      });
                    },
                    activeColor: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            /// Plan options with selection
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlan = 'yearly';
                });
              },
              child: _PlanCard(
                title: "YEARLY ACCESS",
                subtitle: "Just \$49.99 per year",
                price: "\$0.99",
                highlight: _selectedPlan == 'yearly',
                weekly: true,
                bestOffer: true,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlan = 'weekly';
                });
              },
              child: _PlanCard(
                title: "WEEKLY ACCESS",
                subtitle: "Pay as you go",
                price: "\$12.99",
                highlight: _selectedPlan == 'weekly',
                weekly: true,
              ),
            ),
            const Spacer(),

            /// Cancel anytime and continue
            const Text(
              "Cancel Anytime",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final message =
                      _isTrialEnabled
                          ? 'Free Trial Activated for $_selectedPlan Plan'
                          : 'Subscribed to $_selectedPlan Plan';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Terms • Privacy",
              style: TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String price;
  final bool highlight;
  final bool weekly;
  final bool bestOffer;

  const _PlanCard({
    required this.title,
    this.subtitle,
    required this.price,
    this.highlight = false,
    this.weekly = false,
    this.bestOffer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? Colors.red.shade900 : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border:
            highlight ? Border.all(color: Colors.redAccent, width: 1.2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (bestOffer)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "BEST OFFER",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (weekly)
                const Text(
                  "per week",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

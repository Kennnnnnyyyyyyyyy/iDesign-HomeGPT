import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:qonversion_flutter/qonversion_flutter.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final List<String> images = [
    'assets/create/ro1.jpeg',
    'assets/create/ro2.jpeg',
    'assets/create/ro3.jpeg',
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

  Future<void> _handlePurchase() async {
    final qonversionProductId =
        _selectedPlan == 'yearly'
            ? 'yearly_3d_freetrial'
            : 'weekly-nofreetrial';

    try {
      final qonversion = Qonversion.getSharedInstance();
      final products = await qonversion.products();
      final product = products[qonversionProductId];
      if (product == null) {
        throw Exception("Product not found for ID: $qonversionProductId");
      }

      final purchaseModel = QPurchaseModel(product.qonversionId);
      final result = await qonversion.purchase(purchaseModel);
      final entitlement = result['premium_access_homegpt'];

      if (entitlement?.isActive ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Subscription activated successfully!'),
          ),
        );
        context.goNamed(RouterConstants.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Subscription not active.')),
        );
      }
    } catch (e) {
      print('❌ Purchase failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Purchase failed: $e')));
    }
  }

  Future<void> _handleRestore() async {
    try {
      final qonversion = Qonversion.getSharedInstance();
      final entitlements = await qonversion.restore();
      final entitlement = entitlements['premium_access_homegpt'];

      if (entitlement?.isActive ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Purchases successfully restored!')),
        );
        context.goNamed(RouterConstants.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ No purchases to restore')),
        );
      }
    } catch (e) {
      print('❌ Restore failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Restore failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                _buildTopBar(),
                _buildCarousel(),
                const SizedBox(height: 16),
                _buildFeatures(),
                const SizedBox(height: 24),
                _buildFreeTrialToggle(),
                const SizedBox(height: 12),
                _buildPlanSelection(),
                const SizedBox(height: 24),
                const Text(
                  "Cancel Anytime",
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                _buildContinueButton(),
                const SizedBox(height: 12),
                _buildRestoreButton(),
                const SizedBox(height: 16),
                const Text(
                  "Terms • Privacy",
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 50),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.goNamed(RouterConstants.home),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
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
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: const [
          _FeatureItem("Faster Rendering"),
          _FeatureItem("Ad-free Experience"),
          _FeatureItem("Unlimited Design Renders"),
        ],
      ),
    );
  }

  Widget _buildFreeTrialToggle() {
    return Padding(
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
            onChanged: (value) => setState(() => _isTrialEnabled = value),
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }

  // Updated buildPlanSelection with dynamic weekly title
  Widget _buildPlanSelection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedPlan = 'yearly'),
          child: _PlanCard(
            title: "YEARLY ACCESS",
            subtitle: "Just \$49.99 per year",
            price: "\$0.99",
            extraText: "per week",
            highlight: _selectedPlan == 'yearly',
            bestOffer: true,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _selectedPlan = 'weekly'),
          child: _PlanCard(
            title: _isTrialEnabled ? "3-DAYS FREE TRIAL" : "WEEKLY ACCESS",
            subtitle: _isTrialEnabled ? null : "Pay as you go",
            price: _isTrialEnabled ? "then \$12.99" : "\$12.99",
            extraText: _isTrialEnabled ? "per week" : "per week",
            highlight: _selectedPlan == 'weekly',
            bestOffer: false,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handlePurchase,
        child: const Text(
          "Continue",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handleRestore,
        child: const Text(
          "Restore Purchases",
          style: TextStyle(fontSize: 18, color: Colors.white),
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
  final String extraText;
  final bool highlight;
  final bool bestOffer;

  const _PlanCard({
    required this.title,
    this.subtitle,
    required this.price,
    required this.extraText,
    this.highlight = false,
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
              Text(
                extraText,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

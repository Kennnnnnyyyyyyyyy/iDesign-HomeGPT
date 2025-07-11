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
  List<QProduct> _availableProducts = [];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final List<String> images = [
    'assets/create/ro1.jpeg',
    'assets/create/ro2.jpeg',
    'assets/create/ro3.jpeg',
  ];

  static const yearlyWithTrial = 'yearly_3day_trial';
  static const weeklyWithoutTrial = 'weekly';
  static const entitlementID = 'premium';

  late Timer _timer;
  int _currentPage = 0;
  bool _isTrialEnabled = true;
  String _selectedPlan = 'yearly';

  @override
  void initState() {
    super.initState();
    _checkTrialEligibility();
    _startCarousel();
    _initializeOfferingsAndLog();
  }

  Future<void> _initializeOfferingsAndLog() async {
    await _fetchOfferings();
    await _debugPrintQonversionProducts();
  }

  void _startCarousel() {
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

  Future<void> _checkTrialEligibility() async {
    try {
      final qonversion = Qonversion.getSharedInstance();
      final eligibility = await qonversion.checkTrialIntroEligibility([
        yearlyWithTrial,
      ]);

      final status = eligibility[yearlyWithTrial]?.status;
      setState(() {
        _isTrialEnabled = status == QEligibilityStatus.eligible;
      });
    } catch (e) {
      debugPrint("⚠️ Failed to check trial eligibility: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOfferings() async {
    try {
      final QOfferings offerings =
          await Qonversion.getSharedInstance().offerings();
      final QOffering? homegptOffering = offerings.offeringForIdentifier(
        "homegpt",
      );

      if (homegptOffering != null && homegptOffering.products.isNotEmpty) {
        setState(() {
          _availableProducts = homegptOffering.products;
        });

        for (var product in homegptOffering.products) {
          debugPrint("🔹 Qonversion ID: ${product.qonversionId}");
          debugPrint("🔹 Store ID (SKU): ${product.storeId}");
          debugPrint("🔹 Pretty Price: ${product.prettyPrice}");
          debugPrint("🔹 Sku details: ${product.skuDetails}");
          debugPrint("🔹 Trial Duration: ${product.trialPeriod}");

          debugPrint("🔹 Type: ${product.type}");
          debugPrint("🔹 Offering ID: ${homegptOffering.id}");
          debugPrint("------");
        }
      } else {
        debugPrint("⚠️ No products found in 'homegpt' offering.");
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch offerings: $e");
    }
  }

  Future<void> _debugPrintQonversionProducts() async {
    try {
      final products = await Qonversion.getSharedInstance().products();
      debugPrint("🛒 Available Qonversion products:");
      products.forEach((key, product) {
        debugPrint("🔑 key: $key");
        debugPrint("↳ Qonversion ID: ${product.qonversionId}");
        debugPrint("↳ Store ID: ${product.storeId}");
      });
    } catch (e) {
      debugPrint("❌ Failed to fetch products: $e");
    }
  }

  Future<void> _handlePurchase() async {
    final productId =
        _selectedPlan == 'yearly' ? yearlyWithTrial : weeklyWithoutTrial;

    try {
      if (_availableProducts.isEmpty) {
        throw Exception(
          "❌ No products loaded from offerings. Ensure offering is correctly configured in Qonversion.",
        );
      }

      final product = _availableProducts.firstWhere(
        (p) => p.storeId == productId || p.qonversionId == productId,
        orElse: () {
          debugPrint("❌ Could not find product with ID: $productId");
          throw Exception("Product not found in offering: $productId");
        },
      );

      debugPrint("🧾 Initiating purchase for:");
      debugPrint("🔹 Qonversion ID: ${product.qonversionId}");
      debugPrint("🔹 Store ID: ${product.storeId}");
      debugPrint("🔹 Pretty Price: ${product.price}");

      final entitlements = await Qonversion.getSharedInstance().purchase(
        QPurchaseModel(product.qonversionId),
      );
      final entitlement = entitlements[entitlementID];

      if (entitlement?.isActive ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Subscription activated!')),
        );
        context.goNamed(RouterConstants.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Subscription not active.')),
        );
      }
    } catch (e) {
      debugPrint("❌ Purchase failed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Purchase failed: $e')));
    }
  }

  Future<void> _handleRestore() async {
    try {
      final entitlements = await Qonversion.getSharedInstance().restore();
      final entitlement = entitlements[entitlementID];

      if (entitlement?.isActive ?? false) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Purchases restored!')));
        context.goNamed(RouterConstants.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium features coming soon. Stay tuned!'),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Restore failed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Restore failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
              if (_selectedPlan == 'yearly') _buildFreeTrialToggle(),
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
              // const Text(
              //   "Terms • Privacy",
              //   style: TextStyle(color: Colors.white38),
              // ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildTopBar() => Row(
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

  Widget _buildCarousel() => SizedBox(
    height: 240,
    child: PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(images[index], fit: BoxFit.cover),
            ),
          ),
    ),
  );

  Widget _buildFeatures() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: const [
        _FeatureItem("Faster Rendering"),
        _FeatureItem("Ad-free Experience"),
        _FeatureItem("Unlimited Design Renders"),
      ],
    ),
  );

  Widget _buildFreeTrialToggle() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Free trial enabled", style: TextStyle(color: Colors.white)),
        Switch(
          value: _isTrialEnabled,
          onChanged: (value) => setState(() => _isTrialEnabled = value),
          activeColor: Colors.red,
        ),
      ],
    ),
  );

  Widget _buildPlanSelection() => Column(
    children: [
      GestureDetector(
        onTap: () => setState(() => _selectedPlan = 'yearly'),
        child: _PlanCard(
          title: _isTrialEnabled ? "3-DAYS FREE TRIAL" : "YEARLY ACCESS",
          subtitle:
              _isTrialEnabled ? "then \$49.99 per year" : "\$49.99 per year",
          price: _isTrialEnabled ? "\$0.00" : "\$49.99",
          extraText: _isTrialEnabled ? "Trial – then yearly" : "per year",
          highlight: _selectedPlan == 'yearly',
          bestOffer: true,
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => setState(() => _selectedPlan = 'weekly'),
        child: _PlanCard(
          title: "WEEKLY ACCESS",
          subtitle: "\$12.99 per week",
          price: "\$12.99",
          extraText: "per week",
          highlight: _selectedPlan == 'weekly',
          bestOffer: false,
        ),
      ),
    ],
  );

  Widget _buildContinueButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _handlePurchase,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isTrialEnabled && _selectedPlan == 'yearly'
                ? "Try for Free"
                : "Continue",
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    ),
  );

  Widget _buildRestoreButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _handleRestore,
      child: const Text(
        "Restore Purchases",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),
  );
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) => Padding(
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

class _PlanCard extends StatelessWidget {
  final String title, price, extraText;
  final String? subtitle;
  final bool highlight, bestOffer;

  const _PlanCard({
    required this.title,
    this.subtitle,
    required this.price,
    required this.extraText,
    this.highlight = false,
    this.bestOffer = false,
  });

  @override
  Widget build(BuildContext context) => Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

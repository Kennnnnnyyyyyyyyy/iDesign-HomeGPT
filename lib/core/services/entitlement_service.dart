import 'package:qonversion_flutter/qonversion_flutter.dart';

class EntitlementService {
  static const entitlementId =
      "premium_access"; // This should match your Qonversion Entitlement ID

  Future<bool> hasPremium() async {
    try {
      final entitlements =
          await Qonversion.getSharedInstance().checkEntitlements();

      final entitlement = entitlements[entitlementId];

      return entitlement?.isActive ?? false;
    } catch (e) {
      // You can add better error handling here if needed
      print("❌ Qonversion entitlement check failed: $e");
      return false;
    }
  }
}

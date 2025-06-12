import 'package:qonversion_flutter/qonversion_flutter.dart';

class EntitlementService {
  static const entitlementId = "premium_access_homegpt";
  final _qonversion = Qonversion.getSharedInstance();

  Future<bool> hasPremium() async {
    try {
      final entitlements = await _qonversion.checkEntitlements();
      final entitlement = entitlements[entitlementId];
      return entitlement?.isActive ?? false;
    } catch (e) {
      print("❌ Qonversion entitlement check failed: $e");
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final entitlements = await _qonversion.restore();
      final entitlement = entitlements[entitlementId];
      return entitlement?.isActive ?? false;
    } catch (e) {
      print("❌ Qonversion restore failed: $e");
      return false;
    }
  }
}

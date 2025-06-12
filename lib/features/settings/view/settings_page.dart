import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:interior_designer_jasper/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qonversion_flutter/qonversion_flutter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'sales@yiinternational.org',
      query: Uri.encodeFull('subject=Feedback for HomeGPT&body=Hi team,'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app.')),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final userId = supabase.auth.currentUser?.id ?? 'Unknown';

    final List<_SettingItem> settings = [
      _SettingItem(Icons.send, 'Feedback'),
      _SettingItem(Icons.help_outline, 'FAQ'),
      _SettingItem(Icons.article_outlined, 'Terms of Use'),
      _SettingItem(Icons.shield_outlined, 'Privacy Policy'),
      _SettingItem(Icons.restore, 'Restore Purchase'),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed(RouterConstants.home),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ...settings.map(
              (item) => ListTile(
                leading: Icon(item.icon, color: Colors.black),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  switch (item.title) {
                    case 'Feedback':
                      _launchEmail(context);
                      break;
                    case 'FAQ':
                      context.goNamed(RouterConstants.faqs);
                      break;
                    case 'Privacy Policy':
                      context.goNamed(RouterConstants.privacyPolicy);
                      break;
                    case 'Terms of Use':
                      context.goNamed(RouterConstants.tos);
                      break;
                    case 'Restore Purchase':
                      _handleRestore(context);
                      break;
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.title} tapped')),
                      );
                  }
                },
              ),
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.black),
                    const SizedBox(width: 12),
                    const Text('User ID'),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        userId,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: userId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User ID copied!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;

  _SettingItem(this.icon, this.title);
}

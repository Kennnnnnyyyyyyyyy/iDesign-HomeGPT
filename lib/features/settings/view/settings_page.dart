import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const userId = 'f8Wc75DoS0NEp...';

    final List<_SettingItem> settings = [
      _SettingItem(Icons.send, 'Feedback'),
      _SettingItem(Icons.help_outline, 'FAQ'),
      _SettingItem(Icons.star_border, 'Rate Us'),
      _SettingItem(Icons.share_outlined, 'Share with Friends'),
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
          onPressed: () {
            context.goNamed(RouterConstants.home); // 👈 Navigate back to home
          },
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
                  // TODO: Add navigation or functionality
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
                    Text(
                      userId,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: userId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User ID copied!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Version 1.4.4',
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

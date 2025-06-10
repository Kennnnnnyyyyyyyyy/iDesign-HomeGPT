import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:interior_designer_jasper/core/widgets/bottom_navbar.dart';

/// Provider to fetch designs of the current user
final userDesignsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final uid = supabase.auth.currentUser?.id;

  if (uid == null) return [];

  final response = await supabase
      .from('ai_designs')
      .select()
      .eq('supabase_uid', uid)
      .order('created_at', ascending: false);

  print('🎯 Supabase query result: $response');

  return List<Map<String, dynamic>>.from(response);
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(userDesignsProvider));
  }

  Future<void> _refreshDesigns() async {
    ref.invalidate(userDesignsProvider);
    await ref.read(userDesignsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final designsAsync = ref.watch(userDesignsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Your Board',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: designsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (designs) {
          if (designs.isEmpty) {
            return const Center(child: Text("🪄 No images generated yet"));
          }

          return RefreshIndicator(
            onRefresh: _refreshDesigns,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: designs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final design = designs[index];
                return _buildBoardCard(
                  imageUrl: design['output_url'],
                  prompt: design['prompt'] ?? '',
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildBoardCard({required String imageUrl, required String prompt}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            cacheWidth: 800,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => const SizedBox(
                  height: 200,
                  child: Center(child: Text("❌ Failed to load image")),
                ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            child: Text(
              prompt,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

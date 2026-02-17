import 'package:flutter/material.dart';
import '../models/app_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/app_card.dart';
import 'support_screen.dart';
import 'my_account_screen.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  final _authService = AuthService.instance;
  String _username = 'User';
  final List<AppModel> _apps = AppModel.getDummyApps();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getCurrentUser();
    setState(() {
      _username = userInfo['username'] ?? 'User';
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void _handleAppTap(AppModel app) {
    Navigator.pushNamed(
      context,
      '/app-detail',
      arguments: app,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.orangeGradient,
        ),
        child: Column(
          children: [
            // Lighter Blue Header with Orange Text
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6B9BD1), // Lighter blue
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  child: Center(
                    child: Text(
                      'FREE APPS',
                      style: TextStyle(
                        color: const Color(0xFFFF8C42), // Slightly orange
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Apps List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Single Column Layout
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _apps.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: AppCard(
                                app: _apps[index],
                                onTap: () => _handleAppTap(_apps[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Presents Button - Navigate to main page (already here, just scroll to top)
                      _buildBottomButton(
                        icon: Icons.card_giftcard,
                        label: 'Presents',
                        onTap: () {
                          // Scroll to top or refresh - we're already on the main page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You are on the main page'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),

                      // My Account Button
                      _buildBottomButton(
                        icon: Icons.person,
                        label: 'My Account',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyAccountScreen(),
                            ),
                          );
                        },
                      ),

                      // Support Button
                      _buildBottomButton(
                        icon: Icons.support_agent,
                        label: 'Support',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppConstants.primaryOrange,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppConstants.textOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

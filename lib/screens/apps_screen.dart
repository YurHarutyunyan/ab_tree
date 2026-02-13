import 'package:flutter/material.dart';
import '../models/app_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/app_card.dart';

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
            // Blue Header
            Container(
              decoration: const BoxDecoration(
                gradient: AppConstants.blueGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 4),
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
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation Bar
            Container(
              color: Colors.white.withOpacity(0.95),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, $_username',
                    style: const TextStyle(
                      color: AppConstants.textOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/payment');
                        },
                        child: const Text(
                          'Payment',
                          style: TextStyle(
                            color: AppConstants.primaryOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Apps Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Discover Our Applications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Grid Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate number of columns based on width
                        final crossAxisCount = constraints.maxWidth > 900
                            ? 3
                            : constraints.maxWidth > 600
                                ? 2
                                : 1;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 30,
                          ),
                          itemCount: _apps.length,
                          itemBuilder: (context, index) {
                            return AppCard(
                              app: _apps[index],
                              onTap: () => _handleAppTap(_apps[index]),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

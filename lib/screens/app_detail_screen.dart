import 'package:flutter/material.dart';
import '../models/app_model.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../services/mongodb_service.dart';

class AppDetailScreen extends StatefulWidget {
  const AppDetailScreen({super.key});

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends State<AppDetailScreen> {
  final _authService = AuthService.instance;
  final _mongoService = MongoDBService.instance;
  int _creditsCount = 5;
  bool _isLoading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final userInfo = await _authService.getCurrentUser();
    _username = userInfo['username'] ?? '';
    
    // Get app name from arguments after first build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = ModalRoute.of(context)?.settings.arguments as AppModel?;
      if (app != null) {
        final credits = await _mongoService.getAppCredits(_username, app.name);
        setState(() {
          _creditsCount = credits;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _handleBuyButton(String appName) async {
    if (_creditsCount > 0) {
      final newCredits = _creditsCount - 1;
      
      // Save to database
      await _mongoService.updateAppCredits(_username, appName, newCredits);
      
      setState(() {
        _creditsCount = newCredits;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase successful! Credits remaining: $_creditsCount'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show alert when no credits left
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('No Credits'),
            ],
          ),
          content: const Text(
            'You have used all credits. Please add more credits to continue.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppModel app = ModalRoute.of(context)!.settings.arguments as AppModel;
    
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.orangeGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.orangeGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Credits Counter at the top
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars,
                              color: AppConstants.primaryOrange,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Credits count: $_creditsCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.textOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // App Name
                      Text(
                        app.name,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Buy Button in the middle
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 300),
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: _creditsCount > 0 
                              ? AppConstants.buttonGradient 
                              : const LinearGradient(
                                  colors: [Colors.grey, Colors.grey],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6B9BD1), // Blue border matching FREE APPS header
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _creditsCount > 0
                                  ? AppConstants.primaryOrange.withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _handleBuyButton(app.name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _creditsCount > 0 ? 'BUY' : 'NO CREDITS',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

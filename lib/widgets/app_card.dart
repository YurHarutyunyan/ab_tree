import 'package:flutter/material.dart';
import '../models/app_model.dart';
import '../utils/constants.dart';

class AppCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;

  const AppCard({
    super.key,
    required this.app,
    required this.onTap,
  });

  Color _getBadgeColor() {
    switch (app.badge.toUpperCase()) {
      case 'FREE':
        return const Color(0xFF4CAF50);
      case 'NEW':
        return const Color(0xFF42A5F5);
      case 'PREMIUM':
        return const Color(0xFFFFA726);
      default:
        return AppConstants.primaryOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 10,
        shadowColor: AppConstants.primaryOrange.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border(
              top: BorderSide(
                color: AppConstants.primaryOrange,
                width: 6,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    app.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF3E0),
                        Color(0xFFFFE0B2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      app.icon,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  app.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Tagline
                Text(
                  app.tagline,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.brownText,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  app.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Features List
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: app.features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Launch Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppConstants.buttonGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryOrange.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Launch App',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

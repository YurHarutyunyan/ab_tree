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
        elevation: 8,
        shadowColor: AppConstants.primaryOrange.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppConstants.primaryOrange.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Logo/Icon
                Container(
                  width: 80,
                  height: 80,
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
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryOrange.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      app.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Name
                      Text(
                        app.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textOrange,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        app.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon to indicate clickable
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppConstants.primaryOrange,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/app_model.dart';
import '../utils/constants.dart';

class AppDetailScreen extends StatelessWidget {
  const AppDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppModel app = ModalRoute.of(context)!.settings.arguments as AppModel;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.orangeGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back Button
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
                    const Expanded(
                      child: Text(
                        'App Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 44), // Balance back button
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // App Icon (Large)
                          Container(
                            width: 150,
                            height: 150,
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
                                  color: AppConstants.primaryOrange.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                app.icon,
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(app.badge),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              app.badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // App Name
                          Text(
                            app.name,
                            style: const TextStyle(
                              fontSize: 36,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.brownText,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Rating (Placeholder)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < 4
                                      ? Icons.star
                                      : Icons.star_half,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '4.5',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF444444),
                                ),
                              ),
                              const Text(
                                ' (1,234 reviews)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Divider
                          const Divider(height: 1, thickness: 1),
                          const SizedBox(height: 32),

                          // Description Section
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'About this app',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            app.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Features Section
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Key Features',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: app.features.map((feature) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),

                          // Screenshots Section (Placeholder)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Screenshots',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(4, (index) {
                                return Container(
                                  width: 200,
                                  height: 350,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFF3E0),
                                        Color(0xFFFFE0B2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppConstants.borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          app.icon,
                                          style: const TextStyle(fontSize: 48),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Screenshot',
                                          style: TextStyle(
                                            color: AppConstants.brownText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Reviews Section (Placeholder)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Reviews',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(3, (index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppConstants.lightBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppConstants.borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppConstants.primaryOrange,
                                        child: Text(
                                          'U${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'User ${index + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Great app! Really helpful and easy to use. '
                                    'Highly recommend to everyone looking for this type of service.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 32),

                          // Download/Open Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: AppConstants.buttonGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppConstants.primaryOrange.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening ${app.name}...'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Open App',
                                style: TextStyle(
                                  fontSize: 18,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toUpperCase()) {
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
}

class AppModel {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String icon;
  final String badge; // FREE, NEW, PREMIUM
  final List<String> features;

  AppModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.badge,
    required this.features,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'icon': icon,
      'badge': badge,
      'features': features,
    };
  }

  // Create from JSON
  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      badge: json['badge'] as String,
      features: List<String>.from(json['features'] as List),
    );
  }

  // Dummy data for the 6 apps
  static List<AppModel> getDummyApps() {
    return [
      AppModel(
        id: 'artlunch',
        name: 'Art Lunch',
        tagline: 'SINCE 2002',
        description:
            'Creative meal planning and recipe management application. Discover new cuisines and organize your culinary journey.',
        icon: '🍽️',
        badge: 'FREE',
        features: [
          'Recipe collections',
          'Meal planning tools',
          'Shopping lists',
          'Nutrition tracking',
        ],
      ),
      AppModel(
        id: 'portal',
        name: 'Smart Portal',
        tagline: 'MODERN SOLUTION',
        description:
            'All-in-one platform for managing your digital life. Connect, organize, and streamline your daily tasks.',
        icon: '🌐',
        badge: 'NEW',
        features: [
          'Task management',
          'Calendar integration',
          'File storage',
          'Team collaboration',
        ],
      ),
      AppModel(
        id: 'business',
        name: 'Business Hub',
        tagline: 'PROFESSIONAL TOOLS',
        description:
            'Complete business management suite for entrepreneurs and small businesses. Manage everything in one place.',
        icon: '💼',
        badge: 'PREMIUM',
        features: [
          'Invoicing & billing',
          'Client management',
          'Analytics dashboard',
          'Payment processing',
        ],
      ),
      AppModel(
        id: 'learn',
        name: 'Learn Plus',
        tagline: 'EDUCATION CENTER',
        description:
            'Interactive learning platform with courses, tutorials, and certifications. Expand your knowledge base.',
        icon: '📚',
        badge: 'FREE',
        features: [
          'Video courses',
          'Interactive quizzes',
          'Progress tracking',
          'Certificates',
        ],
      ),
      AppModel(
        id: 'creative',
        name: 'Creative Studio',
        tagline: 'DESIGN & CREATE',
        description:
            'Professional design tools for creating stunning visuals. Perfect for designers and content creators.',
        icon: '🎨',
        badge: 'NEW',
        features: [
          'Photo editing',
          'Vector graphics',
          'Templates library',
          'Export options',
        ],
      ),
      AppModel(
        id: 'finance',
        name: 'Finance Tracker',
        tagline: 'MONEY MANAGEMENT',
        description:
            'Keep track of your expenses, income, and investments. Make smarter financial decisions with insights.',
        icon: '💰',
        badge: 'FREE',
        features: [
          'Expense tracking',
          'Budget planning',
          'Investment monitor',
          'Reports & analytics',
        ],
      ),
    ];
  }
}

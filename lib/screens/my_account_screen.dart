import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/mongodb_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _authService = AuthService.instance;
  final _mongoService = MongoDBService.instance;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getCurrentUser();
    
    // Load from MongoDB to get phone number and email
    final user = await _mongoService.findUserByUsername(userInfo['username'] ?? '');
    
    setState(() {
      _username = userInfo['username'] ?? '';
      _firstName = userInfo['firstName'] ?? '';
      _lastName = userInfo['lastName'] ?? '';
      _emailController.text = user?.email ?? '';
      _phoneController.text = user?.phone ?? '';
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Actually save to MongoDB
    final success = await _mongoService.updateUserProfile(
      _username,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'Profile updated successfully' 
              : 'Failed to update profile'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'My Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Account Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Profile Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppConstants.buttonGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Username
                            Text(
                              '@$_username',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.textOrange,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Full Name
                            Text(
                              '$_firstName $_lastName',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Edit Button
                            if (!_isEditing)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _isEditing = true);
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppConstants.primaryOrange,
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Divider
                            const Divider(),
                            const SizedBox(height: 20),

                            // User Info Section
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.textOrange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'your.email@example.com',
                              enabled: _isEditing,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Email is optional
                                }
                                if (!AppConstants.emailRegex.hasMatch(value)) {
                                  return 'Invalid email format';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone Field
                            CustomTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: '+1 (555) 123-4567',
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 30),

                            // Save Button (only visible when editing)
                            if (_isEditing) ...[
                              CustomButton(
                                text: 'Save Changes',
                                onPressed: _saveProfile,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                text: 'Cancel',
                                onPressed: () {
                                  setState(() => _isEditing = false);
                                  _loadUserInfo(); // Reload original data
                                },
                                isOutlined: true,
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Divider
                            const Divider(),
                            const SizedBox(height: 20),

                            // Actions Section
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.textOrange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Payment Button
                            ListTile(
                              leading: const Icon(
                                Icons.payment,
                                color: AppConstants.primaryOrange,
                              ),
                              title: const Text('Payment'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.pushNamed(context, '/payment');
                              },
                            ),

                            // Logout Button
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: _handleLogout,
                            ),
                          ],
                        ),
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
}

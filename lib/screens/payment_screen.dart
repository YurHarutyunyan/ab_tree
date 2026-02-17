import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/mongodb_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '100');
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  
  final _authService = AuthService.instance;
  final _paymentService = PaymentService.instance;
  final _mongoService = MongoDBService.instance;
  
  String? _selectedCountry;
  String _username = 'User';
  bool _isLoading = false;
  double _displayAmount = 100.00;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _amountController.addListener(_updateDisplayAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _updateDisplayAmount() {
    setState(() {
      _displayAmount = double.tryParse(_amountController.text) ?? 0.0;
    });
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

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userInfo = await _authService.getCurrentUser();
    final userId = userInfo['userId'] ?? '';

    final result = await _paymentService.processPayment(
      userId: userId,
      amount: _displayAmount,
      cardNumber: _cardNumberController.text,
      cardHolder: _cardHolderController.text,
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
      address: _addressController.text,
      city: _cityController.text,
      zipCode: _zipController.text,
      country: _selectedCountry ?? '',
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Set all app credits to 5 after successful payment
      final userInfo = await _authService.getCurrentUser();
      final username = userInfo['username'] ?? '';
      if (username.isNotEmpty) {
        await _mongoService.setCreditsAfterPayment(username);
      }
      
      _showSuccessDialog(
        result['transactionId'],
        result['amount'].toStringAsFixed(2),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(String transactionId, String amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment of \$$amount has been processed successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            Text(
              'Transaction ID: $transactionId',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The funds have been transferred to the recipient\'s account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: Color(0xFF689F38), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'All app credits set to 5!',
                    style: TextStyle(
                      color: Color(0xFF33691E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Done',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/apps');
              },
            ),
          ],
        ),
      ),
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
            // User Info Bar
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withOpacity(0.95),
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
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.93),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  '💳 Payment System',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: AppConstants.textOrange,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Securely transfer funds to recipient',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppConstants.brownText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Amount Display
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF81C784),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Amount to Transfer',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${_displayAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF1B5E20),
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Recipient Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFD54F),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _recipientInfoRow(
                                  'Recipient Card:',
                                  AppConstants.recipientCardNumber,
                                ),
                                const SizedBox(height: 4),
                                _recipientInfoRow(
                                  'Recipient Name:',
                                  AppConstants.recipientName,
                                ),
                                const SizedBox(height: 4),
                                _recipientInfoRow(
                                  'Purpose:',
                                  AppConstants.paymentPurpose,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Amount Input
                          const Text(
                            'Payment Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _amountController,
                            label: 'Enter Amount (\$)',
                            hint: '100.00',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Card Information
                          const Text(
                            'Card Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          CustomTextField(
                            controller: _cardNumberController,
                            label: 'Card Number',
                            hint: '1234 5678 9012 3456',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _CardNumberInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card number';
                              }
                              if (!_paymentService.validateCardNumber(value)) {
                                return 'Invalid card number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          CustomTextField(
                            controller: _cardHolderController,
                            label: 'Cardholder Name',
                            hint: 'John Doe',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter cardholder name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _expiryController,
                                  label: 'Expiry Date',
                                  hint: 'MM/YY',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                    _ExpiryDateInputFormatter(),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (!_paymentService.validateExpiryDate(value)) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _cvvController,
                                  label: 'CVV',
                                  hint: '123',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Billing Address
                          const Text(
                            'Billing Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textOrange,
                            ),
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _addressController,
                            label: 'Street Address',
                            hint: '123 Main Street',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _cityController,
                                  label: 'City',
                                  hint: 'New York',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _zipController,
                                  label: 'ZIP Code',
                                  hint: '10001',
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Country',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF444444),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  hintText: 'Select Country',
                                  filled: true,
                                  fillColor: AppConstants.cardBackground,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppConstants.borderColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: AppConstants.countries.map((country) {
                                  return DropdownMenuItem(
                                    value: country['code'],
                                    child: Text(country['name']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a country';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Payment Button
                          CustomButton(
                            text: 'Process Payment',
                            onPressed: _handlePayment,
                            isLoading: _isLoading,
                            gradient: AppConstants.greenGradient,
                          ),
                          const SizedBox(height: 12),

                          // Cancel Button
                          CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            isOutlined: true,
                          ),
                          const SizedBox(height: 16),

                          // Secure Badge
                          const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: Color(0xFF666666),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Secured with 256-bit SSL encryption',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _recipientInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFF57F17),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE65100),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// Card number formatter
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Expiry date formatter
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (text.length <= 2) {
      return newValue;
    }

    final buffer = StringBuffer();
    buffer.write(text.substring(0, 2));
    buffer.write('/');
    buffer.write(text.substring(2));

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

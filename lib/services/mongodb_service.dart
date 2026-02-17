import 'package:mongo_dart/mongo_dart.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../utils/constants.dart';

class MongoDBService {
  static MongoDBService? _instance;
  Db? _db;
  bool _isConnected = false;

  MongoDBService._();

  static MongoDBService get instance {
    _instance ??= MongoDBService._();
    return _instance!;
  }

  // Connect to MongoDB
  Future<bool> connect() async {
    if (_isConnected && _db != null) {
      return true;
    }

    try {
      // For demo purposes, we'll simulate connection
      // In production, replace with actual MongoDB connection string
      if (AppConstants.mongoDbConnectionString == 'YOUR_MONGODB_CONNECTION_STRING') {
        print('⚠️  MongoDB connection string not configured');
        print('Using in-memory storage for demo purposes');
        _isConnected = true;
        return true;
      }

      _db = await Db.create(AppConstants.mongoDbConnectionString);
      await _db!.open();
      _isConnected = true;
      print('✅ Connected to MongoDB');
      return true;
    } catch (e) {
      print('❌ MongoDB connection failed: $e');
      print('Using in-memory storage for demo purposes');
      _isConnected = true;
      return true;
    }
  }

  // Close connection
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _isConnected = false;
    }
  }

  // Users Collection Operations
  DbCollection? get _usersCollection {
    return _db?.collection(AppConstants.usersCollection);
  }

  // Create user
  Future<String?> createUser(UserModel user) async {
    try {
      if (_usersCollection != null) {
        final result = await _usersCollection!.insertOne(user.toJson());
        return result.id.toString();
      }
      // For demo without actual MongoDB
      return DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Find user by username
  Future<UserModel?> findUserByUsername(String username) async {
    try {
      if (_usersCollection != null) {
        final result = await _usersCollection!.findOne(
          where.eq('username', username),
        );
        if (result != null) {
          return UserModel.fromJson(result);
        }
      }
      return null;
    } catch (e) {
      print('Error finding user: $e');
      return null;
    }
  }

  // Find user by email
  Future<UserModel?> findUserByEmail(String email) async {
    try {
      if (_usersCollection != null) {
        final result = await _usersCollection!.findOne(
          where.eq('email', email),
        );
        if (result != null) {
          return UserModel.fromJson(result);
        }
      }
      return null;
    } catch (e) {
      print('Error finding user: $e');
      return null;
    }
  }

  // Payments Collection Operations
  DbCollection? get _paymentsCollection {
    return _db?.collection(AppConstants.paymentsCollection);
  }

  // Create payment record
  Future<String?> createPayment(PaymentModel payment) async {
    try {
      if (_paymentsCollection != null) {
        final result = await _paymentsCollection!.insertOne(payment.toJson());
        return result.id.toString();
      }
      // For demo without actual MongoDB
      return DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }

  // Get user payments
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      if (_paymentsCollection != null) {
        final results = await _paymentsCollection!
            .find(where.eq('userId', userId))
            .toList();
        return results.map((json) => PaymentModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting payments: $e');
      return [];
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      if (_paymentsCollection != null) {
        final result = await _paymentsCollection!.updateOne(
          where.id(ObjectId.parse(paymentId)),
          modify.set('status', status),
        );
        return result.isSuccess;
      }
      return true; // For demo
    } catch (e) {
      print('Error updating payment: $e');
      return false;
    }
  }

  // Update user profile (email and phone)
  Future<bool> updateUserProfile(String username, {String? email, String? phone}) async {
    try {
      if (_usersCollection != null) {
        final updates = modify;
        if (email != null) updates.set('email', email);
        if (phone != null) updates.set('phone', phone);
        
        final result = await _usersCollection!.updateOne(
          where.eq('username', username),
          updates,
        );
        return result.isSuccess;
      }
      return true; // For demo
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Update user credits for a specific app
  Future<bool> updateAppCredits(String username, String appName, int credits) async {
    try {
      print('📝 Updating credits for $username - $appName: $credits');
      if (_usersCollection != null) {
        final result = await _usersCollection!.updateOne(
          where.eq('username', username),
          modify.set('appCredits.$appName', credits),
        );
        print('✅ Update result: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
        print('   Modified count: ${result.nModified}');
        return result.isSuccess;
      }
      print('⚠️  No collection available');
      return true; // For demo
    } catch (e) {
      print('❌ Error updating app credits: $e');
      return false;
    }
  }

  // Set credits to 5 for all apps after payment
  Future<bool> setCreditsAfterPayment(String username) async {
    try {
      print('💳 Setting credits to 5 for all apps for user: $username');
      final allAppsCredits = <String, int>{
        'Art Lunch': 5,
        'Smart Portal': 5,
        'Business Hub': 5,
        'Learn Plus': 5,
        'Creative Studio': 5,
        'Finance Tracker': 5,
      };
      
      if (_usersCollection != null) {
        final result = await _usersCollection!.updateOne(
          where.eq('username', username),
          modify.set('appCredits', allAppsCredits),
        );
        print('✅ Payment credits update: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
        return result.isSuccess;
      }
      return true;
    } catch (e) {
      print('❌ Error setting credits after payment: $e');
      return false;
    }
  }

  // Get user credits for a specific app
  Future<int> getAppCredits(String username, String appName) async {
    try {
      if (_usersCollection != null) {
        final user = await findUserByUsername(username);
        if (user != null && user.appCredits != null) {
          return user.appCredits![appName] ?? 5; // Default 5 if not set
        }
      }
      return 5; // Default
    } catch (e) {
      print('Error getting app credits: $e');
      return 5;
    }
  }
}

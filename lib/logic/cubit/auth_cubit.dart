import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part './auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final supabase = Supabase.instance.client;

  AuthCubit() : super(AuthInitial()) {
    _verifyDatabaseSetup();
  }

  Future<void> _verifyDatabaseSetup() async {
    try {
      // Check tables exist by attempting to query them
      await supabase.from('users').select();
      await supabase.from('settings').select();
      await supabase.from('beverage_types').select();
      await supabase.from('intakes').select();

      // Initialize beverage types if needed
      await _initializeBeverageTypes();
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _initializeBeverageTypes() async {
    try {
      final beverages = await supabase.from('beverage_types').select('name');

      if (beverages.isEmpty) {
        final defaultBeverages = [
          {
            'name': 'Coffee (Brewed)',
            'caffeine_content_per_250ml': 95.00,
            'icon': 'coffee',
            'is_active': true
          },
          {
            'name': 'Espresso',
            'caffeine_content_per_250ml': 150.00,
            'icon': 'espresso',
            'is_active': true
          },
          {
            'name': 'Black Tea',
            'caffeine_content_per_250ml': 26.00,
            'icon': 'tea',
            'is_active': true
          },
          {
            'name': 'Green Tea',
            'caffeine_content_per_250ml': 28.00,
            'icon': 'tea',
            'is_active': true
          },
          {
            'name': 'Energy Drink',
            'caffeine_content_per_250ml': 80.00,
            'icon': 'energy_drink',
            'is_active': true
          },
          {
            'name': 'Cola',
            'caffeine_content_per_250ml': 22.00,
            'icon': 'soda',
            'is_active': true
          },
        ];

        await supabase.from('beverage_types').insert(defaultBeverages).select();
      }
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _createUserInDatabase(User user, {String? displayName}) async {
    try {
      // Check if user already exists
      final existingUsers = await supabase
          .from('users')
          .select('user_id, uid')
          .eq('uid', user.id);

      if (existingUsers.isNotEmpty) {
        // Update last login
        await supabase
            .from('users')
            .update({'last_login_at': DateTime.now().toIso8601String()}).eq(
                'uid', user.id);
        return;
      }

      // Insert new user
      final userInsertResponse = await supabase
          .from('users')
          .insert({
            'uid': user.id,
            'email': user.email,
            'display_name': displayName ?? user.email?.split('@')[0] ?? 'User',
            'created_at': DateTime.now().toIso8601String(),
            'last_login_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Create default settings for the user
      await supabase.from('settings').insert({
        'user_id': userInsertResponse['user_id'],
        'daily_limit': 400.00,
        'notifications': true,
      });
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> createAccountWithGoogleData(String email, String password,
      String? displayName, String? photoUrl) async {
    emit(AuthLoading());

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'avatar_url': photoUrl,
        },
      );

      if (response.user != null) {
        await _createUserInDatabase(response.user!, displayName: displayName);
        emit(UserSingupAndLinkedWithGoogle());
      } else {
        emit(AuthError('Failed to create account'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await supabase.auth.resetPasswordForEmail(email);
      emit(ResetPasswordSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _createUserInDatabase(response.user!);
        emit(UserSignIn());
      } else {
        emit(AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );

      if (response) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          final user = session.user;
          await _createUserInDatabase(user,
              displayName: user.userMetadata?['full_name']);
          emit(UserSignIn());
        } else {
          final user = supabase.auth.currentUser;
          if (user != null) {
            emit(IsNewUser(
              email: user.email ?? '',
              displayName: user.userMetadata?['full_name'],
              photoUrl: user.userMetadata?['avatar_url'],
            ));
          } else {
            emit(AuthError('Google Sign In Failed'));
          }
        }
      } else {
        emit(AuthError('Google Sign In Failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await supabase.auth.signOut();
    emit(UserSignedOut());
  }

  Future<void> signUpWithEmail(String email, String password,
      {String? name}) async {
    emit(AuthLoading());
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'display_name': name} : null,
      );

      if (response.user != null) {
        await _createUserInDatabase(response.user!, displayName: name);
        emit(UserSingupButNotVerified());
      } else {
        emit(AuthError('Signup failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Get current user's ID from the database
  Future<int?> _getCurrentUserId() async {
    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        return null;
      }

      final response = await supabase
          .from('users')
          .select('user_id')
          .eq('uid', currentUser.id)
          .single();

      return response['user_id'] as int;
    } catch (e) {
      return null;
    }
  }

  // Add new beverage intake
  Future<void> addBeverageIntake({
    required String beverageType,
    required double caffeineContentPer250ml,
    required int sizeInMl,
    String? warningLevel,
  }) async {
    try {
      final userId = await _getCurrentUserId();

      if (userId == null) {
        emit(AuthError('User not found'));
        return;
      }

      // Calculate total caffeine content based on size
      final caffeineContent = (caffeineContentPer250ml * sizeInMl) / 250;

      final intakeData = {
        'user_id': userId,
        'beverage_type': beverageType,
        'caffeine_content': caffeineContent,
        'size_in_ml': sizeInMl,
        'base_caffeine_content_per_250ml': caffeineContentPer250ml,
        'warning_level': warningLevel,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Insert the intake data without storing the response
      await supabase.from('intakes').insert(intakeData).select().single();

      emit(IntakeAdded());
    } catch (e) {
      emit(AuthError('Failed to add intake: ${e.toString()}'));
    }
  }

  // Load user's intakes
  Future<void> loadIntakes() async {
    try {
      final userId = await _getCurrentUserId();

      if (userId == null) {
        emit(AuthError('User not found'));
        return;
      }

      final response = await supabase
          .from('intakes')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      emit(IntakesLoaded(List<Map<String, dynamic>>.from(response)));
    } catch (e) {
      emit(AuthError('Failed to load intakes: ${e.toString()}'));
    }
  }

  // Get user's intake history
  Future<List<Map<String, dynamic>>> getIntakeHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(AuthError('User not found'));
        return [];
      }

      var query = supabase
          .from('intakes')
          .select('*, beverage_types!inner(*)')
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toUtc().toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('timestamp', endDate.toUtc().toIso8601String());
      }

      final response = await query.order('timestamp', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Get user's daily caffeine intake
  Future<double> getDailyIntake() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(AuthError('User not found'));
        return 0.0;
      }

      final today = DateTime.now().toUtc();
      final startOfDay =
          DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toIso8601String();

      final response = await supabase
          .from('intakes')
          .select('caffeine_content')
          .eq('user_id', userId)
          .gte('timestamp', startOfDay)
          .lte('timestamp', endOfDay);

      double totalCaffeine = 0.0;
      for (var intake in response) {
        totalCaffeine += (intake['caffeine_content'] as num).toDouble();
      }

      return totalCaffeine;
    } catch (e) {
      return 0.0;
    }
  }

  // Get user's daily limit
  Future<double> getDailyLimit() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return 400.0; // Default limit

      final response = await supabase
          .from('settings')
          .select('daily_limit')
          .eq('user_id', userId)
          .single();

      return (response['daily_limit'] as num).toDouble();
    } catch (e) {
      return 400.0; // Default limit
    }
  }

  // Delete an intake
  Future<void> deleteIntake(int intakeId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(AuthError('User not found'));
        return;
      }

      // First verify the intake exists and belongs to the user
      final existingIntakes = await supabase
          .from('intakes')
          .select()
          .eq('intake_id', intakeId)
          .eq('user_id', userId);

      if (existingIntakes.isEmpty) {
        emit(AuthError('Intake not found or unauthorized'));
        return;
      }

      // Perform the deletion
      await supabase
          .from('intakes')
          .delete()
          .eq('intake_id', intakeId)
          .eq('user_id', userId);

      emit(IntakeDeleted(intakeId));
    } catch (e) {
      emit(AuthError('Failed to delete intake: ${e.toString()}'));
    }
  }

  // Update user's daily limit
  Future<void> updateDailyLimit(double newLimit) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(AuthError('User not found'));
        return;
      }

      await supabase
          .from('settings')
          .update({'daily_limit': newLimit}).eq('user_id', userId);

      emit(SettingsUpdated());
    } catch (e) {
      emit(AuthError('Failed to update daily limit: ${e.toString()}'));
    }
  }

  // Get available beverage types
  Future<List<Map<String, dynamic>>> getBeverageTypes() async {
    try {
      final response = await supabase
          .from('beverage_types')
          .select()
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

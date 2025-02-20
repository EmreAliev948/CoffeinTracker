// ignore_for_file: public_member_api_docs, sort_constructors_first
part of './auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class ResetPasswordSent extends AuthState {}

class UserNotVerified extends AuthState {}

class UserSignedOut extends AuthState {}

class UserSignIn extends AuthState {}

class UserSingupButNotVerified extends AuthState {}

class IsNewUser extends AuthState {
  final String email;
  final String? displayName;
  final String? photoUrl;

  IsNewUser({
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

class UserSingupAndLinkedWithGoogle extends AuthState {}

// New states for intake tracking
class IntakeAdded extends AuthState {}

class IntakesLoaded extends AuthState {
  final List<Map<String, dynamic>> intakes;

  IntakesLoaded(this.intakes);
}

class IntakeDeleted extends AuthState {
  final int intakeId;

  IntakeDeleted(this.intakeId);
}

class SettingsUpdated extends AuthState {}

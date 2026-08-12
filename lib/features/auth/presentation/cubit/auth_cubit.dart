import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:truefit_coaches/core/error/failures.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> coach;
  AuthAuthenticated(this.coach);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  static const String _coachKey = 'persisted_coach_data';
  final SharedPreferences _prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit(this._prefs) : super(AuthInitial()) {
    _loadPersistedData();
  }

  void _loadPersistedData() {
    final String? coachJson = _prefs.getString(_coachKey);
    if (coachJson != null) {
      try {
        final Map<String, dynamic> coach = jsonDecode(coachJson);
        emit(AuthAuthenticated(coach));
        _syncProfile(coach['uid']);
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _syncProfile(String uid) async {
    try {
      final doc = await _firestore.collection('Gym_Coaches').doc(uid).get();
      if (doc.exists) {
        final coach = doc.data()!;
        coach['uid'] = uid;
        await authenticate(coach);
      }
    } catch (_) {}
  }

  Future<Either<Failure, Unit>> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      final user = credential.user;
      if (user == null) {
        emit(AuthError("Authentication failed: User is null"));
        return const Left(AuthFailure("Authentication failed"));
      }

      // Try to get Firestore profile from Gym_Coaches collection
      final doc = await _firestore.collection('Gym_Coaches').doc(user.uid).get();
      
      Map<String, dynamic> coachData;
      if (doc.exists) {
        coachData = doc.data()!;
        coachData['uid'] = user.uid;
      } else {
        // Fallback: Use Firebase User data if Firestore doc isn't seeded yet
        coachData = {
          'uid': user.uid,
          'email': user.email,
          'name': user.email?.split('@')[0].toUpperCase() ?? 'COACH',
          'is_temp_profile': true,
          'role': 'coach', // Default role if not found
        };
      }
      
      await authenticate(coachData);
      return const Right(unit);
      
    } on FirebaseAuthException catch (e) {
      final message = _getFriendlyErrorMessage(e.code);
      emit(AuthError(message));
      return Left(AuthFailure(message));
    } catch (e) {
      emit(AuthError("Connection error. Please check your internet."));
      return const Left(AuthFailure("Unexpected error"));
    }
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'No coach account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'invalid-email': return 'The email address is not valid.';
      case 'user-disabled': return 'This account has been disabled.';
      default: return 'Login failed. Please try again.';
    }
  }

  Future<void> authenticate(Map<String, dynamic> coach) async {
    await _prefs.setString(_coachKey, jsonEncode(coach));
    emit(AuthAuthenticated(coach));
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _prefs.remove(_coachKey);
    emit(AuthUnauthenticated());
  }
}

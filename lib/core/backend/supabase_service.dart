import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();

  late final SupabaseClient client;
  final authState = Rxn<AuthState>();

  Future<SupabaseService> init() async {
    await _initSupabase();
    return this;
  }

  Future<void> _initSupabase() async {
    await Supabase.initialize(
      url: AppConfig.current.supabaseUrl,
      anonKey: AppConfig.current.supabaseAnonKey,
    );
    client = Supabase.instance.client;

    // Listen to Auth State Changes
    client.auth.onAuthStateChange.listen((data) {
      authState.value = data;
    });
  }

  Future<void> updateConfig() async {
    // Supabase.initialize cannot be called twice on the same instance normally
    // but we can try to re-init if we use a workaround or just warn that restart might be needed.
    // However, for this project, we'll try to just re-initialize the client if possible.
    // Actually, supabase_flutter singleton doesn't like re-init.
    // Let's use a workaround: manually create a new SupabaseClient.

    client = SupabaseClient(
      AppConfig.current.supabaseUrl,
      AppConfig.current.supabaseAnonKey,
    );

    // Re-bind listener
    client.auth.onAuthStateChange.listen((data) {
      authState.value = data;
    });

    debugPrint('Supabase switched to: ${AppConfig.current.environment}');
  }

  // --- Auth Logic ---
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInAnonymously() async {
    return await client.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}

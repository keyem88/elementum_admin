import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();

  late final SupabaseClient client;
  final authState = Rxn<AuthState>();

  Future<SupabaseService> init() async {
    await Supabase.initialize(
        url: AppConfig.current.supabaseUrl, 
        anonKey: AppConfig.current.supabaseAnonKey
    );
    client = Supabase.instance.client;

    // Listen to Auth State Changes
    client.auth.onAuthStateChange.listen((data) {
      authState.value = data;
    });

    return this;
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/backend/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Check initial session
    isAuthenticated.value =
        SupabaseService.to.client.auth.currentSession != null;

    // Listen to Auth State Changes
    SupabaseService.to.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        isAuthenticated.value = true;
      } else if (event == AuthChangeEvent.signedOut) {
        isAuthenticated.value = false;
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await SupabaseService.to.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Rolle prüfen
        final profile = await SupabaseService.to.client
            .from('profiles')
            .select('is_admin')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (profile != null && profile['is_admin'] == true) {
          isAuthenticated.value = true;
          Get.snackbar(
            'Erfolg',
            'Willkommen im Admin Board!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          // Kein Admin -> sofort wieder ausloggen!
          await logout();
          isAuthenticated.value = false;
          Get.snackbar(
            'Zugriff verweigert',
            'Du hast keine Admin-Rechte.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Login Fehler',
        'Login fehlgeschlagen. Bitte Zugangsdaten überprüfen.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    await SupabaseService.to.client.auth.signOut();
  }
}

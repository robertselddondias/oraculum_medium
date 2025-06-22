import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/models/medium_model.dart';
import 'package:oraculum_medium/services/firebase_service.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final MediumService _mediumService = Get.find<MediumService>();

  final Rx<User?> currentUser = Rx<User?>(null);
  final Rx<MediumModel?> currentMedium = Rx<MediumModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  void _initializeAuth() {
    currentUser.bindStream(_firebaseService.auth.authStateChanges());
    ever(currentUser, _handleAuthChanged);
  }

  Future<void> _handleAuthChanged(User? user) async {
    if (user != null) {
      debugPrint('=== _handleAuthChanged() ===');
      debugPrint('User ID: ${user.uid}');

      try {
        final medium = await _mediumService.getMediumProfile(user.uid);
        if (medium != null && medium.isActive) {
          currentMedium.value = medium;
          isLoggedIn.value = true;
          debugPrint('✅ Médium autenticado: ${medium.name}');
        } else {
          debugPrint('❌ Médium não encontrado ou inativo');
          await logout();
        }
      } catch (e) {
        debugPrint('❌ Erro ao carregar dados do médium: $e');
        await logout();
      }
    } else {
      currentMedium.value = null;
      isLoggedIn.value = false;
      debugPrint('👤 Usuário deslogado');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('=== login() ===');
      debugPrint('Email: $email');

      isLoading.value = true;

      final UserCredential userCredential = await _firebaseService.auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        final medium = await _mediumService.getMediumProfile(userCredential.user!.uid);

        if (medium == null) {
          await _firebaseService.auth.signOut();
          Get.snackbar('Erro', 'Conta de médium não encontrada');
          return false;
        }

        if (!medium.isActive) {
          await _firebaseService.auth.signOut();
          Get.snackbar('Conta Inativa', 'Sua conta está inativa. Entre em contato com o suporte.');
          return false;
        }

        currentMedium.value = medium;
        debugPrint('✅ Login realizado com sucesso');
        Get.offAllNamed(AppRoutes.dashboard);
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro de autenticação: ${e.code}');

      switch (e.code) {
        case 'user-not-found':
          Get.snackbar('Erro', 'Usuário não encontrado');
          break;
        case 'wrong-password':
          Get.snackbar('Erro', 'Senha incorreta');
          break;
        case 'invalid-email':
          Get.snackbar('Erro', 'Email inválido');
          break;
        case 'user-disabled':
          Get.snackbar('Conta Desabilitada', 'Esta conta foi desabilitada');
          break;
        case 'too-many-requests':
          Get.snackbar('Muitas Tentativas', 'Muitas tentativas de login. Tente novamente mais tarde.');
          break;
        default:
          Get.snackbar('Erro', 'Erro ao fazer login: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Erro inesperado no login: $e');
      Get.snackbar('Erro', 'Erro inesperado ao fazer login');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required List<String> specialties,
    required double pricePerMinute,
    String? bio,
    String? experience,
  }) async {
    try {
      debugPrint('=== register() ===');
      debugPrint('Email: $email');
      debugPrint('Name: $name');

      isLoading.value = true;

      final UserCredential userCredential = await _firebaseService.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        final mediumData = {
          'name': name,
          'email': email,
          'phone': phone,
          'specialties': specialties,
          'pricePerMinute': pricePerMinute,
          'bio': bio ?? '',
          'experience': experience ?? '',
          'isActive': false,
          'isAvailable': false,
          'isOnline': false,
          'rating': 0.0,
          'totalAppointments': 0,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        await _firebaseService.firestore
            .collection('mediums')
            .doc(userCredential.user!.uid)
            .set(mediumData);

        await _mediumService.getMediumSettings(userCredential.user!.uid);
        await _mediumService.getMediumAvailability(userCredential.user!.uid);

        debugPrint('✅ Cadastro realizado com sucesso');
        Get.snackbar(
          'Cadastro Realizado',
          'Seu cadastro foi enviado para análise. Você receberá um email quando for aprovado.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        await logout();
        Get.offAllNamed(AppRoutes.login);
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no cadastro: ${e.code}');

      switch (e.code) {
        case 'weak-password':
          Get.snackbar('Erro', 'A senha é muito fraca');
          break;
        case 'email-already-in-use':
          Get.snackbar('Erro', 'Este email já está sendo usado');
          break;
        case 'invalid-email':
          Get.snackbar('Erro', 'Email inválido');
          break;
        default:
          Get.snackbar('Erro', 'Erro ao criar conta: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Erro inesperado no cadastro: $e');
      Get.snackbar('Erro', 'Erro inesperado ao criar conta');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      debugPrint('=== resetPassword() ===');
      debugPrint('Email: $email');

      isLoading.value = true;

      await _firebaseService.auth.sendPasswordResetEmail(email: email);

      debugPrint('✅ Email de recuperação enviado');
      Get.snackbar(
        'Email Enviado',
        'Um email de recuperação foi enviado para $email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao enviar email: ${e.code}');

      switch (e.code) {
        case 'user-not-found':
          Get.snackbar('Erro', 'Usuário não encontrado');
          break;
        case 'invalid-email':
          Get.snackbar('Erro', 'Email inválido');
          break;
        default:
          Get.snackbar('Erro', 'Erro ao enviar email: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Erro inesperado: $e');
      Get.snackbar('Erro', 'Erro inesperado');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('=== logout() ===');

      if (currentUser.value != null) {
        await _mediumService.updateMediumStatus(currentUser.value!.uid, false);
      }

      await _firebaseService.auth.signOut();
      currentUser.value = null;
      currentMedium.value = null;
      isLoggedIn.value = false;

      debugPrint('✅ Logout realizado');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
      Get.snackbar('Erro', 'Erro ao fazer logout');
    }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      debugPrint('=== updatePassword() ===');

      isLoading.value = true;

      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        Get.snackbar('Erro', 'Usuário não autenticado');
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      debugPrint('✅ Senha atualizada com sucesso');
      Get.snackbar(
        'Senha Atualizada',
        'Sua senha foi atualizada com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao atualizar senha: ${e.code}');

      switch (e.code) {
        case 'wrong-password':
          Get.snackbar('Erro', 'Senha atual incorreta');
          break;
        case 'weak-password':
          Get.snackbar('Erro', 'A nova senha é muito fraca');
          break;
        default:
          Get.snackbar('Erro', 'Erro ao atualizar senha: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Erro inesperado: $e');
      Get.snackbar('Erro', 'Erro inesperado ao atualizar senha');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool get isMediumActive => currentMedium.value?.isActive ?? false;
  bool get isMediumAvailable => currentMedium.value?.isAvailable ?? false;
  String? get mediumId => currentUser.value?.uid;
  String? get mediumName => currentMedium.value?.name;
  String? get mediumEmail => currentUser.value?.email;
}

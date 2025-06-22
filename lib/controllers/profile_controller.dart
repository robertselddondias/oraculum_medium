import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';
import 'package:oraculum_medium/models/medium_model.dart';
import 'package:oraculum_medium/services/firebase_service.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _imagePicker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImage = false.obs;
  final Rx<MediumModel?> mediumProfile = Rx<MediumModel?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);

  final RxList<String> availableSpecialties = <String>[
    'Tarot',
    'Astrologia',
    'Vidência',
    'Mediunidade',
    'Leitura de Aura',
    'Numerologia',
    'Psicografia',
    'Búzios',
    'Runas',
    'Cartomancia',
    'Quiromancia',
    'Cristaloterapia',
    'Reiki',
    'Terapia de Vidas Passadas',
    'Leitura de Mãos',
  ].obs;

  String? get currentMediumId => _authController.currentUser.value?.uid;

  MediumAdminController? get _adminController {
    try {
      return Get.find<MediumAdminController>();
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== ProfileController.loadProfile() ===');
      isLoading.value = true;

      final adminController = _adminController;
      if (adminController != null && adminController.mediumProfile.value != null) {
        mediumProfile.value = adminController.mediumProfile.value;
        debugPrint('✅ Perfil carregado do MediumAdminController: ${mediumProfile.value?.name}');
      } else {
        final mediumDoc = await _firebaseService.getMediumData(currentMediumId!);
        if (mediumDoc.exists) {
          var mediumData = mediumDoc.data() as Map<String, dynamic>;

          // Tratar timestamps antes de criar o modelo
          mediumData = _sanitizeTimestamps(mediumData);

          mediumProfile.value = MediumModel.fromMap(mediumData, currentMediumId!);
          debugPrint('✅ Perfil carregado do Firebase: ${mediumProfile.value?.name}');
        } else {
          debugPrint('❌ Perfil não encontrado no Firebase');
          await _createDefaultProfile();
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil: $e');
      Get.snackbar('Erro', 'Não foi possível carregar o perfil');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _sanitizeTimestamps(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);

    // Lista de campos que podem conter timestamps
    final timestampFields = ['createdAt', 'updatedAt', 'lastSeen'];

    for (final field in timestampFields) {
      if (sanitized[field] != null) {
        final value = sanitized[field];
        if (value is String) {
          try {
            sanitized[field] = DateTime.parse(value);
          } catch (e) {
            sanitized[field] = DateTime.now();
          }
        } else if (value.runtimeType.toString().contains('Timestamp')) {
          try {
            sanitized[field] = value.toDate();
          } catch (e) {
            sanitized[field] = DateTime.now();
          }
        } else if (value is! DateTime) {
          sanitized[field] = DateTime.now();
        }
      }
    }

    return sanitized;
  }

  Future<void> _createDefaultProfile() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      final defaultProfile = {
        'name': user.displayName ?? 'Médium',
        'email': user.email ?? '',
        'imageUrl': user.photoURL,
        'bio': '',
        'specialties': <String>[],
        'pricePerMinute': 2.0,
        'rating': 0.0,
        'totalAppointments': 0,
        'totalReviews': 0,
        'isActive': true,
        'isAvailable': false,
        'phone': '',
        'experience': '',
        'languages': ['Português'],
        'certificates': <String>[],
        'socialMedia': <String, String>{},
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firebaseService.createMediumData(currentMediumId!, defaultProfile);
      mediumProfile.value = MediumModel.fromMap(defaultProfile, currentMediumId!);

      debugPrint('✅ Perfil padrão criado');
    } catch (e) {
      debugPrint('❌ Erro ao criar perfil padrão: $e');
      throw e;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? experience,
    List<String>? specialties,
    double? pricePerMinute,
    String? imageUrl,
  }) async {
    if (currentMediumId == null) return false;

    try {
      debugPrint('=== ProfileController.updateProfile() ===');
      isSaving.value = true;

      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null && name.isNotEmpty) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (bio != null) {
        updateData['bio'] = bio;
        updateData['biography'] = bio; // Para compatibilidade
        updateData['description'] = bio; // Para compatibilidade
      }
      if (experience != null) updateData['experience'] = experience;
      if (specialties != null) updateData['specialties'] = specialties;
      if (pricePerMinute != null) updateData['pricePerMinute'] = pricePerMinute;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;

      await _firebaseService.updateMediumData(currentMediumId!, updateData);

      // Atualizar o modelo local
      if (mediumProfile.value != null) {
        final currentData = mediumProfile.value!.toMap();
        currentData.addAll(updateData);

        // Garantir que updatedAt seja DateTime
        if (currentData['updatedAt'] is String) {
          currentData['updatedAt'] = DateTime.parse(currentData['updatedAt']);
        }

        final sanitizedData = _sanitizeTimestamps(currentData);
        mediumProfile.value = MediumModel.fromMap(sanitizedData, currentMediumId!);
      }

      // Sincronizar com MediumAdminController
      final adminController = _adminController;
      if (adminController != null) {
        await adminController.loadMediumProfile();
      }

      Get.snackbar(
        'Perfil Atualizado',
        'Suas informações foram atualizadas com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint('✅ Perfil atualizado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      Get.snackbar('Erro', 'Erro ao atualizar perfil: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      debugPrint('=== pickImageFromCamera() ===');

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        await _uploadProfileImage();
      }
    } catch (e) {
      debugPrint('❌ Erro ao capturar imagem: $e');
      Get.snackbar('Erro', 'Não foi possível capturar a imagem');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      debugPrint('=== pickImageFromGallery() ===');

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        await _uploadProfileImage();
      }
    } catch (e) {
      debugPrint('❌ Erro ao selecionar imagem: $e');
      Get.snackbar('Erro', 'Não foi possível selecionar a imagem');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (selectedImage.value == null || currentMediumId == null) return;

    try {
      debugPrint('=== _uploadProfileImage() ===');
      isUploadingImage.value = true;

      final fileName = 'profile_${currentMediumId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _firebaseService.storage.ref().child('medium_profiles').child(fileName);

      final uploadTask = ref.putFile(selectedImage.value!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final success = await updateProfile(imageUrl: downloadUrl);

      if (success) {
        selectedImage.value = null;
        Get.snackbar(
          'Foto Atualizada',
          'Sua foto de perfil foi atualizada com sucesso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem: $e');
      Get.snackbar('Erro', 'Erro ao fazer upload da imagem');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> removeProfileImage() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== removeProfileImage() ===');
      isUploadingImage.value = true;

      if (mediumProfile.value?.imageUrl != null && mediumProfile.value!.imageUrl!.isNotEmpty) {
        try {
          final ref = _firebaseService.storage.refFromURL(mediumProfile.value!.imageUrl!);
          await ref.delete();
          debugPrint('✅ Imagem removida do Storage');
        } catch (e) {
          debugPrint('⚠️ Erro ao remover imagem do Storage: $e');
        }
      }

      final success = await updateProfile(imageUrl: '');

      if (success) {
        Get.snackbar(
          'Foto Removida',
          'Sua foto de perfil foi removida',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao remover imagem: $e');
      Get.snackbar('Erro', 'Erro ao remover imagem');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A40),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Alterar Foto do Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    onTap: () {
                      Get.back();
                      pickImageFromCamera();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    onTap: () {
                      Get.back();
                      pickImageFromGallery();
                    },
                  ),
                ),
              ],
            ),
            if (mediumProfile.value?.imageUrl != null && mediumProfile.value!.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Get.back();
                    removeProfileImage();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remover Foto',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validateProfileData({
    required String name,
    required String bio,
    required List<String> specialties,
    required double pricePerMinute,
  }) {
    if (name.trim().isEmpty) {
      Get.snackbar('Erro', 'Nome é obrigatório');
      return false;
    }

    if (name.trim().length < 2) {
      Get.snackbar('Erro', 'Nome deve ter pelo menos 2 caracteres');
      return false;
    }

    if (bio.trim().length < 10) {
      Get.snackbar('Erro', 'Biografia deve ter pelo menos 10 caracteres');
      return false;
    }

    if (specialties.isEmpty) {
      Get.snackbar('Erro', 'Selecione pelo menos uma especialidade');
      return false;
    }

    if (pricePerMinute < 1.0 || pricePerMinute > 100.0) {
      Get.snackbar('Erro', 'Preço deve estar entre R\$ 1,00 e R\$ 100,00 por minuto');
      return false;
    }

    return true;
  }
}

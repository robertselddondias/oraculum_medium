import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/models/medium_model.dart';
import 'package:oraculum_medium/services/firebase_service.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class ProfileController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
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

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadProfile() ===');
      isLoading.value = true;

      final profile = await _mediumService.getMediumProfile(currentMediumId!);
      mediumProfile.value = profile;

      debugPrint('✅ Perfil carregado: ${profile?.name}');
    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil: $e');
      Get.snackbar('Erro', 'Não foi possível carregar o perfil');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? experience,
    List<String>? specialties,
    double? pricePerMinute,
  }) async {
    if (currentMediumId == null) return false;

    try {
      debugPrint('=== updateProfile() ===');
      isSaving.value = true;

      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (bio != null) updateData['bio'] = bio;
      if (experience != null) updateData['experience'] = experience;
      if (specialties != null) updateData['specialties'] = specialties;
      if (pricePerMinute != null) updateData['pricePerMinute'] = pricePerMinute;

      final success = await _mediumService.updateMediumProfile(currentMediumId!, updateData);

      if (success) {
        await loadProfile(); // Recarregar perfil atualizado
        Get.snackbar(
          'Perfil Atualizado',
          'Suas informações foram atualizadas com sucesso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível atualizar o perfil');
      }

      return success;
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

      // Upload da imagem
      final imageUrl = await _firebaseService.uploadProfileImage(
        currentMediumId!,
        selectedImage.value!,
      );

      // Atualizar perfil com nova URL da imagem
      final success = await _mediumService.updateMediumProfile(currentMediumId!, {
        'imageUrl': imageUrl,
      });

      if (success) {
        await loadProfile(); // Recarregar perfil
        Get.snackbar(
          'Foto Atualizada',
          'Sua foto de perfil foi atualizada com sucesso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível atualizar a foto');
      }
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem: $e');
      Get.snackbar('Erro', 'Erro ao fazer upload da imagem');
    } finally {
      isUploadingImage.value = false;
      selectedImage.value = null;
    }
  }

  Future<void> removeProfileImage() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== removeProfileImage() ===');
      isUploadingImage.value = true;

      // Deletar imagem anterior se existir
      if (mediumProfile.value?.imageUrl != null) {
        await _firebaseService.deleteImage(mediumProfile.value!.imageUrl!);
      }

      // Atualizar perfil removendo URL da imagem
      final success = await _mediumService.updateMediumProfile(currentMediumId!, {
        'imageUrl': null,
      });

      if (success) {
        await loadProfile(); // Recarregar perfil
        Get.snackbar(
          'Foto Removida',
          'Sua foto de perfil foi removida',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível remover a foto');
      }
    } catch (e) {
      debugPrint('❌ Erro ao remover imagem: $e');
      Get.snackbar('Erro', 'Erro ao remover imagem');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<bool> toggleAvailabilityStatus() async {
    if (currentMediumId == null || mediumProfile.value == null) return false;

    try {
      debugPrint('=== toggleAvailabilityStatus() ===');

      final currentStatus = mediumProfile.value!.isAvailable;
      final newStatus = !currentStatus;

      final success = await _mediumService.updateMediumProfile(currentMediumId!, {
        'isAvailable': newStatus,
      });

      if (success) {
        mediumProfile.value = mediumProfile.value!.copyWith(isAvailable: newStatus);
        Get.snackbar(
          'Status Atualizado',
          newStatus ? 'Você está disponível para consultas' : 'Você está indisponível',
          backgroundColor: newStatus ? Colors.green : Colors.orange,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao alterar status: $e');
      Get.snackbar('Erro', 'Erro ao alterar status de disponibilidade');
      return false;
    }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      debugPrint('=== updatePassword() ===');

      final success = await _authController.updatePassword(currentPassword, newPassword);
      return success;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar senha: $e');
      return false;
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      pickImageFromCamera();
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Câmera',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text(
                      'Galeria',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E78FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (mediumProfile.value?.imageUrl != null)
              OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  removeProfileImage();
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Remover Foto',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get profileCompletionPercentage {
    if (mediumProfile.value == null) return '0%';

    final profile = mediumProfile.value!;
    int completedFields = 0;
    int totalFields = 8;

    if (profile.name.isNotEmpty) completedFields++;
    if (profile.phone.isNotEmpty) completedFields++;
    if (profile.bio.isNotEmpty) completedFields++;
    if (profile.experience.isNotEmpty) completedFields++;
    if (profile.specialties.isNotEmpty) completedFields++;
    if (profile.pricePerMinute > 0) completedFields++;
    if (profile.imageUrl != null) completedFields++;
    if (profile.isActive) completedFields++;

    final percentage = (completedFields / totalFields * 100).round();
    return '$percentage%';
  }

  Color get profileCompletionColor {
    final percentage = int.tryParse(profileCompletionPercentage.replaceAll('%', '')) ?? 0;

    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  List<String> get incompleteFields {
    if (mediumProfile.value == null) return [];

    final profile = mediumProfile.value!;
    final List<String> incomplete = [];

    if (profile.name.isEmpty) incomplete.add('Nome completo');
    if (profile.phone.isEmpty) incomplete.add('Telefone');
    if (profile.bio.isEmpty) incomplete.add('Biografia');
    if (profile.experience.isEmpty) incomplete.add('Experiência profissional');
    if (profile.specialties.isEmpty) incomplete.add('Especialidades');
    if (profile.pricePerMinute <= 0) incomplete.add('Preço por minuto');
    if (profile.imageUrl == null) incomplete.add('Foto de perfil');

    return incomplete;
  }

  bool get isProfileComplete {
    return incompleteFields.isEmpty && (mediumProfile.value?.isActive ?? false);
  }

  String get statusText {
    final profile = mediumProfile.value;
    if (profile == null) return 'Carregando...';

    if (!profile.isActive) return 'Conta Inativa';
    if (profile.isOnline) return 'Online';
    if (profile.isAvailable) return 'Disponível';
    return 'Ocupado';
  }

  Color get statusColor {
    final profile = mediumProfile.value;
    if (profile == null) return Colors.grey;

    if (!profile.isActive) return Colors.red;
    if (profile.isOnline) return Colors.green;
    if (profile.isAvailable) return Colors.blue;
    return Colors.orange;
  }

  // Métodos adicionais para gestão de especialidades
  void addSpecialty(String specialty) {
    if (!availableSpecialties.contains(specialty)) {
      availableSpecialties.add(specialty);
    }
  }

  void removeSpecialty(String specialty) {
    availableSpecialties.remove(specialty);
  }

  // Método para validar dados do perfil
  Map<String, String?> validateProfileData({
    String? name,
    String? phone,
    String? bio,
    List<String>? specialties,
    double? pricePerMinute,
  }) {
    final errors = <String, String?>{};

    if (name != null && name.trim().length < 3) {
      errors['name'] = 'Nome deve ter pelo menos 3 caracteres';
    }

    if (phone != null && phone.trim().length < 10) {
      errors['phone'] = 'Telefone deve ter pelo menos 10 dígitos';
    }

    if (bio != null && bio.trim().length < 20) {
      errors['bio'] = 'Biografia deve ter pelo menos 20 caracteres';
    }

    if (specialties != null && specialties.isEmpty) {
      errors['specialties'] = 'Selecione pelo menos uma especialidade';
    }

    if (pricePerMinute != null && pricePerMinute <= 0) {
      errors['pricePerMinute'] = 'Preço deve ser maior que zero';
    }

    return errors;
  }

  // Método para obter sugestões de melhoria do perfil
  List<String> getProfileImprovementSuggestions() {
    final suggestions = <String>[];
    final profile = mediumProfile.value;

    if (profile == null) return suggestions;

    if (profile.imageUrl == null) {
      suggestions.add('Adicione uma foto de perfil profissional');
    }

    if (profile.bio.length < 100) {
      suggestions.add('Expanda sua biografia com mais detalhes sobre sua experiência');
    }

    if (profile.specialties.length < 3) {
      suggestions.add('Adicione mais especialidades para atrair mais clientes');
    }

    if (profile.experience.isEmpty) {
      suggestions.add('Adicione informações sobre sua experiência profissional');
    }

    if (profile.rating < 4.0) {
      suggestions.add('Melhore a qualidade do atendimento para aumentar sua avaliação');
    }

    return suggestions;
  }

  // Método para calcular score do perfil
  double get profileScore {
    if (mediumProfile.value == null) return 0.0;

    final profile = mediumProfile.value!;
    double score = 0.0;

    // Dados básicos (40%)
    if (profile.name.isNotEmpty) score += 10;
    if (profile.phone.isNotEmpty) score += 10;
    if (profile.bio.length >= 50) score += 10;
    if (profile.specialties.isNotEmpty) score += 10;

    // Informações profissionais (30%)
    if (profile.experience.isNotEmpty) score += 10;
    if (profile.pricePerMinute > 0) score += 10;
    if (profile.imageUrl != null) score += 10;

    // Status e atividade (30%)
    if (profile.isActive) score += 10;
    if (profile.isAvailable) score += 10;
    if (profile.totalAppointments > 0) score += 10;

    return score;
  }

  String get profileScoreText {
    final score = profileScore;
    if (score >= 90) return 'Excelente';
    if (score >= 70) return 'Bom';
    if (score >= 50) return 'Regular';
    return 'Precisa melhorar';
  }
}

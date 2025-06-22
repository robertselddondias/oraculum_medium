import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/profile_controller.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ProfileController _controller = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;
  late TextEditingController _priceController;

  List<String> _selectedSpecialties = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListener();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _experienceController = TextEditingController();
    _priceController = TextEditingController();

    _updateControllersFromProfile();
  }

  void _setupListener() {
    ever(_controller.mediumProfile, (_) {
      if (mounted) {
        _updateControllersFromProfile();
      }
    });
  }

  void _updateControllersFromProfile() {
    final profile = _controller.mediumProfile.value;
    if (profile != null) {
      _nameController.text = profile.name ?? '';
      _phoneController.text = profile.phone ?? '';
      _bioController.text = profile.bio ?? '';
      _experienceController.text = profile.experience ?? '';
      _priceController.text = profile.pricePerMinute?.toStringAsFixed(2) ?? '2.00';
      _selectedSpecialties = List<String>.from(profile.specialties ?? []);

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isLargeScreen),
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileImageSection(isLargeScreen),
                          SizedBox(height: isLargeScreen ? 32 : 24),
                          _buildBasicInfoSection(isLargeScreen),
                          SizedBox(height: isLargeScreen ? 32 : 24),
                          _buildProfessionalInfoSection(isLargeScreen),
                          SizedBox(height: isLargeScreen ? 32 : 24),
                          _buildSpecialtiesSection(isLargeScreen),
                          SizedBox(height: isLargeScreen ? 32 : 24),
                          _buildPricingSection(isLargeScreen),
                          SizedBox(height: isLargeScreen ? 40 : 32),
                          _buildSaveButton(isLargeScreen),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: isLargeScreen ? 28 : 24,
            ),
          ),
          Expanded(
            child: Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: isLargeScreen ? 48 : 40),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Text(
            'Foto do Perfil',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 20),
          Obx(() {
            final profile = _controller.mediumProfile.value;
            final isUploading = _controller.isUploadingImage.value;

            return Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: isLargeScreen ? 70 : 60,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                  backgroundImage: profile?.imageUrl != null && profile!.imageUrl!.isNotEmpty
                      ? NetworkImage(profile.imageUrl!)
                      : null,
                  child: profile?.imageUrl == null || profile!.imageUrl!.isEmpty
                      ? Icon(
                    Icons.person,
                    size: isLargeScreen ? 60 : 50,
                    color: Colors.white,
                  )
                      : null,
                ),
                if (isUploading)
                  Container(
                    width: isLargeScreen ? 140 : 120,
                    height: isLargeScreen ? 140 : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: isUploading ? null : _controller.showImagePickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: isLargeScreen ? 24 : 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildBasicInfoSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Básicas',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 20),
          _buildTextField(
            controller: _nameController,
            label: 'Nome Completo',
            hint: 'Digite seu nome completo',
            icon: Icons.person,
            isLargeScreen: isLargeScreen,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nome é obrigatório';
              }
              if (value.trim().length < 2) {
                return 'Nome deve ter pelo menos 2 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Telefone',
            hint: '(11) 99999-9999',
            icon: Icons.phone,
            isLargeScreen: isLargeScreen,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PhoneInputFormatter(),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildProfessionalInfoSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Profissionais',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 20),
          _buildTextField(
            controller: _bioController,
            label: 'Biografia',
            hint: 'Conte um pouco sobre você e sua experiência...',
            icon: Icons.description,
            isLargeScreen: isLargeScreen,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Biografia é obrigatória';
              }
              if (value.trim().length < 10) {
                return 'Biografia deve ter pelo menos 10 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildTextField(
            controller: _experienceController,
            label: 'Experiência',
            hint: 'Descreva sua experiência e formação...',
            icon: Icons.work,
            isLargeScreen: isLargeScreen,
            maxLines: 3,
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildSpecialtiesSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Especialidades',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Text(
            'Selecione suas áreas de especialidade',
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _controller.availableSpecialties.map((specialty) {
              final isSelected = _selectedSpecialties.contains(specialty);
              return FilterChip(
                label: Text(
                  specialty,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: isLargeScreen ? 14 : 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecialties.add(specialty);
                    } else {
                      _selectedSpecialties.remove(specialty);
                    }
                  });
                },
                backgroundColor: Colors.white.withOpacity(0.1),
                selectedColor: AppTheme.primaryColor,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.white30,
                ),
              );
            }).toList(),
          )),
          if (_selectedSpecialties.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecione pelo menos uma especialidade',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: isLargeScreen ? 14 : 12,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildPricingSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preços',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 24 : 20),
          _buildTextField(
            controller: _priceController,
            label: 'Preço por Minuto (R\$)',
            hint: '2.00',
            icon: Icons.attach_money,
            isLargeScreen: isLargeScreen,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Preço é obrigatório';
              }
              final price = double.tryParse(value);
              if (price == null) {
                return 'Digite um preço válido';
              }
              if (price < 1.0 || price > 100.0) {
                return 'Preço deve estar entre R\$ 1,00 e R\$ 100,00';
              }
              return null;
            },
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade300,
                  size: isLargeScreen ? 24 : 20,
                ),
                SizedBox(width: isLargeScreen ? 12 : 8),
                Expanded(
                  child: Text(
                    'Defina um preço competitivo. Você pode alterá-lo a qualquer momento.',
                    style: TextStyle(
                      color: Colors.blue.shade200,
                      fontSize: isLargeScreen ? 14 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isLargeScreen,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        color: Colors.white,
        fontSize: isLargeScreen ? 16 : 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: isLargeScreen ? 24 : 20,
        ),
        labelStyle: TextStyle(
          color: Colors.white70,
          fontSize: isLargeScreen ? 16 : 14,
        ),
        hintStyle: TextStyle(
          color: Colors.white38,
          fontSize: isLargeScreen ? 16 : 14,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade400,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 2,
          ),
        ),
        errorStyle: TextStyle(
          color: Colors.red.shade300,
          fontSize: isLargeScreen ? 14 : 12,
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLargeScreen) {
    return SizedBox(
      width: double.infinity,
      height: isLargeScreen ? 64 : 56,
      child: Obx(() {
        return ElevatedButton(
          onPressed: _controller.isSaving.value ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
          child: _controller.isSaving.value
              ? SizedBox(
            width: isLargeScreen ? 28 : 24,
            height: isLargeScreen ? 28 : 24,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            'Salvar Alterações',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 700),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSpecialties.isEmpty) {
      Get.snackbar(
        'Erro',
        'Selecione pelo menos uma especialidade',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();
    final experience = _experienceController.text.trim();
    final priceText = _priceController.text.trim();

    final price = double.tryParse(priceText);
    if (price == null) {
      Get.snackbar(
        'Erro',
        'Digite um preço válido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_controller.validateProfileData(
      name: name,
      bio: bio,
      specialties: _selectedSpecialties,
      pricePerMinute: price,
    )) {
      return;
    }

    final success = await _controller.updateProfile(
      name: name,
      phone: phone.isEmpty ? null : phone,
      bio: bio,
      experience: experience.isEmpty ? null : experience,
      specialties: _selectedSpecialties,
      pricePerMinute: price,
    );

    if (success) {
      Get.back();
    }
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length <= 2) {
      return TextEditingValue(
        text: '($text',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else if (text.length <= 7) {
      return TextEditingValue(
        text: '(${text.substring(0, 2)}) ${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 4),
      );
    } else if (text.length <= 11) {
      return TextEditingValue(
        text: '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}',
        selection: TextSelection.collapsed(offset: text.length + 5),
      );
    }

    return TextEditingValue(
      text: '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}',
      selection: TextSelection.collapsed(offset: 15),
    );
  }
}

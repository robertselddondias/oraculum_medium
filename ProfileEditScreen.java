import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/profile_controller.dart';
import 'package:oraculum_medium/models/medium_model.dart';
import 'package:oraculum_medium/widgets/buttons/custom_elevated_button.dart';
import 'package:oraculum_medium/widgets/loading_overlay.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

    @override
    State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
    final ProfileController _controller = Get.find<ProfileController>();
    final _formKey = GlobalKey<FormState>();

    late TextEditingController _nameController;
    late TextEditingController _emailController;
    late TextEditingController _phoneController;
    late TextEditingController _bioController;
    late TextEditingController _experienceController;

    Set<String> _selectedSpecialties = {};
    File? _selectedImage;
    bool _isLoading = false;

    final List<String> _availableSpecialties = [
            'Tarô',
            'Astrologia',
            'Numerologia',
            'Runas',
            'Cartomancia',
            'Quiromancia',
            'Búzios',
            'Cristais',
            'Reiki',
            'Espiritualidade',
            ];

    @override
    void initState() {
        super.initState();
        _initializeControllers();
    }

    void _initializeControllers() {
        final medium = _controller.medium.value;
        _nameController = TextEditingController(text: medium?.name ?? '');
        _emailController = TextEditingController(text: medium?.email ?? '');
        _phoneController = TextEditingController(text: medium?.phone ?? '');
        _bioController = TextEditingController(text: medium?.bio ?? '');
        _experienceController = TextEditingController(text: medium?.experience ?? '');
        _selectedSpecialties = Set.from(medium?.specialties ?? []);
    }

    @override
    void dispose() {
        _nameController.dispose();
        _emailController.dispose();
        _phoneController.dispose();
        _bioController.dispose();
        _experienceController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final size = MediaQuery.of(context).size;
        final isLargeScreen = size.width > 400;

        return LoadingOverlay(
                isLoading: _isLoading,
                child: Scaffold(
                backgroundColor: AppTheme.backgroundColor,
                appBar: _buildAppBar(isLargeScreen),
                body: SingleChildScrollView(
                padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                child: Form(
                key: _formKey,
                child: Column(
                children: [
        _buildProfileImageSection(isLargeScreen),
                SizedBox(height: isLargeScreen ? 32 : 24),
        _buildPersonalInfoSection(isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 20),
        _buildProfessionalInfoSection(isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 20),
        _buildSpecialtiesSection(isLargeScreen),
                SizedBox(height: isLargeScreen ? 40 : 32),
        _buildSaveButton(isLargeScreen),
                SizedBox(height: isLargeScreen ? 20 : 16),
              ],
            ),
          ),
        ),
      ),
    );
    }

    PreferredSizeWidget _buildAppBar(bool isLargeScreen) {
        return AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                'Editar Perfil',
                style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 22 : 20,
                fontWeight: FontWeight.bold,
        ),
      ),
        centerTitle: true,
                leading: IconButton(
                onPressed: () => Get.back(),
                icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
            ),
          ),
        child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
    }

    Widget _buildProfileImageSection(bool isLargeScreen) {
        return Container(
                padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
        Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
        ),
        boxShadow: [
        BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
          ),
        ],
      ),
        child: Column(
                children: [
        Stack(
                alignment: Alignment.center,
                children: [
        Container(
                width: isLargeScreen ? 140 : 120,
                height: isLargeScreen ? 140 : 120,
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                colors: [
        AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
        CircleAvatar(
                radius: isLargeScreen ? 60 : 50,
                backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                    : (_controller.medium.value?.profileImageUrl?.isNotEmpty == true
                ? NetworkImage(_controller.medium.value!.profileImageUrl!)
                        : null) as ImageProvider?,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: _selectedImage == null &&
                (_controller.medium.value?.profileImageUrl?.isEmpty ?? true)
                    ? Icon(
                Icons.person,
                size: isLargeScreen ? 60 : 50,
                color: AppTheme.primaryColor,
                      )
                    : null,
              ),
        Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                width: isLargeScreen ? 44 : 40,
                height: isLargeScreen ? 44 : 40,
                decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                color: Colors.white,
                width: 3,
                      ),
        boxShadow: [
        BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
                        ),
                      ],
                    ),
        child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: isLargeScreen ? 20 : 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        SizedBox(height: isLargeScreen ? 20 : 16),
        Text(
                'Toque para alterar foto',
                style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
                delay: Duration(milliseconds: 200),
        duration: Duration(milliseconds: 600),
    ).slideY(
                begin: 0.1,
                end: 0,
                duration: Duration(milliseconds: 500),
    );
    }

    Widget _buildPersonalInfoSection(bool isLargeScreen) {
        return Container(
                padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
        Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
        ),
        boxShadow: [
        BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
          ),
        ],
      ),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        Row(
                children: [
        Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                ),
        child: Icon(
                Icons.person_outline,
                color: AppTheme.primaryColor,
                size: 24,
                ),
              ),
        SizedBox(width: 16),
        Text(
                'Informações Pessoais',
                style: TextStyle(
                fontSize: isLargeScreen ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              ),
            ],
          ),
        SizedBox(height: isLargeScreen ? 28 : 24),
        _buildTextField(
                controller: _nameController,
                label: 'Nome Completo',
                hint: 'Digite seu nome completo',
                icon: Icons.account_circle_outlined,
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
                controller: _emailController,
                label: 'E-mail',
                hint: 'seu@email.com',
                icon: Icons.email_outlined,
                isLargeScreen: isLargeScreen,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
        if (value == null || value.trim().isEmpty) {
            return 'E-mail é obrigatório';
        }
        if (!GetUtils.isEmail(value.trim())) {
            return 'Digite um e-mail válido';
        }
        return null;
            },
          ),
        SizedBox(height: isLargeScreen ? 20 : 16),
        _buildTextField(
                controller: _phoneController,
                label: 'Telefone',
                hint: '(11) 99999-9999',
                icon: Icons.phone_outlined,
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
                delay: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 500),
    );
    }

    Widget _buildProfessionalInfoSection(bool isLargeScreen) {
        return Container(
                padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
        Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
        ),
        boxShadow: [
        BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
          ),
        ],
      ),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        Row(
                children: [
        Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
                ),
        child: Icon(
                Icons.work_outline,
                color: Colors.purple,
                size: 24,
                ),
              ),
        SizedBox(width: 16),
        Text(
                'Informações Profissionais',
                style: TextStyle(
                fontSize: isLargeScreen ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              ),
            ],
          ),
        SizedBox(height: isLargeScreen ? 28 : 24),
        _buildTextField(
                controller: _bioController,
                label: 'Biografia',
                hint: 'Conte um pouco sobre você e sua experiência...',
                icon: Icons.description_outlined,
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
                icon: Icons.star_outline,
                isLargeScreen: isLargeScreen,
                maxLines: 3,
          ),
        ],
      ),
    ).animate().fadeIn(
                delay: Duration(milliseconds: 400),
        duration: Duration(milliseconds: 500),
    );
    }

    Widget _buildSpecialtiesSection(bool isLargeScreen) {
        return Container(
                padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
        Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
        ),
        boxShadow: [
        BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
          ),
        ],
      ),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        Row(
                children: [
        Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
                ),
        child: Icon(
                Icons.auto_awesome,
                color: Colors.orange,
                size: 24,
                ),
              ),
        SizedBox(width: 16),
        Text(
                'Especialidades',
                style: TextStyle(
                fontSize: isLargeScreen ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              ),
            ],
          ),
        SizedBox(height: isLargeScreen ? 20 : 16),
        Text(
                'Selecione suas áreas de especialidade',
                style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                color: Colors.white.withOpacity(0.7),
            ),
          ),
        SizedBox(height: isLargeScreen ? 24 : 20),
        Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableSpecialties.map((specialty) {
        final isSelected = _selectedSpecialties.contains(specialty);
        return GestureDetector(
                onTap: () {
            setState(() {
                if (isSelected) {
                    _selectedSpecialties.remove(specialty);
                } else {
                    _selectedSpecialties.add(specialty);
                }
            });
        },
        child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 20 : 16,
                vertical: isLargeScreen ? 12 : 10,
                  ),
        decoration: BoxDecoration(
                color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.8)
                : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withOpacity(0.3),
                width: 1.5,
                    ),
        boxShadow: isSelected
                ? [
        BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
        child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
        if (isSelected)
            Icon(
                    Icons.check_circle,
                    color: Colors.white,
                size: 16,
                        ),
        if (isSelected) SizedBox(width: 8),
        Text(
                specialty,
                style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 15 : 14,
                fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        if (_selectedSpecialties.isEmpty)
            Padding(
                    padding: EdgeInsets.only(top: 16),
        child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
                  ),
                ),
        child: Row(
                children: [
        Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 20,
                    ),
        SizedBox(width: 12),
        Expanded(
                child: Text(
                'Selecione pelo menos uma especialidade',
                style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(
                delay: Duration(milliseconds: 500),
        duration: Duration(milliseconds: 500),
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
        return Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
        ),
      ),
        child: TextFormField(
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
                size: isLargeScreen ? 24 : 22,
          ),
        labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isLargeScreen ? 16 : 14,
          ),
        hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isLargeScreen ? 15 : 13,
          ),
        border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isLargeScreen ? 20 : 16,
          ),
        errorStyle: TextStyle(
                color: Colors.red.shade300,
                fontSize: 12,
          ),
        ),
      ),
    );
    }

    Widget _buildSaveButton(bool isLargeScreen) {
        return Container(
                width: double.infinity,
                height: isLargeScreen ? 56 : 52,
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                colors: [
        AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
        BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: Offset(0, 8),
          ),
        ],
      ),
        child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
                ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
                ),
              )
            : Text(
                'Salvar Alterações',
                style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                ),
              ),
      ),
    ).animate().fadeIn(
                delay: Duration(milliseconds: 600),
        duration: Duration(milliseconds: 500),
    ).slideY(
                begin: 0.2,
                end: 0,
                duration: Duration(milliseconds: 500),
    );
    }

    Future<void> _pickImage() async {
        try {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
      );

            if (pickedFile != null) {
                setState(() {
                    _selectedImage = File(pickedFile.path);
                });
            }
        } catch (e) {
            Get.snackbar(
                    'Erro',
                    'Não foi possível selecionar a imagem',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
      );
        }
    }

    Future<void> _saveProfile() async {
        if (!_formKey.currentState!.validate()) {
            return;
        }

        if (_selectedSpecialties.isEmpty) {
            Get.snackbar(
                    'Atenção',
                    'Selecione pelo menos uma especialidade',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
      );
            return;
        }

        setState(() {
            _isLoading = true;
        });

        try {
            final medium = MediumModel(
                    id: _controller.medium.value?.id ?? '',
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    bio: _bioController.text.trim(),
                    experience: _experienceController.text.trim(),
                    specialties: _selectedSpecialties.toList(),
                    profileImageUrl: _controller.medium.value?.profileImageUrl ?? '',
                    isActive: _controller.medium.value?.isActive ?? true,
                    isAvailable: _controller.medium.value?.isAvailable ?? false,
                    rating: _controller.medium.value?.rating ?? 0.0,
                    totalReadings: _controller.medium.value?.totalReadings ?? 0,
                    pricePerMinute: _controller.medium.value?.pricePerMinute ?? 0.0,
                    createdAt: _controller.medium.value?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
      );

            await _controller.updateProfile(medium, _selectedImage);

            Get.back();
            Get.snackbar(
                    'Sucesso',
                    'Perfil atualizado com sucesso!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
      );
        } catch (e) {
            Get.snackbar(
                    'Erro',
                    'Erro ao atualizar perfil: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
      );
        } finally {
            setState(() {
                _isLoading = false;
            });
        }
    }
}

class _PhoneInputFormatter extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
            TextEditingValue oldValue,
            TextEditingValue newValue,
            ) {
        final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

        if (text.length <= 2) {
            return newValue.copyWith(text: text);
        } else if (text.length <= 7) {
            return newValue.copyWith(
                    text: '(${text.substring(0, 2)}) ${text.substring(2)}',
                    selection: TextSelection.collapsed(offset: text.length + 4),
      );
        } else if (text.length <= 11) {
            return newValue.copyWith(
                    text: '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}',
                    selection: TextSelection.collapsed(offset: text.length + 5),
      );
        }

        return oldValue;
    }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';

class MediumRegisterScreen extends StatefulWidget {
  const MediumRegisterScreen({super.key});

  @override
  State<MediumRegisterScreen> createState() => _MediumRegisterScreenState();
}

class _MediumRegisterScreenState extends State<MediumRegisterScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  final List<String> _availableSpecialties = [
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
  ];

  final List<String> _selectedSpecialties = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildRegisterForm(),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                const SizedBox(height: 16),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const Expanded(
          child: Column(
            children: [
              Text(
                'Cadastro de Médium',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Crie sua conta profissional',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            _buildProfessionalInfoSection(),
            const SizedBox(height: 24),
            _buildSpecialtiesSection(),
            const SizedBox(height: 24),
            _buildTermsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações Pessoais',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Nome Completo',
          hint: 'Seu nome completo',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira seu nome';
            }
            if (value.length < 3) {
              return 'Nome deve ter pelo menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'seu@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira seu email';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Por favor, insira um email válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Telefone',
          hint: '(11) 99999-9999',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira seu telefone';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _passwordController,
          label: 'Senha',
          hint: 'Sua senha',
          isVisible: _isPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira uma senha';
            }
            if (value.length < 6) {
              return 'A senha deve ter pelo menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirmar Senha',
          hint: 'Confirme sua senha',
          isVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, confirme sua senha';
            }
            if (value != _passwordController.text) {
              return 'As senhas não coincidem';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações Profissionais',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _priceController,
          label: 'Preço por Minuto (R\$)',
          hint: '5.00',
          icon: Icons.attach_money,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o preço por minuto';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Por favor, insira um preço válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: 'Biografia',
          hint: 'Conte um pouco sobre você...',
          icon: Icons.description_outlined,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, escreva uma breve biografia';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _experienceController,
          label: 'Experiência Profissional',
          hint: 'Descreva sua experiência...',
          icon: Icons.work_outline,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSpecialtiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Especialidades',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selecione suas especialidades (máximo 5)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSpecialties.map((specialty) {
            final isSelected = _selectedSpecialties.contains(specialty);
            return FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (_selectedSpecialties.length < 5) {
                      _selectedSpecialties.add(specialty);
                    } else {
                      Get.snackbar('Limite atingido', 'Você pode selecionar no máximo 5 especialidades');
                    }
                  } else {
                    _selectedSpecialties.remove(specialty);
                  }
                });
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: AppTheme.primaryColor.withOpacity(0.3),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        if (_selectedSpecialties.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Selecione pelo menos uma especialidade',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Expanded(
              child: Text(
                'Eu li e aceito os termos de uso e política de privacidade',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.white60),
          ),
          style: const TextStyle(color: Colors.white),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white60,
              ),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() {
        return ElevatedButton(
          onPressed: _authController.isLoading.value ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _authController.isLoading.value
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'Criar Conta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Já tem uma conta? ',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Faça login',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSpecialties.isEmpty) {
      Get.snackbar('Erro', 'Selecione pelo menos uma especialidade');
      return;
    }

    if (!_acceptTerms) {
      Get.snackbar('Erro', 'Você deve aceitar os termos de uso');
      return;
    }

    final success = await _authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      specialties: _selectedSpecialties,
      pricePerMinute: double.parse(_priceController.text),
      bio: _bioController.text.trim(),
      experience: _experienceController.text.trim(),
    );

    if (success) {
      // Sucesso já é tratado no controller
    }
  }
}

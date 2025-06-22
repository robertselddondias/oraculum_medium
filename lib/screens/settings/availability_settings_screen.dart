import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';

class AvailabilitySettingsScreen extends StatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  State<AvailabilitySettingsScreen> createState() => _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState extends State<AvailabilitySettingsScreen> {
  final MediumAdminController _controller = Get.find<MediumAdminController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQuickToggleSection(),
                      const SizedBox(height: 20),
                      _buildDefaultDurationSection(),
                      const SizedBox(height: 20),
                      _buildAvailableDurationsSection(),
                      const SizedBox(height: 20),
                      _buildBreakTimesSection(),
                      const SizedBox(height: 20),
                      _buildAdvancedSettingsSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Configurações de Disponibilidade',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickToggleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Geral',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponível para consultas',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ative para aceitar novos agendamentos',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final isAvailable = _controller.mediumProfile.value?.isAvailable ?? false;
                return Switch(
                  value: isAvailable,
                  onChanged: (_) => _controller.toggleAvailabilityStatus(),
                  activeColor: AppTheme.primaryColor,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDurationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duração Padrão',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Duração padrão sugerida para novas consultas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final defaultDuration = _controller.getDefaultDuration();
            return Wrap(
              spacing: 8,
              children: [15, 30, 45, 60, 90].map((duration) {
                final isSelected = defaultDuration == duration;
                return ChoiceChip(
                  label: Text('${duration}min'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _controller.updateDefaultDuration(duration);
                    }
                  },
                  backgroundColor: Colors.white.withOpacity(0.1),
                  selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAvailableDurationsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Durações Disponíveis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecione as durações que você oferece',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final availableDurations = _controller.getConsultationDurations();
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [15, 30, 45, 60, 90, 120].map((duration) {
                final isSelected = availableDurations.contains(duration);
                return FilterChip(
                  label: Text('${duration}min'),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newDurations = List<int>.from(availableDurations);
                    if (selected) {
                      newDurations.add(duration);
                    } else {
                      newDurations.remove(duration);
                    }
                    if (newDurations.isNotEmpty) {
                      _controller.updateConsultationDurations(newDurations);
                    } else {
                      Get.snackbar('Erro', 'Você deve manter pelo menos uma duração disponível');
                    }
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBreakTimesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Intervalos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSliderSetting(
            'Tempo entre consultas',
            'Intervalo mínimo entre agendamentos',
            _controller.bufferTime.toDouble(),
            5.0,
            60.0,
            'min',
                (value) => _controller.updateBufferTime(value.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações Avançadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSliderSetting(
            'Máximo de consultas por dia',
            'Limite diário de agendamentos',
            _controller.maxDailyAppointments.toDouble(),
            1.0,
            20.0,
            'consultas',
                (value) => _controller.updateMaxDailyAppointments(value.round()),
          ),
          const SizedBox(height: 20),
          _buildSwitchSetting(
            'Aceitar automaticamente',
            'Confirmar agendamentos automaticamente',
            _controller.autoAcceptAppointments.value,
                (value) => _controller.updateAutoAcceptAppointments(value),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange.shade300,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Atenção: Com aceitação automática ativa, todas as consultas serão confirmadas instantaneamente.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
      String title,
      String subtitle,
      double value,
      double min,
      double max,
      String unit,
      Function(double) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).round(),
                activeColor: AppTheme.primaryColor,
                inactiveColor: Colors.white24,
                onChanged: onChanged,
              ),
            ),
            Container(
              width: 80,
              alignment: Alignment.centerRight,
              child: Text(
                '${value.round()} $unit',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() {
        return ElevatedButton(
          onPressed: _controller.isSaving.value ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _controller.isSaving.value
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'Salvar Configurações',
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

  void _saveSettings() async {
    final success = await _controller.updateAvailability(_controller.availability);

    if (success) {
      Get.back();
    }
  }
}
